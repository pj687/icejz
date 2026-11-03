<template>
	<div class="inbox-page">
		<header class="inbox-hero">
			<div>
				<p class="kicker">Message Center</p>
				<h1>我的消息</h1>
				<p>查看系统通知、公告与私信，支持一键全部已读</p>
			</div>
			<div class="hero-actions">
				<span class="unread-chip">未读 {{ unreadCount }}</span>
				<el-button :disabled="!unreadCount" @click="readAll">全部已读</el-button>
			</div>
		</header>

		<el-card class="inbox-card" shadow="never">
			<div class="toolbar">
				<el-radio-group v-model="readFilter" @change="reload">
					<el-radio-button value="all">全部</el-radio-button>
					<el-radio-button value="0">未读</el-radio-button>
					<el-radio-button value="1">已读</el-radio-button>
				</el-radio-group>
				<el-input
					v-model="title"
					clearable
					placeholder="搜索标题"
					style="width: 220px"
					@keyup.enter="reload"
					@clear="reload"
				>
					<template #append>
						<el-button icon="Search" @click="reload" />
					</template>
				</el-input>
			</div>

			<ul v-loading="loading" class="msg-list">
				<li
					v-for="item in list"
					:key="item.id"
					:class="{ unread: item.readStatus === 0 }"
					@click="openDetail(item)"
				>
					<span class="type">{{ typeLabel(item.type) }}</span>
					<div class="body">
						<strong>{{ item.title }}</strong>
						<p>{{ item.content }}</p>
						<em>{{ item.senderName || '系统' }} · {{ item.sendTime }}</em>
					</div>
					<span class="status">{{ item.readStatus === 0 ? '未读' : '已读' }}</span>
				</li>
				<li v-if="!loading && !list.length" class="empty">暂无消息</li>
			</ul>

			<el-pagination
				v-if="total > 0"
				class="pager"
				background
				layout="total, prev, pager, next"
				:current-page="page"
				:page-size="limit"
				:total="total"
				@current-change="onPageChange"
			/>
		</el-card>

		<el-drawer v-model="drawerVisible" title="消息详情" size="420px">
			<div v-if="current" class="drawer-body">
				<h3>{{ current.title }}</h3>
				<div class="meta">
					<span>{{ typeLabel(current.type) }}</span>
					<span>{{ current.senderName || '系统' }}</span>
					<span>{{ current.sendTime }}</span>
				</div>
				<p>{{ current.content }}</p>
			</div>
		</el-drawer>
	</div>
</template>

<script setup lang="ts" name="SysMessageInbox">
import { onMounted, ref } from 'vue'
import { ElMessage } from 'element-plus'
import {
	useMessageLatestApi,
	useMessageMyApi,
	useMessageMyPageApi,
	useMessageReadAllApi,
	useMessageUnreadCountApi
} from '@/api/sys/message'

const loading = ref(false)
const list = ref<any[]>([])
const page = ref(1)
const limit = ref(10)
const total = ref(0)
const title = ref('')
const readFilter = ref<'all' | '0' | '1'>('all')
const unreadCount = ref(0)
const drawerVisible = ref(false)
const current = ref<any>(null)

const typeLabel = (type: number) => {
	if (type === 1) return '公告'
	if (type === 2) return '私信'
	return '通知'
}

const fetchUnread = async () => {
	try {
		const res: any = await useMessageUnreadCountApi()
		unreadCount.value = Number(res.data || 0)
	} catch {
		unreadCount.value = 0
	}
}

const reload = async () => {
	page.value = 1
	await loadList()
}

const loadList = async () => {
	loading.value = true
	try {
		const res: any = await useMessageMyPageApi({
			page: page.value,
			limit: limit.value,
			title: title.value || undefined,
			readStatus: readFilter.value === 'all' ? undefined : Number(readFilter.value)
		})
		list.value = res.data?.list || []
		total.value = Number(res.data?.total || 0)
	} finally {
		loading.value = false
	}
}

const onPageChange = async (p: number) => {
	page.value = p
	await loadList()
}

const openDetail = async (item: any) => {
	const res: any = await useMessageMyApi(item.id)
	current.value = res.data
	drawerVisible.value = true
	item.readStatus = 1
	await fetchUnread()
}

const readAll = async () => {
	await useMessageReadAllApi()
	ElMessage.success('已全部标记为已读')
	await Promise.all([loadList(), fetchUnread()])
}

onMounted(async () => {
	await Promise.all([loadList(), fetchUnread()])
	// warm latest endpoint for workbench consumers
	useMessageLatestApi(3).catch(() => undefined)
})
</script>

<style scoped lang="scss">
.inbox-page {
	--ink: #122033;
	--muted: #64748b;
	--soft: #f8fbfd;
	--line: #e8eef5;
	--panel: #fff;
	--brand-deep: #007eb8;
	display: flex;
	flex-direction: column;
	gap: 16px;
	padding: 2px 2px 20px;
}

.inbox-hero {
	display: flex;
	justify-content: space-between;
	gap: 16px;
	align-items: flex-end;
	padding: 20px 22px;
	border-radius: 20px;
	border: 1px solid rgba(0, 168, 232, 0.14);
	background: linear-gradient(145deg, color-mix(in srgb, var(--panel) 96%, transparent), color-mix(in srgb, var(--soft) 90%, transparent));
}

.kicker {
	margin: 0 0 6px;
	font-size: 12px;
	font-weight: 700;
	color: var(--brand-deep);
}

.inbox-hero h1 {
	margin: 0;
	font-size: 26px;
	color: var(--ink);
}

.inbox-hero p {
	margin: 8px 0 0;
	font-size: 13px;
	color: var(--muted);
}

.hero-actions {
	display: flex;
	align-items: center;
	gap: 10px;
}

.unread-chip {
	height: 32px;
	padding: 0 12px;
	border-radius: 999px;
	display: inline-flex;
	align-items: center;
	font-size: 12px;
	font-weight: 720;
	color: #007eb8;
	background: rgba(0, 168, 232, 0.1);
}

.inbox-card {
	border-radius: 18px;
	border: 1px solid #e7eef5;
}

.toolbar {
	display: flex;
	justify-content: space-between;
	gap: 12px;
	flex-wrap: wrap;
	margin-bottom: 14px;
}

.msg-list {
	list-style: none;
	margin: 0;
	padding: 0;
	display: flex;
	flex-direction: column;
	gap: 8px;
	min-height: 220px;
}

.msg-list li {
	display: flex;
	align-items: flex-start;
	gap: 12px;
	padding: 14px;
	border-radius: 14px;
	background: var(--soft);
	cursor: pointer;
	transition: background 0.18s ease, transform 0.18s ease;

	&:hover {
		background: rgba(0, 168, 232, 0.08);
		transform: translateY(-1px);
	}

	&.unread {
		background: rgba(0, 168, 232, 0.08);
		strong::before {
			content: '';
			display: inline-block;
			width: 6px;
			height: 6px;
			margin-right: 6px;
			border-radius: 50%;
			background: #00a8e8;
			vertical-align: middle;
		}
	}

	&.empty {
		justify-content: center;
		align-items: center;
		min-height: 180px;
		color: var(--muted);
		cursor: default;

		&:hover {
			background: var(--soft);
			transform: none;
		}
	}
}

.type {
	flex-shrink: 0;
	height: 24px;
	padding: 0 8px;
	border-radius: 999px;
	display: inline-flex;
	align-items: center;
	font-size: 11px;
	font-weight: 720;
	color: var(--brand-deep);
	background: rgba(0, 168, 232, 0.1);
}

.body {
	flex: 1;
	min-width: 0;

	strong {
		display: block;
		font-size: 14px;
		color: var(--ink);
	}

	p {
		margin: 6px 0;
		font-size: 13px;
		color: var(--muted);
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
	}

	em {
		font-style: normal;
		font-size: 12px;
		color: #94a3b8;
	}
}

.status {
	flex-shrink: 0;
	font-size: 12px;
	color: var(--muted);
}

.pager {
	margin-top: 16px;
	justify-content: flex-end;
}

.drawer-body {
	h3 {
		margin: 0 0 10px;
		font-size: 18px;
		color: var(--ink);
	}

	.meta {
		display: flex;
		flex-wrap: wrap;
		gap: 10px;
		margin-bottom: 14px;
		font-size: 12px;
		color: var(--muted);
	}

	p {
		margin: 0;
		padding: 14px;
		border-radius: 12px;
		background: var(--soft);
		line-height: 1.7;
		white-space: pre-wrap;
		word-break: break-word;
		color: var(--ink);
	}
}

@media (max-width: 760px) {
	.inbox-hero {
		flex-direction: column;
		align-items: flex-start;
	}
}
</style>
