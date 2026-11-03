<template>
	<div class="workbench-page">
		<header class="wb-top">
			<div class="wb-intro">
				<p class="wb-kicker">{{ weekDay }} · {{ todayLabel }}</p>
				<h1>我的工作台</h1>
				<p class="wb-lead">把今天的任务、进度和记事放在一起，按优先级推进。</p>
			</div>

			<div class="wb-metrics" aria-label="工作台概览">
				<div class="metric">
					<span>进行中</span>
					<strong>{{ projects.length }}</strong>
				</div>
				<div class="metric">
					<span>待办</span>
					<strong>{{ todos.length }}</strong>
				</div>
				<div class="metric">
					<span>消息</span>
					<strong>{{ messages.length }}</strong>
				</div>
				<div class="metric">
					<span>记事</span>
					<strong>{{ notes.length }}</strong>
				</div>
			</div>

			<button class="btn-ghost" type="button" @click="go('/dashboard/index')">返回首页</button>
		</header>

		<section class="wb-grid">
			<aside class="rail">
				<div class="profile">
					<img class="avatar" :src="userStore.user.avatar || constant.defaultAvatar" alt="avatar" />
					<div class="profile-copy">
						<strong>{{ userStore.user.realName || '管理员' }}</strong>
						<em>{{ userStore.user.username || 'admin' }}</em>
						<span class="online"><i></i>在线</span>
					</div>
				</div>

				<nav class="quick-nav" aria-label="快捷入口">
					<button type="button" @click="go('/profile')">
						<ma-icon icon="icon-user" />
						资料
					</button>
					<button type="button" @click="go('/sys/user/index')">
						<ma-icon icon="icon-message-fill" />
						用户
					</button>
					<button type="button" @click="go('/iframe/53')">
						<ma-icon icon="icon-code" />
						生成
					</button>
					<button type="button" @click="go('/sys/menu/index')">
						<ma-icon icon="icon-setting" />
						菜单
					</button>
				</nav>

				<dl class="info-list">
					<div>
						<dt>姓名</dt>
						<dd>{{ userStore.user.realName || '管理员' }}</dd>
					</div>
					<div>
						<dt>账号</dt>
						<dd>{{ userStore.user.username || 'admin' }}</dd>
					</div>
					<div>
						<dt>邮箱</dt>
						<dd>{{ userStore.user.email || '未设置' }}</dd>
					</div>
					<div>
						<dt>手机</dt>
						<dd>{{ userStore.user.mobile || '未设置' }}</dd>
					</div>
				</dl>
			</aside>

			<div class="main-col">
				<section class="block focus-block">
					<header class="block-head">
						<div>
							<h2>进行中的事项</h2>
							<p>按优先级推进今日关键交付</p>
						</div>
						<span class="chip">{{ projects.length }} 项</span>
					</header>

					<div class="project-list">
						<article v-for="item in projects" :key="item.id" class="project-row" :data-tone="item.tone">
							<div class="project-main">
								<div class="project-title">
									<strong>{{ item.title }}</strong>
									<span>{{ item.daysLeft }} 天</span>
								</div>
								<p>{{ item.desc }}</p>
								<div class="progress" :aria-label="item.title + ' ' + item.percent + '%'">
									<div class="track"><i :style="{ width: item.percent + '%' }"></i></div>
									<em>{{ item.percent }}%</em>
								</div>
							</div>
							<button type="button" class="btn-enter" @click="go(item.path)">进入</button>
						</article>
					</div>
				</section>

				<section class="block calendar-block">
					<header class="block-head">
						<div>
							<h2>{{ monthLabel }}</h2>
							<p>点选日期，添加记事与叮嘱</p>
						</div>
						<div class="cal-nav">
							<button type="button" class="icon-btn" title="上一月" @click="shiftMonth(-1)">‹</button>
							<button type="button" class="icon-btn" title="下一月" @click="shiftMonth(1)">›</button>
						</div>
					</header>

					<div class="cal-grid">
						<span v-for="w in weeks" :key="w" class="w">{{ w }}</span>
						<button
							v-for="day in calendarDays"
							:key="day.key"
							type="button"
							class="day"
							:class="{
								mute: !day.current,
								today: day.today,
								has: day.hasNote,
								active: day.dateKey === selectedDateKey
							}"
							:disabled="!day.current"
							@click="selectDay(day)"
						>
							{{ day.n }}
							<i v-if="day.hasNote" class="dot" aria-hidden="true"></i>
						</button>
					</div>

					<div class="note-board">
						<div class="note-head">
							<div>
								<strong>{{ selectedDateLabel }}</strong>
								<em>{{ selectedNotes.length ? `${selectedNotes.length} 条记事` : '暂无记事' }}</em>
							</div>
							<div class="note-tabs" role="tablist">
								<button
									v-for="t in noteTypes"
									:key="t.key"
									type="button"
									role="tab"
									:aria-selected="draftType === t.key"
									:class="{ active: draftType === t.key }"
									@click="draftType = t.key"
								>
									{{ t.label }}
								</button>
							</div>
						</div>

						<ul v-if="selectedNotes.length" class="note-list">
							<li v-for="note in selectedNotes" :key="note.id" :data-type="note.type">
								<span class="note-tag">{{ noteTypeLabel(note.type) }}</span>
								<div class="note-body">
									<p>{{ note.text }}</p>
									<em>{{ note.createdAt }}</em>
								</div>
								<button type="button" class="note-del" title="删除" @click="removeNote(note.id)">删除</button>
							</li>
						</ul>
						<div v-else class="note-empty">这一天还没有叮嘱，写一句给未来的自己吧</div>

						<div class="note-composer">
							<textarea
								v-model="draftText"
								rows="2"
								maxlength="120"
								:placeholder="draftPlaceholder"
								@keydown.enter.exact.prevent="addNote"
							/>
							<div class="composer-foot">
								<span>{{ draftText.length }}/120</span>
								<button type="button" class="btn-primary" :disabled="!draftText.trim() || noteSaving" @click="addNote">
									{{ noteSaving ? '保存中…' : `添加${noteTypeLabel(draftType)}` }}
								</button>
							</div>
						</div>
					</div>
				</section>
			</div>

			<aside class="side">
				<section class="block">
					<header class="block-head">
						<div>
							<h2>待办</h2>
							<p>优先处理</p>
						</div>
						<span class="chip soft">{{ todos.length }}</span>
					</header>
					<ul class="todo-list">
						<li v-for="item in todos" :key="item.id">
							<span class="prio" :data-level="item.level">{{ item.levelText }}</span>
							<div class="todo-body">
								<strong>{{ item.title }}</strong>
								<em>{{ item.time }}</em>
							</div>
							<button type="button" @click="go(item.path)">处理</button>
						</li>
					</ul>
				</section>

				<section class="block">
					<header class="block-head">
						<div>
							<h2>最新消息</h2>
							<p>系统与协作提醒</p>
						</div>
						<button type="button" class="link-btn" @click="go('/sys/message/inbox')">全部</button>
					</header>
					<ul class="msg-list">
						<li v-for="item in messages" :key="item.id" @click="go('/sys/message/inbox')">
							<span class="msg-mark" :class="'tone-' + item.tone">{{ item.short }}</span>
							<div class="msg-body">
								<strong>{{ item.name }}</strong>
								<p>{{ item.text }}</p>
							</div>
							<em>{{ item.time }}</em>
						</li>
						<li v-if="!messages.length" class="msg-empty">暂无站内消息</li>
					</ul>
				</section>
			</aside>
		</section>
	</div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/store/modules/user'
import constant from '@/utils/constant'
import {
	useWorkbenchNoteDeleteApi,
	useWorkbenchNoteListApi,
	useWorkbenchNoteSaveApi,
	type WorkbenchNote
} from '@/api/sys/workbench-note'
import { useMessageLatestApi } from '@/api/sys/message'

type NoteType = 'memo' | 'nudge' | 'remind'
type DayNote = {
	id: string
	dateKey: string
	type: NoteType
	text: string
	createdAt: string
}

const router = useRouter()
const userStore = useUserStore()

const now = new Date()
const weekMap = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六']
const weekDay = weekMap[now.getDay()]
const weeks = ['一', '二', '三', '四', '五', '六', '日']
const todayLabel = `${now.getMonth() + 1}月${now.getDate()}日`

const viewYear = ref(now.getFullYear())
const viewMonth = ref(now.getMonth())
const monthLabel = computed(() => `${viewYear.value} 年 ${viewMonth.value + 1} 月`)

const pad2 = (n: number) => String(n).padStart(2, '0')
const toDateKey = (y: number, m: number, d: number) => `${y}-${pad2(m + 1)}-${pad2(d)}`
const todayKey = toDateKey(now.getFullYear(), now.getMonth(), now.getDate())
const selectedDateKey = ref(todayKey)

const noteTypes: Array<{ key: NoteType; label: string }> = [
	{ key: 'nudge', label: '叮嘱' },
	{ key: 'memo', label: '记事' },
	{ key: 'remind', label: '提醒' }
]

const noteTypeLabel = (type: NoteType) => noteTypes.find(t => t.key === type)?.label || '记事'

const storageKey = computed(
	() => `icejz-workbench-notes:${userStore.user?.username || userStore.user?.id || 'guest'}`
)
const notesLoading = ref(false)
const noteSaving = ref(false)

const formatCreatedAt = (createTime?: string) => {
	if (!createTime) return '--:--'
	const match = createTime.match(/(\d{2}):(\d{2})/)
	return match ? `${match[1]}:${match[2]}` : createTime.slice(11, 16) || '--:--'
}

const mapRemoteNote = (item: WorkbenchNote): DayNote => ({
	id: String(item.id),
	dateKey: item.noteDate,
	type: (item.noteType as NoteType) || 'memo',
	text: item.content,
	createdAt: formatCreatedAt(item.createTime)
})

const loadLocalNotes = (): DayNote[] => {
	try {
		const raw = localStorage.getItem(storageKey.value)
		if (!raw) return []
		const parsed = JSON.parse(raw)
		return Array.isArray(parsed) ? parsed : []
	} catch {
		return []
	}
}

const clearLocalNotes = () => {
	localStorage.removeItem(storageKey.value)
}

const notes = ref<DayNote[]>([])
const draftType = ref<NoteType>('nudge')
const draftText = ref('')

const fetchNotes = async () => {
	notesLoading.value = true
	try {
		const res: any = await useWorkbenchNoteListApi()
		const list: WorkbenchNote[] = Array.isArray(res?.data) ? res.data : []
		if (list.length) {
			notes.value = list.map(mapRemoteNote)
			clearLocalNotes()
			return
		}
		const local = loadLocalNotes()
		if (!local.length) {
			notes.value = []
			return
		}
		const migrated: DayNote[] = []
		for (const item of local) {
			try {
				const saved: any = await useWorkbenchNoteSaveApi({
					noteDate: item.dateKey,
					noteType: item.type,
					content: item.text
				})
				if (saved?.data) {
					migrated.push(mapRemoteNote(saved.data))
				}
			} catch {
				migrated.push(item)
			}
		}
		notes.value = migrated
		if (migrated.every(n => /^\d+$/.test(n.id))) {
			clearLocalNotes()
		}
	} catch {
		notes.value = loadLocalNotes()
		ElMessage.warning('记事同步失败，已暂用本地缓存')
	} finally {
		notesLoading.value = false
	}
}

watch(storageKey, () => {
	fetchNotes()
})

onMounted(() => {
	fetchNotes()
	loadLatestMessages()
})

const notesByDate = computed(() => {
	const map = new Map<string, DayNote[]>()
	for (const note of notes.value) {
		const list = map.get(note.dateKey) || []
		list.push(note)
		map.set(note.dateKey, list)
	}
	return map
})

const selectedNotes = computed(() => notesByDate.value.get(selectedDateKey.value) || [])

const selectedDateLabel = computed(() => {
	const [y, m, d] = selectedDateKey.value.split('-').map(Number)
	const date = new Date(y, m - 1, d)
	const tip = selectedDateKey.value === todayKey ? '今天' : weekMap[date.getDay()]
	return `${y}年${m}月${d}日 · ${tip}`
})

const draftPlaceholder = computed(() => {
	if (draftType.value === 'nudge') return '写一句叮嘱，比如：别忘了复核权限配置…'
	if (draftType.value === 'remind') return '写一条提醒，比如：14:00 同步生成器…'
	return '记一点备忘，比如：和产品对齐字段命名…'
})

const projects = [
	{
		id: 1,
		title: '用户权限梳理',
		desc: '角色菜单授权复核',
		percent: 72,
		daysLeft: 3,
		tone: 'blue',
		path: '/sys/role/index'
	},
	{
		id: 2,
		title: '代码生成交付',
		desc: '数据源与模板路径对齐',
		percent: 58,
		daysLeft: 5,
		tone: 'teal',
		path: '/iframe/53'
	},
	{
		id: 3,
		title: '定时任务巡检',
		desc: '失败任务排查与告警',
		percent: 36,
		daysLeft: 2,
		tone: 'amber',
		path: '/quartz/schedule/index'
	}
]

const todos = [
	{ id: 1, title: '审核新用户申请', time: '今天 10:20', level: 'high', levelText: '高', path: '/sys/user/index' },
	{ id: 2, title: '同步生成器配置', time: '今天 11:05', level: 'mid', levelText: '中', path: '/iframe/53' },
	{ id: 3, title: '检查失败任务日志', time: '昨天 16:40', level: 'mid', levelText: '中', path: '/quartz/schedule/index' },
	{ id: 4, title: '更新个人资料', time: '昨天 09:15', level: 'low', levelText: '低', path: '/profile' }
]

const messages = ref<
	Array<{ id: number | string; name: string; short: string; text: string; time: string; tone: string }>
>([])

const typeTone = (type?: number) => {
	if (type === 1) return 'teal'
	if (type === 2) return 'amber'
	return 'blue'
}

const loadLatestMessages = async () => {
	try {
		const res: any = await useMessageLatestApi(5)
		const list = Array.isArray(res?.data) ? res.data : []
		messages.value = list.map((item: any) => ({
			id: item.id,
			name: item.senderName || '系统通知',
			short: (item.senderName || '系').slice(0, 1),
			text: item.title || item.content || '',
			time: String(item.sendTime || '').slice(11, 16) || '--:--',
			tone: typeTone(item.type)
		}))
	} catch {
		messages.value = []
	}
}

const calendarDays = computed(() => {
	const y = viewYear.value
	const m = viewMonth.value
	const first = new Date(y, m, 1)
	const start = (first.getDay() + 6) % 7
	const daysInMonth = new Date(y, m + 1, 0).getDate()
	const prevDays = new Date(y, m, 0).getDate()
	const list: {
		key: string
		n: number
		current: boolean
		today: boolean
		hasNote: boolean
		dateKey: string
	}[] = []

	for (let i = start - 1; i >= 0; i--) {
		const n = prevDays - i
		const pm = m === 0 ? 11 : m - 1
		const py = m === 0 ? y - 1 : y
		list.push({
			key: `p-${i}`,
			n,
			current: false,
			today: false,
			hasNote: false,
			dateKey: toDateKey(py, pm, n)
		})
	}
	for (let d = 1; d <= daysInMonth; d++) {
		const dateKey = toDateKey(y, m, d)
		list.push({
			key: `c-${d}`,
			n: d,
			current: true,
			today: dateKey === todayKey,
			hasNote: (notesByDate.value.get(dateKey)?.length || 0) > 0,
			dateKey
		})
	}
	let next = 1
	const nm = m === 11 ? 0 : m + 1
	const ny = m === 11 ? y + 1 : y
	while (list.length % 7 !== 0) {
		const n = next++
		list.push({
			key: `n-${list.length}`,
			n,
			current: false,
			today: false,
			hasNote: false,
			dateKey: toDateKey(ny, nm, n)
		})
	}
	return list
})

const shiftMonth = (delta: number) => {
	const date = new Date(viewYear.value, viewMonth.value + delta, 1)
	viewYear.value = date.getFullYear()
	viewMonth.value = date.getMonth()
}

const selectDay = (day: { current: boolean; dateKey: string }) => {
	if (!day.current) return
	selectedDateKey.value = day.dateKey
}

const addNote = async () => {
	const text = draftText.value.trim()
	if (!text || noteSaving.value) return
	noteSaving.value = true
	try {
		const res: any = await useWorkbenchNoteSaveApi({
			noteDate: selectedDateKey.value,
			noteType: draftType.value,
			content: text
		})
		if (res?.data) {
			notes.value = [mapRemoteNote(res.data), ...notes.value]
		} else {
			await fetchNotes()
		}
		draftText.value = ''
		ElMessage.success(`${noteTypeLabel(draftType.value)}已保存到云端`)
	} catch {
		ElMessage.error('保存失败，请稍后重试')
	} finally {
		noteSaving.value = false
	}
}

const removeNote = async (id: string) => {
	const numericId = Number(id)
	if (!Number.isFinite(numericId)) {
		notes.value = notes.value.filter(n => n.id !== id)
		return
	}
	try {
		await useWorkbenchNoteDeleteApi([numericId])
		notes.value = notes.value.filter(n => n.id !== id)
		ElMessage.success('已删除')
	} catch {
		ElMessage.error('删除失败，请稍后重试')
	}
}

const go = (path: string) => {
	router.push(path).catch(() => undefined)
}
</script>

<style lang="scss" scoped>
.workbench-page {
	--ink: #122033;
	--muted: #64748b;
	--soft: #f5f9fc;
	--line: #e7eef5;
	--panel: #fff;
	--brand: #00a8e8;
	--brand-deep: #007eb8;
	display: flex;
	flex-direction: column;
	gap: 18px;
	min-height: calc(100vh - 140px);
	padding: 4px 2px 20px;
	animation: rise 0.35s ease both;
	background:
		radial-gradient(900px 320px at 100% -8%, rgba(0, 168, 232, 0.08), transparent 55%),
		radial-gradient(640px 260px at 0% 100%, rgba(0, 168, 232, 0.05), transparent 52%);
}

@keyframes rise {
	from {
		opacity: 0;
		transform: translateY(8px);
	}
	to {
		opacity: 1;
		transform: none;
	}
}

.wb-top {
	display: grid;
	grid-template-columns: minmax(0, 1.2fr) auto auto;
	align-items: end;
	gap: 18px;
	padding: 20px 22px;
	border-radius: 22px;
	border: 1px solid rgba(0, 168, 232, 0.14);
	background:
		linear-gradient(145deg, color-mix(in srgb, var(--panel) 96%, transparent), color-mix(in srgb, var(--soft) 90%, transparent)),
		radial-gradient(480px 200px at 0% 40%, rgba(0, 168, 232, 0.1), transparent 60%);
	box-shadow: 0 12px 28px rgba(15, 23, 36, 0.04);
}

.wb-kicker {
	margin: 0 0 6px;
	font-size: 12px;
	font-weight: 700;
	letter-spacing: 0.04em;
	color: var(--brand-deep);
}

.wb-intro h1 {
	margin: 0;
	font-size: 28px;
	font-weight: 760;
	letter-spacing: -0.02em;
	color: var(--ink);
}

.wb-lead {
	margin: 8px 0 0;
	max-width: 420px;
	font-size: 13.5px;
	line-height: 1.6;
	color: var(--muted);
}

.wb-metrics {
	display: grid;
	grid-template-columns: repeat(4, minmax(64px, 1fr));
	gap: 4px 18px;
	padding: 4px 4px 4px 18px;
	border-left: 1px solid rgba(0, 168, 232, 0.12);
}

.metric {
	display: flex;
	flex-direction: column;
	gap: 4px;
	min-width: 0;

	span {
		font-size: 12px;
		color: var(--muted);
	}

	strong {
		font-size: 22px;
		font-weight: 760;
		font-variant-numeric: tabular-nums;
		letter-spacing: -0.02em;
		color: var(--ink);
	}
}

.btn-ghost,
.btn-primary,
.btn-enter,
.todo-list button {
	border: none;
	cursor: pointer;
	font-family: inherit;
}

.btn-ghost {
	height: 40px;
	padding: 0 16px;
	border-radius: 12px;
	background: color-mix(in srgb, var(--panel) 80%, transparent);
	border: 1px solid rgba(0, 168, 232, 0.18);
	color: var(--brand-deep);
	font-size: 13px;
	font-weight: 700;
	transition: background 0.18s ease, transform 0.18s ease;

	&:hover {
		background: rgba(0, 168, 232, 0.08);
		transform: translateY(-1px);
	}
}

.btn-primary {
	height: 34px;
	padding: 0 14px;
	border-radius: 11px;
	background: var(--brand);
	color: #fff;
	font-size: 12px;
	font-weight: 740;
	box-shadow: 0 8px 16px rgba(0, 168, 232, 0.2);
	transition: transform 0.18s ease, filter 0.18s ease;

	&:hover:not(:disabled) {
		transform: translateY(-1px);
		filter: brightness(1.04);
	}

	&:disabled {
		opacity: 0.45;
		cursor: not-allowed;
		box-shadow: none;
	}
}

.wb-grid {
	display: grid;
	grid-template-columns: 260px minmax(0, 1.25fr) 300px;
	gap: 16px;
	align-items: start;
}

.rail,
.main-col,
.side {
	display: flex;
	flex-direction: column;
	gap: 16px;
	min-width: 0;
}

.rail,
.block {
	padding: 18px;
	border-radius: 20px;
	background: color-mix(in srgb, var(--panel) 94%, transparent);
	border: 1px solid var(--line);
	box-shadow: 0 10px 24px rgba(15, 23, 36, 0.035);
}

.profile {
	display: flex;
	align-items: center;
	gap: 12px;
}

.avatar {
	width: 56px;
	height: 56px;
	border-radius: 16px;
	object-fit: cover;
	background: var(--panel);
	box-shadow: 0 0 0 3px rgba(0, 168, 232, 0.16);
}

.profile-copy {
	min-width: 0;

	strong {
		display: block;
		font-size: 16px;
		font-weight: 750;
		color: var(--ink);
	}

	em {
		display: block;
		margin-top: 2px;
		font-style: normal;
		font-size: 12px;
		color: #7a8796;
	}
}

.online {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	margin-top: 8px;
	font-size: 11px;
	font-weight: 700;
	color: #0f766e;

	i {
		width: 6px;
		height: 6px;
		border-radius: 50%;
		background: #14b8a6;
	}
}

.quick-nav {
	display: grid;
	grid-template-columns: repeat(4, 1fr);
	gap: 6px;

	button {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		gap: 4px;
		min-height: 54px;
		padding: 8px 4px;
		border: none;
		border-radius: 14px;
		background: var(--soft);
		color: var(--brand-deep);
		font-size: 11px;
		font-weight: 650;
		cursor: pointer;
		transition: background 0.18s ease, transform 0.18s ease;

		&:hover {
			background: rgba(0, 168, 232, 0.1);
			transform: translateY(-1px);
		}
	}
}

.info-list {
	margin: 0;
	padding: 0;
	display: flex;
	flex-direction: column;
	gap: 10px;

	div {
		display: flex;
		justify-content: space-between;
		gap: 10px;
		padding-bottom: 10px;
		border-bottom: 1px solid rgba(231, 238, 245, 0.95);

		&:last-child {
			padding-bottom: 0;
			border-bottom: none;
		}
	}

	dt {
		font-size: 12px;
		color: #7a8796;
	}

	dd {
		margin: 0;
		font-size: 12px;
		font-weight: 650;
		color: var(--ink);
		text-align: right;
		word-break: break-all;
	}
}

.block-head {
	display: flex;
	justify-content: space-between;
	align-items: flex-start;
	gap: 10px;
	margin-bottom: 14px;

	h2 {
		margin: 0 0 4px;
		font-size: 16px;
		font-weight: 740;
		color: var(--ink);
	}

	p {
		margin: 0;
		font-size: 12px;
		color: #7a8796;
	}
}

.chip {
	flex-shrink: 0;
	height: 26px;
	padding: 0 10px;
	border-radius: 999px;
	display: inline-flex;
	align-items: center;
	font-size: 11px;
	font-weight: 740;
	color: #fff;
	background: var(--brand);

	&.soft {
		color: var(--brand-deep);
		background: rgba(0, 168, 232, 0.1);
	}
}

.project-list {
	display: flex;
	flex-direction: column;
	gap: 10px;
}

.project-row {
	display: flex;
	align-items: center;
	gap: 14px;
	padding: 14px 14px 14px 16px;
	border-radius: 16px;
	background: var(--soft);
	border: 1px solid transparent;
	border-left: 3px solid var(--brand);
	transition: transform 0.18s ease, background 0.18s ease, border-color 0.18s ease;

	&[data-tone='teal'] {
		border-left-color: #2fbfa4;
	}

	&[data-tone='amber'] {
		border-left-color: #f0a202;
	}

	&:hover {
		transform: translateY(-1px);
		background: rgba(0, 168, 232, 0.06);
	}
}

.project-main {
	flex: 1;
	min-width: 0;
}

.project-title {
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 8px;

	strong {
		font-size: 14px;
		font-weight: 740;
		color: var(--ink);
	}

	span {
		font-size: 12px;
		font-weight: 700;
		color: #7a8796;
	}
}

.project-row p {
	margin: 6px 0 10px;
	font-size: 12.5px;
	line-height: 1.45;
	color: var(--muted);
}

.progress {
	display: flex;
	align-items: center;
	gap: 8px;

	.track {
		flex: 1;
		height: 7px;
		border-radius: 999px;
		background: rgba(15, 23, 36, 0.08);
		overflow: hidden;

		i {
			display: block;
			height: 100%;
			border-radius: inherit;
			background: linear-gradient(90deg, #00a8e8, #67e8f9);
		}
	}

	em {
		font-style: normal;
		font-size: 12px;
		font-weight: 700;
		font-variant-numeric: tabular-nums;
		color: #475569;
		min-width: 34px;
	}
}

.project-row[data-tone='teal'] .progress .track i {
	background: linear-gradient(90deg, #2fbfa4, #5eead4);
}

.project-row[data-tone='amber'] .progress .track i {
	background: linear-gradient(90deg, #f0a202, #fcd34d);
}

.btn-enter {
	flex-shrink: 0;
	height: 34px;
	padding: 0 14px;
	border-radius: 11px;
	background: color-mix(in srgb, var(--brand) 14%, var(--panel));
	border: 1px solid rgba(0, 168, 232, 0.22);
	color: var(--brand-deep);
	font-size: 12px;
	font-weight: 720;
	transition: transform 0.18s ease, filter 0.18s ease;

	&:hover {
		transform: translateY(-1px);
		filter: brightness(1.08);
	}
}

.cal-nav {
	display: flex;
	gap: 6px;
}

.icon-btn {
	width: 32px;
	height: 32px;
	border: 1px solid rgba(0, 168, 232, 0.16);
	border-radius: 10px;
	background: var(--panel);
	color: var(--brand-deep);
	font-size: 18px;
	line-height: 1;
	cursor: pointer;
	transition: background 0.18s ease, transform 0.18s ease;

	&:hover {
		background: rgba(0, 168, 232, 0.1);
		transform: translateY(-1px);
	}
}

.cal-grid {
	display: grid;
	grid-template-columns: repeat(7, 1fr);
	gap: 6px;
}

.cal-grid .w {
	text-align: center;
	font-size: 12px;
	font-weight: 700;
	color: #94a3b8;
	padding-bottom: 2px;
}

.day {
	position: relative;
	aspect-ratio: 1;
	border: none;
	border-radius: 12px;
	background: var(--soft);
	color: var(--ink);
	font-size: 13px;
	font-weight: 650;
	cursor: pointer;
	transition: transform 0.18s ease, background 0.18s ease, box-shadow 0.18s ease;

	&:hover:not(.mute):not(:disabled) {
		transform: translateY(-1px);
		background: rgba(0, 168, 232, 0.1);
	}

	&:disabled {
		cursor: default;
	}

	&.mute {
		opacity: 0.3;
	}

	&.has {
		background: rgba(0, 168, 232, 0.12);
		color: var(--brand-deep);
		font-weight: 760;
	}

	&.today {
		background: var(--ink);
		color: #fff;
		font-weight: 760;
	}

	&.active {
		box-shadow: 0 0 0 2px rgba(0, 168, 232, 0.4);
	}

	&.today.active {
		box-shadow: 0 0 0 2px rgba(56, 189, 248, 0.55);
	}

	.dot {
		position: absolute;
		left: 50%;
		bottom: 5px;
		width: 4px;
		height: 4px;
		border-radius: 50%;
		background: var(--brand);
		transform: translateX(-50%);
	}

	&.today .dot {
		background: #7dd3fc;
	}
}

.note-board {
	margin-top: 14px;
	padding-top: 14px;
	border-top: 1px solid var(--line);
}

.note-head {
	display: flex;
	align-items: flex-start;
	justify-content: space-between;
	gap: 10px;
	margin-bottom: 12px;

	strong {
		display: block;
		font-size: 14px;
		font-weight: 740;
		color: var(--ink);
	}

	em {
		display: block;
		margin-top: 3px;
		font-style: normal;
		font-size: 12px;
		color: #7a8796;
	}
}

.note-tabs {
	display: flex;
	flex-wrap: wrap;
	justify-content: flex-end;
	gap: 6px;

	button {
		height: 28px;
		padding: 0 10px;
		border-radius: 999px;
		border: 1px solid var(--line);
		background: var(--panel);
		color: var(--muted);
		font-size: 11px;
		font-weight: 700;
		cursor: pointer;
		transition: background 0.18s ease, color 0.18s ease, border-color 0.18s ease;

		&.active {
			color: #fff;
			border-color: transparent;
			background: var(--brand);
		}
	}
}

.note-list {
	list-style: none;
	margin: 0 0 12px;
	padding: 0;
	display: flex;
	flex-direction: column;
	gap: 8px;
	max-height: 168px;
	overflow: auto;
}

.note-list li {
	display: flex;
	align-items: flex-start;
	gap: 8px;
	padding: 10px;
	border-radius: 14px;
	background: var(--soft);
}

.note-tag {
	flex-shrink: 0;
	height: 22px;
	padding: 0 8px;
	border-radius: 999px;
	display: inline-flex;
	align-items: center;
	font-size: 11px;
	font-weight: 740;
	color: var(--brand-deep);
	background: rgba(0, 168, 232, 0.1);
}

.note-list li[data-type='nudge'] .note-tag {
	color: #0f766e;
	background: rgba(47, 191, 164, 0.14);
}

.note-list li[data-type='remind'] .note-tag {
	color: #c2410c;
	background: rgba(240, 162, 2, 0.16);
}

.note-body {
	flex: 1;
	min-width: 0;

	p {
		margin: 0;
		font-size: 13px;
		line-height: 1.45;
		color: var(--ink);
		word-break: break-word;
	}

	em {
		display: block;
		margin-top: 4px;
		font-style: normal;
		font-size: 11px;
		color: #94a3b8;
	}
}

.note-del {
	flex-shrink: 0;
	height: 28px;
	padding: 0 8px;
	border: none;
	border-radius: 8px;
	background: transparent;
	color: #94a3b8;
	font-size: 12px;
	font-weight: 700;
	cursor: pointer;

	&:hover {
		background: rgba(239, 68, 68, 0.1);
		color: #dc2626;
	}
}

.note-empty {
	margin-bottom: 12px;
	padding: 18px 12px;
	border-radius: 14px;
	text-align: center;
	font-size: 12.5px;
	color: #7a8796;
	background: var(--soft);
}

.note-composer {
	display: flex;
	flex-direction: column;
	gap: 8px;

	textarea {
		width: 100%;
		resize: none;
		padding: 10px 12px;
		border-radius: 14px;
		border: 1px solid var(--line);
		outline: none;
		background: var(--panel);
		color: var(--ink);
		font-size: 13px;
		line-height: 1.5;
		font-family: inherit;

		&:focus {
			border-color: rgba(0, 168, 232, 0.45);
			box-shadow: 0 0 0 3px rgba(0, 168, 232, 0.1);
		}
	}
}

.composer-foot {
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 10px;

	span {
		font-size: 11px;
		color: #94a3b8;
		font-variant-numeric: tabular-nums;
	}
}

.todo-list,
.msg-list {
	list-style: none;
	margin: 0;
	padding: 0;
	display: flex;
	flex-direction: column;
	gap: 8px;
}

.todo-list li,
.msg-list li {
	display: flex;
	align-items: center;
	gap: 10px;
	padding: 10px 8px;
	border-radius: 12px;
	transition: background 0.18s ease;

	&:hover {
		background: var(--soft);
	}
}

.prio {
	width: 28px;
	height: 28px;
	border-radius: 9px;
	display: grid;
	place-items: center;
	font-size: 12px;
	font-weight: 760;
	flex-shrink: 0;

	&[data-level='high'] {
		background: rgba(235, 103, 9, 0.14);
		color: #c2410c;
	}

	&[data-level='mid'] {
		background: rgba(0, 168, 232, 0.12);
		color: var(--brand-deep);
	}

	&[data-level='low'] {
		background: rgba(100, 116, 139, 0.12);
		color: #64748b;
	}
}

.todo-body {
	flex: 1;
	min-width: 0;

	strong {
		display: block;
		font-size: 13px;
		font-weight: 720;
		color: var(--ink);
	}

	em {
		font-style: normal;
		font-size: 12px;
		color: #7a8796;
	}
}

.todo-list button {
	height: 30px;
	padding: 0 12px;
	border-radius: 999px;
	background: rgba(0, 168, 232, 0.1);
	color: var(--brand-deep);
	font-size: 12px;
	font-weight: 700;
	transition: background 0.18s ease, color 0.18s ease;

	&:hover {
		background: var(--brand);
		color: #fff;
	}
}

.link-btn {
	border: none;
	background: transparent;
	color: var(--brand-deep);
	font-size: 12px;
	font-weight: 700;
	cursor: pointer;
	padding: 0;
}

.msg-mark {
	width: 34px;
	height: 34px;
	border-radius: 11px;
	display: grid;
	place-items: center;
	color: #fff;
	font-size: 12px;
	font-weight: 760;
	flex-shrink: 0;
	background: #00a8e8;

	&.tone-teal {
		background: #2fbfa4;
	}

	&.tone-amber {
		background: #f0a202;
	}
}

.msg-empty {
	justify-content: center;
	color: #7a8796;
	font-size: 12px;
	padding: 18px 8px !important;
	cursor: default !important;

	&:hover {
		background: transparent !important;
	}
}

.msg-body {
	flex: 1;
	min-width: 0;

	strong {
		display: block;
		font-size: 13px;
		font-weight: 720;
		color: var(--ink);
	}

	p {
		margin: 2px 0 0;
		font-size: 12px;
		color: var(--muted);
	}
}

.msg-list em {
	margin-left: auto;
	font-style: normal;
	font-size: 11px;
	font-weight: 650;
	color: #94a3b8;
	flex-shrink: 0;
	font-variant-numeric: tabular-nums;
}

@media (max-width: 1200px) {
	.wb-grid {
		grid-template-columns: 1fr 1fr;
	}

	.rail {
		grid-column: 1 / -1;
		display: grid;
		grid-template-columns: auto 1fr auto;
		align-items: center;
		gap: 16px;
	}

	.info-list {
		display: none;
	}

	.side {
		grid-column: 1 / -1;
		display: grid;
		grid-template-columns: 1fr 1fr;
		gap: 16px;
	}
}

@media (max-width: 860px) {
	.wb-top {
		grid-template-columns: 1fr;
		align-items: stretch;
	}

	.wb-metrics {
		padding: 12px 0 0;
		border-left: none;
		border-top: 1px solid rgba(0, 168, 232, 0.12);
		grid-template-columns: repeat(4, minmax(0, 1fr));
	}

	.btn-ghost {
		width: 100%;
	}

	.wb-grid,
	.side {
		grid-template-columns: 1fr;
	}

	.rail {
		grid-template-columns: 1fr;
	}

	.info-list {
		display: flex;
	}
}
</style>
