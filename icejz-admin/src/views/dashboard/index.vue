<template>
	<div class="home-page">
		<section class="home-top">
			<div class="brand-block">
				<img class="brand-logo" src="/logo.png" alt="ICEJZ" />
				<div>
					<span class="kicker">ICEJZ Home</span>
					<h1>平台总览</h1>
					<p>从这里进入工作台，统筹系统能力、交付进度与协作动态。</p>
				</div>
			</div>
			<div class="top-actions">
				<button class="btn-primary" type="button" @click="go('/dashboard/workbench')">进入工作台</button>
				<button class="btn-soft" type="button" @click="go('/iframe/53')">代码生成</button>
			</div>
		</section>

		<section class="panel welcome-panel">
			<div class="welcome-glow" aria-hidden="true"></div>
			<div class="welcome-body">
				<div class="welcome-mascot" title="单击变身 · 双击打开对话">
					<transition name="pet-bubble">
						<div
							v-if="petBubbleVisible"
							class="pet-speech-bubble"
							@click.stop="openAssistant()"
						>
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
						@dblclick="openAssistant()"
					/>
				</div>
				<div class="welcome-copy">
					<span class="kicker soft">{{ assistantStore.robotName }} · Assistant</span>
					<h2>{{ helloTitle }}</h2>
					<p>{{ helloLead }}</p>
					<div class="quick-btns">
						<button type="button" @click="go('/dashboard/workbench')">打开工作台</button>
						<button type="button" @click="go('/sys/user/index')">用户管理</button>
						<button type="button" @click="go('/iframe/53')">代码生成器</button>
						<button type="button" class="primary" @click="openAssistant()">呼叫小冰</button>
					</div>
					<div class="ask-box">
						<input v-model="ask" type="text" placeholder="问问小冰任何事..." @keyup.enter="onAsk" />
						<button type="button" @click="onAsk">↵</button>
					</div>
				</div>
			</div>
		</section>

		<section class="timeline-card">
			<header class="section-head">
				<div>
					<h2>本周计划</h2>
					<p>关键交付节点与协作安排</p>
				</div>
				<span class="chip">Week Plan</span>
			</header>
			<div class="timeline-track">
				<article v-for="item in weekPlans" :key="item.id" class="timeline-row">
					<div class="who">
						<span class="avatar" :style="{ background: item.color }">{{ item.short }}</span>
						<div>
							<strong>{{ item.name }}</strong>
							<em>{{ item.role }}</em>
						</div>
					</div>
					<div class="bars">
						<span
							v-for="bar in item.bars"
							:key="bar.label"
							class="bar"
							:class="bar.tone"
							:style="{ gridColumn: `${bar.start} / span ${bar.span}` }"
						>
							{{ bar.label }}
						</span>
					</div>
				</article>
				<div class="days">
					<span v-for="d in days" :key="d">{{ d }}</span>
				</div>
			</div>
		</section>

		<section class="bento">
			<div class="panel events-panel">
				<header class="section-head">
					<div>
						<h2>近期事项</h2>
						<p>活动与会议提醒</p>
					</div>
				</header>
				<div class="event-list">
					<article v-for="(item, idx) in events" :key="item.id" class="event-card" :class="{ accent: idx === 0 }">
						<div class="event-meta">
							<strong>{{ item.time }}</strong>
							<em>{{ item.date }}</em>
						</div>
						<h3>{{ item.title }}</h3>
						<p>{{ item.desc }}</p>
						<div class="avatars">
							<span v-for="a in item.people" :key="a" class="mini">{{ a }}</span>
						</div>
					</article>
				</div>
			</div>

			<div class="panel progress-panel">
				<header class="section-head">
					<div>
						<h2>能力进度</h2>
						<p>模块建设与接入情况</p>
					</div>
				</header>
				<div class="progress-grid">
					<article v-for="item in progresses" :key="item.name" class="progress-card">
						<span class="dot" :style="{ background: item.color }"></span>
						<strong>{{ item.name }}</strong>
						<em>{{ item.owner }}</em>
						<div class="bar-track">
							<i :style="{ width: item.percent + '%', background: item.color }"></i>
						</div>
						<span class="percent">{{ item.done }}/{{ item.total }} 完成</span>
					</article>
				</div>
			</div>
		</section>
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

const onWelcomeMorph = (form: IceBotForm) => {
	const name = displayName.value
	const text =
		form === 'fly'
			? `飞行态报到！${getGreetHello(name)}`
			: `机体合体完成～${getGreetHello(name)}`
	showPetBubble(text, 6200)
	if (form === 'bot') {
		window.setTimeout(() => welcomePetRef.value?.play('waving'), 80)
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

const days = ['一', '二', '三', '四', '五', '六', '日']

const weekPlans = [
	{
		id: 1,
		name: '系统管理',
		role: '权限与组织',
		short: '系',
		color: 'linear-gradient(135deg,#00a8e8,#3ec6ff)',
		bars: [{ label: '角色复核', start: 1, span: 3, tone: 'blue' }]
	},
	{
		id: 2,
		name: '代码生成',
		role: '工程交付',
		short: '码',
		color: 'linear-gradient(135deg,#2fbfa4,#7ad9c8)',
		bars: [{ label: '模板输出', start: 2, span: 4, tone: 'teal' }]
	},
	{
		id: 3,
		name: '运维监控',
		role: '稳定性',
		short: '运',
		color: 'linear-gradient(135deg,#f0a202,#f6c85f)',
		bars: [{ label: '巡检窗口', start: 4, span: 3, tone: 'amber' }]
	}
]

const events = [
	{ id: 1, time: '10:00', date: '今天', title: '版本评审会', desc: '确认本周发布清单与回归范围', people: ['张', '李', '王'] },
	{ id: 2, time: '14:30', date: '明天', title: '数据源联调', desc: '生成器接入业务库并验证导入', people: ['陈', '赵'] },
	{ id: 3, time: '09:30', date: '周五', title: '权限策略同步', desc: '菜单与角色授权对齐', people: ['周', '吴'] }
]

const progresses = [
	{ name: 'icejz-boot', owner: '后端主线', done: 8, total: 10, percent: 80, color: '#00a8e8' },
	{ name: 'icejz-admin', owner: '管理端', done: 7, total: 10, percent: 70, color: '#2fbfa4' },
	{ name: 'icejz-cloud', owner: '微服务', done: 5, total: 10, percent: 50, color: '#1496d4' },
	{ name: 'icejz-app', owner: '移动端', done: 4, total: 10, percent: 40, color: '#f0a202' }
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
	display: flex;
	flex-direction: column;
	gap: 16px;
	animation: rise 0.45s ease both;
	padding: 2px;
	min-height: calc(100vh - 140px);
	background:
		radial-gradient(900px 360px at 100% -10%, rgba(0, 168, 232, 0.08), transparent 55%),
		radial-gradient(700px 280px at 0% 100%, rgba(47, 191, 164, 0.07), transparent 50%);
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

.home-top {
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 16px;
	padding: 8px 4px;
}

.brand-block {
	display: flex;
	gap: 14px;
	align-items: center;
}

.brand-logo {
	width: 52px;
	height: 52px;
	border-radius: 16px;
	object-fit: cover;
	background: #fff;
	box-shadow: 0 10px 24px rgba(0, 168, 232, 0.2);
}

.kicker {
	display: inline-block;
	margin-bottom: 4px;
	font-size: 12px;
	font-weight: 700;
	letter-spacing: 0.06em;
	color: #00a8e8;
}

.kicker.light {
	color: rgba(255, 255, 255, 0.85);
}

.brand-block h1 {
	margin: 0;
	font-size: 26px;
	color: #122033;
	font-weight: 760;
}

.brand-block p {
	margin: 6px 0 0;
	color: #64748b;
	font-size: 13px;
}

.top-actions {
	display: flex;
	gap: 10px;
	flex-wrap: wrap;
}

.btn-primary,
.btn-soft {
	height: 40px;
	padding: 0 16px;
	border-radius: 999px;
	border: none;
	font-weight: 650;
	cursor: pointer;
}

.btn-primary {
	color: #fff;
	background: linear-gradient(135deg, #00a8e8, #0090d0);
	box-shadow: 0 10px 22px rgba(0, 168, 232, 0.28);
}

.btn-soft {
	color: #007eb8;
	background: rgba(0, 168, 232, 0.1);
}

.timeline-card,
.panel {
	border-radius: 24px;
	background: rgba(255, 255, 255, 0.9);
	border: 1px solid rgba(232, 238, 245, 0.95);
	box-shadow: 0 14px 36px rgba(15, 23, 36, 0.05);
	padding: 18px;
}

.section-head {
	display: flex;
	align-items: flex-start;
	justify-content: space-between;
	margin-bottom: 14px;

	h2 {
		margin: 0 0 4px;
		font-size: 16px;
		color: #122033;
	}
	p {
		margin: 0;
		font-size: 12px;
		color: #7a8796;
	}
}

.chip {
	padding: 6px 10px;
	border-radius: 999px;
	font-size: 12px;
	font-weight: 650;
	color: #007eb8;
	background: rgba(0, 168, 232, 0.1);
}

.timeline-track {
	display: flex;
	flex-direction: column;
	gap: 12px;
}

.timeline-row {
	display: grid;
	grid-template-columns: 180px 1fr;
	gap: 12px;
	align-items: center;
}

.who {
	display: flex;
	gap: 10px;
	align-items: center;

	strong {
		display: block;
		font-size: 13px;
		color: #1f2a37;
	}
	em {
		font-style: normal;
		font-size: 12px;
		color: #7a8796;
	}
}

.avatar {
	width: 36px;
	height: 36px;
	border-radius: 12px;
	display: grid;
	place-items: center;
	color: #fff;
	font-size: 13px;
	font-weight: 700;
}

.bars {
	display: grid;
	grid-template-columns: repeat(7, 1fr);
	gap: 6px;
	min-height: 34px;
	align-items: center;
}

.bar {
	height: 28px;
	border-radius: 999px;
	display: grid;
	place-items: center;
	font-size: 12px;
	font-weight: 650;
	color: #0f3a4d;
	padding: 0 10px;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
}

.bar.blue {
	background: rgba(0, 168, 232, 0.22);
}
.bar.teal {
	background: rgba(47, 191, 164, 0.24);
}
.bar.amber {
	background: rgba(240, 162, 2, 0.24);
}

.days {
	display: grid;
	grid-template-columns: 180px repeat(7, 1fr);
	gap: 6px;
	padding-left: 192px;
	color: #94a3b8;
	font-size: 12px;
}

.bento {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 16px;
}

.event-list {
	display: flex;
	flex-direction: column;
	gap: 10px;
}

.event-card {
	padding: 14px;
	border-radius: 18px;
	background: #f7fbfe;
	border: 1px solid #eaf1f7;

	&.accent {
		background: linear-gradient(160deg, #fff7df, #fff);
		border-color: rgba(240, 162, 2, 0.25);
	}

	h3 {
		margin: 8px 0 4px;
		font-size: 15px;
		color: #122033;
	}
	p {
		margin: 0 0 10px;
		font-size: 12px;
		color: #64748b;
		line-height: 1.5;
	}
}

.event-meta {
	display: flex;
	justify-content: space-between;
	font-size: 12px;
	color: #7a8796;
}

.avatars {
	display: flex;
	gap: 6px;
}

.mini {
	width: 24px;
	height: 24px;
	border-radius: 50%;
	display: grid;
	place-items: center;
	font-size: 11px;
	font-weight: 700;
	color: #0369a1;
	background: rgba(0, 168, 232, 0.14);
}

.progress-grid {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 10px;
}

.progress-card {
	padding: 14px;
	border-radius: 18px;
	background: #f8fbfd;
	border: 1px solid #eaf1f7;

	.dot {
		display: inline-block;
		width: 8px;
		height: 8px;
		border-radius: 50%;
		margin-bottom: 8px;
	}
	strong {
		display: block;
		font-size: 14px;
		color: #122033;
	}
	em {
		display: block;
		margin: 4px 0 10px;
		font-style: normal;
		font-size: 12px;
		color: #7a8796;
	}
}

.bar-track {
	height: 7px;
	border-radius: 999px;
	background: #e8eef5;
	overflow: hidden;
	margin-bottom: 8px;

	i {
		display: block;
		height: 100%;
		border-radius: inherit;
	}
}

.percent {
	font-size: 12px;
	color: #64748b;
}

.welcome-panel {
	position: relative;
	overflow: visible;
	min-height: 240px;
	color: #122033;
	border: 1px solid rgba(0, 168, 232, 0.14);
	background:
		linear-gradient(145deg, rgba(255, 255, 255, 0.55), rgba(232, 247, 253, 0.35)),
		radial-gradient(520px 280px at 0% 50%, rgba(0, 168, 232, 0.12), transparent 55%);
	backdrop-filter: blur(14px);
	box-shadow: 0 12px 32px rgba(15, 23, 36, 0.04);
}

.welcome-glow {
	position: absolute;
	left: -40px;
	top: -60px;
	width: 260px;
	height: 260px;
	border-radius: 50%;
	background: radial-gradient(circle, rgba(62, 198, 255, 0.28), transparent 68%);
	pointer-events: none;
	overflow: hidden;
}

.welcome-body {
	position: relative;
	z-index: 1;
	display: grid;
	grid-template-columns: 220px minmax(0, 1fr);
	gap: 20px;
	align-items: center;
	min-height: 220px;
	padding: 16px 8px 16px 8px;
	overflow: visible;
}

.welcome-copy {
	min-width: 0;
}

.kicker.soft {
	display: inline-flex;
	align-items: center;
	padding: 4px 10px;
	border-radius: 999px;
	font-size: 12px;
	font-weight: 700;
	letter-spacing: 0.02em;
	color: #007eb8;
	background: rgba(0, 168, 232, 0.1);
	border: 1px solid rgba(0, 168, 232, 0.16);
}

.welcome-panel h2 {
	margin: 12px 0 8px;
	font-size: 28px;
	font-weight: 760;
	color: #0f1724;
}

.welcome-panel p {
	margin: 0 0 16px;
	color: #5f7386;
	line-height: 1.65;
	font-size: 13px;
}

.welcome-mascot {
	justify-self: center;
	align-self: center;
	position: relative;
	z-index: 2;
	width: 220px;
	min-height: 220px;
	display: grid;
	place-items: center;
	background: transparent;
	padding: 12px 0;
	overflow: visible;
	cursor: pointer;
}

.pet-speech-bubble {
	position: absolute;
	left: calc(100% - 28px);
	top: 18px;
	z-index: 3;
	width: max-content;
	max-width: 220px;
	padding: 10px 28px 10px 12px;
	border-radius: 16px 16px 16px 6px;
	background: rgba(255, 255, 255, 0.97);
	border: 1px solid rgba(0, 168, 232, 0.2);
	box-shadow: 0 12px 28px rgba(8, 50, 80, 0.14);
	backdrop-filter: blur(10px);
	cursor: pointer;

	p {
		margin: 0;
		font-size: 12.5px;
		line-height: 1.55;
		font-weight: 650;
		color: #0f4f6e;
		white-space: normal;
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
		color: #007eb8;
	}
}

.pet-bubble-tail {
	position: absolute;
	left: -6px;
	bottom: 14px;
	width: 12px;
	height: 12px;
	background: #fff;
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

.quick-btns {
	display: flex;
	flex-wrap: wrap;
	gap: 8px;
	margin-bottom: 14px;

	button {
		height: 34px;
		padding: 0 12px;
		border-radius: 999px;
		border: 1px solid rgba(0, 168, 232, 0.16);
		background: rgba(255, 255, 255, 0.72);
		color: #0f4f6e;
		cursor: pointer;
		font-size: 12px;
		font-weight: 650;
		backdrop-filter: blur(6px);

		&.primary {
			color: #fff;
			border-color: transparent;
			background: linear-gradient(135deg, #00a8e8, #2bbef5);
			box-shadow: 0 8px 18px rgba(0, 168, 232, 0.24);
		}
	}
}

.ask-box {
	display: flex;
	gap: 8px;
	padding: 8px;
	border-radius: 16px;
	background: rgba(255, 255, 255, 0.7);
	border: 1px solid rgba(0, 168, 232, 0.12);
	backdrop-filter: blur(8px);

	input {
		flex: 1;
		height: 38px;
		border: none;
		outline: none;
		background: transparent;
		color: #122033;
		padding: 0 10px;
	}
	input::placeholder {
		color: #94a3b8;
	}
	button {
		width: 38px;
		height: 38px;
		border: none;
		border-radius: 12px;
		background: linear-gradient(135deg, #00a8e8, #2bbef5);
		color: #fff;
		font-weight: 700;
		cursor: pointer;
	}
}

@media (max-width: 860px) {
	.home-top,
	.timeline-row,
	.bento,
	.progress-grid,
	.welcome-body {
		grid-template-columns: 1fr;
		display: grid;
	}
	.home-top {
		display: flex;
		flex-direction: column;
		align-items: flex-start;
	}
	.welcome-mascot {
		justify-self: center;
	}
	.pet-speech-bubble {
		left: 50%;
		right: auto;
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
	.days {
		display: none;
	}
	.timeline-row {
		grid-template-columns: 1fr;
	}
}
</style>
