<template>
	<el-dialog
		v-model="visible"
		class="org-auth-dialog user-detail-dialog"
		title="用户详情"
		width="720px"
		:close-on-click-modal="false"
		draggable
		destroy-on-close
	>
		<div v-loading="loading" class="user-detail">
			<header class="detail-hero">
				<div class="hero-avatar" :class="{ banned: isBanned }">
					<img v-if="detail.avatar" :src="detail.avatar" alt="" />
					<span v-else>{{ avatarText }}</span>
				</div>
				<div class="hero-copy">
					<div class="hero-title">
						<strong>{{ detail.realName || '—' }}</strong>
						<ma-dict-label dict-type="user_status" :dict-value="detail.status" />
						<span v-if="detail.superAdmin === 1" class="admin-pill">超管</span>
					</div>
					<p class="hero-sub">
						<span>@{{ detail.username || '—' }}</span>
						<span class="dot" aria-hidden="true">·</span>
						<span>ID {{ detail.id || '—' }}</span>
					</p>
					<p v-if="isBanned" class="ban-line">
						{{ banText }}
					</p>
				</div>
			</header>

			<section class="detail-block">
				<header class="block-head">
					<strong>基础资料</strong>
					<span>联系方式与账号属性</span>
				</header>
				<div class="info-grid">
					<div class="info-cell">
						<span>手机号</span>
						<strong>{{ detail.mobile || '—' }}</strong>
					</div>
					<div class="info-cell">
						<span>邮箱</span>
						<strong class="email">{{ detail.email || '—' }}</strong>
					</div>
					<div class="info-cell">
						<span>性别</span>
						<strong><ma-dict-label dict-type="user_gender" :dict-value="detail.gender" /></strong>
					</div>
					<div class="info-cell">
						<span>创建时间</span>
						<strong>{{ detail.createTime || '—' }}</strong>
					</div>
				</div>
			</section>

			<section class="detail-block">
				<header class="block-head">
					<strong>组织归属</strong>
					<span>机构、主管、角色与岗位</span>
				</header>
				<div class="info-grid">
					<div class="info-cell">
						<span>所属机构</span>
						<strong>{{ detail.orgName || '—' }}</strong>
					</div>
					<div class="info-cell">
						<span>直属主管</span>
						<strong>{{ leaderName || '—' }}</strong>
					</div>
					<div class="info-cell wide">
						<span>所属角色</span>
						<div class="tag-row">
							<template v-if="roleNames.length">
								<span v-for="name in roleNames" :key="name" class="chip">{{ name }}</span>
							</template>
							<em v-else class="empty">未分配角色</em>
						</div>
					</div>
					<div class="info-cell wide">
						<span>所属岗位</span>
						<div class="tag-row">
							<template v-if="postNames.length">
								<span v-for="name in postNames" :key="name" class="chip soft">{{ name }}</span>
							</template>
							<em v-else class="empty">未分配岗位</em>
						</div>
					</div>
				</div>
			</section>

			<section class="detail-block">
				<header class="block-head">
					<strong>登录设备策略</strong>
					<span>个人多设备偏好（空则跟随系统）</span>
				</header>
				<div class="info-grid">
					<div class="info-cell">
						<span>多设备登录</span>
						<strong>
							<span class="multi-tag" :data-mode="multiMode">{{ multiLabel }}</span>
						</strong>
					</div>
					<div class="info-cell">
						<span>设备上限</span>
						<strong>{{ multiMaxText }}</strong>
					</div>
				</div>
				<p v-if="isBanned && detail.banReason" class="ban-reason">
					封禁原因：{{ detail.banReason }}
				</p>
			</section>
		</div>

		<template #footer>
			<el-button @click="visible = false">关闭</el-button>
			<el-button v-auth="'sys:user:update'" type="primary" @click="editHandle">去修改</el-button>
		</template>
	</el-dialog>
</template>

<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { useUserApi, useRealNameListApi } from '@/api/sys/user'
import { useRoleListApi } from '@/api/sys/role'
import { usePostListApi } from '@/api/sys/post'

const emit = defineEmits<{ edit: [id: number] }>()

const visible = ref(false)
const loading = ref(false)
const roleList = ref<any[]>([])
const postList = ref<any[]>([])
const leaderName = ref('')

const detail = reactive<any>({
	id: '',
	username: '',
	realName: '',
	avatar: '',
	mobile: '',
	email: '',
	gender: 0,
	orgId: '',
	orgName: '',
	leaderId: '',
	status: 1,
	superAdmin: 0,
	roleIdList: [] as number[],
	postIdList: [] as number[],
	multiDeviceLogin: null as number | null,
	multiDeviceMax: null as number | null,
	banReason: '',
	banTime: '',
	banExpireTime: '',
	createTime: ''
})

const isBanned = computed(() => Number(detail.status) === 0)
const avatarText = computed(() => (detail.realName || detail.username || '?').slice(0, 1))

const roleNames = computed(() => {
	const ids = detail.roleIdList || []
	return roleList.value.filter(r => ids.includes(r.id)).map(r => r.name)
})

const postNames = computed(() => {
	const ids = detail.postIdList || []
	return postList.value.filter(p => ids.includes(p.id)).map(p => p.postName)
})

const multiMode = computed(() => {
	if (detail.multiDeviceLogin === 1) return 'on'
	if (detail.multiDeviceLogin === 0) return 'off'
	return 'sys'
})

const multiLabel = computed(() => {
	if (detail.multiDeviceLogin === 1) return '允许多设备'
	if (detail.multiDeviceLogin === 0) return '仅单设备'
	return '跟随系统'
})

const multiMaxText = computed(() => {
	if (detail.multiDeviceLogin !== 1) return '—'
	return detail.multiDeviceMax ? String(detail.multiDeviceMax) : '跟随系统上限'
})

const formatDateTime = (t?: string) => {
	if (!t) return ''
	return String(t).replace('T', ' ').replace(/\.\d+$/, '').slice(0, 19)
}

const banText = computed(() => {
	if (!isBanned.value) return ''
	if (!detail.banExpireTime) return '永久封禁'
	return `封禁至 ${formatDateTime(detail.banExpireTime)}`
})

const resetDetail = () => {
	Object.assign(detail, {
		id: '',
		username: '',
		realName: '',
		avatar: '',
		mobile: '',
		email: '',
		gender: 0,
		orgId: '',
		orgName: '',
		leaderId: '',
		status: 1,
		superAdmin: 0,
		roleIdList: [],
		postIdList: [],
		multiDeviceLogin: null,
		multiDeviceMax: null,
		banReason: '',
		banTime: '',
		banExpireTime: '',
		createTime: ''
	})
	leaderName.value = ''
}

const loadMeta = async () => {
	const [roles, posts] = await Promise.all([useRoleListApi(), usePostListApi()])
	roleList.value = roles.data || []
	postList.value = posts.data || []
}

const loadLeader = async (leaderId?: number) => {
	leaderName.value = ''
	if (!leaderId) return
	try {
		const { data } = await useRealNameListApi([leaderId])
		leaderName.value = Array.isArray(data) && data[0] ? String(data[0]) : String(leaderId)
	} catch {
		leaderName.value = String(leaderId)
	}
}

const init = async (id: number) => {
	visible.value = true
	loading.value = true
	resetDetail()
	try {
		await loadMeta()
		const { data } = await useUserApi(id)
		Object.assign(detail, data || {})
		await loadLeader(data?.leaderId)
	} finally {
		loading.value = false
	}
}

const editHandle = () => {
	const id = Number(detail.id)
	visible.value = false
	if (id) {
		emit('edit', id)
	}
}

defineExpose({ init })
</script>

<style scoped lang="scss">
.user-detail {
	--ud-ink: #122033;
	--ud-muted: #64748b;
	--ud-soft: #fbfcfe;
	--ud-cell: #fff;
	--ud-line: #e8eef5;
	--ud-brand: #007eb8;
	--ud-brand-soft: rgba(0, 168, 232, 0.12);
	display: flex;
	flex-direction: column;
	gap: 14px;
	min-height: 220px;
}

.detail-hero {
	display: flex;
	align-items: center;
	gap: 14px;
	padding: 16px;
	border-radius: 16px;
	border: 1px solid rgba(0, 168, 232, 0.14);
	background:
		radial-gradient(120% 140% at 0% 0%, rgba(0, 168, 232, 0.1), transparent 55%),
		linear-gradient(180deg, var(--ud-soft), var(--ud-cell));
}

.hero-avatar {
	width: 56px;
	height: 56px;
	border-radius: 16px;
	overflow: hidden;
	display: grid;
	place-items: center;
	flex-shrink: 0;
	font-size: 22px;
	font-weight: 760;
	color: var(--ud-brand);
	background: var(--ud-brand-soft);

	img {
		width: 100%;
		height: 100%;
		object-fit: cover;
	}

	&.banned {
		color: #be123c;
		background: rgba(225, 29, 72, 0.1);
	}
}

.hero-copy {
	min-width: 0;
	flex: 1;
}

.hero-title {
	display: flex;
	flex-wrap: wrap;
	align-items: center;
	gap: 8px;

	strong {
		font-size: 18px;
		font-weight: 740;
		color: var(--ud-ink);
	}
}

.admin-pill {
	display: inline-flex;
	align-items: center;
	height: 22px;
	padding: 0 8px;
	border-radius: 999px;
	font-size: 11px;
	font-weight: 700;
	color: #7c3aed;
	background: rgba(124, 58, 237, 0.1);
}

.hero-sub {
	display: flex;
	flex-wrap: wrap;
	align-items: center;
	gap: 6px;
	margin: 6px 0 0;
	font-size: 12.5px;
	color: var(--ud-muted);
}

.dot {
	opacity: 0.5;
}

.ban-line {
	margin: 8px 0 0;
	font-size: 12.5px;
	font-weight: 650;
	color: #b45309;
}

.detail-block {
	padding: 14px;
	border-radius: 14px;
	border: 1px solid var(--ud-line);
	background: var(--ud-soft);
}

.block-head {
	margin-bottom: 12px;

	strong {
		display: block;
		font-size: 14px;
		color: var(--ud-ink);
	}

	span {
		display: block;
		margin-top: 2px;
		font-size: 12px;
		color: var(--ud-muted);
	}
}

.info-grid {
	display: grid;
	grid-template-columns: repeat(2, minmax(0, 1fr));
	gap: 10px;
}

.info-cell {
	display: grid;
	gap: 4px;
	min-width: 0;
	padding: 10px 12px;
	border-radius: 12px;
	background: var(--ud-cell);
	border: 1px solid color-mix(in srgb, var(--ud-line) 95%, transparent);

	&.wide {
		grid-column: 1 / -1;
	}

	span {
		font-size: 11px;
		font-weight: 650;
		color: var(--ud-muted);
	}

	strong {
		font-size: 13px;
		font-weight: 700;
		color: var(--ud-ink);
		word-break: break-all;

		&.email {
			word-break: break-all;
		}
	}
}

.tag-row {
	display: flex;
	flex-wrap: wrap;
	gap: 6px;
}

.chip {
	display: inline-flex;
	align-items: center;
	height: 24px;
	padding: 0 10px;
	border-radius: 999px;
	font-size: 12px;
	font-weight: 650;
	color: var(--ud-brand);
	background: var(--ud-brand-soft);

	&.soft {
		color: #0f766e;
		background: rgba(47, 191, 164, 0.12);
	}
}

.empty {
	font-style: normal;
	font-size: 12.5px;
	color: #94a3b8;
}

.multi-tag {
	display: inline-flex;
	align-items: center;
	height: 22px;
	padding: 0 8px;
	border-radius: 999px;
	font-size: 11px;
	font-weight: 650;
	border: 1px solid var(--ud-line);
	background: var(--ud-soft);
	color: var(--ud-muted);

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

.ban-reason {
	margin: 10px 0 0;
	padding: 10px 12px;
	border-radius: 12px;
	font-size: 12.5px;
	line-height: 1.55;
	color: #9f1239;
	background: rgba(225, 29, 72, 0.06);
	border: 1px solid rgba(225, 29, 72, 0.1);
}

@media (max-width: 640px) {
	.info-grid {
		grid-template-columns: 1fr;
	}
}
</style>
