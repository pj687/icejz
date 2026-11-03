<template>
	<div class="home-page">
		<section class="hero">
			<div class="hero-main">
				<div class="hero-mascot" title="单击变身 · 双击打开对话">
					<transition name="pet-bubble">
						<div v-if="petBubbleVisible" class="pet-speech-bubble" @click.stop="openAssistant()">
							<p>{{ petBubbleText }}</p>
							<button type="button" class="pet-bubble-close" aria-label="关闭" @click.stop="hidePetBubble">
								×
							</button>
							<i class="pet-bubble-tail" aria-hidden="true"></i>
						</div>
					</transition>
					<IceBotMascot
						ref="welcomePetRef"
						size="xl"
						pet
						form="fly"
						click-to-morph
						:bounce="true"
						:talking="petBubbleVisible"
						:auto-morph-ms="0"
						:auto-action-ms="0"
						@morph="onWelcomeMorph"
						@morph-request="onWelcomeMorphRequest"
						@dblclick="openAssistant()"
					/>
				</div>

				<div class="hero-copy">
					<div class="hero-brand">
						<img class="brand-logo" src="/logo.png" alt="ICEJZ" />
						<div>
							<span class="kicker">{{ assistantStore.robotName }} · ICEJZ</span>
							<p class="brand-line">平台总览</p>
						</div>
					</div>

					<h1>{{ helloTitle }}</h1>
					<p class="hero-lead">{{ helloLead }}</p>

					<div class="hero-actions">
						<button class="btn-primary" type="button" @click="go('/dashboard/workbench')">进入工作台</button>
						<button class="btn-ghost" type="button" @click="go('/sys/user/index')">用户管理</button>
						<button class="btn-ghost" type="button" @click="go('/iframe/53')">代码生成</button>
						<button class="btn-ghost accent" type="button" @click="openAssistant()">呼叫小冰</button>
					</div>

					<div class="ask-box">
						<input v-model="ask" type="text" placeholder="问问小冰任何事..." @keyup.enter="onAsk" />
						<button type="button" @click="onAsk">发送</button>
					</div>
				</div>
			</div>

			<div class="metric-rail" aria-label="关键指标">
				<article v-for="item in metrics" :key="item.label" class="metric-item">
					<span class="metric-label">{{ item.label }}</span>
					<strong>{{ item.value }}</strong>
					<em :class="item.trend">{{ item.hint }}</em>
				</article>
			</div>
		</section>

		<div class="home-body">
			<div class="home-main">
				<section class="week-board">
					<header class="section-head">
						<div>
							<h2>本周计划</h2>
							<p>{{ weekRange }}</p>
						</div>
						<span class="chip">{{ doneCount }}/{{ weekPlans.length }} 已推进</span>
					</header>

					<div class="week-days" role="list">
						<button
							v-for="day in weekDays"
							:key="day.key"
							type="button"
							class="day-pill"
							:class="{ active: activeDay === day.key, today: day.isToday }"
							@click="activeDay = day.key"
						>
							<em>{{ day.label }}</em>
							<strong>{{ day.date }}</strong>
							<span v-if="day.count" class="day-count">{{ day.count }}</span>
						</button>
					</div>

					<div class="plan-list">
						<article v-for="item in filteredPlans" :key="item.id" class="plan-row" :class="'tone-' + item.tone">
							<div class="plan-status" :class="item.status">{{ statusLabel(item.status) }}</div>
							<div class="plan-main">
								<strong>{{ item.title }}</strong>
								<p>{{ item.desc }}</p>
							</div>
							<div class="plan-meta">
								<span class="owner">{{ item.owner }}</span>
								<span class="when">{{ item.when }}</span>
							</div>
						</article>
						<div v-if="!filteredPlans.length" class="plan-empty">这一天暂无安排</div>
					</div>
				</section>

				<section class="aside-block entry-block">
					<header class="section-head compact">
						<div>
							<h2>快捷入口</h2>
							<p>常用能力一键到达</p>
						</div>
					</header>
					<div class="entry-grid">
						<button v-for="item in entries" :key="item.path" type="button" class="entry-card" @click="go(item.path)">
							<span class="entry-mark">{{ item.mark }}</span>
							<span class="entry-copy">
								<strong>{{ item.title }}</strong>
								<em>{{ item.desc }}</em>
							</span>
						</button>
					</div>
				</section>
			</div>

			<aside class="home-aside">
				<section class="aside-block">
					<header class="section-head compact">
						<div>
							<h2>近期事项</h2>
							<p>接下来需要关注的节点</p>
						</div>
					</header>
					<ol class="focus-list">
						<li v-for="(item, idx) in events" :key="item.id">
							<span class="focus-index">{{ String(idx + 1).padStart(2, '0') }}</span>
							<div class="focus-body">
								<div class="focus-top">
									<strong>{{ item.title }}</strong>
									<em>{{ item.date }} · {{ item.time }}</em>
								</div>
								<p>{{ item.desc }}</p>
							</div>
						</li>
					</ol>
				</section>

				<section class="aside-block">
					<header class="section-head compact">
						<div>
							<h2>模块进展</h2>
							<p>核心工程线建设情况</p>
						</div>
					</header>
					<div class="module-list">
						<article v-for="item in progresses" :key="item.name" class="module-row">
							<div class="module-head">
								<div>
									<strong>{{ item.name }}</strong>
									<em>{{ item.owner }}</em>
								</div>
								<span>{{ item.percent }}%</span>
							</div>
							<div class="module-track" :aria-label="item.name + ' ' + item.percent + '%'">
								<i :style="{ width: item.percent + '%' }"></i>
							</div>
							<span class="module-foot">{{ item.done }}/{{ item.total }} 完成</span>
						</article>
					</div>
				</section>
			</aside>
		</div>
	</div>
</template>

<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/store/modules/user'
import IceBotMascot from '@/components/assistant/IceBotMascot.vue'
import type { IceBotForm } from '@/components/assistant/IceBotMascot.vue'
import { useAssistantStore } from '@/store/modules/assistant'
import { useAiRobotInfoApi } from '@/api/sys/ai'
import { getDashboardLead, getGreetHello, getShortHello } from '@/components/assistant/greetings'

const router = useRouter()
const userStore = useUserStore()
const assistantStore = useAssistantStore()
const ask = ref('')
const welcomePetRef = ref<InstanceType<typeof IceBotMascot> | null>(null)
const petBubbleVisible = ref(false)
const petBubbleText = ref('')
let petBubbleTimer = 0

const displayName = computed(() => userStore.user.realName || '管理员')
const helloTitle = computed(() => getShortHello(displayName.value))
const helloLead = computed(() => getDashboardLead(displayName.value))

const hidePetBubble = () => {
	if (petBubbleTimer) {
		window.clearTimeout(petBubbleTimer)
		petBubbleTimer = 0
	}
	petBubbleVisible.value = false
}

const showPetBubble = (text: string, duration = 5600) => {
	petBubbleText.value = text
	petBubbleVisible.value = true
	if (petBubbleTimer) window.clearTimeout(petBubbleTimer)
	petBubbleTimer = window.setTimeout(() => {
		petBubbleVisible.value = false
		petBubbleTimer = 0
	}, duration)
}

const onWelcomeMorphRequest = () => {
	if (welcomePetRef.value?.morphing) return
	welcomePetRef.value?.transform()
}

const onWelcomeMorph = (form: IceBotForm) => {
	const name = displayName.value
	const text =
		form === 'fly'
			? `飞行态报到！${getGreetHello(name)}`
			: `机体合体完成～${getGreetHello(name)}`
	showPetBubble(text, 6200)
	if (form === 'bot') {
		window.setTimeout(() => welcomePetRef.value?.greet(), 80)
	}
}

onMounted(async () => {
	try {
		const { data } = await useAiRobotInfoApi()
		assistantStore.setRobotProfile({ name: data?.name, welcome: data?.welcome })
	} catch {
		// ignore
	}
})

onBeforeUnmount(() => {
	hidePetBubble()
})

const dayLabels = ['日', '一', '二', '三', '四', '五', '六']
const now = new Date()
const mondayOffset = (now.getDay() + 6) % 7
const monday = new Date(now)
monday.setDate(now.getDate() - mondayOffset)

const weekDays = Array.from({ length: 7 }, (_, index) => {
	const date = new Date(monday)
	date.setDate(monday.getDate() + index)
	const key = `${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()}`
	return {
		key,
		label: dayLabels[date.getDay()],
		date: `${date.getMonth() + 1}/${date.getDate()}`,
		isToday:
			date.getFullYear() === now.getFullYear() &&
			date.getMonth() === now.getMonth() &&
			date.getDate() === now.getDate(),
		count: 0
	}
})

const activeDay = ref(weekDays.find((d) => d.isToday)?.key || weekDays[0].key)

const weekRange = computed(() => {
	const start = weekDays[0]
	const end = weekDays[6]
	return `${start.date} — ${end.date}`
})

type PlanStatus = 'doing' | 'todo' | 'done'

const weekPlans = [
	{
		id: 1,
		title: '角色权限复核',
		desc: '核对菜单授权与组织数据范围',
		owner: '系统管理',
		when: '上午',
		tone: 'blue',
		status: 'doing' as PlanStatus,
		dayIndex: 0
	},
	{
		id: 2,
		title: '代码生成模板输出',
		desc: '补齐 CRUD 与导入导出模板',
		owner: '工程交付',
		when: '全天',
		tone: 'teal',
		status: 'todo' as PlanStatus,
		dayIndex: 1
	},
	{
		id: 3,
		title: '数据源联调',
		desc: '生成器接入业务库并验证导入',
		owner: '数据平台',
		when: '下午',
		tone: 'cyan',
		status: 'todo' as PlanStatus,
		dayIndex: 2
	},
	{
		id: 4,
		title: '巡检窗口',
		desc: '服务健康检查与告警策略确认',
		owner: '运维监控',
		when: '上午',
		tone: 'amber',
		status: 'todo' as PlanStatus,
		dayIndex: 3
	},
	{
		id: 5,
		title: '版本评审会',
		desc: '确认发布清单与回归范围',
		owner: '产品协作',
		when: '10:00',
		tone: 'blue',
		status: 'doing' as PlanStatus,
		dayIndex: mondayOffset
	},
	{
		id: 6,
		title: '权限策略同步',
		desc: '菜单与角色授权对齐',
		owner: '系统管理',
		when: '周五上午',
		tone: 'teal',
		status: 'done' as PlanStatus,
		dayIndex: 4
	}
].map((item) => ({
	...item,
	dayKey: weekDays[Math.min(Math.max(item.dayIndex, 0), 6)].key
}))

weekDays.forEach((day) => {
	day.count = weekPlans.filter((item) => item.dayKey === day.key).length
})

const filteredPlans = computed(() => weekPlans.filter((item) => item.dayKey === activeDay.value))
const doneCount = computed(() => weekPlans.filter((item) => item.status === 'done' || item.status === 'doing').length)

const statusLabel = (status: PlanStatus) => {
	if (status === 'doing') return '进行中'
	if (status === 'done') return '已完成'
	return '待开始'
}

const metrics = [
	{ label: '在线模块', value: '12', hint: '核心能力已接入', trend: 'up' },
	{ label: '本周事项', value: String(weekPlans.length), hint: '含评审与联调', trend: 'flat' },
	{ label: '平均进度', value: '60%', hint: '四条工程线', trend: 'up' },
	{ label: '待办优先', value: '3', hint: '今日需跟进', trend: 'warn' }
]

const events = [
	{ id: 1, time: '10:00', date: '今天', title: '版本评审会', desc: '确认本周发布清单与回归范围' },
	{ id: 2, time: '14:30', date: '明天', title: '数据源联调', desc: '生成器接入业务库并验证导入' },
	{ id: 3, time: '09:30', date: '周五', title: '权限策略同步', desc: '菜单与角色授权对齐' }
]

const progresses = [
	{ name: 'icejz-boot', owner: '后端主线', done: 8, total: 10, percent: 80 },
	{ name: 'icejz-admin', owner: '管理端', done: 7, total: 10, percent: 70 },
	{ name: 'icejz-cloud', owner: '微服务', done: 5, total: 10, percent: 50 },
	{ name: 'icejz-app', owner: '移动端', done: 4, total: 10, percent: 40 }
]

const entries = [
	{ title: '工作台', desc: '日常处理入口', path: '/dashboard/workbench', mark: '台' },
	{ title: '用户管理', desc: '账号与组织', path: '/sys/user/index', mark: '用' },
	{ title: '代码生成', desc: '工程加速', path: '/iframe/53', mark: '码' },
	{ title: '系统参数', desc: '全局配置', path: '/sys/config/index', mark: '参' }
]

const go = (path: string) => {
	router.push(path).catch(() => undefined)
}

const openAssistant = (text?: string) => {
	assistantStore.openPanel(text)
}

const onAsk = () => {
	const text = ask.value.trim()
	if (!text) return
	ask.value = ''
	openAssistant(text)
}
</script>

<style lang="scss" scoped>
.home-page {
	--ink: #122033;
	--muted: #64748b;
	--soft: #f5f9fc;
	--line: #e7eef5;
	--panel: #fff;
	--brand: #00a8e8;
	--brand-deep: #007eb8;
	display: flex;
	flex-direction: column;
	gap: 20px;
	min-height: calc(100vh - 140px);
	padding: 4px 2px 20px;
	animation: rise 0.35s ease both;
	background:
		radial-gradient(920px 320px at 100% -8%, rgba(0, 168, 232, 0.08), transparent 55%),
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

.hero {
	display: grid;
	gap: 16px;
	padding: 20px 22px 18px;
	border-radius: 22px;
	border: 1px solid rgba(0, 168, 232, 0.14);
	background:
		linear-gradient(145deg, color-mix(in srgb, var(--panel) 96%, transparent), color-mix(in srgb, var(--soft) 90%, transparent)),
		radial-gradient(520px 240px at 0% 40%, rgba(0, 168, 232, 0.1), transparent 60%);
	box-shadow: 0 14px 32px rgba(15, 23, 36, 0.04);
}

.hero-main {
	display: grid;
	grid-template-columns: 200px minmax(0, 1fr);
	gap: 18px;
	align-items: center;
}

.hero-mascot {
	position: relative;
	z-index: 2;
	width: 200px;
	min-height: 200px;
	display: grid;
	place-items: center;
	justify-self: center;
	cursor: pointer;
}

.hero-copy {
	min-width: 0;
}

.hero-brand {
	display: flex;
	align-items: center;
	gap: 12px;
	margin-bottom: 12px;
}

.brand-logo {
	width: 44px;
	height: 44px;
	border-radius: 14px;
	object-fit: cover;
	background: var(--panel);
	box-shadow: 0 8px 18px rgba(0, 168, 232, 0.18);
}

.kicker {
	display: inline-block;
	font-size: 12px;
	font-weight: 700;
	letter-spacing: 0.04em;
	color: var(--brand-deep);
}

.brand-line {
	margin: 2px 0 0;
	font-size: 13px;
	font-weight: 650;
	color: var(--muted);
}

.hero-copy h1 {
	margin: 0 0 8px;
	font-size: 30px;
	line-height: 1.2;
	font-weight: 760;
	color: var(--ink);
	letter-spacing: -0.02em;
}

.hero-lead {
	margin: 0 0 16px;
	max-width: 52ch;
	font-size: 14px;
	line-height: 1.65;
	color: var(--muted);
}

.hero-actions {
	display: flex;
	flex-wrap: wrap;
	gap: 8px;
	margin-bottom: 14px;
}

.btn-primary,
.btn-ghost {
	height: 38px;
	padding: 0 14px;
	border-radius: 12px;
	border: none;
	font-size: 13px;
	font-weight: 650;
	cursor: pointer;
	transition: transform 0.18s ease, box-shadow 0.18s ease, background 0.18s ease;
}

.btn-primary {
	color: #fff;
	background: linear-gradient(135deg, #00a8e8, #0090d0);
	box-shadow: 0 10px 20px rgba(0, 168, 232, 0.24);

	&:hover {
		transform: translateY(-1px);
	}
}

.btn-ghost {
	color: var(--brand-deep);
	background: rgba(0, 168, 232, 0.08);
	border: 1px solid rgba(0, 168, 232, 0.12);

	&.accent {
		background: rgba(0, 168, 232, 0.14);
	}

	&:hover {
		background: rgba(0, 168, 232, 0.14);
	}
}

.ask-box {
	display: flex;
	gap: 8px;
	max-width: 520px;
	padding: 6px;
	border-radius: 14px;
	background: color-mix(in srgb, var(--panel) 82%, transparent);
	border: 1px solid rgba(0, 168, 232, 0.14);

	input {
		flex: 1;
		min-width: 0;
		height: 38px;
		border: none;
		outline: none;
		background: transparent;
		color: var(--ink);
		padding: 0 10px;
		font-size: 13px;
	}

	input::placeholder {
		color: #94a3b8;
	}

	button {
		height: 38px;
		padding: 0 14px;
		border: none;
		border-radius: 10px;
		background: var(--brand);
		color: #fff;
		font-size: 13px;
		font-weight: 700;
		cursor: pointer;
	}
}

.metric-rail {
	display: grid;
	grid-template-columns: repeat(4, minmax(0, 1fr));
	gap: 0;
	border-top: 1px solid rgba(0, 168, 232, 0.1);
	padding-top: 14px;
}

.metric-item {
	padding: 4px 16px;
	border-right: 1px solid rgba(0, 168, 232, 0.1);

	&:last-child {
		border-right: none;
	}

	.metric-label {
		display: block;
		font-size: 12px;
		font-weight: 650;
		color: var(--muted);
	}

	strong {
		display: block;
		margin-top: 6px;
		font-size: 26px;
		line-height: 1;
		letter-spacing: -0.03em;
		color: var(--ink);
		font-variant-numeric: tabular-nums;
	}

	em {
		display: block;
		margin-top: 6px;
		font-style: normal;
		font-size: 12px;
		color: var(--muted);

		&.up {
			color: #0f766e;
		}
		&.warn {
			color: #b45309;
		}
	}
}

.home-body {
	display: grid;
	grid-template-columns: minmax(0, 1.45fr) minmax(280px, 0.9fr);
	gap: 16px;
	align-items: start;
}

.home-main,
.home-aside {
	display: flex;
	flex-direction: column;
	gap: 16px;
	min-width: 0;
}

.week-board,
.aside-block {
	padding: 18px;
	border-radius: 20px;
	background: color-mix(in srgb, var(--panel) 94%, transparent);
	border: 1px solid var(--line);
	box-shadow: 0 10px 24px rgba(15, 23, 36, 0.035);
}

.section-head {
	display: flex;
	align-items: flex-start;
	justify-content: space-between;
	gap: 12px;
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

	&.compact {
		margin-bottom: 12px;
	}
}

.chip {
	padding: 6px 10px;
	border-radius: 999px;
	font-size: 12px;
	font-weight: 650;
	color: var(--brand-deep);
	background: rgba(0, 168, 232, 0.1);
	white-space: nowrap;
}

.week-days {
	display: grid;
	grid-template-columns: repeat(7, minmax(0, 1fr));
	gap: 8px;
	margin-bottom: 14px;
}

.day-pill {
	position: relative;
	display: flex;
	flex-direction: column;
	align-items: flex-start;
	gap: 4px;
	min-height: 64px;
	padding: 10px 12px;
	border-radius: 14px;
	border: 1px solid transparent;
	background: var(--soft);
	cursor: pointer;
	text-align: left;
	transition: background 0.18s ease, border-color 0.18s ease, transform 0.18s ease;

	em {
		font-style: normal;
		font-size: 12px;
		color: #7a8796;
	}

	strong {
		font-size: 15px;
		color: var(--ink);
		font-weight: 720;
	}

	&.today {
		border-color: rgba(0, 168, 232, 0.22);
	}

	&.active {
		background: rgba(0, 168, 232, 0.1);
		border-color: rgba(0, 168, 232, 0.28);
		transform: translateY(-1px);

		em,
		strong {
			color: var(--brand-deep);
		}
	}
}

.day-count {
	position: absolute;
	top: 8px;
	right: 8px;
	min-width: 18px;
	height: 18px;
	padding: 0 5px;
	border-radius: 999px;
	display: grid;
	place-items: center;
	font-size: 11px;
	font-weight: 700;
	color: var(--brand-deep);
	background: rgba(0, 168, 232, 0.12);
}

.plan-list {
	display: flex;
	flex-direction: column;
	gap: 8px;
}

.plan-row {
	display: grid;
	grid-template-columns: 72px minmax(0, 1fr) auto;
	gap: 12px;
	align-items: center;
	padding: 12px 14px;
	border-radius: 14px;
	background: var(--soft);

	&.tone-teal .plan-status.doing,
	&.tone-cyan .plan-status.doing {
		color: var(--brand-deep);
	}
}

.plan-status {
	height: 26px;
	padding: 0 8px;
	border-radius: 999px;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	font-size: 11px;
	font-weight: 700;
	color: var(--muted);
	background: var(--soft);

	&.doing {
		color: var(--brand-deep);
		background: rgba(0, 168, 232, 0.12);
	}

	&.done {
		color: #0f766e;
		background: rgba(15, 118, 110, 0.1);
	}
}

.plan-main {
	min-width: 0;

	strong {
		display: block;
		font-size: 14px;
		color: var(--ink);
	}

	p {
		margin: 4px 0 0;
		font-size: 12px;
		color: #7a8796;
		line-height: 1.45;
	}
}

.plan-meta {
	display: flex;
	flex-direction: column;
	align-items: flex-end;
	gap: 4px;
	font-size: 12px;
	color: #7a8796;
	white-space: nowrap;

	.owner {
		color: #334155;
		font-weight: 650;
	}
}

.plan-empty {
	padding: 28px 12px;
	text-align: center;
	font-size: 13px;
	color: #94a3b8;
	border-radius: 14px;
	border: 1px dashed var(--line);
	background: var(--soft);
}

.focus-list {
	list-style: none;
	margin: 0;
	padding: 0;
	display: flex;
	flex-direction: column;
	gap: 10px;
}

.focus-list li {
	display: grid;
	grid-template-columns: 40px minmax(0, 1fr);
	gap: 10px;
	padding: 10px 0;
	border-bottom: 1px solid #eef3f8;

	&:last-child {
		border-bottom: none;
		padding-bottom: 0;
	}
}

.focus-index {
	width: 40px;
	height: 40px;
	border-radius: 12px;
	display: grid;
	place-items: center;
	font-size: 13px;
	font-weight: 760;
	color: var(--brand-deep);
	background: rgba(0, 168, 232, 0.1);
}

.focus-top {
	display: flex;
	justify-content: space-between;
	gap: 10px;
	align-items: baseline;

	strong {
		font-size: 14px;
		color: var(--ink);
	}

	em {
		font-style: normal;
		font-size: 12px;
		color: #7a8796;
		white-space: nowrap;
	}
}

.focus-body p {
	margin: 6px 0 0;
	font-size: 12px;
	line-height: 1.5;
	color: var(--muted);
}

.module-list {
	display: flex;
	flex-direction: column;
	gap: 12px;
}

.module-row {
	padding-bottom: 10px;
	border-bottom: 1px solid #eef3f8;

	&:last-child {
		border-bottom: none;
		padding-bottom: 0;
	}
}

.module-head {
	display: flex;
	justify-content: space-between;
	gap: 12px;
	align-items: flex-start;
	margin-bottom: 8px;

	strong {
		display: block;
		font-size: 14px;
		color: var(--ink);
	}

	em {
		display: block;
		margin-top: 2px;
		font-style: normal;
		font-size: 12px;
		color: #7a8796;
	}

	span {
		font-size: 13px;
		font-weight: 720;
		color: var(--brand-deep);
		font-variant-numeric: tabular-nums;
	}
}

.module-track {
	height: 7px;
	border-radius: 999px;
	background: #e8eef5;
	overflow: hidden;

	i {
		display: block;
		height: 100%;
		border-radius: inherit;
		background: linear-gradient(90deg, #00a8e8, #3ec6ff);
	}
}

.module-foot {
	display: inline-block;
	margin-top: 6px;
	font-size: 12px;
	color: var(--muted);
}

.entry-grid {
	display: grid;
	grid-template-columns: repeat(2, minmax(0, 1fr));
	gap: 10px;
}

.entry-card {
	display: flex;
	align-items: center;
	gap: 12px;
	width: 100%;
	padding: 14px 12px;
	border: 1px solid transparent;
	border-radius: 14px;
	background: var(--soft);
	cursor: pointer;
	text-align: left;
	transition: background 0.18s ease, border-color 0.18s ease, transform 0.18s ease;

	&:hover {
		background: rgba(0, 168, 232, 0.08);
		border-color: rgba(0, 168, 232, 0.16);
		transform: translateY(-1px);
	}
}

.entry-mark {
	width: 36px;
	height: 36px;
	border-radius: 11px;
	display: grid;
	place-items: center;
	font-size: 13px;
	font-weight: 760;
	color: var(--brand-deep);
	background: rgba(0, 168, 232, 0.1);
	flex-shrink: 0;
}

.entry-copy {
	min-width: 0;
	display: flex;
	flex-direction: column;
	gap: 2px;

	strong {
		font-size: 13px;
		color: var(--ink);
	}

	em {
		font-style: normal;
		font-size: 12px;
		color: #7a8796;
	}
}

.pet-speech-bubble {
	position: absolute;
	left: calc(100% - 24px);
	top: 16px;
	z-index: 3;
	width: max-content;
	max-width: 220px;
	padding: 10px 28px 10px 12px;
	border-radius: 16px 16px 16px 6px;
	background: color-mix(in srgb, var(--panel) 97%, transparent);
	border: 1px solid rgba(0, 168, 232, 0.2);
	box-shadow: 0 12px 28px rgba(8, 50, 80, 0.14);
	cursor: pointer;

	p {
		margin: 0;
		font-size: 12.5px;
		line-height: 1.55;
		font-weight: 650;
		color: #0f4f6e;
		word-break: break-word;
	}
}

.pet-bubble-close {
	position: absolute;
	top: 4px;
	right: 4px;
	width: 20px;
	height: 20px;
	border: none;
	border-radius: 8px;
	background: transparent;
	color: #94a3b8;
	font-size: 14px;
	line-height: 1;
	cursor: pointer;

	&:hover {
		background: rgba(0, 168, 232, 0.1);
		color: var(--brand-deep);
	}
}

.pet-bubble-tail {
	position: absolute;
	left: -6px;
	bottom: 14px;
	width: 12px;
	height: 12px;
	background: var(--panel);
	border-left: 1px solid rgba(0, 168, 232, 0.2);
	border-bottom: 1px solid rgba(0, 168, 232, 0.2);
	transform: rotate(45deg);
}

.pet-bubble-enter-active,
.pet-bubble-leave-active {
	transition: opacity 0.22s ease, transform 0.22s ease;
}
.pet-bubble-enter-from,
.pet-bubble-leave-to {
	opacity: 0;
	transform: translateX(-8px) scale(0.96);
}

@media (max-width: 1100px) {
	.home-body {
		grid-template-columns: 1fr;
	}

	.metric-rail {
		grid-template-columns: repeat(2, minmax(0, 1fr));
		gap: 12px;
	}

	.metric-item {
		border-right: none;
		padding: 8px 4px;
		border-top: 1px solid rgba(0, 168, 232, 0.08);
	}
}

@media (max-width: 640px) {
	.entry-grid {
		grid-template-columns: 1fr;
	}
}

@media (max-width: 860px) {
	.hero-main,
	.week-days {
		grid-template-columns: 1fr;
	}

	.hero-mascot {
		width: 180px;
		min-height: 180px;
	}

	.hero-copy h1 {
		font-size: 24px;
	}

	.plan-row {
		grid-template-columns: 1fr;
		gap: 8px;
	}

	.plan-meta {
		align-items: flex-start;
		flex-direction: row;
		gap: 10px;
	}

	.pet-speech-bubble {
		left: 50%;
		top: 0;
		transform: translate(-50%, -8px);
		border-radius: 16px 16px 6px 16px;
	}

	.pet-bubble-tail {
		left: 50%;
		bottom: -6px;
		transform: translateX(-50%) rotate(-45deg);
		border-left: none;
		border-right: 1px solid rgba(0, 168, 232, 0.2);
		border-bottom: 1px solid rgba(0, 168, 232, 0.2);
	}

	.pet-bubble-enter-from,
	.pet-bubble-leave-to {
		transform: translate(-50%, 0) scale(0.96);
	}
}
</style>
