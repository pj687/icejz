<template>
	<div class="org-auth-page user-page">
		<section class="org-auth-hero">
			<div class="hero-copy">
				<span class="hero-kicker"><i class="hero-mark" aria-hidden="true"></i>组织权限</span>
				<h2>用户管理</h2>
				<p>按机构筛选账号，统一维护角色、岗位与人员状态</p>
			</div>
			<div class="hero-meta">
				<span class="hero-chip"><em>{{ state.total || 0 }}</em>位用户</span>
				<span class="hero-chip">机构联动</span>
			</div>
		</section>

		<div class="user-layout" :class="{ 'org-collapsed': !orgPanelOpen }">
			<aside v-show="orgPanelOpen" class="user-org-pane">
				<ma-data-tree-left
					url="/sys/org/list"
					title="机构列表"
					tree-data
					collapsible
					class="user-org-tree"
					@click="handleClick"
					@hide="toggleOrgPanel"
				/>
			</aside>

			<section class="user-main-pane">
				<section class="user-filter-panel">
					<header class="filter-head">
						<div class="filter-title">
							<span class="filter-mark" aria-hidden="true"></span>
							<strong>筛选条件</strong>
							<em>按账号信息快速查找用户</em>
						</div>
						<button
							v-if="!orgPanelOpen"
							type="button"
							class="org-expand-btn"
							title="显示机构列表"
							@click="toggleOrgPanel"
						>
							显示机构
						</button>
					</header>

					<div class="filter-body">
						<el-form ref="queryRef" :inline="true" :model="state.queryForm" class="query-form" @keyup.enter="getDataList()">
							<el-form-item prop="username">
								<el-input v-model="state.queryForm.username" clearable placeholder="用户名">
									<template #prefix><ma-icon icon="icon-user" /></template>
								</el-input>
							</el-form-item>
							<el-form-item prop="mobile">
								<el-input v-model="state.queryForm.mobile" clearable placeholder="手机号">
									<template #prefix><ma-icon icon="icon-phone" /></template>
								</el-input>
							</el-form-item>
							<el-form-item prop="gender" class="gender-item">
								<ma-dict-select v-model="state.queryForm.gender" dict-type="user_gender" clearable placeholder="性别" />
							</el-form-item>
							<el-form-item class="filter-actions">
								<el-button class="search-btn" icon="Search" type="primary" @click="getDataList()">查询</el-button>
								<el-button class="reset-btn" icon="RefreshRight" @click="resetQuery">重置</el-button>
							</el-form-item>
						</el-form>
					</div>

					<div v-if="hasOrgFilter" class="filter-chips">
						<span class="filter-chip">
							已按机构筛选
							<button type="button" @click="clearOrgFilter">清除</button>
						</span>
					</div>
				</section>

				<el-card class="org-auth-card page-card" shadow="never" v-loading="state.dataListLoading">
					<div class="org-auth-toolbar">
						<el-space wrap>
							<el-button v-auth="'sys:user:save'" icon="Plus" type="primary" @click="addOrUpdateHandle()">新增用户</el-button>
							<span v-auth="'sys:user:import'">
								<ma-upload-excel action="/sys/user/import">
									<el-button plain icon="Upload">导入</el-button>
								</ma-upload-excel>
							</span>
							<el-button v-auth="'sys:user:export'" plain icon="Download" @click="downloadHandle('/sys/user/export')">导出</el-button>
							<el-button v-auth="'sys:user:delete'" icon="Delete" plain type="danger" @click="deleteBatchHandle()">批量删除</el-button>
						</el-space>
						<ma-view-mode v-model="viewMode" />
					</div>

					<template v-if="viewMode === 'table'">
						<el-table
							show-overflow-tooltip
							:data="state.dataList"
							class="layout-table"
							@selection-change="selectionChangeHandle"
						>
							<el-table-column type="selection" header-align="center" align="center" width="50"></el-table-column>
							<el-table-column prop="realName" label="姓名" min-width="140">
								<template #default="scope">
									<button type="button" class="org-auth-name name-link" @click="detailHandle(scope.row.id)">
										<span class="avatar">{{ (scope.row.realName || scope.row.username || '?').slice(0, 1) }}</span>
										{{ scope.row.realName || '—' }}
									</button>
								</template>
							</el-table-column>
							<el-table-column prop="username" label="用户名" min-width="120"></el-table-column>
							<ma-dict-column prop="gender" label="性别" dict-type="user_gender" width="90"></ma-dict-column>
							<el-table-column prop="mobile" label="手机号" min-width="120"></el-table-column>
							<el-table-column prop="orgName" label="所属机构" min-width="140"></el-table-column>
							<el-table-column label="多设备" min-width="110">
								<template #default="scope">
									<span class="multi-device-tag" :data-mode="multiDeviceMode(scope.row)">
										{{ multiDeviceLabel(scope.row) }}
									</span>
								</template>
							</el-table-column>
							<el-table-column prop="status" label="状态" min-width="200">
								<template #default="scope">
									<div class="status-cell">
										<ma-dict-label dict-type="user_status" :dict-value="scope.row.status" />
										<em v-if="isBanned(scope.row.status)" class="ban-expire">
											{{ banExpireText(scope.row) }}
										</em>
									</div>
								</template>
							</el-table-column>
							<el-table-column prop="createTime" label="创建时间" min-width="170"></el-table-column>
							<el-table-column label="操作" fixed="right" align="center" width="328">
								<template #default="scope">
									<div class="org-auth-actions">
										<el-button
											v-auth="['sys:user:info', 'sys:user:page', 'sys:user:update']"
											class="act-btn act-ghost"
											:icon="View"
											@click="detailHandle(scope.row.id)"
										>
											详情
										</el-button>
										<el-button v-auth="'sys:user:update'" class="act-btn act-primary" :icon="Edit" @click="addOrUpdateHandle(scope.row.id)">修改</el-button>
										<el-button
											v-auth="'sys:user:update'"
											class="act-btn"
											:class="isBanned(scope.row.status) ? 'act-success' : 'act-warn'"
											:icon="isBanned(scope.row.status) ? CircleCheck : CircleClose"
											@click="openBanDialog(scope.row)"
										>
											{{ isBanned(scope.row.status) ? '解封' : '封禁' }}
										</el-button>
										<el-button v-auth="'sys:user:delete'" class="act-btn act-danger" :icon="Delete" @click="deleteBatchHandle(scope.row.id)">删除</el-button>
									</div>
								</template>
							</el-table-column>
						</el-table>
					</template>

					<div v-else class="org-auth-card-grid">
						<article v-for="row in state.dataList" :key="row.id" class="org-auth-entity-card">
							<div class="card-top">
								<button type="button" class="card-identity name-link" @click="detailHandle(row.id)">
									<span class="card-avatar">{{ (row.realName || row.username || '?').slice(0, 1) }}</span>
									<div class="card-title">
										<strong>{{ row.realName || '—' }}</strong>
										<em>@{{ row.username || '—' }}</em>
									</div>
								</button>
								<ma-dict-label dict-type="user_status" :dict-value="row.status" />
							</div>
							<div class="card-meta">
								<div class="meta-row"><span>手机号</span><b>{{ row.mobile || '—' }}</b></div>
								<div class="meta-row"><span>所属机构</span><b>{{ row.orgName || '—' }}</b></div>
								<div class="meta-row"><span>性别</span><b><ma-dict-label dict-type="user_gender" :dict-value="row.gender" /></b></div>
								<div class="meta-row"><span>创建时间</span><b>{{ row.createTime || '—' }}</b></div>
								<div v-if="isBanned(row.status)" class="meta-row">
									<span>封禁至</span><b>{{ banExpireText(row) }}</b>
								</div>
							</div>
							<div class="card-foot">
								<span class="org-auth-code">ID {{ row.id }}</span>
								<div class="org-auth-actions">
									<el-button
										v-auth="['sys:user:info', 'sys:user:page', 'sys:user:update']"
										class="act-btn act-ghost"
										:icon="View"
										@click="detailHandle(row.id)"
									>
										详情
									</el-button>
									<el-button v-auth="'sys:user:update'" class="act-btn act-primary" :icon="Edit" @click="addOrUpdateHandle(row.id)">修改</el-button>
									<el-button
										v-auth="'sys:user:update'"
										class="act-btn"
										:class="isBanned(row.status) ? 'act-success' : 'act-warn'"
										:icon="isBanned(row.status) ? CircleCheck : CircleClose"
										@click="openBanDialog(row)"
									>
										{{ isBanned(row.status) ? '解封' : '封禁' }}
									</el-button>
									<el-button v-auth="'sys:user:delete'" class="act-btn act-danger" :icon="Delete" @click="deleteBatchHandle(row.id)">删除</el-button>
								</div>
							</div>
						</article>
						<div v-if="!state.dataList?.length" class="org-auth-empty-card">暂无用户数据</div>
					</div>

					<el-pagination
						:current-page="state.page"
						:page-sizes="state.pageSizes"
						:page-size="state.limit"
						:total="state.total"
						layout="total, sizes, prev, pager, next, jumper"
						@size-change="sizeChangeHandle"
						@current-change="currentChangeHandle"
					>
					</el-pagination>
				</el-card>
			</section>
		</div>

		<add-or-update ref="addOrUpdateRef" @refresh-data-list="getDataList"></add-or-update>
		<detail ref="detailRef" @edit="addOrUpdateHandle"></detail>

		<el-dialog
			v-model="banVisible"
			class="org-auth-dialog ban-dialog"
			:title="banForm.toStatus === 0 ? '封禁用户' : '解封用户'"
			width="520px"
			:close-on-click-modal="false"
			draggable
		>
			<div v-if="banTarget" class="ban-body">
				<div class="ban-user">
					<span class="ban-avatar">{{ (banTarget.realName || banTarget.username || '?').slice(0, 1) }}</span>
					<div class="ban-user-copy">
						<strong>{{ banTarget.realName || '—' }}</strong>
						<em>@{{ banTarget.username }} · {{ banTarget.orgName || '未分配机构' }}</em>
					</div>
				</div>

				<template v-if="banForm.toStatus === 0">
					<p class="ban-tip">
						封禁后该账号无法登录；全部在线设备会被立即踢下线。临时封禁到期后，下次登录会自动解封。
					</p>
					<el-form label-position="top" class="ban-form">
						<el-form-item label="封禁时长" required>
							<el-radio-group v-model="banForm.banDuration" class="ban-duration">
								<el-radio-button
									v-for="opt in banDurationOptions"
									:key="opt.value"
									:value="opt.value"
								>
									{{ opt.label }}
								</el-radio-button>
							</el-radio-group>
						</el-form-item>
						<el-form-item v-if="banForm.banDuration === 'custom'" label="到期时间" required>
							<el-date-picker
								v-model="banForm.banExpireTime"
								type="datetime"
								value-format="YYYY-MM-DD HH:mm:ss"
								format="YYYY-MM-DD HH:mm:ss"
								date-format="YYYY-MM-DD"
								time-format="HH:mm:ss"
								:default-time="banDefaultTime"
								:disabled-date="banDisabledDate"
								placeholder="选择封禁到期时间（含时分秒）"
								style="width: 100%"
								popper-class="ban-datetime-popper"
							/>
						</el-form-item>
						<p v-if="banForm.banDuration !== 'permanent' && banForm.banDuration !== 'custom'" class="ban-expire-preview">
							预计解封：{{ previewExpireText }}
						</p>
						<p v-else-if="banForm.banDuration === 'custom' && banForm.banExpireTime" class="ban-expire-preview">
							将封禁至：{{ formatDateTime(banForm.banExpireTime) }}
						</p>
						<el-form-item label="封禁原因（可选）">
							<el-input
								v-model="banForm.reason"
								type="textarea"
								:rows="3"
								maxlength="200"
								show-word-limit
								placeholder="例如：违规操作、账号异常、安全排查等"
							/>
						</el-form-item>
						<el-form-item label="站内通知">
							<div class="notify-row">
								<el-switch v-model="banForm.sendNotify" active-text="发送封禁通知" inactive-text="不发送" />
								<span class="notify-hint">开启后向该用户发送站内信（解封后可在收件箱查看）</span>
							</div>
						</el-form-item>
					</el-form>
				</template>
				<template v-else>
					<p class="ban-tip">
						解封后账号恢复正常登录。
						<template v-if="banTarget.banExpireTime || banTarget.banReason">
							当前封禁：{{ banExpireText(banTarget)
							}}{{ banTarget.banReason ? `；原因：${banTarget.banReason}` : '' }}
						</template>
					</p>
					<el-form label-position="top" class="ban-form">
						<el-form-item label="备注（可选）">
							<el-input
								v-model="banForm.reason"
								type="textarea"
								:rows="2"
								maxlength="200"
								show-word-limit
								placeholder="解封说明，写入通知内容"
							/>
						</el-form-item>
						<el-form-item label="站内通知">
							<div class="notify-row">
								<el-switch v-model="banForm.sendNotify" active-text="发送解封通知" inactive-text="不发送" />
							</div>
						</el-form-item>
					</el-form>
				</template>
			</div>
			<template #footer>
				<el-button @click="banVisible = false">取消</el-button>
				<el-button
					:type="banForm.toStatus === 0 ? 'warning' : 'primary'"
					:loading="banSubmitting"
					@click="submitBan"
				>
					{{ banForm.toStatus === 0 ? '确认封禁' : '确认解封' }}
				</el-button>
			</template>
		</el-dialog>
	</div>
</template>

<script setup lang="ts" name="SysUserIndex">
import { useCrud } from '@/hooks'
import { useViewMode } from '@/hooks/useViewMode'
import { computed, reactive, ref, watch } from 'vue'
import { CircleCheck, CircleClose, Delete, Edit, View } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import AddOrUpdate from './add-or-update.vue'
import Detail from './detail.vue'
import MaViewMode from '@/components/ma-view-mode/index.vue'
import { IHooksOptions } from '@/hooks/interface'
import { useUserStatusApi } from '@/api/sys/user'

const { viewMode } = useViewMode('sys-user')
const ORG_PANEL_KEY = 'sys-user-org-panel'

const state: IHooksOptions = reactive({
	dataListUrl: '/sys/user/page',
	deleteUrl: '/sys/user',
	queryForm: {
		username: '',
		mobile: '',
		gender: '',
		orgId: [] as any[]
	}
})

const queryRef = ref()
const addOrUpdateRef = ref()
const detailRef = ref()
const addOrUpdateHandle = (id?: number) => {
	addOrUpdateRef.value.init(id)
}
const detailHandle = (id: number) => {
	detailRef.value.init(id)
}

const orgPanelOpen = ref(localStorage.getItem(ORG_PANEL_KEY) !== '0')
const hasOrgFilter = computed(() => Array.isArray(state.queryForm.orgId) && state.queryForm.orgId.length > 0)

watch(orgPanelOpen, v => {
	localStorage.setItem(ORG_PANEL_KEY, v ? '1' : '0')
})

const toggleOrgPanel = () => {
	orgPanelOpen.value = !orgPanelOpen.value
}

const handleClick = (orgId: any[]) => {
	state.queryForm.orgId = orgId
	getDataList()
}

const clearOrgFilter = () => {
	state.queryForm.orgId = []
	getDataList()
}

const resetQuery = () => {
	state.queryForm.orgId = []
	reset(queryRef.value)
}

const isBanned = (status: number | string) => Number(status) === 0

const multiDeviceMode = (row: any) => {
	if (row?.multiDeviceLogin === 1) return 'on'
	if (row?.multiDeviceLogin === 0) return 'off'
	return 'sys'
}

const multiDeviceLabel = (row: any) => {
	if (row?.multiDeviceLogin === 1) {
		return row.multiDeviceMax ? `多设备≤${row.multiDeviceMax}` : '多设备'
	}
	if (row?.multiDeviceLogin === 0) {
		return '单设备'
	}
	return '跟随系统'
}

const pad2 = (n: number) => String(n).padStart(2, '0')

const formatDateTime = (t?: string | Date | number[]) => {
	if (t == null || t === '') {
		return ''
	}
	// Jackson 偶发数组：[y,M,d,H,m,s]
	if (Array.isArray(t) && t.length >= 3) {
		const [y, m, d, h = 0, mi = 0, s = 0] = t
		return `${y}-${pad2(Number(m))}-${pad2(Number(d))} ${pad2(Number(h))}:${pad2(Number(mi))}:${pad2(Number(s))}`
	}
	if (t instanceof Date && !Number.isNaN(t.getTime())) {
		return `${t.getFullYear()}-${pad2(t.getMonth() + 1)}-${pad2(t.getDate())} ${pad2(t.getHours())}:${pad2(t.getMinutes())}:${pad2(t.getSeconds())}`
	}
	const raw = String(t).trim()
	// 仅日期时补全 00:00:00，避免列表缺分秒
	if (/^\d{4}-\d{2}-\d{2}$/.test(raw)) {
		return `${raw} 00:00:00`
	}
	return raw.replace('T', ' ').replace(/\.\d+$/, '').replace(/Z$/, '').slice(0, 19)
}

const banExpireText = (row: any) => {
	if (!row) {
		return ''
	}
	if (!row.banExpireTime) {
		return '永久封禁'
	}
	return `至 ${formatDateTime(row.banExpireTime)}`
}

const banVisible = ref(false)
const banSubmitting = ref(false)
const banTarget = ref<any>(null)
const banDefaultTime = new Date(2000, 0, 1, 23, 59, 59)
const banDurationOptions = [
	{ value: 'permanent', label: '永久' },
	{ value: '5m', label: '5 分钟' },
	{ value: '10m', label: '10 分钟' },
	{ value: '15m', label: '15 分钟' },
	{ value: '30m', label: '30 分钟' },
	{ value: '1h', label: '1 小时' },
	{ value: '6h', label: '6 小时' },
	{ value: '12h', label: '12 小时' },
	{ value: '1d', label: '1 天' },
	{ value: '3d', label: '3 天' },
	{ value: '7d', label: '7 天' },
	{ value: '15d', label: '15 天' },
	{ value: '30d', label: '30 天' },
	{ value: '90d', label: '90 天' },
	{ value: 'custom', label: '自定义' }
] as const

const banForm = reactive({
	toStatus: 0,
	reason: '',
	banDuration: 'permanent',
	banExpireTime: '' as string,
	sendNotify: true
})

const banDisabledDate = (date: Date) => {
	const today = new Date()
	today.setHours(0, 0, 0, 0)
	return date.getTime() < today.getTime()
}

const previewExpireText = computed(() => {
	const key = banForm.banDuration
	const m = /^(\d+)([mhd])$/.exec(key)
	if (!m) {
		return ''
	}
	const amount = Number(m[1])
	const unit = m[2]
	const d = new Date()
	if (unit === 'm') {
		d.setMinutes(d.getMinutes() + amount)
	} else if (unit === 'h') {
		d.setHours(d.getHours() + amount)
	} else {
		d.setDate(d.getDate() + amount)
	}
	return formatDateTime(d)
})

const openBanDialog = (row: any) => {
	banTarget.value = row
	banForm.toStatus = isBanned(row.status) ? 1 : 0
	banForm.reason = ''
	banForm.banDuration = 'permanent'
	banForm.banExpireTime = ''
	banForm.sendNotify = true
	banVisible.value = true
}

const submitBan = async () => {
	if (!banTarget.value?.id) {
		return
	}
	if (banForm.toStatus === 0 && banForm.banDuration === 'custom' && !banForm.banExpireTime) {
		ElMessage.warning('请选择封禁到期时间')
		return
	}
	banSubmitting.value = true
	try {
		await useUserStatusApi({
			id: banTarget.value.id,
			status: banForm.toStatus,
			reason: banForm.reason?.trim() || undefined,
			banDuration: banForm.toStatus === 0 ? banForm.banDuration : undefined,
			banExpireTime: banForm.toStatus === 0 && banForm.banDuration === 'custom' ? banForm.banExpireTime : undefined,
			sendNotify: banForm.sendNotify
		})
		ElMessage.success(banForm.toStatus === 0 ? '已封禁并强制下线' : '已解封')
		banVisible.value = false
		getDataList()
	} catch {
		/* 全局拦截已提示 */
	} finally {
		banSubmitting.value = false
	}
}

const { getDataList, selectionChangeHandle, sizeChangeHandle, currentChangeHandle, deleteBatchHandle, downloadHandle, reset } = useCrud(state)
</script>

<style scoped lang="scss">
.user-layout {
	display: grid;
	grid-template-columns: 260px minmax(0, 1fr);
	gap: 12px;
	align-items: stretch;

	&.org-collapsed {
		grid-template-columns: minmax(0, 1fr);
	}
}

.user-org-pane {
	min-width: 0;
}

.user-org-tree {
	height: 100%;
}

.user-main-pane {
	min-width: 0;
}

.user-filter-panel {
	--uf-brand: var(--oa-brand, var(--el-color-primary));
	--uf-brand-deep: var(--oa-brand-deep, var(--el-color-primary-dark-2, var(--el-color-primary)));
	--uf-ink: var(--oa-ink, var(--el-text-color-primary));
	--uf-muted: var(--oa-muted, var(--el-text-color-secondary));
	--uf-line: var(--oa-line, var(--el-border-color-lighter));
	--uf-surface: var(--oa-surface, var(--el-bg-color));
	--uf-surface-soft: var(--oa-surface-soft, var(--el-fill-color-blank, var(--el-bg-color)));
	margin-bottom: 12px;
	padding: 14px 16px 12px;
	border-radius: 16px;
	border: 1px solid color-mix(in srgb, var(--uf-brand) 22%, var(--uf-line));
	background:
		linear-gradient(
			145deg,
			color-mix(in srgb, var(--uf-surface) 96%, transparent),
			color-mix(in srgb, var(--uf-surface-soft) 94%, transparent)
		),
		radial-gradient(520px 120px at 0% 0%, color-mix(in srgb, var(--uf-brand) 10%, transparent), transparent 70%);
	box-shadow: 0 6px 18px color-mix(in srgb, var(--uf-ink) 4%, transparent);
}

.filter-head {
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 12px;
	margin-bottom: 12px;
}

.filter-title {
	display: inline-flex;
	align-items: center;
	gap: 8px;
	min-width: 0;

	strong {
		font-size: 14px;
		color: var(--uf-ink);
	}

	em {
		font-style: normal;
		font-size: 12px;
		color: var(--uf-muted);
	}
}

.filter-mark {
	width: 8px;
	height: 8px;
	border-radius: 50%;
	background: var(--uf-brand);
	box-shadow: 0 0 0 4px color-mix(in srgb, var(--uf-brand) 18%, transparent);
	flex-shrink: 0;
}

.filter-body {
	min-width: 0;
}

.query-form {
	display: flex;
	flex-wrap: wrap;
	align-items: center;
	gap: 10px 12px;
	margin: 0;

	:deep(.el-form-item) {
		margin: 0;
	}

	:deep(.el-input),
	:deep(.el-select) {
		width: 168px;
	}

	:deep(.el-input__wrapper),
	:deep(.el-select__wrapper) {
		min-height: 34px;
		border-radius: 11px;
		box-shadow: 0 0 0 1px var(--uf-line) inset;
		background: var(--uf-surface);
		transition: box-shadow 0.18s ease, background 0.18s ease;
	}

	:deep(.el-input__wrapper:hover),
	:deep(.el-select__wrapper:hover) {
		box-shadow: 0 0 0 1px color-mix(in srgb, var(--uf-brand) 40%, var(--uf-line)) inset;
	}

	:deep(.el-input__wrapper.is-focus),
	:deep(.el-select__wrapper.is-focused) {
		box-shadow:
			0 0 0 1px var(--uf-brand) inset,
			0 0 0 3px color-mix(in srgb, var(--uf-brand) 16%, transparent);
	}

	:deep(.el-input__prefix) {
		color: var(--uf-muted);
	}
}

.filter-actions {
	:deep(.el-form-item__content) {
		display: inline-flex;
		gap: 8px;
	}
}

.search-btn {
	border: 0;
	border-radius: 10px;
	background: linear-gradient(135deg, var(--uf-brand), color-mix(in srgb, var(--uf-brand) 70%, #fff));
}

.reset-btn {
	border-radius: 10px;
	border-color: var(--uf-line);
	color: var(--uf-muted);
	background: var(--uf-surface);

	&:hover {
		border-color: color-mix(in srgb, var(--uf-brand) 40%, var(--uf-line));
		color: var(--uf-brand-deep);
		background: color-mix(in srgb, var(--uf-brand) 8%, var(--uf-surface));
	}
}

.org-expand-btn {
	height: 30px;
	padding: 0 12px;
	border-radius: 999px;
	border: 1px solid color-mix(in srgb, var(--uf-brand) 30%, var(--uf-line));
	background: color-mix(in srgb, var(--uf-brand) 10%, var(--uf-surface));
	color: var(--uf-brand-deep);
	font-size: 12px;
	font-weight: 650;
	cursor: pointer;
	flex-shrink: 0;

	&:hover {
		background: color-mix(in srgb, var(--uf-brand) 16%, var(--uf-surface));
	}
}

.filter-chips {
	display: flex;
	flex-wrap: wrap;
	gap: 8px;
	margin-top: 10px;
	padding-top: 10px;
	border-top: 1px dashed var(--uf-line);
}

.filter-chip {
	display: inline-flex;
	align-items: center;
	gap: 8px;
	height: 28px;
	padding: 0 10px;
	border-radius: 999px;
	background: color-mix(in srgb, var(--uf-brand) 12%, var(--uf-surface));
	color: var(--uf-brand-deep);
	font-size: 12px;
	font-weight: 650;

	button {
		appearance: none;
		border: 0;
		background: transparent;
		color: var(--uf-muted);
		cursor: pointer;
		padding: 0;
		font: inherit;

		&:hover {
			color: var(--el-color-danger);
		}
	}
}

@media (max-width: 1100px) {
	.filter-title em {
		display: none;
	}
}

.ban-body {
	display: flex;
	flex-direction: column;
	gap: 14px;
}

.ban-user {
	display: flex;
	align-items: center;
	gap: 12px;
	padding: 12px 14px;
	border-radius: 14px;
	background: #f7fbfe;
	border: 1px solid #e8eef5;
}

.ban-avatar {
	width: 40px;
	height: 40px;
	border-radius: 50%;
	display: inline-grid;
	place-items: center;
	font-weight: 750;
	color: #007eb8;
	background: linear-gradient(135deg, rgba(0, 168, 232, 0.18), rgba(0, 168, 232, 0.08));
}

.ban-user-copy {
	min-width: 0;
	display: grid;
	gap: 2px;

	strong {
		font-size: 15px;
		color: #122033;
	}

	em {
		font-style: normal;
		font-size: 12.5px;
		color: #64748b;
	}
}

.ban-tip {
	margin: 0;
	font-size: 13px;
	line-height: 1.6;
	color: #64748b;
}

.ban-form {
	display: flex;
	flex-direction: column;
	gap: 4px;
}

.ban-duration {
	display: flex;
	flex-wrap: wrap;
	gap: 8px;

	:deep(.el-radio-button) {
		margin: 0;
	}

	:deep(.el-radio-button__inner) {
		border-radius: 10px !important;
		border: 1px solid #e2e8f0 !important;
		box-shadow: none !important;
		padding: 8px 12px;
	}

	:deep(.el-radio-button:first-child .el-radio-button__inner),
	:deep(.el-radio-button:last-child .el-radio-button__inner) {
		border-radius: 10px !important;
	}

	:deep(.el-radio-button.is-active .el-radio-button__inner) {
		border-color: rgba(0, 168, 232, 0.45) !important;
		background: rgba(0, 168, 232, 0.12);
		color: #007eb8;
	}
}

.notify-row {
	display: flex;
	flex-direction: column;
	align-items: flex-start;
	gap: 6px;
}

.notify-hint {
	font-size: 12px;
	line-height: 1.45;
	color: #94a3b8;
}

.status-cell {
	display: flex;
	flex-direction: column;
	align-items: flex-start;
	gap: 4px;
}

.ban-expire {
	font-style: normal;
	font-size: 11px;
	line-height: 1.35;
	color: #b45309;
	font-variant-numeric: tabular-nums;
	white-space: nowrap;
}

.ban-expire-preview {
	margin: -2px 0 8px;
	font-size: 12px;
	line-height: 1.5;
	color: #007eb8;
	font-variant-numeric: tabular-nums;
}

.multi-device-tag {
	display: inline-flex;
	align-items: center;
	height: 22px;
	padding: 0 8px;
	border-radius: 999px;
	font-size: 11px;
	font-weight: 650;
	border: 1px solid #e2e8f0;
	background: #f8fafc;
	color: #64748b;

	&[data-mode='on'] {
		color: #0f766e;
		background: rgba(47, 191, 164, 0.12);
		border-color: rgba(47, 191, 164, 0.22);
	}

	&[data-mode='off'] {
		color: #b45309;
		background: rgba(240, 162, 2, 0.12);
		border-color: rgba(240, 162, 2, 0.22);
	}
}

.name-link {
	appearance: none;
	border: 0;
	background: transparent;
	padding: 0;
	cursor: pointer;
	text-align: left;
	color: inherit;
	font: inherit;

	&:hover {
		color: #007eb8;

		strong {
			color: #007eb8;
		}
	}
}

@media (max-width: 992px) {
	.user-layout {
		grid-template-columns: 1fr;
	}

	.user-org-tree {
		min-height: 280px;
	}
}
</style>

<style lang="scss">
/* 弹层 teleport 到 body，需非 scoped 才能保证时分秒列完整显示 */
.ban-datetime-popper {
	.el-picker-panel {
		&.has-time {
			min-width: 420px;
		}
	}

	.el-time-panel {
		width: 160px;
	}

	.el-time-spinner.has-seconds .el-time-spinner__wrapper {
		width: 33.33%;
	}
}
</style>
