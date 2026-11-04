<template>
	<div class="org-auth-page login-security">
		<section class="org-auth-hero">
			<div class="hero-copy">
				<span class="hero-kicker"><i class="hero-mark" aria-hidden="true"></i>系统管理</span>
				<h2>登录安全</h2>
				<p>系统总开关优先：关闭后全员强制单设备互踢，个人与用户管理均不可再开启；开启后用户可在「个人中心 → 登录设备」覆盖为关/开。</p>
			</div>
			<div class="hero-meta">
				<span class="hero-chip" :class="{ on: form.multiDeviceLogin }">
					{{ form.multiDeviceLogin ? '多设备 · 开' : '单设备互踢' }}
				</span>
				<span class="hero-chip">上限 {{ form.multiDeviceMax || 5 }}</span>
			</div>
		</section>

		<el-card class="org-auth-card page-card" shadow="never" v-loading="loading">
			<el-form label-position="top" class="security-form">
				<section class="block">
					<div class="block-head">
						<strong>多设备登录（系统总开关）</strong>
						<em>关闭即全员强制单设备；开启后未单独配置的用户跟随多设备，个人仍可主动关掉。</em>
					</div>
					<div class="switch-panel" :class="{ on: form.multiDeviceLogin }">
						<div class="switch-copy">
							<span class="switch-title">允许多设备同时登录</span>
							<span class="switch-desc">
								{{
									form.multiDeviceLogin
										? '已开启：允许多端在线；个人可覆盖关闭。超过上限将踢掉最早会话。'
										: '已关闭：全员强制单设备互踢，个人与用户管理均无法开启多设备。'
								}}
							</span>
						</div>
						<el-switch v-model="form.multiDeviceLogin" active-text="开启" inactive-text="关闭" />
					</div>
				</section>

				<section class="block" :class="{ dimmed: !form.multiDeviceLogin }">
					<div class="block-head">
						<strong>同时在线上限</strong>
						<em>仅在开启多设备时生效。超出后按登录时间踢最早会话（Redis + 数据库令牌一并失效）。</em>
					</div>
					<el-form-item label="最多同时在线设备数">
						<el-input-number v-model="form.multiDeviceMax" :min="1" :max="50" :disabled="!form.multiDeviceLogin" />
					</el-form-item>
					<p class="field-help">建议 3～10。过大可能增加被盗用后的风险面。</p>
				</section>

				<div class="actions">
					<el-button type="primary" :loading="saving" @click="onSave">保存配置</el-button>
					<el-button :disabled="loading || saving" @click="loadConfig">重新加载</el-button>
				</div>
			</el-form>
		</el-card>
	</div>
</template>

<script setup lang="ts" name="SysLoginSecurityConfig">
import { onMounted, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { useLoginSecurityConfigApi, useLoginSecurityConfigSaveApi } from '@/api/sys/login-security'

const loading = ref(false)
const saving = ref(false)
const form = reactive({
	multiDeviceLogin: false,
	multiDeviceMax: 5
})

const loadConfig = async () => {
	loading.value = true
	try {
		const { data } = await useLoginSecurityConfigApi()
		form.multiDeviceLogin = !!data?.multiDeviceLogin
		form.multiDeviceMax = data?.multiDeviceMax ?? 5
	} catch {
		ElMessage.error('加载登录安全配置失败')
	} finally {
		loading.value = false
	}
}

const onSave = async () => {
	saving.value = true
	try {
		await useLoginSecurityConfigSaveApi({
			multiDeviceLogin: form.multiDeviceLogin,
			multiDeviceMax: form.multiDeviceMax
		})
		ElMessage.success('保存成功')
		await loadConfig()
	} catch {
		ElMessage.error('保存失败')
	} finally {
		saving.value = false
	}
}

onMounted(loadConfig)
</script>

<style scoped lang="scss">
.login-security {
	.security-form {
		display: flex;
		flex-direction: column;
		gap: 22px;
	}

	.block {
		padding: 4px 2px 8px;
		border-bottom: 1px dashed #e8eef5;

		&.dimmed {
			opacity: 0.55;
		}
	}

	.block-head {
		margin-bottom: 14px;

		strong {
			display: block;
			font-size: 15px;
			color: #122033;
		}

		em {
			display: block;
			margin-top: 4px;
			font-style: normal;
			font-size: 12.5px;
			line-height: 1.55;
			color: #64748b;
		}
	}

	.switch-panel {
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: 16px;
		padding: 16px 18px;
		border-radius: 14px;
		border: 1px solid #e8eef5;
		background: var(--icejz-card-bg, #f7fbfe);
		transition: border-color 0.2s ease, background 0.2s ease;

		&.on {
			border-color: rgba(0, 168, 232, 0.28);
			background: linear-gradient(135deg, rgba(0, 168, 232, 0.08), var(--icejz-card-bg, #f7fbfe));
		}
	}

	.switch-copy {
		display: grid;
		gap: 4px;
		min-width: 0;
	}

	.switch-title {
		font-size: 14px;
		font-weight: 700;
		color: #122033;
	}

	.switch-desc {
		font-size: 12.5px;
		line-height: 1.55;
		color: #64748b;
	}

	.field-help {
		margin: -4px 0 0;
		font-size: 12px;
		line-height: 1.55;
		color: #7b8b9c;
	}

	.actions {
		display: flex;
		gap: 10px;
		padding-top: 4px;
	}

	.hero-chip.on {
		color: #007eb8;
		background: rgba(0, 168, 232, 0.12);
	}
}
</style>
