<template>
	<div class="org-auth-page ai-config">
		<section class="org-auth-hero">
			<div class="hero-copy">
				<span class="hero-kicker"><i class="hero-mark" aria-hidden="true"></i>系统管理</span>
				<h2>AI 助手</h2>
				<p>配置平台机器人形象、欢迎语与默认模型接入</p>
			</div>
			<div class="hero-meta">
				<span class="hero-chip"><em>{{ state.total || 0 }}</em>个模型</span>
				<span class="hero-chip">{{ robotEnabled ? '已启用' : '已停用' }}</span>
			</div>
		</section>

		<section class="robot-card">
			<div class="robot-visual">
				<IceBotMascot size="xl" pet form="fly" :bounce="true" :auto-action-ms="0" :show-name="false" />
				<div class="bot-caption">{{ robotForm.name || '小冰' }} · 点击互动</div>
			</div>
			<div class="robot-form">
				<div class="robot-title">
					<strong>IP 机器人管控</strong>
					<em>由技术人员配置：名称、欢迎语、开关与默认调用模型（终端用户对话窗不可改模型）</em>
				</div>
				<el-form label-position="top" class="robot-fields">
					<div class="grid">
						<el-form-item label="机器人名称">
							<el-input v-model="robotForm.name" maxlength="32" placeholder="例如：小冰" />
						</el-form-item>
						<el-form-item label="启用状态">
							<el-switch v-model="robotEnabled" active-text="启用" inactive-text="停用" />
						</el-form-item>
						<el-form-item label="默认模型" class="span-2">
							<el-select v-model="robotForm.defaultModelId" clearable placeholder="选择默认调用的模型" style="width: 100%">
								<el-option
									v-for="item in enabledModels"
									:key="item.id"
									:label="`${item.name}（${item.apiType === 0 ? '本地' : '线上'} · ${item.modelName}）`"
									:value="item.id"
								/>
							</el-select>
						</el-form-item>
						<el-form-item label="欢迎语" class="span-2">
							<el-input v-model="robotForm.welcome" type="textarea" :rows="3" maxlength="200" show-word-limit />
						</el-form-item>
					</div>
					<el-button type="primary" class="save-robot" @click="saveRobot">保存机器人设置</el-button>
				</el-form>
			</div>
		</section>

		<section class="model-card org-auth-card">
			<div class="model-head">
				<div>
					<strong>模型接入</strong>
					<em>技术人员在此维护线上 OpenAI 兼容接口 / 本地 Ollama；对话侧自动使用默认模型</em>
				</div>
				<div class="ops">
					<el-button icon="Plus" type="primary" @click="addOrUpdateHandle()">新增模型</el-button>
					<el-button icon="Delete" plain type="danger" @click="deleteBatchHandle()">批量删除</el-button>
				</div>
			</div>

			<el-table v-loading="state.dataListLoading" :data="state.dataList" class="layout-table" @selection-change="selectionChangeHandle">
				<el-table-column type="selection" header-align="center" align="center" width="50" />
				<el-table-column prop="name" label="名称" min-width="120">
					<template #default="{ row }">
						<span class="org-auth-name">
							<span class="avatar model">{{ (row.name || '模').slice(0, 1) }}</span>
							{{ row.name }}
						</span>
					</template>
				</el-table-column>
				<el-table-column prop="provider" label="厂商" width="110" />
				<el-table-column label="接入" width="100" align="center">
					<template #default="{ row }">
						<span class="sys-type-pill" :class="row.apiType === 0 ? 'button' : 'menu'">
							{{ row.apiType === 0 ? '本地' : '线上' }}
						</span>
					</template>
				</el-table-column>
				<el-table-column prop="modelName" label="模型" min-width="140" show-overflow-tooltip />
				<el-table-column prop="baseUrl" label="Base URL" min-width="180" show-overflow-tooltip>
					<template #default="{ row }">
						<span v-if="row.baseUrl" class="sys-route-code">{{ row.baseUrl }}</span>
						<span v-else>—</span>
					</template>
				</el-table-column>
				<el-table-column label="默认" width="90" align="center">
					<template #default="{ row }">
						<span v-if="row.isDefault === 1" class="sys-type-pill api">默认</span>
						<span v-else>—</span>
					</template>
				</el-table-column>
				<el-table-column label="状态" width="90" align="center">
					<template #default="{ row }">
						<span class="sys-type-pill" :class="row.status === 1 ? 'button' : 'open-out'">
							{{ row.status === 1 ? '启用' : '禁用' }}
						</span>
					</template>
				</el-table-column>
				<el-table-column label="操作" fixed="right" width="230" align="center">
					<template #default="scope">
						<div class="org-auth-actions">
							<el-button class="act-btn act-warn" @click="testHandle(scope.row)">测试</el-button>
							<el-button class="act-btn act-primary" :icon="Edit" @click="addOrUpdateHandle(scope.row.id)">修改</el-button>
							<el-button class="act-btn act-danger" :icon="Delete" @click="deleteBatchHandle(scope.row.id)">删除</el-button>
						</div>
					</template>
				</el-table-column>
			</el-table>

			<el-pagination
				:current-page="state.page"
				:page-sizes="state.pageSizes"
				:page-size="state.limit"
				:total="state.total"
				layout="total, sizes, prev, pager, next, jumper"
				@size-change="sizeChangeHandle"
				@current-change="currentChangeHandle"
			/>
		</section>

		<add-or-update ref="addOrUpdateRef" @refreshDataList="onModelChanged" />
	</div>
</template>

<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Delete, Edit } from '@element-plus/icons-vue'
import { useCrud } from '@/hooks'
import { IHooksOptions } from '@/hooks/interface'
import IceBotMascot from '@/components/assistant/IceBotMascot.vue'
import AddOrUpdate from './add-or-update.vue'
import { useAiModelEnabledListApi, useAiModelTestApi, useAiRobotInfoApi, useAiRobotSaveApi } from '@/api/sys/ai'

const state: IHooksOptions = reactive({
	dataListUrl: '/sys/ai/model/page',
	deleteUrl: '/sys/ai/model',
	queryForm: {}
})

const addOrUpdateRef = ref()
const enabledModels = ref<any[]>([])
const robotForm = reactive({
	name: '小冰',
	welcome: '你好，我是 ICEJZ 小冰，有什么可以帮你的？',
	enabled: 1,
	defaultModelId: null as number | null
})

const robotEnabled = computed({
	get: () => robotForm.enabled === 1,
	set: (val: boolean) => {
		robotForm.enabled = val ? 1 : 0
	}
})

const addOrUpdateHandle = (id?: number) => {
	addOrUpdateRef.value.init(id)
}

const loadRobot = async () => {
	const { data } = await useAiRobotInfoApi()
	Object.assign(robotForm, {
		name: data.name || '小冰',
		welcome: data.welcome,
		enabled: data.enabled ?? 1,
		defaultModelId: data.defaultModelId || null
	})
}

const loadEnabledModels = async () => {
	const { data } = await useAiModelEnabledListApi()
	enabledModels.value = data || []
}

const saveRobot = async () => {
	await useAiRobotSaveApi(robotForm)
	ElMessage.success('机器人设置已保存')
	await loadRobot()
	await loadEnabledModels()
	getDataList()
}

const onModelChanged = async () => {
	getDataList()
	await loadEnabledModels()
	await loadRobot()
}

const testHandle = async (row: any) => {
	try {
		await ElMessageBox.confirm(`将使用「${row.name}」发送一条测试消息，是否继续？`, '测试模型', { type: 'info' })
		const { data } = await useAiModelTestApi(row.id)
		ElMessageBox.alert(data?.content || '无返回内容', '模型回复', { confirmButtonText: '好的' })
	} catch {
		// cancel
	}
}

const { getDataList, selectionChangeHandle, sizeChangeHandle, currentChangeHandle, deleteBatchHandle } = useCrud(state)

onMounted(async () => {
	await loadRobot()
	await loadEnabledModels()
})
</script>

<style scoped lang="scss">
.ai-config {
	gap: 16px;
}

.robot-card,
.model-card {
	--ai-ink: #122033;
	--ai-muted: #7a8796;
	--ai-soft: #eef8fc;
	--ai-panel: #fff;
	--ai-line: #e7eef5;
	--ai-brand: #007eb8;
	border: 1px solid var(--ai-line);
	border-radius: 20px;
	background: color-mix(in srgb, var(--ai-panel) 94%, transparent);
	overflow: hidden;
	box-shadow: 0 10px 24px rgba(15, 23, 36, 0.035);
}

.robot-card {
	display: grid;
	grid-template-columns: 200px minmax(0, 1fr);
}

.robot-visual {
	display: grid;
	place-items: center;
	align-content: center;
	gap: 4px;
	padding: 20px 12px;
	background:
		radial-gradient(120% 100% at 50% 0%, rgba(0, 168, 232, 0.16), transparent 60%),
		linear-gradient(180deg, color-mix(in srgb, #00a8e8 8%, var(--ai-soft)), var(--ai-soft));
}

.bot-caption {
	font-size: 13px;
	font-weight: 750;
	color: var(--ai-brand);
	letter-spacing: 0.04em;
}

.robot-form {
	padding: 18px 20px 20px;
}

.robot-title {
	margin-bottom: 12px;

	strong {
		display: block;
		font-size: 16px;
		color: var(--ai-ink);
	}
	em {
		font-style: normal;
		font-size: 12.5px;
		color: var(--ai-muted);
	}
}

.grid {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 4px 14px;
}

.span-2 {
	grid-column: 1 / -1;
}

.save-robot {
	margin-top: 4px;
	border-radius: 10px;
	background: linear-gradient(135deg, #00a8e8, #2bbef5);
	border: none;
}

.model-card {
	padding: 16px 16px 8px;
}

.model-head {
	display: flex;
	justify-content: space-between;
	align-items: flex-start;
	gap: 12px;
	margin-bottom: 12px;

	strong {
		display: block;
		font-size: 15px;
		color: var(--ai-ink);
	}
	em {
		font-style: normal;
		font-size: 12.5px;
		color: var(--ai-muted);
	}
}

.ops {
	display: flex;
	gap: 8px;
	flex-shrink: 0;
}

@media (max-width: 900px) {
	.robot-card {
		grid-template-columns: 1fr;
	}
	.grid {
		grid-template-columns: 1fr;
	}
	.model-head {
		flex-direction: column;
	}
}
</style>
