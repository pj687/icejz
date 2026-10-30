<template>
	<div class="workbench-page">
		<section class="wb-hero">
			<div class="hero-glow" aria-hidden="true"></div>
			<div class="hero-copy">
				<span class="kicker">Workbench</span>
				<h1>我的工作台</h1>
				<p>关注个人任务、项目进度与消息动态，把今天的关键事项一次排清。</p>
			</div>
			<div class="hero-actions">
				<div class="stat-pills">
					<span><em>{{ projects.length }}</em>进行中</span>
					<span><em>{{ todos.length }}</em>待办</span>
					<span><em>{{ messages.length }}</em>消息</span>
				</div>
				<button class="btn-home" type="button" @click="go('/dashboard/index')">返回首页</button>
			</div>
		</section>

		<section class="wb-bento">
			<aside class="panel profile-panel">
				<div class="profile-cover">
					<div class="avatar-ring">
						<img class="avatar" :src="userStore.user.avatar || constant.defaultAvatar" alt="avatar" />
					</div>
					<div class="profile-meta">
						<strong>{{ userStore.user.realName || '管理员' }}</strong>
						<em>{{ userStore.user.username || 'admin' }} · ICEJZ</em>
						<span class="online-tag"><i></i>在线</span>
					</div>
				</div>

				<div class="contact-row">
					<button type="button" title="个人中心" @click="go('/profile')">
						<ma-icon icon="icon-user" />
						<span>资料</span>
					</button>
					<button type="button" title="消息" @click="go('/sys/user/index')">
						<ma-icon icon="icon-message-fill" />
						<span>用户</span>
					</button>
					<button type="button" title="代码生成" @click="go('/iframe/53')">
						<ma-icon icon="icon-code" />
						<span>生成</span>
					</button>
					<button type="button" title="设置" @click="go('/sys/menu/index')">
						<ma-icon icon="icon-setting" />
						<span>菜单</span>
					</button>
				</div>

				<div class="slot-card">
					<header>
						<strong>今日时段</strong>
						<em>{{ weekDay }}</em>
					</header>
					<div class="slots">
						<button
							v-for="slot in slots"
							:key="slot"
							type="button"
							:class="{ active: slot === activeSlot }"
							@click="activeSlot = slot"
						>
							{{ slot }}
						</button>
					</div>
				</div>

				<div class="info-card">
					<strong>详细信息</strong>
					<ul>
						<li><span>姓名</span><em>{{ userStore.user.realName || '管理员' }}</em></li>
						<li><span>账号</span><em>{{ userStore.user.username || 'admin' }}</em></li>
						<li><span>邮箱</span><em>{{ userStore.user.email || '未设置' }}</em></li>
						<li><span>手机</span><em>{{ userStore.user.mobile || '未设置' }}</em></li>
					</ul>
				</div>
			</aside>

			<div class="center-col">
				<div class="panel projects-panel">
					<header class="section-head">
						<div>
							<h2>进行中的事项</h2>
							<p>按优先级推进今日关键交付</p>
						</div>
						<span class="head-chip">Focus</span>
					</header>
					<div class="project-list">
						<article v-for="item in projects" :key="item.id" class="project-card" :class="item.tone">
							<div class="project-top">
								<strong>{{ item.title }}</strong>
								<span class="days">{{ item.daysLeft }} 天</span>
							</div>
							<p>{{ item.desc }}</p>
							<div class="project-foot">
								<div class="progress">
									<div class="track"><i :style="{ width: item.percent + '%' }"></i></div>
									<em>{{ item.percent }}%</em>
								</div>
								<button type="button" @click="go(item.path)">进入</button>
							</div>
						</article>
					</div>
				</div>

				<div class="panel calendar-panel">
					<header class="section-head">
						<div>
							<h2>{{ monthLabel }}</h2>
							<p>点选日期，添加记事与叮嘱</p>
						</div>
						<div class="cal-nav">
							<button type="button" class="nav-btn" title="上一月" @click="shiftMonth(-1)">‹</button>
							<button type="button" class="nav-btn" title="下一月" @click="shiftMonth(1)">›</button>
							<span class="head-chip soft">记事</span>
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
							<div class="note-type-tabs">
								<button
									v-for="t in noteTypes"
									:key="t.key"
									type="button"
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
								<button type="button" class="note-del" title="删除" @click="removeNote(note.id)">删</button>
							</li>
						</ul>
						<div v-else class="note-empty">这一天还没有叮嘱，写一句给未来的自己吧～</div>

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
								<button type="button" class="note-add" :disabled="!draftText.trim() || noteSaving" @click="addNote">
									{{ noteSaving ? '保存中…' : `添加${noteTypeLabel(draftType)}` }}
								</button>
							</div>
						</div>
					</div>
				</div>
			</div>

			<aside class="panel inbox-panel">
				<header class="section-head">
					<div>
						<h2>待办与动态</h2>
						<p>Inbox · 优先处理</p>
					</div>
					<span class="count">{{ todos.length }}</span>
				</header>
				<ul class="inbox-list">
					<li v-for="item in todos" :key="item.id">
						<span class="badge" :class="item.level">{{ item.levelText }}</span>
						<div class="body">
							<strong>{{ item.title }}</strong>
							<em>{{ item.time }}</em>
						</div>
						<button type="button" @click="go(item.path)">处理</button>
					</li>
				</ul>

				<header class="section-head sub">
					<div>
						<h2>最新消息</h2>
						<p>系统与协作提醒</p>
					</div>
				</header>
				<ul class="msg-list">
					<li v-for="item in messages" :key="item.id">
						<span class="avatar" :style="{ background: item.color }">{{ item.short }}</span>
						<div class="msg-body">
							<strong>{{ item.name }}</strong>
							<p>{{ item.text }}</p>
						</div>
						<em>{{ item.time }}</em>
					</li>
				</ul>
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

const slots = ['09:00', '11:00', '14:00', '16:00', '18:00']
const activeSlot = ref('14:00')

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

const messages = [
	{ id: 1, name: '运维助手', short: '运', text: '夜间备份已完成', time: '08:30', color: '#00a8e8' },
	{ id: 2, name: '系统通知', short: '系', text: '有 3 个任务待执行', time: '09:12', color: '#2fbfa4' },
	{ id: 3, name: '安全中心', short: '安', text: '建议开启二次校验', time: '10:05', color: '#f0a202' }
]

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
	display: flex;
	flex-direction: column;
	gap: 18px;
	animation: rise 0.45s ease both;
	padding: 2px;
	min-height: calc(100vh - 140px);
	background:
		radial-gradient(900px 360px at 100% -10%, rgba(0, 168, 232, 0.1), transparent 55%),
		radial-gradient(760px 300px at 0% 100%, rgba(47, 191, 164, 0.08), transparent 52%),
		linear-gradient(180deg, rgba(248, 251, 255, 0.4), transparent 40%);
}

@keyframes rise {
	from {
		opacity: 0;
		transform: translateY(10px);
	}
	to {
		opacity: 1;
		transform: none;
	}
}

.wb-hero {
	position: relative;
	display: flex;
	align-items: flex-end;
	justify-content: space-between;
	gap: 16px;
	overflow: hidden;
	padding: 22px 24px;
	border-radius: 28px;
	border: 1px solid rgba(0, 168, 232, 0.14);
	background:
		linear-gradient(145deg, rgba(255, 255, 255, 0.72), rgba(232, 247, 253, 0.42)),
		radial-gradient(480px 220px at 0% 50%, rgba(0, 168, 232, 0.12), transparent 60%);
	backdrop-filter: blur(14px);
	box-shadow: 0 14px 36px rgba(15, 23, 36, 0.05);
}

.hero-glow {
	position: absolute;
	right: -40px;
	top: -70px;
	width: 240px;
	height: 240px;
	border-radius: 50%;
	background: radial-gradient(circle, rgba(62, 198, 255, 0.28), transparent 68%);
	pointer-events: none;
}

.hero-copy,
.hero-actions {
	position: relative;
	z-index: 1;
}

.kicker {
	display: inline-flex;
	align-items: center;
	margin-bottom: 8px;
	padding: 4px 10px;
	border-radius: 999px;
	font-size: 11px;
	font-weight: 750;
	letter-spacing: 0.08em;
	color: #007eb8;
	background: rgba(0, 168, 232, 0.1);
	border: 1px solid rgba(0, 168, 232, 0.16);
}

.wb-hero h1 {
	margin: 0;
	font-size: 30px;
	font-weight: 780;
	letter-spacing: -0.02em;
	color: #0f1724;
}

.wb-hero p {
	margin: 8px 0 0;
	max-width: 460px;
	color: #5f7386;
	font-size: 13.5px;
	line-height: 1.65;
}

.hero-actions {
	display: flex;
	flex-direction: column;
	align-items: flex-end;
	gap: 12px;
}

.stat-pills {
	display: flex;
	flex-wrap: wrap;
	justify-content: flex-end;
	gap: 8px;

	span {
		display: inline-flex;
		align-items: center;
		gap: 6px;
		height: 30px;
		padding: 0 12px;
		border-radius: 999px;
		font-size: 12px;
		font-weight: 650;
		color: #0f4f6e;
		background: rgba(255, 255, 255, 0.78);
		border: 1px solid rgba(0, 168, 232, 0.12);
	}
	em {
		font-style: normal;
		font-weight: 780;
		color: #00a8e8;
	}
}

.btn-home {
	height: 40px;
	padding: 0 18px;
	border: none;
	border-radius: 999px;
	background: linear-gradient(135deg, #00a8e8, #2bbef5);
	color: #fff;
	font-weight: 700;
	cursor: pointer;
	box-shadow: 0 10px 22px rgba(0, 168, 232, 0.24);
	transition: transform 0.14s ease, filter 0.14s ease;

	&:hover {
		transform: translateY(-1px);
		filter: brightness(1.03);
	}
}

.wb-bento {
	display: grid;
	grid-template-columns: 288px minmax(0, 1.2fr) 332px;
	gap: 16px;
	align-items: start;
}

.panel {
	position: relative;
	border-radius: 26px;
	background: rgba(255, 255, 255, 0.88);
	border: 1px solid rgba(232, 238, 245, 0.95);
	box-shadow:
		0 14px 36px rgba(15, 23, 36, 0.05),
		inset 0 1px 0 rgba(255, 255, 255, 0.9);
	padding: 18px;
	backdrop-filter: blur(10px);
}

.profile-panel {
	display: flex;
	flex-direction: column;
	gap: 14px;
}

.profile-cover {
	display: flex;
	gap: 14px;
	align-items: center;
	padding: 14px;
	border-radius: 22px;
	background:
		linear-gradient(160deg, rgba(0, 168, 232, 0.14), rgba(47, 191, 164, 0.08)),
		rgba(255, 255, 255, 0.55);
	border: 1px solid rgba(0, 168, 232, 0.1);
}

.avatar-ring {
	flex-shrink: 0;
	padding: 3px;
	border-radius: 22px;
	background: linear-gradient(145deg, #00a8e8, #7dd3fc, #2fbfa4);
}

.avatar {
	display: block;
	width: 64px;
	height: 64px;
	border-radius: 19px;
	object-fit: cover;
	background: #fff;
	border: 2px solid #fff;
}

.profile-meta {
	min-width: 0;

	strong {
		display: block;
		font-size: 17px;
		font-weight: 760;
		color: #122033;
	}
	em {
		display: block;
		margin-top: 4px;
		font-style: normal;
		font-size: 12px;
		color: #7a8796;
	}
}

.online-tag {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	margin-top: 8px;
	padding: 3px 8px;
	border-radius: 999px;
	font-size: 11px;
	font-weight: 700;
	color: #0f766e;
	background: rgba(47, 191, 164, 0.12);

	i {
		width: 6px;
		height: 6px;
		border-radius: 50%;
		background: #14b8a6;
		box-shadow: 0 0 0 3px rgba(20, 184, 166, 0.18);
	}
}

.contact-row {
	display: grid;
	grid-template-columns: repeat(4, 1fr);
	gap: 8px;

	button {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		gap: 4px;
		height: 58px;
		border-radius: 16px;
		border: 1px solid rgba(234, 241, 247, 0.95);
		background: linear-gradient(180deg, #fff, #f7fbfe);
		color: #007eb8;
		cursor: pointer;
		transition: transform 0.14s ease, box-shadow 0.14s ease, border-color 0.14s ease;

		span {
			font-size: 11px;
			font-weight: 650;
			color: #5f7386;
		}

		&:hover {
			transform: translateY(-1px);
			border-color: rgba(0, 168, 232, 0.22);
			box-shadow: 0 8px 18px rgba(0, 168, 232, 0.1);
		}
	}
}

.slot-card,
.info-card {
	padding: 14px;
	border-radius: 18px;
	background: linear-gradient(180deg, rgba(247, 251, 254, 0.95), rgba(255, 255, 255, 0.9));
	border: 1px solid #eaf1f7;
}

.slot-card header,
.info-card > strong {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 12px;
	font-size: 13px;
	font-weight: 750;
	color: #122033;
}

.slot-card em {
	font-style: normal;
	color: #7a8796;
	font-size: 12px;
	font-weight: 600;
}

.slots {
	display: flex;
	flex-wrap: wrap;
	gap: 8px;

	button {
		height: 30px;
		padding: 0 11px;
		border-radius: 999px;
		border: 1px solid #e2e8f0;
		background: #fff;
		color: #475569;
		font-size: 12px;
		font-weight: 650;
		cursor: pointer;
		transition: transform 0.12s ease, background 0.12s ease, color 0.12s ease;

		&:hover {
			transform: translateY(-1px);
		}

		&.active {
			background: linear-gradient(135deg, #00a8e8, #38bdf8);
			border-color: transparent;
			color: #fff;
			box-shadow: 0 6px 14px rgba(0, 168, 232, 0.22);
		}
	}
}

.info-card ul {
	list-style: none;
	margin: 0;
	padding: 0;
	display: flex;
	flex-direction: column;
	gap: 10px;
}

.info-card li {
	display: flex;
	justify-content: space-between;
	gap: 8px;
	padding-bottom: 8px;
	border-bottom: 1px dashed rgba(226, 232, 240, 0.9);
	font-size: 12px;

	&:last-child {
		padding-bottom: 0;
		border-bottom: none;
	}

	span {
		color: #7a8796;
	}
	em {
		font-style: normal;
		color: #1f2a37;
		font-weight: 650;
		text-align: right;
		word-break: break-all;
	}
}

.center-col {
	display: flex;
	flex-direction: column;
	gap: 16px;
	min-width: 0;
}

.section-head {
	display: flex;
	justify-content: space-between;
	align-items: flex-start;
	gap: 10px;
	margin-bottom: 14px;

	h2 {
		margin: 0 0 4px;
		font-size: 17px;
		font-weight: 760;
		color: #122033;
	}
	p {
		margin: 0;
		font-size: 12px;
		color: #7a8796;
	}

	&.sub {
		margin-top: 18px;
	}
}

.head-chip {
	flex-shrink: 0;
	height: 26px;
	padding: 0 10px;
	border-radius: 999px;
	display: inline-flex;
	align-items: center;
	font-size: 11px;
	font-weight: 750;
	letter-spacing: 0.04em;
	color: #fff;
	background: linear-gradient(135deg, #00a8e8, #38bdf8);

	&.soft {
		color: #0369a1;
		background: rgba(0, 168, 232, 0.1);
		border: 1px solid rgba(0, 168, 232, 0.14);
	}
}

.cal-nav {
	display: flex;
	align-items: center;
	gap: 6px;
}

.nav-btn {
	width: 28px;
	height: 28px;
	border: 1px solid rgba(0, 168, 232, 0.16);
	border-radius: 10px;
	background: rgba(255, 255, 255, 0.9);
	color: #0369a1;
	font-size: 18px;
	line-height: 1;
	cursor: pointer;
	transition: background 0.12s ease, transform 0.12s ease;

	&:hover {
		transform: translateY(-1px);
		background: rgba(0, 168, 232, 0.1);
	}
}

.project-list {
	display: flex;
	flex-direction: column;
	gap: 12px;
}

.project-card {
	padding: 16px;
	border-radius: 20px;
	border: 1px solid transparent;
	transition: transform 0.16s ease, box-shadow 0.16s ease;

	&:hover {
		transform: translateY(-2px);
		box-shadow: 0 12px 28px rgba(15, 23, 36, 0.06);
	}

	&.blue {
		background: linear-gradient(160deg, rgba(0, 168, 232, 0.14), rgba(255, 255, 255, 0.96));
		border-color: rgba(0, 168, 232, 0.1);
	}
	&.teal {
		background: linear-gradient(160deg, rgba(47, 191, 164, 0.14), rgba(255, 255, 255, 0.96));
		border-color: rgba(47, 191, 164, 0.1);
	}
	&.amber {
		background: linear-gradient(160deg, rgba(240, 162, 2, 0.16), rgba(255, 255, 255, 0.96));
		border-color: rgba(240, 162, 2, 0.12);
	}

	p {
		margin: 8px 0 14px;
		font-size: 12.5px;
		line-height: 1.5;
		color: #64748b;
	}
}

.project-top {
	display: flex;
	justify-content: space-between;
	gap: 8px;

	strong {
		color: #122033;
		font-size: 15px;
		font-weight: 750;
	}
}

.days {
	font-size: 12px;
	font-weight: 700;
	color: #7a8796;
	padding: 2px 8px;
	border-radius: 999px;
	background: rgba(255, 255, 255, 0.7);
}

.project-foot {
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 10px;
}

.progress {
	display: flex;
	align-items: center;
	gap: 8px;
	flex: 1;

	.track {
		flex: 1;
		height: 8px;
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
		color: #475569;
		min-width: 36px;
	}
}

.project-card.teal .progress .track i {
	background: linear-gradient(90deg, #2fbfa4, #5eead4);
}
.project-card.amber .progress .track i {
	background: linear-gradient(90deg, #f0a202, #fcd34d);
}

.project-foot button {
	height: 32px;
	padding: 0 14px;
	border: none;
	border-radius: 999px;
	background: #122033;
	color: #fff;
	font-size: 12px;
	font-weight: 700;
	cursor: pointer;
	transition: transform 0.12s ease, filter 0.12s ease;

	&:hover {
		transform: translateY(-1px);
		filter: brightness(1.08);
	}
}

.cal-grid {
	display: grid;
	grid-template-columns: repeat(7, 1fr);
	gap: 8px;
}

.cal-grid .w {
	text-align: center;
	font-size: 12px;
	font-weight: 700;
	color: #94a3b8;
}

.day {
	position: relative;
	aspect-ratio: 1;
	border-radius: 14px;
	border: none;
	background: #f3f7fb;
	color: #334155;
	font-size: 13px;
	font-weight: 650;
	cursor: pointer;
	transition: transform 0.12s ease, background 0.12s ease, box-shadow 0.12s ease;

	&:hover:not(.mute):not(:disabled) {
		transform: translateY(-1px);
		background: #e8f6fc;
	}

	&:disabled {
		cursor: default;
	}
}

.day.mute {
	opacity: 0.32;
}
.day.has {
	background: rgba(0, 168, 232, 0.12);
	color: #0369a1;
	font-weight: 780;
}
.day.today {
	background: linear-gradient(145deg, #122033, #1e3a5f);
	color: #fff;
	font-weight: 780;
	box-shadow: 0 8px 18px rgba(15, 23, 36, 0.18);
}
.day.active {
	box-shadow:
		0 0 0 2px rgba(0, 168, 232, 0.35),
		0 8px 16px rgba(0, 168, 232, 0.16);
}
.day.today.active {
	box-shadow:
		0 0 0 2px rgba(56, 189, 248, 0.55),
		0 8px 18px rgba(15, 23, 36, 0.18);
}
.day .dot {
	position: absolute;
	left: 50%;
	bottom: 5px;
	width: 4px;
	height: 4px;
	border-radius: 50%;
	background: #00a8e8;
	transform: translateX(-50%);
}
.day.today .dot {
	background: #7dd3fc;
}

.note-board {
	margin-top: 14px;
	padding: 14px;
	border-radius: 18px;
	background: linear-gradient(180deg, rgba(247, 251, 254, 0.98), rgba(255, 255, 255, 0.94));
	border: 1px solid #eaf1f7;
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
		font-weight: 750;
		color: #122033;
	}
	em {
		display: block;
		margin-top: 3px;
		font-style: normal;
		font-size: 12px;
		color: #7a8796;
	}
}

.note-type-tabs {
	display: flex;
	flex-wrap: wrap;
	justify-content: flex-end;
	gap: 6px;

	button {
		height: 26px;
		padding: 0 10px;
		border-radius: 999px;
		border: 1px solid #e2e8f0;
		background: #fff;
		color: #64748b;
		font-size: 11px;
		font-weight: 700;
		cursor: pointer;

		&.active {
			color: #fff;
			border-color: transparent;
			background: linear-gradient(135deg, #00a8e8, #38bdf8);
			box-shadow: 0 5px 12px rgba(0, 168, 232, 0.22);
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
	background: #fff;
	border: 1px solid #eaf1f7;
}

.note-tag {
	flex-shrink: 0;
	height: 22px;
	padding: 0 8px;
	border-radius: 999px;
	display: inline-flex;
	align-items: center;
	font-size: 11px;
	font-weight: 750;
	color: #0369a1;
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
		color: #1f2a37;
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
	height: 24px;
	padding: 0 8px;
	border: none;
	border-radius: 8px;
	background: rgba(148, 163, 184, 0.12);
	color: #64748b;
	font-size: 11px;
	font-weight: 700;
	cursor: pointer;

	&:hover {
		background: rgba(239, 68, 68, 0.12);
		color: #dc2626;
	}
}

.note-empty {
	margin-bottom: 12px;
	padding: 16px 12px;
	border-radius: 14px;
	text-align: center;
	font-size: 12.5px;
	color: #7a8796;
	background: rgba(255, 255, 255, 0.7);
	border: 1px dashed rgba(0, 168, 232, 0.18);
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
		border: 1px solid #e2e8f0;
		outline: none;
		background: #fff;
		color: #122033;
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
	}
}

.note-add {
	height: 32px;
	padding: 0 14px;
	border: none;
	border-radius: 999px;
	background: linear-gradient(135deg, #00a8e8, #2bbef5);
	color: #fff;
	font-size: 12px;
	font-weight: 750;
	cursor: pointer;
	box-shadow: 0 8px 16px rgba(0, 168, 232, 0.22);

	&:disabled {
		opacity: 0.45;
		cursor: not-allowed;
		box-shadow: none;
	}
}

.inbox-panel .count {
	min-width: 30px;
	height: 30px;
	border-radius: 999px;
	display: grid;
	place-items: center;
	background: linear-gradient(135deg, #00a8e8, #38bdf8);
	color: #fff;
	font-size: 12px;
	font-weight: 780;
	box-shadow: 0 6px 14px rgba(0, 168, 232, 0.22);
}

.inbox-list,
.msg-list {
	list-style: none;
	margin: 0;
	padding: 0;
	display: flex;
	flex-direction: column;
	gap: 10px;
}

.inbox-list li,
.msg-list li {
	display: flex;
	align-items: center;
	gap: 10px;
	padding: 12px;
	border-radius: 16px;
	background: linear-gradient(180deg, #f8fcff, #f3f8fc);
	border: 1px solid #eaf1f7;
	transition: transform 0.14s ease, box-shadow 0.14s ease;

	&:hover {
		transform: translateY(-1px);
		box-shadow: 0 8px 18px rgba(15, 23, 36, 0.04);
	}
}

.badge {
	width: 30px;
	height: 30px;
	border-radius: 10px;
	display: grid;
	place-items: center;
	font-size: 12px;
	font-weight: 780;
	flex-shrink: 0;
}
.badge.high {
	background: rgba(235, 103, 9, 0.14);
	color: #c2410c;
}
.badge.mid {
	background: rgba(0, 168, 232, 0.12);
	color: #0369a1;
}
.badge.low {
	background: rgba(100, 116, 139, 0.12);
	color: #64748b;
}

.inbox-list .body {
	flex: 1;
	min-width: 0;
	strong {
		display: block;
		font-size: 13px;
		font-weight: 720;
		color: #1f2a37;
	}
	em {
		font-style: normal;
		font-size: 12px;
		color: #7a8796;
	}
}

.inbox-list button {
	height: 30px;
	padding: 0 12px;
	border: none;
	border-radius: 999px;
	background: rgba(0, 168, 232, 0.1);
	color: #007eb8;
	font-size: 12px;
	font-weight: 700;
	cursor: pointer;
	transition: background 0.12s ease, color 0.12s ease;

	&:hover {
		background: linear-gradient(135deg, #00a8e8, #38bdf8);
		color: #fff;
	}
}

.msg-list .avatar {
	width: 36px;
	height: 36px;
	border-radius: 13px;
	display: grid;
	place-items: center;
	color: #fff;
	font-size: 12px;
	font-weight: 780;
	flex-shrink: 0;
	box-shadow: 0 6px 14px rgba(15, 23, 36, 0.12);
}

.msg-body {
	flex: 1;
	min-width: 0;
}

.msg-list strong {
	display: block;
	font-size: 13px;
	font-weight: 720;
	color: #122033;
}
.msg-list p {
	margin: 2px 0 0;
	font-size: 12px;
	color: #64748b;
}
.msg-list em {
	margin-left: auto;
	font-style: normal;
	font-size: 11px;
	font-weight: 650;
	color: #94a3b8;
	flex-shrink: 0;
}

@media (max-width: 1200px) {
	.wb-bento {
		grid-template-columns: 1fr 1fr;
	}
	.inbox-panel {
		grid-column: 1 / -1;
	}
}

@media (max-width: 860px) {
	.wb-hero {
		flex-direction: column;
		align-items: flex-start;
	}
	.hero-actions {
		width: 100%;
		align-items: stretch;
	}
	.stat-pills {
		justify-content: flex-start;
	}
	.btn-home {
		width: 100%;
	}
	.wb-bento {
		grid-template-columns: 1fr;
	}
}
</style>
