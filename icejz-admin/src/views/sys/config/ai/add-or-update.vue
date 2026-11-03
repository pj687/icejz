<template>
	<el-drawer
		v-model="visible"
		:title="!dataForm.id ? '新增模型' : '修改模型'"
		:size="760"
		class="ai-model-drawer"
		destroy-on-close
	>
		<div class="drawer-banner">
			<img class="banner-mascot" src="/mascot/xiaobing-main.png?v=6" alt="" />
			<div>
				<strong>{{ !dataForm.id ? '接入 AI 模型' : '编辑模型配置' }}</strong>
				<em>由技术人员维护；对话侧自动使用默认模型，终端用户不可见此配置</em>
			</div>
		</div>

		<el-form
			ref="dataFormRef"
			class="drawer-form"
			:model="dataForm"
			:rules="dataRules"
			label-position="top"
			@keyup.enter="submitHandle()"
		>
			<section class="form-section">
				<header class="section-title">
					<span>基础信息</span>
				</header>
				<div class="form-grid">
					<el-form-item label="显示名称" prop="name">
						<el-input v-model="dataForm.name" maxlength="64" placeholder="例如：小冰 · DeepSeek" />
					</el-form-item>
					<el-form-item label="厂商" prop="provider">
						<el-select v-model="dataForm.provider" style="width: 100%" @change="onProviderChange">
							<el-option label="OpenAI" value="openai" />
							<el-option label="DeepSeek" value="deepseek" />
							<el-option label="通义千问" value="qwen" />
							<el-option label="Ollama（本地）" value="ollama" />
							<el-option label="自定义" value="custom" />
						</el-select>
					</el-form-item>
					<el-form-item label="接入类型" prop="apiType">
						<el-radio-group v-model="dataForm.apiType" class="type-radios">
							<el-radio-button :value="1">线上</el-radio-button>
							<el-radio-button :value="0">本地</el-radio-button>
						</el-radio-group>
					</el-form-item>
					<el-form-item label="状态" prop="status">
						<el-radio-group v-model="dataForm.status" class="type-radios">
							<el-radio-button :value="1">启用</el-radio-button>
							<el-radio-button :value="0">禁用</el-radio-button>
						</el-radio-group>
					</el-form-item>
				</div>
			</section>

			<section class="form-section">
				<header class="section-title">
					<span>接口连接</span>
				</header>
				<div class="form-grid">
					<el-form-item label="Base URL" prop="baseUrl" class="span-2">
						<el-input v-model="dataForm.baseUrl" placeholder="https://api.openai.com/v1 或 http://127.0.0.1:11434/v1" />
					</el-form-item>
					<el-form-item label="API Key" prop="apiKey">
						<el-input
							v-model="dataForm.apiKey"
							type="password"
							show-password
							placeholder="DeepSeek/OpenAI/通义等必填；仅本地 Ollama 可留空"
						/>
						<div class="field-hint">云端模型缺 Key 或 Key 无效时，上游常返回 401 Authentication Fails (governor)。</div>
					</el-form-item>
					<el-form-item label="模型名称" prop="modelName">
						<el-input v-model="dataForm.modelName" placeholder="如 gpt-4o-mini / deepseek-chat / qwen2.5" />
					</el-form-item>
				</div>
			</section>

			<section class="form-section">
				<header class="section-title">
					<span>生成参数</span>
				</header>
				<div class="form-grid">
					<el-form-item label="温度" prop="temperature" class="span-2">
						<el-slider v-model="dataForm.temperature" :min="0" :max="2" :step="0.1" show-input />
					</el-form-item>
					<el-form-item label="最大 Token" prop="maxTokens">
						<el-input-number v-model="dataForm.maxTokens" :min="256" :max="128000" :step="256" style="width: 100%" />
					</el-form-item>
					<el-form-item label="排序" prop="sort">
						<el-input-number v-model="dataForm.sort" :min="0" :max="9999" style="width: 100%" />
					</el-form-item>
					<el-form-item label="系统提示词" prop="systemPrompt" class="span-2">
						<el-input
							v-model="dataForm.systemPrompt"
							type="textarea"
							:rows="5"
							placeholder="定义小冰人设。建议包含：身份、回答风格、擅长范围、不确定时如何说明。DeepSeek 等云端模型务必填写有效 API Key。"
						/>
						<div class="field-hint">提示词只影响回答风格；若出现 401 / Authentication Fails，请先检查 API Key，与提示词无关。</div>
					</el-form-item>
					<el-form-item label="设为默认模型" prop="isDefault">
						<div class="switch-row">
							<el-switch v-model="isDefaultSwitch" />
							<span>开启后，对话将优先使用该模型</span>
						</div>
					</el-form-item>
					<el-form-item label="备注" prop="remark">
						<el-input v-model="dataForm.remark" placeholder="可选备注" />
					</el-form-item>
				</div>
			</section>
		</el-form>

		<template #footer>
			<div class="drawer-footer">
				<el-button @click="visible = false">取消</el-button>
				<el-button type="primary" class="save-btn" @click="submitHandle()">保存配置</el-button>
			</div>
		</template>
	</el-drawer>
</template>

<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus/es'
import { useAiModelApi, useAiModelSubmitApi } from '@/api/sys/ai'

const emit = defineEmits(['refreshDataList'])
const visible = ref(false)
const dataFormRef = ref()

const dataForm = reactive({
	id: '',
	name: '',
	provider: 'openai',
	apiType: 1,
	baseUrl: 'https://api.openai.com/v1',
	apiKey: '',
	modelName: '',
	temperature: 0.7,
	maxTokens: 2048,
	systemPrompt:
		'你是 ICEJZ 管理后台助手「小冰」。回答友好简洁、可执行；熟悉系统配置、权限、短信邮件与 AI 模型接入；不确定时如实说明，勿编造菜单或密钥。',
	isDefault: 0,
	sort: 0,
	status: 1,
	remark: ''
})

const isDefaultSwitch = computed({
	get: () => dataForm.isDefault === 1,
	set: (val: boolean) => {
		dataForm.isDefault = val ? 1 : 0
	}
})

const providerPresets: Record<string, { apiType: number; baseUrl: string; modelName: string }> = {
	openai: { apiType: 1, baseUrl: 'https://api.openai.com/v1', modelName: 'gpt-4o-mini' },
	deepseek: { apiType: 1, baseUrl: 'https://api.deepseek.com/v1', modelName: 'deepseek-chat' },
	qwen: { apiType: 1, baseUrl: 'https://dashscope.aliyuncs.com/compatible-mode/v1', modelName: 'qwen-plus' },
	ollama: { apiType: 0, baseUrl: 'http://127.0.0.1:11434/v1', modelName: 'qwen2.5' },
	custom: { apiType: 1, baseUrl: '', modelName: '' }
}

const onProviderChange = (provider: string) => {
	const preset = providerPresets[provider]
	if (!preset) return
	dataForm.apiType = preset.apiType
	dataForm.baseUrl = preset.baseUrl
	if (!dataForm.modelName || Object.values(providerPresets).some(p => p.modelName === dataForm.modelName)) {
		dataForm.modelName = preset.modelName
	}
}

const init = (id?: number) => {
	visible.value = true
	dataForm.id = ''
	Object.assign(dataForm, {
		name: '',
		provider: 'openai',
		apiType: 1,
		baseUrl: 'https://api.openai.com/v1',
		apiKey: '',
		modelName: '',
		temperature: 0.7,
		maxTokens: 2048,
		systemPrompt:
			'你是 ICEJZ 管理后台助手「小冰」。回答友好简洁、可执行；熟悉系统配置、权限、短信邮件与 AI 模型接入；不确定时如实说明，勿编造菜单或密钥。',
		isDefault: 0,
		sort: 0,
		status: 1,
		remark: ''
	})
	if (dataFormRef.value) {
		dataFormRef.value.resetFields()
	}
	if (id) {
		useAiModelApi(id).then(res => {
			Object.assign(dataForm, res.data)
			dataForm.temperature = Number(res.data.temperature ?? 0.7)
		})
	}
}

const dataRules = ref({
	name: [{ required: true, message: '必填项不能为空', trigger: 'blur' }],
	provider: [{ required: true, message: '必填项不能为空', trigger: 'change' }],
	apiType: [{ required: true, message: '必填项不能为空', trigger: 'change' }],
	baseUrl: [{ required: true, message: '必填项不能为空', trigger: 'blur' }],
	modelName: [{ required: true, message: '必填项不能为空', trigger: 'blur' }]
})

const submitHandle = () => {
	dataFormRef.value.validate((valid: boolean) => {
		if (!valid) return false
		useAiModelSubmitApi(dataForm).then(() => {
			ElMessage.success({
				message: '操作成功',
				duration: 500,
				onClose: () => {
					visible.value = false
					emit('refreshDataList')
				}
			})
		})
	})
}

defineExpose({ init })
</script>

<style scoped lang="scss">
.drawer-banner {
	display: flex;
	align-items: center;
	gap: 14px;
	margin: 0 0 18px;
	padding: 14px 16px;
	border-radius: 16px;
	background:
		radial-gradient(120% 140% at 0% 0%, rgba(0, 168, 232, 0.16), transparent 55%),
		linear-gradient(135deg, #f3faff, #eef8fc);
	border: 1px solid rgba(0, 168, 232, 0.14);

	strong {
		display: block;
		font-size: 15px;
		color: #122033;
		font-weight: 750;
	}
	em {
		display: block;
		margin-top: 4px;
		font-style: normal;
		font-size: 12px;
		line-height: 1.5;
		color: #6b7c8f;
	}
}

.banner-mascot {
	width: 56px;
	height: 56px;
	object-fit: contain;
	filter: drop-shadow(0 8px 14px rgba(5, 70, 102, 0.16));
	flex-shrink: 0;
}

.drawer-form {
	padding-bottom: 8px;
}

.form-section {
	margin-bottom: 16px;
	padding: 14px 14px 4px;
	border-radius: 16px;
	background: var(--icejz-surface-2, #fbfcfe);
	border: 1px solid var(--icejz-card-border, #e8eef5);
}

.section-title {
	display: flex;
	align-items: center;
	gap: 8px;
	margin-bottom: 10px;

	span {
		font-size: 13px;
		font-weight: 750;
		color: #0f4f6e;
		letter-spacing: 0.02em;
	}

	&::before {
		content: '';
		width: 3px;
		height: 14px;
		border-radius: 999px;
		background: linear-gradient(180deg, #00a8e8, #2bbef5);
	}
}

.form-grid {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 0 14px;
}

.span-2 {
	grid-column: 1 / -1;
}

.type-radios {
	width: 100%;

	:deep(.el-radio-button) {
		flex: 1;
	}
	:deep(.el-radio-button__inner) {
		width: 100%;
	}
}

.switch-row {
	display: flex;
	align-items: center;
	gap: 10px;
	min-height: 32px;
	color: #64748b;
	font-size: 12.5px;
}

.field-hint {
	margin-top: 6px;
	font-size: 12px;
	line-height: 1.5;
	color: #7b8b9c;
}

.drawer-footer {
	display: flex;
	justify-content: flex-end;
	gap: 10px;
}

.save-btn {
	border: none;
	background: linear-gradient(135deg, #00a8e8, #2bbef5);
}

:deep(.el-form-item__label) {
	font-weight: 650;
	color: #334155;
}

@media (max-width: 720px) {
	.form-grid {
		grid-template-columns: 1fr;
	}
}
</style>
