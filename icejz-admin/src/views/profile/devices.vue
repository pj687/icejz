<template>
	<div class="devices-page" v-loading="loading">
		<section class="pref-card" v-loading="prefLoading">
			<header class="pref-head">
				<div class="pref-head-copy">
					<span class="pref-kicker">个人偏好</span>
					<strong>多设备登录</strong>
					<em>{{ systemOn ? '系统已开启多设备；你可覆盖为关/开，保存后对新登录立即生效' : '系统已关闭多设备：全员强制单设备，个人无法开启' }}</em>
				</div>
				<span class="pref-chip" :data-on="effectiveOn ? '1' : '0'">
					当前生效：{{ effectiveOn ? `多设备 · 上限 ${effectiveMax}` : '单设备互踢' }}
				</span>
			</header>

			<div v-if="!systemOn" class="lock-tip">系统总开关已关闭，无法选择「允许多设备」。</div>

			<div class="mode-grid" role="radiogroup" aria-label="多设备策略">
				<button
					v-for="opt in modeOptions"
					:key="opt.value"
					type="button"
					class="mode-card"
					:class="[opt.value, { active: prefMode === opt.value, locked: opt.value === 'on' && !systemOn }]"
					role="radio"
					:aria-checked="prefMode === opt.value"
					:disabled="opt.value === 'on' && !systemOn"
					@click="selectMode(opt.value)"
				>
					<span class="mode-badge">{{ opt.badge }}</span>
					<strong>{{ opt.title }}</strong>
					<p>{{ opt.desc }}</p>
					<em v-if="opt.value === 'sys'">系统：{{ systemOn ? `多设备 ≤ ${systemMax}` : '单设备互踢（强制）' }}</em>
					<em v-else-if="opt.value === 'on'">{{ systemOn ? `上限可在 1～${systemMax} 内调整` : '系统关闭时不可选' }}</em>
					<em v-else>{{ systemOn ? '个人强制单设备' : '与系统关闭效果一致' }}</em>
					<i class="mode-check" aria-hidden="true"></i>
				</button>
			</div>

			<div class="limit-panel" :class="{ dimmed: prefMode !== 'on' }">
				<div class="limit-copy">
					<strong>设备上限</strong>
					<span>仅「允许多设备」时生效，且不得超过系统上限 {{ systemMax }}</span>
				</div>
				<div class="limit-ctrl">
					<el-input-number
						v-model="prefMax"
						:min="1"
						:max="systemMax"
						:disabled="prefMode !== 'on'"
						controls-position="right"
					/>
					<span class="limit-sys">系统上限 {{ systemMax }}</span>
				</div>
			</div>

			<div class="pref-actions">
				<el-button type="primary" class="save-btn" :loading="prefSaving" @click="savePref">保存设置</el-button>
				<el-button :disabled="prefLoading || prefSaving" @click="loadPref">重新加载</el-button>
			</div>
		</section>

		<section class="session-card">
			<header class="session-head">
				<div>
					<strong>在线会话</strong>
					<em>可下线其它设备；本机请使用右上角退出登录</em>
				</div>
				<el-button :disabled="loading" @click="loadList">刷新</el-button>
			</header>

			<div v-if="!list.length && !loading" class="empty">暂无其它在线设备</div>

			<ul v-else class="device-list">
				<li v-for="item in list" :key="item.accessToken" class="device-item" :class="{ current: item.current }">
					<div class="device-icon" aria-hidden="true">
						<span>{{ clientShort(item.clientType) }}</span>
					</div>
					<div class="device-main">
						<div class="device-title">
							<strong>{{ clientLabel(item.clientType) }}</strong>
							<span v-if="item.current" class="badge">本机</span>
						</div>
						<p class="device-meta">
							<span>IP {{ item.loginIp || '—' }}</span>
							<span>{{ formatTime(item.loginTime) }}</span>
						</p>
						<p class="device-ua" :title="item.userAgent">{{ shortUa(item.userAgent) }}</p>
					</div>
					<div class="device-actions">
						<el-button
							v-if="!item.current"
							type="danger"
							plain
							size="small"
							:loading="kicking === item.accessToken"
							@click="kick(item.accessToken)"
						>
							下线
						</el-button>
						<span v-else class="current-tip">当前设备</span>
					</div>
				</li>
			</ul>
		</section>
	</div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
	useMyLoginSecurityApi,
	useMyLoginSecuritySaveApi,
	useUserDeviceKickApi,
	useUserDeviceListApi
} from '@/api/sys/device'

type DeviceItem = {
	accessToken: string
	loginIp?: string
	userAgent?: string
	clientType?: string
	loginTime?: string
	current?: boolean
}

type PrefMode = 'sys' | 'on' | 'off'

const loading = ref(false)
const kicking = ref('')
const list = ref<DeviceItem[]>([])

const prefLoading = ref(false)
const prefSaving = ref(false)
const prefMode = ref<PrefMode>('sys')
const prefMax = ref(5)
const systemOn = ref(false)
const systemMax = ref(5)
const effectiveOn = ref(false)
const effectiveMax = ref(5)

const modeOptions: Array<{ value: PrefMode; badge: string; title: string; desc: string }> = [
	{
		value: 'sys',
		badge: '默认',
		title: '跟随系统',
		desc: '完全按管理员「登录安全」配置执行'
	},
	{
		value: 'on',
		badge: '多端',
		title: '允许多设备',
		desc: '同一账号可在多端同时在线'
	},
	{
		value: 'off',
		badge: '互踢',
		title: '仅单设备',
		desc: '新登录会使其它设备立即下线'
	}
]

const selectMode = (value: PrefMode) => {
	if (value === 'on' && !systemOn.value) {
		ElMessage.warning('系统已关闭多设备登录，个人不可开启')
		return
	}
	prefMode.value = value
}

const clientLabel = (type?: string) => {
	const map: Record<string, string> = { pc: 'PC 浏览器', app: '移动 App', mp: '小程序' }
	return map[type || ''] || type || '未知设备'
}

const clientShort = (type?: string) => {
	const map: Record<string, string> = { pc: 'PC', app: 'App', mp: '小程' }
	return map[type || ''] || '?'
}

const shortUa = (ua?: string) => {
	if (!ua) {
		return '—'
	}
	if (ua.length <= 90) {
		return ua
	}
	return ua.slice(0, 90) + '…'
}

const formatTime = (t?: string) => {
	if (!t) {
		return '—'
	}
	return String(t).replace('T', ' ').replace(/\.\d+$/, '').slice(0, 19)
}

const loadList = async () => {
	loading.value = true
	try {
		const { data } = await useUserDeviceListApi()
		list.value = Array.isArray(data) ? data : []
	} catch {
		ElMessage.error('加载登录设备失败')
	} finally {
		loading.value = false
	}
}

const loadPref = async () => {
	prefLoading.value = true
	try {
		const { data } = await useMyLoginSecurityApi()
		systemOn.value = !!data?.systemMultiDeviceLogin
		systemMax.value = Math.max(1, data?.systemMultiDeviceMax ?? 5)
		effectiveOn.value = !!data?.effectiveMultiDeviceLogin
		effectiveMax.value = Math.min(data?.effectiveMultiDeviceMax ?? systemMax.value, systemMax.value)
		const clampMax = (n?: number | null) => Math.max(1, Math.min(n ?? systemMax.value, systemMax.value))
		if (data?.multiDeviceLogin === 1) {
			prefMode.value = systemOn.value ? 'on' : 'sys'
			prefMax.value = clampMax(data?.multiDeviceMax)
		} else if (data?.multiDeviceLogin === 0) {
			prefMode.value = 'off'
			prefMax.value = systemMax.value
		} else {
			prefMode.value = 'sys'
			prefMax.value = systemMax.value
		}
	} catch {
		ElMessage.error('加载多设备设置失败')
	} finally {
		prefLoading.value = false
	}
}

const savePref = async () => {
	if (prefMode.value === 'on' && !systemOn.value) {
		ElMessage.warning('系统已关闭多设备登录，个人不可开启')
		return
	}
	prefSaving.value = true
	try {
		const multiDeviceLogin = prefMode.value === 'sys' ? null : prefMode.value === 'on' ? 1 : 0
		const multiDeviceMax =
			prefMode.value === 'on' ? Math.max(1, Math.min(prefMax.value || systemMax.value, systemMax.value)) : null
		await useMyLoginSecuritySaveApi({ multiDeviceLogin, multiDeviceMax })
		ElMessage.success('已保存，对新登录立即生效')
		await loadPref()
	} catch {
		ElMessage.error('保存失败')
	} finally {
		prefSaving.value = false
	}
}

const kick = (accessToken: string) => {
	ElMessageBox.confirm('确定下线该设备？对方需重新登录。', '下线设备', {
		confirmButtonText: '确定',
		cancelButtonText: '取消',
		type: 'warning'
	})
		.then(async () => {
			kicking.value = accessToken
			try {
				await useUserDeviceKickApi(accessToken)
				ElMessage.success('已下线')
				await loadList()
			} catch {
				ElMessage.error('下线失败')
			} finally {
				kicking.value = ''
			}
		})
		.catch(() => {})
}

onMounted(() => {
	loadPref()
	loadList()
})
</script>

<style scoped lang="scss">
.devices-page {
	display: flex;
	flex-direction: column;
	gap: 16px;
}

.pref-card,
.session-card {
	padding: 16px 18px 18px;
	border-radius: 16px;
	border: 1px solid var(--icejz-card-border, #e8eef5);
	background: var(--icejz-card-bg, #fff);
	box-shadow: 0 8px 20px rgba(15, 23, 36, 0.03);
}

.pref-card {
	background:
		radial-gradient(120% 140% at 0% 0%, rgba(0, 168, 232, 0.07), transparent 52%),
		linear-gradient(180deg, #fbfdff, #fff);
}

.pref-head {
	display: flex;
	align-items: flex-start;
	justify-content: space-between;
	gap: 12px;
	margin-bottom: 14px;
}

.pref-head-copy {
	min-width: 0;

	.pref-kicker {
		display: inline-flex;
		margin-bottom: 6px;
		padding: 2px 8px;
		border-radius: 999px;
		font-size: 11px;
		font-weight: 700;
		color: #007eb8;
		background: rgba(0, 168, 232, 0.1);
	}

	strong {
		display: block;
		font-size: 16px;
		font-weight: 740;
		color: #122033;
	}

	em {
		display: block;
		margin-top: 4px;
		font-style: normal;
		font-size: 12.5px;
		line-height: 1.5;
		color: #64748b;
	}
}

.pref-chip {
	flex-shrink: 0;
	display: inline-flex;
	align-items: center;
	min-height: 28px;
	padding: 0 11px;
	border-radius: 999px;
	font-size: 11.5px;
	font-weight: 700;
	color: #64748b;
	background: var(--soft, #f1f5f9);
	border: 1px solid var(--line, #e2e8f0);

	&[data-on='1'] {
		color: #0f766e;
		background: rgba(47, 191, 164, 0.12);
		border-color: rgba(47, 191, 164, 0.22);
	}
}

.mode-grid {
	display: grid;
	grid-template-columns: repeat(3, minmax(0, 1fr));
	gap: 10px;
	margin-bottom: 14px;
}

.lock-tip {
	margin: -4px 0 12px;
	padding: 10px 12px;
	border-radius: 10px;
	font-size: 12.5px;
	line-height: 1.5;
	color: #9a3412;
	background: rgba(251, 146, 60, 0.12);
	border: 1px solid rgba(251, 146, 60, 0.28);
}

.mode-card {
	--accent: #64748b;
	position: relative;
	display: flex;
	flex-direction: column;
	align-items: flex-start;
	gap: 6px;
	min-height: 132px;
	padding: 14px 14px 12px;
	border-radius: 14px;
	border: 1px solid var(--line, #e8eef5);
	background: var(--panel, #fff);
	text-align: left;

	&.locked,
	&:disabled {
		opacity: 0.48;
		cursor: not-allowed;
		pointer-events: none;
	}
	cursor: pointer;
	transition: border-color 0.18s ease, box-shadow 0.18s ease, transform 0.18s ease, background 0.18s ease;

	&.sys {
		--accent: #007eb8;
	}
	&.on {
		--accent: #0f766e;
	}
	&.off {
		--accent: #b45309;
	}

	&:hover {
		border-color: color-mix(in srgb, var(--accent) 35%, #e8eef5);
		transform: translateY(-1px);
	}

	&.active {
		border-color: color-mix(in srgb, var(--accent) 45%, #e8eef5);
		background: linear-gradient(160deg, color-mix(in srgb, var(--accent) 10%, var(--panel, #fff)), var(--panel, #fff));
		box-shadow: 0 10px 22px color-mix(in srgb, var(--accent) 12%, transparent);

		.mode-check {
			opacity: 1;
			transform: scale(1);
		}

		.mode-badge {
			color: #fff;
			background: var(--accent);
		}
	}

	strong {
		font-size: 14px;
		font-weight: 740;
		color: #122033;
	}

	p {
		margin: 0;
		font-size: 12px;
		line-height: 1.5;
		color: #64748b;
	}

	em {
		margin-top: auto;
		font-style: normal;
		font-size: 11px;
		font-weight: 650;
		color: color-mix(in srgb, var(--accent) 80%, #64748b);
	}
}

.mode-badge {
	display: inline-flex;
	align-items: center;
	height: 20px;
	padding: 0 8px;
	border-radius: 999px;
	font-size: 11px;
	font-weight: 700;
	color: var(--accent);
	background: color-mix(in srgb, var(--accent) 12%, #fff);
}

.mode-check {
	position: absolute;
	top: 12px;
	right: 12px;
	width: 18px;
	height: 18px;
	border-radius: 50%;
	opacity: 0;
	transform: scale(0.7);
	transition: opacity 0.18s ease, transform 0.18s ease;
	background:
		radial-gradient(circle at center, #fff 0 35%, transparent 36%),
		var(--accent);

	&::after {
		content: '';
		position: absolute;
		inset: 5px 4px 6px 5px;
		border: solid #fff;
		border-width: 0 0 2px 2px;
		transform: rotate(-45deg);
	}
}

.limit-panel {
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 14px;
	padding: 14px 16px;
	margin-bottom: 14px;
	border-radius: 14px;
	border: 1px solid var(--line, #e8eef5);
	background: var(--soft, #f7fbfe);
	transition: opacity 0.18s ease;

	&.dimmed {
		opacity: 0.55;
	}
}

.limit-copy {
	min-width: 0;

	strong {
		display: block;
		font-size: 13.5px;
		color: #122033;
	}

	span {
		display: block;
		margin-top: 3px;
		font-size: 12px;
		line-height: 1.45;
		color: #64748b;
	}
}

.limit-ctrl {
	display: flex;
	align-items: center;
	gap: 10px;
	flex-shrink: 0;
}

.limit-sys {
	font-size: 12px;
	color: #94a3b8;
	white-space: nowrap;
}

.pref-actions {
	display: flex;
	gap: 8px;
}

.save-btn {
	border: none;
	background: linear-gradient(135deg, #00a8e8, #2bbef5);
}

.session-head {
	display: flex;
	align-items: flex-start;
	justify-content: space-between;
	gap: 12px;
	margin-bottom: 14px;
	padding-bottom: 12px;
	border-bottom: 1px dashed #e8eef5;

	strong {
		display: block;
		font-size: 14px;
		color: #122033;
	}

	em {
		display: block;
		margin-top: 3px;
		font-style: normal;
		font-size: 12px;
		color: #64748b;
	}
}

.empty {
	padding: 28px 12px;
	text-align: center;
	color: #94a3b8;
	font-size: 13px;
	border-radius: 12px;
	background: var(--soft, #f7fbfe);
	border: 1px dashed var(--line, #e8eef5);
}

.device-list {
	margin: 0;
	padding: 0;
	list-style: none;
	display: grid;
	gap: 10px;
}

.device-item {
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 14px;
	padding: 14px 16px;
	border-radius: 14px;
	border: 1px solid var(--icejz-card-border, #e8eef5);
	background: var(--icejz-card-bg, #fff);

	&.current {
		border-color: rgba(0, 168, 232, 0.28);
		background: linear-gradient(135deg, rgba(0, 168, 232, 0.06), var(--icejz-card-bg, #fff));
	}
}

.device-icon {
	flex-shrink: 0;
	width: 40px;
	height: 40px;
	border-radius: 12px;
	display: grid;
	place-items: center;
	font-size: 12px;
	font-weight: 740;
	color: #007eb8;
	background: rgba(0, 168, 232, 0.1);
}

.device-main {
	min-width: 0;
	flex: 1;
}

.device-title {
	display: flex;
	align-items: center;
	gap: 8px;

	strong {
		font-size: 14px;
		color: #122033;
	}
}

.badge {
	display: inline-flex;
	height: 20px;
	align-items: center;
	padding: 0 8px;
	border-radius: 999px;
	font-size: 11px;
	font-weight: 700;
	color: #007eb8;
	background: rgba(0, 168, 232, 0.12);
}

.device-meta {
	display: flex;
	flex-wrap: wrap;
	gap: 10px;
	margin: 6px 0 4px;
	font-size: 12px;
	color: #64748b;
}

.device-ua {
	margin: 0;
	font-size: 12px;
	color: #94a3b8;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.current-tip {
	font-size: 12px;
	font-weight: 650;
	color: #007eb8;
}

@media (max-width: 860px) {
	.mode-grid {
		grid-template-columns: 1fr;
	}

	.limit-panel {
		flex-direction: column;
		align-items: stretch;
	}

	.limit-ctrl {
		justify-content: space-between;
	}
}

@media (max-width: 640px) {
	.pref-head,
	.session-head {
		flex-direction: column;
	}

	.device-item {
		flex-direction: column;
		align-items: stretch;
	}

	.device-actions {
		display: flex;
		justify-content: flex-end;
	}
}
</style>
