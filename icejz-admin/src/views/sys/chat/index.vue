<template>
	<div class="chat-page">
		<aside class="chat-sidebar">
			<header class="side-hero">
				<div class="side-hero-text">
					<p class="kicker">Enterprise Chat</p>
					<strong>即时通讯</strong>
					<span>单聊 · 群聊 · 文件协同</span>
				</div>
				<div class="side-actions">
					<el-button v-auth="'sys:chat:direct'" class="action-btn" plain @click="openDirect">
						<ma-icon icon="icon-user" />
						单聊
					</el-button>
					<el-button v-auth="'sys:chat:group'" class="action-btn primary" type="primary" @click="openGroup">
						<ma-icon icon="icon-team" />
						建群
					</el-button>
				</div>
			</header>

			<div class="side-search">
				<el-input
					v-model="keyword"
					clearable
					placeholder="搜索会话"
					@change="loadConversations"
					@clear="loadConversations"
					@keyup.enter="loadConversations"
				>
					<template #prefix>
						<ma-icon icon="icon-search" />
					</template>
				</el-input>
			</div>

			<el-scrollbar class="conv-scroll">
				<div
					v-for="item in conversations"
					:key="item.id"
					class="conv-item"
					:class="{ active: item.id === activeId }"
					@click="selectConversation(item)"
				>
					<div class="avatar-wrap">
						<el-avatar :size="44" :src="item.displayAvatar || defaultAvatar" shape="square" class="conv-avatar">
							{{ (item.displayName || '?').slice(0, 1) }}
						</el-avatar>
						<span v-if="item.type === 2" class="type-dot" title="群聊" />
					</div>
					<div class="conv-body">
						<div class="conv-top">
							<span class="conv-name">{{ item.displayName }}</span>
							<span class="conv-time">{{ formatTime(item.lastMsgTime) }}</span>
						</div>
						<div class="conv-bottom">
							<span class="conv-preview">
								<em v-if="item.type === 2" class="tag">群</em>
								{{ item.lastMsgContent || '暂无消息' }}
							</span>
							<span v-if="item.unreadCount" class="badge">{{ item.unreadCount > 99 ? '99+' : item.unreadCount }}</span>
						</div>
					</div>
				</div>
				<div v-if="!conversations.length" class="empty-hint">
					<div class="empty-icon"><ma-icon icon="icon-message" /></div>
					<p>暂无会话</p>
					<small>发起单聊或创建群聊开始沟通</small>
				</div>
			</el-scrollbar>
		</aside>

		<section class="chat-main">
			<template v-if="active">
				<header class="main-head">
					<div class="main-title">
						<el-avatar :size="40" :src="active.displayAvatar || defaultAvatar" shape="square" class="conv-avatar">
							{{ (active.displayName || '?').slice(0, 1) }}
						</el-avatar>
						<div>
							<strong>{{ active.displayName }}</strong>
							<span class="type-chip">{{ active.type === 2 ? `群聊 · ${active.memberCount || 0} 人` : '单聊' }}</span>
						</div>
					</div>
					<div class="main-actions">
						<button
							v-if="active.type === 2"
							type="button"
							class="icon-btn"
							:class="{ on: panelOpen }"
							title="成员"
							@click="panelOpen = !panelOpen"
						>
							<ma-icon icon="icon-team" />
						</button>
						<button v-if="canDissolve" type="button" class="icon-btn danger" title="解散" @click="dissolveActive">
							<ma-icon icon="icon-delete" />
						</button>
					</div>
				</header>

				<el-scrollbar ref="msgScrollRef" class="msg-scroll">
					<div class="msg-list">
						<div v-if="hasMore" class="load-more" @click="loadOlder">加载更早消息</div>
						<template v-for="msg in messages" :key="msg.id">
							<div v-if="msg.msgType === 9 || msg.status === 0" class="sys-row">
								<span class="sys-pill">{{ msg.status === 0 ? '消息已撤回' : msg.content }}</span>
							</div>
							<div v-else class="msg-row" :class="{ mine: msg.mine }">
								<el-avatar :size="36" :src="msg.senderAvatar || defaultAvatar" shape="square" class="conv-avatar">
									{{ (msg.senderName || '?').slice(0, 1) }}
								</el-avatar>
								<div class="bubble-wrap">
									<div class="meta">
										<span>{{ msg.senderName }}</span>
										<span>{{ formatTime(msg.createTime) }}</span>
									</div>
									<div v-if="msg.msgType === 1" class="bubble media">
										<el-image :src="msg.fileUrl" :preview-src-list="[msg.fileUrl]" fit="cover" class="chat-img" />
									</div>
									<div v-else-if="msg.msgType === 2" class="bubble file" @click="openFile(msg.fileUrl)">
										<div class="file-icon"><ma-icon icon="icon-file" /></div>
										<div class="file-meta">
											<strong>{{ msg.fileName || '文件' }}</strong>
											<small>{{ formatSize(msg.fileSize) }}</small>
										</div>
									</div>
									<div v-else class="bubble text">{{ msg.content }}</div>
									<div v-if="msg.mine || canManage" class="msg-ops">
										<el-button link type="danger" size="small" @click="recall(msg.id)">撤回</el-button>
									</div>
								</div>
							</div>
						</template>
					</div>
				</el-scrollbar>

				<footer class="composer">
					<div class="composer-tools">
						<el-upload :show-file-list="false" :http-request="uploadImage" accept="image/*">
							<button type="button" class="tool-btn" title="图片">
								<ma-icon icon="icon-image" />
								<span>图片</span>
							</button>
						</el-upload>
						<el-upload v-auth="'sys:chat:file'" :show-file-list="false" :http-request="uploadFile">
							<button type="button" class="tool-btn" title="文件">
								<ma-icon icon="icon-file" />
								<span>文件</span>
							</button>
						</el-upload>
					</div>
					<div class="composer-box">
						<el-input
							v-model="draft"
							type="textarea"
							:rows="3"
							resize="none"
							placeholder="输入消息，Enter 发送，Shift+Enter 换行"
							@keydown.enter.exact.prevent="sendText"
						/>
						<el-button class="send-btn" type="primary" :disabled="!draft.trim()" @click="sendText">发送</el-button>
					</div>
				</footer>
			</template>
			<div v-else class="main-empty">
				<div class="empty-icon"><ma-icon icon="icon-message-fill" /></div>
				<p>选择左侧会话开始沟通</p>
				<small>支持文本、图片与文件消息</small>
			</div>
		</section>

		<aside v-if="active && active.type === 2 && panelOpen" class="chat-panel">
			<header class="panel-head">
				<div>
					<strong>群成员</strong>
					<span>{{ members.length }} 人</span>
				</div>
				<el-button v-auth="'sys:chat:page'" size="small" type="primary" plain @click="addMemberVisible = true">添加</el-button>
			</header>
			<el-scrollbar>
				<div v-for="m in members" :key="m.userId" class="member-row">
					<el-avatar :size="34" :src="m.avatar || defaultAvatar" shape="square" class="conv-avatar">
						{{ (m.realName || m.username || '?').slice(0, 1) }}
					</el-avatar>
					<div class="member-body">
						<div class="member-name">{{ m.realName || m.username }}</div>
						<span class="role-chip" :class="'r' + (m.role || 0)">{{ roleLabel(m.role) }}</span>
					</div>
					<el-button
						v-if="m.role !== 2"
						v-auth="'sys:chat:page'"
						link
						type="danger"
						size="small"
						@click="removeMember(m.userId)"
					>
						移除
					</el-button>
				</div>
			</el-scrollbar>
		</aside>

		<el-dialog
			v-model="directVisible"
			class="chat-dialog direct-dialog"
			width="480px"
			align-center
			destroy-on-close
			:show-close="true"
		>
			<template #header>
				<div class="dlg-head">
					<span class="dlg-icon"><ma-icon icon="icon-user" /></span>
					<div>
						<strong>发起单聊</strong>
						<p>选择一位同事，立即开始一对一沟通</p>
					</div>
				</div>
			</template>
			<div class="dlg-body direct-body">
				<button v-if="!directPeer" type="button" class="peer-empty" @click="openDirectPicker">
					<span class="peer-empty-icon"><ma-icon icon="icon-adduser" /></span>
					<div class="peer-empty-text">
						<strong>选择对方用户</strong>
						<small>支持按机构筛选，双击即可选中</small>
					</div>
					<span class="peer-empty-action">去选择</span>
				</button>
				<div v-else class="peer-card">
					<el-avatar :size="52" :src="directPeer.avatar || defaultAvatar" shape="square" class="conv-avatar">
						{{ (directPeer.realName || directPeer.username || '?').slice(0, 1) }}
					</el-avatar>
					<div class="peer-info">
						<strong>{{ directPeer.realName || directPeer.username }}</strong>
						<span v-if="directPeer.username && directPeer.realName">@{{ directPeer.username }}</span>
						<em>{{ directPeer.orgName || '未分配机构' }}</em>
					</div>
					<div class="peer-ops">
						<el-button link type="primary" @click="openDirectPicker">更换</el-button>
						<el-button link type="danger" @click="clearDirectPeer">清除</el-button>
					</div>
				</div>
				<ul class="direct-tips">
					<li>已有会话会直接打开，不会重复创建</li>
					<li>对方需具备即时通讯权限才能正常收发</li>
				</ul>
			</div>
			<template #footer>
				<el-button @click="directVisible = false">取消</el-button>
				<el-button type="primary" class="direct-submit" :disabled="!directUserId" @click="submitDirect">
					开始聊天
				</el-button>
			</template>
		</el-dialog>

		<el-dialog
			v-model="groupVisible"
			class="chat-dialog"
			width="560px"
			align-center
			destroy-on-close
			:show-close="true"
		>
			<template #header>
				<div class="dlg-head">
					<span class="dlg-icon group"><ma-icon icon="icon-team" /></span>
					<div>
						<strong>创建群聊</strong>
						<p>为项目或团队建一个沟通空间</p>
					</div>
				</div>
			</template>
			<div class="dlg-body">
				<label class="dlg-label">群名称</label>
				<el-input v-model="groupTitle" maxlength="40" show-word-limit placeholder="请输入群名称" />
				<label class="dlg-label mt">群成员</label>
				<div class="member-picker">
					<el-button type="primary" plain @click="pickGroupMembers">
						<ma-icon icon="icon-plus" />
						选择成员
					</el-button>
					<div class="picked-bar">
						<span class="picked-chip">已选 {{ groupMemberIds.length }} 人</span>
						<el-button v-if="groupMemberIds.length" link type="danger" @click="groupMemberIds = []">清空</el-button>
					</div>
				</div>
			</div>
			<template #footer>
				<el-button @click="groupVisible = false">取消</el-button>
				<el-button type="primary" @click="submitGroup">创建群聊</el-button>
			</template>
		</el-dialog>

		<ma-user-dialog
			v-model="userDialogVisible"
			:multiple="pickMode !== 'direct'"
			url="/sys/chat/peer/page"
			title="选择可聊用户"
			@select="onUsersPicked"
		/>
	</div>
</template>

<script setup lang="ts">
import { computed, nextTick, onMounted, ref, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { UploadRequestOptions } from 'element-plus'
import { useWebSocket } from '@vueuse/core'
import MaUserDialog from '@/components/ma-user/ma-user-dialog/index.vue'
import constant from '@/utils/constant'
import cache from '@/utils/cache'
import { uploadImg } from '@/api/sys/upload'
import { useUserStore } from '@/store/modules/user'
import {
	useChatAddMembersApi,
	useChatConversationPageApi,
	useChatDirectApi,
	useChatDissolveApi,
	useChatGroupApi,
	useChatMembersApi,
	useChatMessagePageApi,
	useChatReadApi,
	useChatRecallApi,
	useChatRemoveMembersApi,
	useChatSendApi
} from '@/api/sys/chat'

const defaultAvatar = constant.defaultAvatar
const userStore = useUserStore()
const canManage = computed(() => userStore.authorityList?.includes('sys:chat:manage') || userStore.user?.superAdmin === 1)

const conversations = ref<any[]>([])
const messages = ref<any[]>([])
const members = ref<any[]>([])
const activeId = ref<number | null>(null)
const active = ref<any>(null)
const canDissolve = computed(() => {
	if (!active.value || active.value.type !== 2) return false
	if (canManage.value) return true
	return String(active.value.ownerId) === String(userStore.user?.id)
})
const keyword = ref('')
const draft = ref('')
const panelOpen = ref(true)
const hasMore = ref(false)
const msgScrollRef = ref()

const directVisible = ref(false)
const directUserId = ref<number>()
const directPeer = ref<any>(null)
const groupVisible = ref(false)
const groupTitle = ref('')
const groupMemberIds = ref<number[]>([])
const userDialogVisible = ref(false)
const pickMode = ref<'group' | 'member' | 'direct'>('group')
const addMemberVisible = ref(false)

const wsUrl = constant.apiUrl.replace('http://', 'ws://').replace('https://', 'wss://') + '/ws?access_token=' + cache.getToken()
const { data: wsData } = useWebSocket(wsUrl, { autoReconnect: true })

watch(
	() => wsData.value,
	val => {
		if (!val) return
		try {
			handleWs(JSON.parse(val))
		} catch {
			/* ignore */
		}
	}
)

const sameId = (a: any, b: any) => a != null && b != null && String(a) === String(b)

const upsertMessage = (msg: any) => {
	if (!msg?.id) return
	const idx = messages.value.findIndex((m: any) => sameId(m.id, msg.id))
	if (idx >= 0) {
		messages.value[idx] = { ...messages.value[idx], ...msg }
		return
	}
	messages.value.push(msg)
	scrollBottom()
}

const handleWs = (packet: any) => {
	const type = packet?.type
	const payload = packet?.data || {}
	if (!type || !String(type).startsWith('chat.')) return
	if (type === 'chat.new' || type === 'chat.recall' || type === 'chat.read' || type === 'chat.dissolve') {
		loadConversations()
		if (payload.conversationId && sameId(payload.conversationId, activeId.value)) {
			if (type === 'chat.new' && payload.message) {
				upsertMessage(payload.message)
				useChatReadApi(activeId.value)
			}
			if (type === 'chat.recall' && payload.message) {
				const idx = messages.value.findIndex((m: any) => sameId(m.id, payload.messageId))
				if (idx >= 0) messages.value[idx] = payload.message
			}
			if (type === 'chat.dissolve') {
				active.value = null
				activeId.value = null
				messages.value = []
			}
		}
	}
}

const loadConversations = async () => {
	const res = await useChatConversationPageApi({ page: 1, limit: 100, keyword: keyword.value || undefined })
	conversations.value = res.data?.list || []
}

const selectConversation = async (item: any) => {
	activeId.value = item.id
	active.value = item
	messages.value = []
	hasMore.value = false
	await loadMessages()
	await useChatReadApi(item.id)
	await loadConversations()
	if (item.type === 2) {
		const mres = await useChatMembersApi(item.id)
		members.value = mres.data || []
	}
	scrollBottom()
}

const loadMessages = async (beforeId?: number) => {
	if (!activeId.value) return
	const res = await useChatMessagePageApi({
		page: 1,
		limit: 30,
		conversationId: activeId.value,
		beforeId
	})
	const list = res.data?.list || []
	hasMore.value = list.length >= 30
	if (beforeId) {
		messages.value = [...list, ...messages.value]
	} else {
		messages.value = list
	}
}

const loadOlder = async () => {
	if (!messages.value.length) return
	await loadMessages(messages.value[0].id)
}

const sendText = async () => {
	const content = draft.value.trim()
	if (!content || !activeId.value) return
	const res = await useChatSendApi({
		conversationId: activeId.value,
		msgType: 0,
		content
	})
	draft.value = ''
	appendMine(res.data)
	await loadConversations()
}

const uploadImage = async (options: UploadRequestOptions) => {
	await sendUploaded(options.file as File, 1)
}

const uploadFile = async (options: UploadRequestOptions) => {
	await sendUploaded(options.file as File, 2)
}

const sendUploaded = async (file: File, msgType: number) => {
	if (!activeId.value) return
	const form = new FormData()
	form.append('file', file)
	const up = await uploadImg(form)
	const fileUrl = up.data?.url || up.data
	await useChatSendApi({
		conversationId: activeId.value,
		msgType,
		content: msgType === 1 ? '[图片]' : '[文件]',
		fileUrl,
		fileName: file.name,
		fileSize: file.size
	}).then(res => {
		appendMine(res.data)
		loadConversations()
	})
}

const appendMine = (msg: any) => {
	upsertMessage(msg)
}

const recall = async (id: number) => {
	await useChatRecallApi(id)
	const idx = messages.value.findIndex((m: any) => m.id === id)
	if (idx >= 0) {
		messages.value[idx].status = 0
		messages.value[idx].content = '消息已撤回'
	}
	loadConversations()
}

const openDirect = () => {
	directUserId.value = undefined
	directPeer.value = null
	directVisible.value = true
}

const openDirectPicker = () => {
	pickMode.value = 'direct'
	userDialogVisible.value = true
}

const clearDirectPeer = () => {
	directUserId.value = undefined
	directPeer.value = null
}

const submitDirect = async () => {
	if (!directUserId.value) {
		ElMessage.warning('请选择用户')
		return
	}
	const res = await useChatDirectApi({ userId: directUserId.value })
	directVisible.value = false
	directPeer.value = null
	await loadConversations()
	await selectConversation(res.data)
}

const openGroup = () => {
	groupTitle.value = ''
	groupMemberIds.value = []
	groupVisible.value = true
}

const pickGroupMembers = () => {
	pickMode.value = 'group'
	userDialogVisible.value = true
}

const onUsersPicked = async (rows: any[]) => {
	if (pickMode.value === 'direct') {
		const peer = rows?.[0]
		if (!peer?.id) return
		directUserId.value = peer.id
		directPeer.value = peer
		return
	}
	const ids = rows.map(r => r.id).filter(Boolean)
	if (pickMode.value === 'group') {
		groupMemberIds.value = ids
		return
	}
	if (!activeId.value) return
	await useChatAddMembersApi({ conversationId: activeId.value, userIds: ids })
	const mres = await useChatMembersApi(activeId.value)
	members.value = mres.data || []
	ElMessage.success('已添加')
}

const submitGroup = async () => {
	if (!groupTitle.value.trim()) {
		ElMessage.warning('请输入群名称')
		return
	}
	if (!groupMemberIds.value.length) {
		ElMessage.warning('请选择成员')
		return
	}
	const res = await useChatGroupApi({ title: groupTitle.value.trim(), memberIds: groupMemberIds.value })
	groupVisible.value = false
	await loadConversations()
	await selectConversation(res.data)
}

const removeMember = async (userId: number) => {
	if (!activeId.value) return
	await ElMessageBox.confirm('确定移除该成员？', '提示')
	await useChatRemoveMembersApi({ conversationId: activeId.value, userIds: [userId] })
	const mres = await useChatMembersApi(activeId.value)
	members.value = mres.data || []
}

const dissolveActive = async () => {
	if (!activeId.value) return
	await ElMessageBox.confirm('确定解散该会话？', '提示', { type: 'warning' })
	await useChatDissolveApi(activeId.value)
	active.value = null
	activeId.value = null
	messages.value = []
	await loadConversations()
}

const scrollBottom = async () => {
	await nextTick()
	const wrap = msgScrollRef.value?.$el?.querySelector?.('.el-scrollbar__wrap')
	if (wrap) wrap.scrollTop = wrap.scrollHeight
}

const formatTime = (val?: string) => {
	if (!val) return ''
	return String(val).replace('T', ' ').slice(5, 16)
}

const formatSize = (size?: number) => {
	if (!size) return ''
	if (size < 1024) return size + ' B'
	if (size < 1024 * 1024) return (size / 1024).toFixed(1) + ' KB'
	return (size / 1024 / 1024).toFixed(1) + ' MB'
}

const roleLabel = (role?: number) => {
	if (role === 2) return '群主'
	if (role === 1) return '管理员'
	return '成员'
}

const openFile = (url?: string) => {
	if (url) window.open(url, '_blank')
}

watch(addMemberVisible, v => {
	if (v) {
		pickMode.value = 'member'
		userDialogVisible.value = true
		addMemberVisible.value = false
	}
})

onMounted(() => {
	loadConversations()
})
</script>

<style scoped lang="scss">
.chat-page {
	--ink: #122033;
	--muted: #64748b;
	--soft: #f8fbfd;
	--line: #e8eef5;
	--panel: #fff;
	--brand: #00a8e8;
	--brand-deep: #007eb8;
	--mine: #dff3ff;
	display: grid;
	grid-template-columns: 320px minmax(0, 1fr) auto;
	height: calc(100vh - 120px);
	min-height: 560px;
	background: var(--soft);
	border: 1px solid var(--line);
	border-radius: 18px;
	overflow: hidden;
	box-shadow: 0 8px 28px rgba(18, 32, 51, 0.04);
}

.chat-sidebar {
	display: flex;
	flex-direction: column;
	background: var(--panel);
	border-right: 1px solid var(--line);
}

.side-hero {
	padding: 16px 16px 10px;
	border-bottom: 1px solid rgba(0, 168, 232, 0.08);
	background: linear-gradient(145deg, color-mix(in srgb, var(--panel) 94%, transparent), color-mix(in srgb, var(--soft) 88%, transparent));
}

.side-hero-text {
	display: grid;
	gap: 2px;
	margin-bottom: 12px;
}

.kicker {
	margin: 0;
	font-size: 11px;
	font-weight: 700;
	letter-spacing: 0.04em;
	color: var(--brand-deep);
	text-transform: uppercase;
}

.side-hero-text strong {
	font-size: 18px;
	color: var(--ink);
}

.side-hero-text span {
	font-size: 12px;
	color: var(--muted);
}

.side-actions {
	display: flex;
	gap: 8px;
}

.action-btn {
	flex: 1;
	border-radius: 10px;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	gap: 4px;
}

.action-btn.primary {
	background: linear-gradient(135deg, var(--brand), #2bbef5);
	border-color: transparent;
}

.side-search {
	padding: 12px 14px 8px;

	:deep(.el-input__wrapper) {
		border-radius: 999px;
		box-shadow: 0 0 0 1px var(--line) inset;
		background: var(--soft);
	}
}

.conv-scroll {
	flex: 1;
}

.conv-item {
	display: flex;
	gap: 12px;
	padding: 12px 14px;
	cursor: pointer;
	position: relative;
	transition: background 0.18s ease;

	&::before {
		content: '';
		position: absolute;
		left: 0;
		top: 10px;
		bottom: 10px;
		width: 3px;
		border-radius: 0 4px 4px 0;
		background: transparent;
		transition: background 0.18s ease;
	}

	&:hover {
		background: rgba(0, 168, 232, 0.06);
	}

	&.active {
		background: rgba(0, 168, 232, 0.1);

		&::before {
			background: var(--brand-deep);
		}
	}
}

.avatar-wrap {
	position: relative;
	flex-shrink: 0;
}

.conv-avatar {
	border-radius: 12px !important;
	background: linear-gradient(135deg, #e8f7fd, #d5eef9);
	color: var(--brand-deep);
	font-weight: 700;
}

.type-dot {
	position: absolute;
	right: -2px;
	bottom: -2px;
	width: 10px;
	height: 10px;
	border-radius: 50%;
	background: var(--brand);
	border: 2px solid #fff;
}

.conv-body {
	min-width: 0;
	flex: 1;
}

.conv-top,
.conv-bottom {
	display: flex;
	justify-content: space-between;
	align-items: center;
	gap: 8px;
}

.conv-name {
	font-weight: 650;
	color: var(--ink);
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.conv-time,
.conv-preview {
	color: var(--muted);
	font-size: 12px;
}

.conv-preview {
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
	max-width: 170px;
	display: inline-flex;
	align-items: center;
	gap: 4px;
}

.tag {
	font-style: normal;
	font-size: 10px;
	padding: 0 4px;
	border-radius: 4px;
	background: rgba(0, 168, 232, 0.12);
	color: var(--brand-deep);
	flex-shrink: 0;
}

.badge {
	min-width: 18px;
	height: 18px;
	padding: 0 6px;
	border-radius: 999px;
	background: linear-gradient(135deg, #ff6b6b, #f56c6c);
	color: #fff;
	font-size: 11px;
	line-height: 18px;
	text-align: center;
	font-weight: 650;
	box-shadow: 0 2px 6px rgba(245, 108, 108, 0.28);
}

.chat-main {
	display: flex;
	flex-direction: column;
	min-width: 0;
	background:
		radial-gradient(1200px 400px at 10% -10%, rgba(0, 168, 232, 0.06), transparent 60%),
		linear-gradient(180deg, #f7fafc 0%, #f3f7fb 100%);
}

.main-head {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 12px 18px;
	background: color-mix(in srgb, var(--panel) 92%, transparent);
	border-bottom: 1px solid var(--line);
	backdrop-filter: blur(8px);
}

.main-title {
	display: flex;
	align-items: center;
	gap: 12px;

	strong {
		display: block;
		color: var(--ink);
		font-size: 15px;
	}
}

.type-chip {
	display: inline-flex;
	margin-top: 4px;
	padding: 2px 8px;
	border-radius: 999px;
	font-size: 11px;
	color: var(--brand-deep);
	background: rgba(0, 168, 232, 0.1);
}

.main-actions {
	display: flex;
	gap: 6px;
}

.icon-btn {
	width: 34px;
	height: 34px;
	border: 0;
	border-radius: 10px;
	background: transparent;
	color: var(--muted);
	cursor: pointer;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	transition: background 0.18s ease, color 0.18s ease;

	&:hover,
	&.on {
		background: rgba(0, 168, 232, 0.12);
		color: var(--brand-deep);
	}

	&.danger:hover {
		background: rgba(245, 108, 108, 0.12);
		color: #f56c6c;
	}
}

.msg-scroll {
	flex: 1;
	padding: 14px 18px;
}

.msg-list {
	display: flex;
	flex-direction: column;
	gap: 16px;
}

.sys-row {
	display: flex;
	justify-content: center;
}

.sys-pill {
	padding: 4px 12px;
	border-radius: 999px;
	font-size: 12px;
	color: var(--muted);
	background: rgba(148, 163, 184, 0.14);
}

.msg-row {
	display: flex;
	gap: 10px;
	align-items: flex-start;

	&.mine {
		flex-direction: row-reverse;

		.meta {
			justify-content: flex-end;
		}

		.bubble.text {
			background: linear-gradient(135deg, #dff3ff, #ccebff);
			border-radius: 14px 4px 14px 14px;
			color: var(--ink);
		}

		.msg-ops {
			text-align: right;
		}
	}
}

.bubble-wrap {
	max-width: min(68%, 520px);
}

.meta {
	display: flex;
	gap: 8px;
	margin-bottom: 4px;
	color: var(--muted);
	font-size: 12px;
}

.bubble {
	padding: 10px 14px;
	border-radius: 4px 14px 14px 14px;
	background: var(--panel);
	border: 1px solid rgba(232, 238, 245, 0.9);
	box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04);
	word-break: break-word;
	white-space: pre-wrap;
}

.bubble.media {
	padding: 4px;
	overflow: hidden;
}

.bubble.file {
	display: flex;
	align-items: center;
	gap: 10px;
	cursor: pointer;
	min-width: 180px;
	transition: border-color 0.18s ease, transform 0.18s ease;

	&:hover {
		border-color: rgba(0, 168, 232, 0.35);
		transform: translateY(-1px);
	}
}

.file-icon {
	width: 36px;
	height: 36px;
	border-radius: 10px;
	display: grid;
	place-items: center;
	background: rgba(0, 168, 232, 0.12);
	color: var(--brand-deep);
	flex-shrink: 0;
}

.file-meta {
	display: grid;
	gap: 2px;
	min-width: 0;

	strong {
		font-size: 13px;
		color: var(--ink);
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
	}

	small {
		color: var(--muted);
	}
}

.chat-img {
	width: 180px;
	height: 180px;
	border-radius: 10px;
	display: block;
}

.msg-ops {
	margin-top: 2px;
	opacity: 0;
	transition: opacity 0.15s ease;
}

.msg-row:hover .msg-ops {
	opacity: 1;
}

.composer {
	border-top: 1px solid var(--line);
	background: var(--panel);
	padding: 10px 14px 14px;
}

.composer-tools {
	display: flex;
	gap: 6px;
	margin-bottom: 8px;
}

.tool-btn {
	display: inline-flex;
	align-items: center;
	gap: 4px;
	height: 30px;
	padding: 0 10px;
	border: 0;
	border-radius: 8px;
	background: transparent;
	color: var(--muted);
	cursor: pointer;
	font-size: 13px;
	transition: background 0.18s ease, color 0.18s ease;

	&:hover {
		background: rgba(0, 168, 232, 0.1);
		color: var(--brand-deep);
	}
}

.composer-box {
	position: relative;
	border: 1px solid var(--line);
	border-radius: 14px;
	background: var(--soft);
	padding: 8px 12px 48px;

	:deep(.el-textarea__inner) {
		box-shadow: none;
		background: transparent;
		padding: 4px 0;
		line-height: 1.6;
	}
}

.send-btn {
	position: absolute;
	right: 10px;
	bottom: 10px;
	border-radius: 10px;
	min-width: 72px;
	background: linear-gradient(135deg, var(--brand), #2bbef5);
	border: 0;
}

.chat-panel {
	width: 260px;
	background: var(--panel);
	border-left: 1px solid var(--line);
	display: flex;
	flex-direction: column;
}

.panel-head {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 14px 14px 12px;
	border-bottom: 1px solid var(--line);

	strong {
		display: block;
		color: var(--ink);
	}

	span {
		font-size: 12px;
		color: var(--muted);
	}
}

.member-row {
	display: flex;
	align-items: center;
	gap: 10px;
	padding: 10px 14px;
	transition: background 0.15s ease;

	&:hover {
		background: rgba(0, 168, 232, 0.06);
	}
}

.member-body {
	flex: 1;
	min-width: 0;
	display: grid;
	gap: 4px;
}

.member-name {
	font-size: 13px;
	color: var(--ink);
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.role-chip {
	display: inline-flex;
	width: fit-content;
	padding: 1px 7px;
	border-radius: 999px;
	font-size: 11px;
	background: rgba(148, 163, 184, 0.16);
	color: var(--muted);

	&.r2 {
		background: rgba(0, 168, 232, 0.14);
		color: var(--brand-deep);
	}

	&.r1 {
		background: rgba(103, 194, 58, 0.14);
		color: #529b2e;
	}
}

.main-empty,
.empty-hint {
	display: grid;
	place-content: center;
	justify-items: center;
	gap: 6px;
	padding: 40px 24px;
	text-align: center;
	color: var(--muted);

	p {
		margin: 0;
		font-size: 14px;
		color: var(--ink);
		font-weight: 600;
	}

	small {
		font-size: 12px;
	}
}

.empty-icon {
	width: 56px;
	height: 56px;
	border-radius: 16px;
	display: grid;
	place-items: center;
	margin-bottom: 6px;
	background: rgba(0, 168, 232, 0.1);
	color: var(--brand-deep);
	font-size: 22px;
}

.load-more {
	text-align: center;
	padding: 8px;
	color: var(--brand-deep);
	cursor: pointer;
	font-size: 13px;

	&:hover {
		text-decoration: underline;
	}
}

.dlg-head {
	display: flex;
	align-items: flex-start;
	gap: 12px;

	strong {
		display: block;
		font-size: 16px;
		color: var(--ink);
	}

	p {
		margin: 4px 0 0;
		font-size: 12px;
		color: var(--muted);
	}
}

.dlg-icon {
	width: 40px;
	height: 40px;
	border-radius: 12px;
	display: grid;
	place-items: center;
	background: rgba(0, 168, 232, 0.12);
	color: var(--brand-deep);
	flex-shrink: 0;

	&.group {
		background: rgba(0, 126, 184, 0.12);
	}
}

.dlg-body {
	display: grid;
	gap: 8px;
}

.dlg-label {
	font-size: 13px;
	font-weight: 600;
	color: var(--ink);

	&.mt {
		margin-top: 10px;
	}
}

.member-picker {
	display: grid;
	gap: 10px;
}

.picked-bar {
	display: flex;
	align-items: center;
	justify-content: space-between;
	padding: 10px 12px;
	border-radius: 12px;
	background: var(--soft);
	border: 1px dashed var(--line);
}

.picked-chip {
	font-size: 13px;
	color: var(--brand-deep);
	font-weight: 650;
}

.direct-body {
	gap: 14px;
}

.peer-empty {
	width: 100%;
	display: flex;
	align-items: center;
	gap: 12px;
	padding: 16px;
	border: 1px dashed rgba(0, 168, 232, 0.35);
	border-radius: 14px;
	background: linear-gradient(145deg, rgba(0, 168, 232, 0.06), rgba(248, 251, 253, 0.9));
	cursor: pointer;
	text-align: left;
	transition: border-color 0.18s ease, transform 0.18s ease, box-shadow 0.18s ease;

	&:hover {
		border-color: var(--brand);
		transform: translateY(-1px);
		box-shadow: 0 8px 20px rgba(0, 126, 184, 0.08);
	}
}

.peer-empty-icon {
	width: 44px;
	height: 44px;
	border-radius: 12px;
	display: grid;
	place-items: center;
	background: rgba(0, 168, 232, 0.14);
	color: var(--brand-deep);
	flex-shrink: 0;
	font-size: 18px;
}

.peer-empty-text {
	flex: 1;
	min-width: 0;
	display: grid;
	gap: 2px;

	strong {
		color: var(--ink);
		font-size: 14px;
	}

	small {
		color: var(--muted);
		font-size: 12px;
	}
}

.peer-empty-action {
	padding: 6px 12px;
	border-radius: 999px;
	font-size: 12px;
	font-weight: 650;
	color: #fff;
	background: linear-gradient(135deg, var(--brand), #2bbef5);
	flex-shrink: 0;
}

.peer-card {
	display: flex;
	align-items: center;
	gap: 12px;
	padding: 14px;
	border-radius: 14px;
	border: 1px solid rgba(0, 168, 232, 0.18);
	background: linear-gradient(145deg, #fff, #f4fbff);
}

.peer-info {
	flex: 1;
	min-width: 0;
	display: grid;
	gap: 2px;

	strong {
		color: var(--ink);
		font-size: 15px;
	}

	span {
		color: var(--muted);
		font-size: 12px;
	}

	em {
		font-style: normal;
		font-size: 12px;
		color: var(--brand-deep);
	}
}

.peer-ops {
	display: flex;
	flex-direction: column;
	align-items: flex-end;
	gap: 2px;
}

.direct-tips {
	margin: 0;
	padding: 10px 12px 10px 28px;
	border-radius: 12px;
	background: var(--soft);
	color: var(--muted);
	font-size: 12px;
	line-height: 1.7;
}
</style>

<style lang="scss">
.chat-dialog.el-dialog {
	border-radius: 18px;
	overflow: hidden;

	.el-dialog__header {
		margin: 0;
		padding: 18px 20px 8px;
	}

	.el-dialog__body {
		padding: 8px 20px 12px;
	}

	.el-dialog__footer {
		padding: 12px 20px 18px;
	}

	&.direct-dialog {
		.el-dialog__header {
			padding: 20px 22px 10px;
			background: linear-gradient(180deg, rgba(0, 168, 232, 0.08), transparent);
		}

		.el-dialog__footer {
			.direct-submit {
				min-width: 108px;
				border-radius: 10px;
				border: 0;
				background: linear-gradient(135deg, #00a8e8, #2bbef5);
			}
		}
	}
}
</style>
