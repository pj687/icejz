<template>
	<Teleport to="body">
		<transition name="assistant-fade">
			<div v-if="assistantStore.open" class="assistant-mask" @click="assistantStore.closePanel()"></div>
		</transition>

		<transition name="assistant-slide">
			<aside
				v-if="assistantStore.open"
				class="assistant-panel"
				:class="{ 'with-history': !guest && showHistory }"
				role="dialog"
				aria-label="ICEJZ 小冰助手"
			>
				<div class="panel-glow" aria-hidden="true"></div>

				<div class="panel-shell">
					<aside v-if="!guest && showHistory" class="history-pane">
						<div class="history-head">
							<strong>历史对话</strong>
							<button type="button" class="text-btn tiny" :disabled="loading" @click="startNewChat">新对话</button>
						</div>
						<div v-if="sessionsLoading" class="history-empty">加载中…</div>
						<div v-else-if="!sessions.length" class="history-empty">还没有历史，发一条消息开始吧</div>
						<ul v-else class="session-list">
							<li
								v-for="item in sessions"
								:key="item.id"
								:class="{ active: item.id === currentSessionId }"
								@click="openSession(item.id)"
							>
								<div class="session-main">
									<strong>{{ item.title || '新对话' }}</strong>
									<em>{{ formatSessionTime(item.lastMsgTime || item.createTime) }}</em>
								</div>
								<button
									type="button"
									class="session-del"
									title="删除"
									@click.stop="removeSession(item.id)"
								>
									删
								</button>
							</li>
						</ul>
					</aside>

					<div class="chat-pane">
						<header class="panel-head">
							<div class="head-main">
								<div class="avatar-wrap">
									<IceBotMascot size="sm" :bounce="loading" />
								</div>
								<div class="head-copy">
									<div class="title-row">
										<strong>{{ assistantStore.robotName }}</strong>
										<span class="status-pill" :class="{ busy: loading }">
											<i class="online-dot"></i>
											{{ loading ? '思考中' : '在线' }}
										</span>
									</div>
									<em>ICEJZ 平台智能助手 · 随时为你服务</em>
								</div>
							</div>
							<div class="head-actions">
								<button
									v-if="!guest"
									type="button"
									class="text-btn"
									:class="{ on: showHistory }"
									@click="toggleHistory"
								>
									历史
								</button>
								<button
									v-if="!guest"
									type="button"
									class="text-btn"
									:disabled="loading"
									@click="startNewChat"
								>
									新对话
								</button>
								<button
									v-if="messages.length"
									type="button"
									class="text-btn"
									@click="clearChat"
								>
									清空
								</button>
								<button type="button" class="icon-btn" aria-label="关闭" @click="assistantStore.closePanel()">×</button>
							</div>
						</header>

						<div ref="listRef" class="msg-list">
							<div class="msg assistant">
								<img class="msg-avatar" src="/mascot/xiaobing-main.png?v=6" alt="" />
								<div class="bubble">
									<p class="greet-line">{{ panelHello }}</p>
									<p>
										{{
											guest
												? '我是小冰，登录前也能陪你聊聊～有登录问题尽管问我。'
												: assistantStore.welcome
										}}
									</p>
								</div>
							</div>

							<div v-for="(msg, idx) in messages" :key="idx" class="msg" :class="msg.role">
								<img v-if="msg.role === 'assistant'" class="msg-avatar" src="/mascot/xiaobing-main.png?v=6" alt="" />
								<div class="bubble">{{ msg.content }}</div>
							</div>

							<div v-if="loading" class="msg assistant">
								<img class="msg-avatar" src="/mascot/xiaobing-main.png?v=6" alt="" />
								<div class="bubble typing">
									<span></span><span></span><span></span>
								</div>
							</div>

							<div v-if="!messages.length && !loading" class="quick-chips">
								<button
									v-for="chip in quickasks"
									:key="chip"
									type="button"
									class="chip"
									@click="askChip(chip)"
								>
									{{ chip }}
								</button>
							</div>
						</div>

						<footer class="panel-foot">
							<div class="composer">
								<textarea
									v-model="input"
									rows="3"
									:placeholder="
										guest
											? '登录前也可以问我，例如：怎么登录？为什么要勾选协议？'
											: '问问小冰，例如：怎么生成业务代码？怎么配置用户权限？'
									"
									@keydown.enter.exact.prevent="send"
								></textarea>
								<div class="composer-bar">
									<span class="foot-hint">
										{{ guest ? 'Enter 发送 · Shift+Enter 换行' : '对话已云端保存 · Enter 发送' }}
									</span>
									<button type="button" class="send-btn" :disabled="loading || !input.trim()" @click="send">
										<span>{{ loading ? '发送中' : '发送' }}</span>
										<svg viewBox="0 0 24 24" aria-hidden="true">
											<path
												d="M4.5 12.5 19 5l-5.2 14.2-2.3-5.1L4.5 12.5Z"
												fill="currentColor"
											/>
										</svg>
									</button>
								</div>
							</div>
						</footer>
					</div>
				</div>
			</aside>
		</transition>
	</Teleport>
</template>

<script setup lang="ts">
import { computed, nextTick, onMounted, ref, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import IceBotMascot from './IceBotMascot.vue'
import { useAssistantStore } from '@/store/modules/assistant'
import { useUserStore } from '@/store/modules/user'
import {
	useAiChatApi,
	useAiChatSessionDeleteApi,
	useAiChatSessionListApi,
	useAiChatSessionMessagesApi,
	useAiRobotInfoApi,
	type AiChatSession
} from '@/api/sys/ai'
import { getGreetHello, getTimeHello } from './greetings'

/** 将上游鉴权等原始错误转成对话里可读的提示 */
const formatAssistantError = (raw: string) => {
	const text = (raw || '').trim()
	if (!text) {
		return '小冰暂时连不上模型。请技术人员到「系统配置 · AI助手」检查模型是否启用、API Key 是否填写正确。'
	}
	const lower = text.toLowerCase()
	if (
		lower.includes('authentication fails') ||
		lower.includes('governor') ||
		text.includes('鉴权失败') ||
		text.includes('(401)')
	) {
		return (
			'模型鉴权失败啦～多半是 API Key 没填、填错或已失效（DeepSeek 常见提示 Authentication Fails）。\n' +
			'请到「系统配置 · AI助手」打开当前默认模型，补全/更新 API Key，保存后再试。\n' +
			'（这和系统提示词无关，改提示词解决不了 401。）'
		)
	}
	if (text.includes('额度不足') || lower.includes('402')) {
		return '模型账户额度不足，请到服务商控制台充值，或切换到其它可用模型。'
	}
	if (text.includes('过于频繁') || lower.includes('429')) {
		return '请求太频繁了，稍等一会儿再问我吧。'
	}
	return text
}

const props = withDefaults(
	defineProps<{
		/** 登录页等未登录场景：本地应答，不调需鉴权接口 */
		guest?: boolean
	}>(),
	{ guest: false }
)

type ChatMsg = { role: 'user' | 'assistant'; content: string }

const assistantStore = useAssistantStore()
const userStore = useUserStore()
const messages = ref<ChatMsg[]>([])
const input = ref('')
const loading = ref(false)
const listRef = ref<HTMLElement | null>(null)
const showHistory = ref(true)
const sessions = ref<AiChatSession[]>([])
const sessionsLoading = ref(false)
const currentSessionId = ref<number | null>(null)

const guestName = '朋友'
const panelHello = computed(() =>
	getTimeHello(props.guest ? guestName : userStore.user?.realName || '管理员')
)
const quickasks = computed(() =>
	props.guest
		? ['怎么登录？', '账号和手机怎么选？', '为什么要勾选协议？', '跟我打个招呼吧']
		: ['怎么打开工作台？', '如何生成业务代码？', '用户权限怎么配？', '跟我打个招呼吧']
)

const guestReply = (text: string) => {
	const q = text.toLowerCase()
	if (/招呼|你好|hello|hi|嗨/.test(q)) return getGreetHello(guestName)
	if (/协议|同意|勾选/.test(q)) {
		return '登录前需要阅读并勾选下方协议，勾选后即可使用账号或手机号登录～'
	}
	if (/手机|验证码|短信/.test(q)) {
		return '切换到「手机登录」页签，输入手机号获取验证码即可。若收不到验证码，稍后再试或联系管理员。'
	}
	if (/账号|密码|登录|登入|signin|login/.test(q)) {
		return '在右侧选择「账号登录」，输入账号和密码；也可以用「手机登录」。勾选协议后点登录就能进入控制台。'
	}
	if (/工作台|代码|权限|菜单|生成/.test(q)) {
		return '这些能力登录后就能用啦。先完成登录，我在控制台里继续帮你～'
	}
	return '登录页我可以陪你互动、答登录相关问题。完整平台助手能力，登录后即可解锁哦～'
}

const formatSessionTime = (raw?: string) => {
	if (!raw) return ''
	const m = raw.match(/(\d{2}-\d{2})\s+(\d{2}:\d{2})/)
	if (m) return `${m[1]} ${m[2]}`
	return raw.slice(5, 16)
}

const scrollBottom = async () => {
	await nextTick()
	if (listRef.value) {
		listRef.value.scrollTop = listRef.value.scrollHeight
	}
}

const loadProfile = async () => {
	if (props.guest) {
		assistantStore.setRobotProfile({
			name: '小冰',
			welcome: '登录前我也能陪你互动，登录后解锁完整助手能力～'
		})
		return
	}
	try {
		const { data } = await useAiRobotInfoApi()
		assistantStore.setRobotProfile({
			name: data?.name,
			welcome: data?.welcome
		})
	} catch {
		// keep defaults when backend not ready
	}
}

const loadSessions = async (preferId?: number | null) => {
	if (props.guest) return
	sessionsLoading.value = true
	try {
		const { data } = await useAiChatSessionListApi()
		sessions.value = Array.isArray(data) ? data : []
		const target =
			preferId && sessions.value.some(s => s.id === preferId)
				? preferId
				: currentSessionId.value && sessions.value.some(s => s.id === currentSessionId.value)
					? currentSessionId.value
					: sessions.value[0]?.id || null
		if (target) {
			if (target !== currentSessionId.value || !messages.value.length) {
				await openSession(target, false)
			}
		} else {
			currentSessionId.value = null
			messages.value = []
		}
	} catch {
		sessions.value = []
	} finally {
		sessionsLoading.value = false
	}
}

const openSession = async (id: number, closeIfSame = true) => {
	if (props.guest || loading.value) return
	if (closeIfSame && id === currentSessionId.value) return
	try {
		const { data } = await useAiChatSessionMessagesApi(id)
		currentSessionId.value = id
		messages.value = (Array.isArray(data) ? data : [])
			.filter((m: any) => m?.role === 'user' || m?.role === 'assistant')
			.map((m: any) => ({ role: m.role, content: m.content }))
		await scrollBottom()
	} catch {
		ElMessage.warning('加载会话失败')
	}
}

const startNewChat = () => {
	if (loading.value) return
	currentSessionId.value = null
	messages.value = []
	input.value = ''
}

const clearChat = () => {
	messages.value = []
	input.value = ''
	if (!props.guest) {
		currentSessionId.value = null
	}
}

const toggleHistory = () => {
	showHistory.value = !showHistory.value
}

const removeSession = async (id: number) => {
	try {
		await ElMessageBox.confirm('确定删除这条历史对话吗？', '提示', { type: 'warning' })
		await useAiChatSessionDeleteApi([id])
		if (currentSessionId.value === id) {
			currentSessionId.value = null
			messages.value = []
		}
		await loadSessions()
		ElMessage.success('已删除')
	} catch {
		// cancelled or failed
	}
}

const askChip = (text: string) => {
	input.value = text
	send()
}

const send = async () => {
	const text = input.value.trim()
	if (!text || loading.value) return

	messages.value.push({ role: 'user', content: text })
	input.value = ''
	assistantStore.draft = ''
	loading.value = true
	await scrollBottom()

	try {
		if (props.guest) {
			await new Promise(r => window.setTimeout(r, 280))
			messages.value.push({ role: 'assistant', content: guestReply(text) })
		} else {
			const history = messages.value.slice(0, -1).slice(-8).map(m => ({ role: m.role, content: m.content }))
			const { data } = await useAiChatApi({
				message: text,
				sessionId: currentSessionId.value,
				history
			})
			if (data?.sessionId) {
				currentSessionId.value = data.sessionId
			}
			messages.value.push({ role: 'assistant', content: data?.content || '小冰暂时没有想好怎么回答～' })
			await loadSessions(currentSessionId.value)
		}
	} catch (e: any) {
		const raw = e?.msg || e?.message || ''
		const tip = formatAssistantError(raw)
		messages.value.push({ role: 'assistant', content: tip })
		ElMessage.warning(tip.length > 80 ? tip.slice(0, 80) + '…' : tip)
	} finally {
		loading.value = false
		await scrollBottom()
	}
}

watch(
	() => assistantStore.open,
	async val => {
		if (val) {
			await loadProfile()
			if (!props.guest) {
				await loadSessions()
			}
			if (assistantStore.draft) {
				input.value = assistantStore.draft
				assistantStore.draft = ''
				await nextTick()
				await send()
			} else {
				await scrollBottom()
			}
		}
	}
)

onMounted(loadProfile)
</script>

<style scoped lang="scss">
.assistant-mask {
	position: fixed;
	inset: 0;
	z-index: 3000;
	background: rgba(10, 22, 38, 0.32);
	backdrop-filter: blur(6px);
}

.assistant-panel {
	position: fixed;
	right: max(20px, 2vw);
	bottom: max(16px, 2vh);
	z-index: 3001;
	width: min(560px, calc(100vw - 28px));
	height: min(820px, calc(100vh - 36px));
	display: flex;
	flex-direction: column;
	border-radius: 28px;
	overflow: hidden;
	isolation: isolate;
	background: linear-gradient(165deg, rgba(255, 255, 255, 0.97), rgba(236, 247, 253, 0.94));
	border: 1px solid rgba(0, 168, 232, 0.2);
	box-shadow:
		0 32px 72px rgba(8, 40, 64, 0.2),
		0 0 0 1px rgba(255, 255, 255, 0.6) inset;
	backdrop-filter: blur(22px);
	transition: width 0.22s ease;

	&.with-history {
		width: min(820px, calc(100vw - 28px));
	}
}

.panel-glow {
	position: absolute;
	top: -100px;
	right: -60px;
	width: 280px;
	height: 280px;
	border-radius: 50%;
	background: radial-gradient(circle, rgba(0, 168, 232, 0.24), transparent 68%);
	pointer-events: none;
	z-index: 0;
}

.panel-shell {
	position: relative;
	z-index: 1;
	display: flex;
	flex: 1;
	min-height: 0;
}

.history-pane {
	width: 220px;
	flex-shrink: 0;
	display: flex;
	flex-direction: column;
	border-right: 1px solid rgba(0, 168, 232, 0.12);
	background: linear-gradient(180deg, rgba(226, 245, 253, 0.72), rgba(255, 255, 255, 0.4));
}

.history-head {
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 8px;
	padding: 16px 12px 12px;

	strong {
		font-size: 13px;
		font-weight: 760;
		color: #0f1724;
	}
}

.history-empty {
	padding: 24px 14px;
	font-size: 12px;
	line-height: 1.6;
	color: #7b8b9c;
	text-align: center;
}

.session-list {
	list-style: none;
	margin: 0;
	padding: 0 8px 12px;
	overflow: auto;
	flex: 1;
	display: flex;
	flex-direction: column;
	gap: 6px;
}

.session-list li {
	display: flex;
	align-items: center;
	gap: 6px;
	padding: 10px 10px;
	border-radius: 14px;
	cursor: pointer;
	border: 1px solid transparent;
	transition: background 0.15s ease, border-color 0.15s ease;

	&:hover {
		background: rgba(255, 255, 255, 0.72);
		border-color: rgba(0, 168, 232, 0.12);
	}

	&.active {
		background: rgba(0, 168, 232, 0.12);
		border-color: rgba(0, 168, 232, 0.2);
	}
}

.session-main {
	min-width: 0;
	flex: 1;

	strong {
		display: block;
		font-size: 12.5px;
		font-weight: 700;
		color: #122033;
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
	}

	em {
		display: block;
		margin-top: 4px;
		font-style: normal;
		font-size: 11px;
		color: #8a9aab;
	}
}

.session-del {
	width: 26px;
	height: 26px;
	border: none;
	border-radius: 8px;
	background: transparent;
	color: #94a3b8;
	font-size: 11px;
	font-weight: 700;
	cursor: pointer;
	flex-shrink: 0;

	&:hover {
		background: rgba(239, 68, 68, 0.1);
		color: #dc2626;
	}
}

.chat-pane {
	flex: 1;
	min-width: 0;
	display: flex;
	flex-direction: column;
}

.panel-head,
.msg-list,
.panel-foot {
	position: relative;
	z-index: 1;
}

.panel-head {
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 12px;
	padding: 16px 18px 14px;
	background: linear-gradient(180deg, rgba(226, 245, 253, 0.95), rgba(255, 255, 255, 0.35));
	border-bottom: 1px solid rgba(0, 168, 232, 0.12);
}

.head-main {
	display: flex;
	align-items: center;
	gap: 14px;
	min-width: 0;
}

.avatar-wrap {
	width: 58px;
	height: 58px;
	border-radius: 18px;
	display: grid;
	place-items: center;
	background: radial-gradient(circle at 35% 30%, #fff 0%, #eef8fd 70%);
	border: 1px solid rgba(0, 168, 232, 0.16);
	box-shadow: 0 10px 22px rgba(0, 120, 170, 0.14);
	overflow: hidden;
	flex-shrink: 0;
}

.head-copy {
	min-width: 0;
}

.title-row {
	display: flex;
	align-items: center;
	gap: 10px;

	strong {
		font-size: 18px;
		font-weight: 760;
		color: #0f1724;
	}
}

.status-pill {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	height: 24px;
	padding: 0 10px;
	border-radius: 999px;
	font-size: 11px;
	font-weight: 700;
	color: #15803d;
	background: rgba(34, 197, 94, 0.12);
	border: 1px solid rgba(34, 197, 94, 0.2);

	&.busy {
		color: #007eb8;
		background: rgba(0, 168, 232, 0.12);
		border-color: rgba(0, 168, 232, 0.22);
	}
}

.online-dot {
	width: 7px;
	height: 7px;
	border-radius: 50%;
	background: #22c55e;
	box-shadow: 0 0 0 3px rgba(34, 197, 94, 0.16);

	.status-pill.busy & {
		background: #00a8e8;
		box-shadow: 0 0 0 3px rgba(0, 168, 232, 0.18);
		animation: pulse-dot 1s ease-in-out infinite;
	}
}

.head-copy em {
	display: block;
	margin-top: 4px;
	font-style: normal;
	font-size: 12.5px;
	color: #6b7c8f;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
	max-width: 280px;
}

.head-actions {
	display: flex;
	align-items: center;
	gap: 8px;
	flex-shrink: 0;
}

.text-btn {
	height: 34px;
	padding: 0 12px;
	border: none;
	border-radius: 11px;
	background: rgba(15, 23, 36, 0.04);
	color: #64748b;
	font-size: 12px;
	font-weight: 700;
	cursor: pointer;

	&.tiny {
		height: 28px;
		padding: 0 10px;
		font-size: 11px;
	}

	&.on,
	&:hover {
		background: rgba(0, 168, 232, 0.1);
		color: #007eb8;
	}

	&:disabled {
		opacity: 0.45;
		cursor: not-allowed;
	}
}

.icon-btn {
	width: 36px;
	height: 36px;
	border: none;
	border-radius: 12px;
	background: rgba(15, 23, 36, 0.05);
	font-size: 20px;
	line-height: 1;
	cursor: pointer;
	color: #64748b;
	transition: background 0.15s ease, color 0.15s ease;

	&:hover {
		background: rgba(0, 168, 232, 0.12);
		color: #007eb8;
	}
}

.msg-list {
	flex: 1;
	overflow: auto;
	padding: 20px 18px 14px;
	display: flex;
	flex-direction: column;
	gap: 14px;
	background:
		radial-gradient(640px 260px at 8% 0%, rgba(0, 168, 232, 0.07), transparent 55%),
		radial-gradient(520px 220px at 100% 100%, rgba(47, 191, 164, 0.06), transparent 50%);
}

.msg {
	display: flex;
	align-items: flex-end;
	gap: 10px;
	animation: msg-in 0.22s ease both;

	&.user {
		justify-content: flex-end;

		.bubble {
			background: linear-gradient(135deg, #00a8e8, #2bbef5);
			color: #fff;
			border-bottom-right-radius: 6px;
			box-shadow: 0 10px 22px rgba(0, 168, 232, 0.24);
		}
	}

	&.assistant,
	&.bot {
		justify-content: flex-start;

		.bubble {
			background: rgba(255, 255, 255, 0.94);
			color: #1e293b;
			border: 1px solid rgba(0, 168, 232, 0.12);
			border-bottom-left-radius: 6px;
			box-shadow: 0 8px 18px rgba(15, 23, 36, 0.05);
		}
	}
}

.msg-avatar {
	width: 32px;
	height: 32px;
	border-radius: 50%;
	object-fit: cover;
	background: #eef8fd;
	border: 1px solid rgba(0, 168, 232, 0.14);
	flex-shrink: 0;
}

.bubble {
	max-width: 82%;
	padding: 12px 14px;
	border-radius: 18px;
	font-size: 14px;
	line-height: 1.7;
	white-space: pre-wrap;
	word-break: break-word;

	p {
		margin: 0;
	}
	.greet-line {
		margin-bottom: 8px;
		font-weight: 750;
		color: #007eb8;
	}
}

.typing {
	display: inline-flex;
	gap: 5px;
	align-items: center;
	min-width: 52px;
	min-height: 22px;

	span {
		width: 7px;
		height: 7px;
		border-radius: 50%;
		background: #00a8e8;
		animation: blink 1s infinite ease-in-out;

		&:nth-child(2) {
			animation-delay: 0.15s;
		}
		&:nth-child(3) {
			animation-delay: 0.3s;
		}
	}
}

.quick-chips {
	display: flex;
	flex-wrap: wrap;
	gap: 8px;
	padding: 4px 0 2px;
}

.chip {
	height: 34px;
	padding: 0 14px;
	border-radius: 999px;
	border: 1px solid rgba(0, 168, 232, 0.16);
	background: rgba(255, 255, 255, 0.88);
	color: #0f4f6e;
	font-size: 12.5px;
	font-weight: 650;
	cursor: pointer;
	transition: background 0.15s ease, border-color 0.15s ease, transform 0.12s ease;

	&:hover {
		background: rgba(0, 168, 232, 0.1);
		border-color: rgba(0, 168, 232, 0.28);
		transform: translateY(-1px);
	}
}

.panel-foot {
	padding: 14px 16px 16px;
	border-top: 1px solid rgba(0, 168, 232, 0.12);
	background: rgba(255, 255, 255, 0.62);
}

.composer {
	display: flex;
	flex-direction: column;
	gap: 8px;
	padding: 12px 12px 10px;
	border-radius: 18px;
	background: rgba(255, 255, 255, 0.92);
	border: 1px solid rgba(0, 168, 232, 0.14);
	box-shadow: 0 10px 24px rgba(15, 23, 36, 0.05);
	transition: border-color 0.15s ease, box-shadow 0.15s ease;

	&:focus-within {
		border-color: rgba(0, 168, 232, 0.42);
		box-shadow: 0 0 0 3px rgba(0, 168, 232, 0.12);
	}

	textarea {
		resize: none;
		border: none;
		outline: none;
		background: transparent;
		padding: 4px 4px 0;
		font: inherit;
		font-size: 14px;
		line-height: 1.6;
		color: #122033;
		min-height: 72px;

		&::placeholder {
			color: #94a3b8;
		}
	}
}

.composer-bar {
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 12px;
}

.send-btn {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	min-width: 92px;
	height: 40px;
	padding: 0 14px;
	border: none;
	border-radius: 12px;
	color: #fff;
	font-weight: 700;
	font-size: 13px;
	cursor: pointer;
	background: linear-gradient(135deg, #00a8e8, #2bbef5);
	box-shadow: 0 8px 16px rgba(0, 168, 232, 0.25);
	transition: transform 0.12s ease, opacity 0.12s ease;

	svg {
		width: 14px;
		height: 14px;
	}

	&:hover:not(:disabled) {
		transform: translateY(-1px);
	}

	&:disabled {
		opacity: 0.45;
		cursor: not-allowed;
		box-shadow: none;
	}
}

.foot-hint {
	font-size: 11.5px;
	color: #94a3b8;
}

@media (max-width: 900px) {
	.assistant-panel.with-history {
		width: min(560px, calc(100vw - 28px));
	}

	.history-pane {
		position: absolute;
		left: 0;
		top: 0;
		bottom: 0;
		z-index: 5;
		box-shadow: 8px 0 24px rgba(8, 40, 64, 0.12);
	}
}

@media (max-width: 640px) {
	.assistant-panel {
		right: 10px;
		bottom: 10px;
		width: calc(100vw - 20px);
		height: calc(100vh - 20px);
		border-radius: 22px;

		&.with-history {
			width: calc(100vw - 20px);
		}
	}
}

.assistant-fade-enter-active,
.assistant-fade-leave-active {
	transition: opacity 0.2s ease;
}
.assistant-fade-enter-from,
.assistant-fade-leave-to {
	opacity: 0;
}

.assistant-slide-enter-active,
.assistant-slide-leave-active {
	transition: transform 0.26s cubic-bezier(0.22, 1, 0.36, 1), opacity 0.26s ease;
}
.assistant-slide-enter-from,
.assistant-slide-leave-to {
	opacity: 0;
	transform: translateY(20px) scale(0.97);
}

@keyframes blink {
	0%,
	80%,
	100% {
		opacity: 0.35;
		transform: translateY(0);
	}
	40% {
		opacity: 1;
		transform: translateY(-2px);
	}
}

@keyframes pulse-dot {
	0%,
	100% {
		transform: scale(1);
		opacity: 1;
	}
	50% {
		transform: scale(0.85);
		opacity: 0.7;
	}
}

@keyframes msg-in {
	from {
		opacity: 0;
		transform: translateY(6px);
	}
	to {
		opacity: 1;
		transform: none;
	}
}
</style>
