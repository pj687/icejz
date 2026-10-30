<template>
	<div
		v-show="!assistantStore.open"
		ref="fabRef"
		class="assistant-fab"
		:class="[{ dragging, moving }, `form-${currentForm}`]"
		:style="fabStyle"
		@pointerdown="onPointerDown"
		@click="onClick"
		@dblclick.stop="openChat"
	>
		<div class="fab-stage" :data-action="currentAction" :data-form="currentForm">
			<transition name="bubble">
				<div
					v-if="bubbleVisible"
					class="speech-bubble"
					@pointerdown.stop
					@click.stop="onBubbleClick"
				>
					<p>{{ bubbleText }}</p>
					<button type="button" class="bubble-close" aria-label="关闭" @click.stop="hideBubble">×</button>
					<i class="bubble-tail" aria-hidden="true"></i>
				</div>
			</transition>

			<button
				type="button"
				class="morph-fab-btn"
				:data-form="currentForm"
				title="机体 ↔ 飞行 变身"
				@pointerdown.stop
				@click.stop="morphNow"
			>
				变身
			</button>
			<span class="action-chip" v-if="currentAction !== 'idle'">{{ actionChip }}</span>

			<div class="stage-glow" aria-hidden="true"></div>
			<div class="stage-pedestal" aria-hidden="true"></div>

			<IceBotMascot
				ref="botRef"
				size="lg"
				pet
				:form="currentForm"
				:bounce="!dragging && currentAction === 'idle'"
				:talking="bubbleVisible"
				:auto-morph-ms="0"
				:auto-action-ms="20000"
				@morph="onMorph"
				@action="onPetAction"
			/>
		</div>

		<button
			v-if="assistantStore.dockHidden"
			type="button"
			class="dock-reveal"
			title="展开操作栏"
			@pointerdown.stop
			@click.stop="assistantStore.setDockHidden(false)"
		>
			展开
		</button>

		<div v-else class="fab-dock" @pointerdown.stop @click.stop>
			<div class="dock-head">
				<span class="dock-head-title">操作</span>
				<button type="button" class="dock-hide-btn" title="隐藏操作栏" @click="assistantStore.setDockHidden(true)">
					隐藏
				</button>
			</div>
			<div v-for="group in actionGroups" :key="group.key" class="dock-row actions" :data-group="group.key">
				<span class="dock-group-label">{{ group.label }}</span>
				<button
					v-for="item in group.items"
					:key="item.key"
					type="button"
					class="dock-btn soft"
					:class="{ active: currentAction === item.key }"
					:title="item.label"
					:disabled="currentForm === 'fly'"
					@click="playAction(item.key)"
				>
					{{ item.short }}
				</button>
			</div>
			<div class="dock-row tools">
				<button type="button" class="dock-btn soft" title="打招呼" @click="greetNow">招呼</button>
				<button
					type="button"
					class="dock-btn accent"
					:class="{ active: currentForm === 'fly' }"
					title="机体 ↔ 飞行 变身"
					@click="morphNow"
				>
					变身
				</button>
				<button type="button" class="dock-btn primary" title="打开对话" @click="openChat">对话</button>
			</div>
		</div>
	</div>
</template>

<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import IceBotMascot from './IceBotMascot.vue'
import type { IceBotForm, IcePetAction } from './IceBotMascot.vue'
import { DOCK_PET_STATES } from './petStates'
import { useAssistantStore } from '@/store/modules/assistant'
import { useUserStore } from '@/store/modules/user'
import { buildGreeting, getClickHello } from './greetings'

const props = withDefaults(
	defineProps<{
		/** 登录页等未登录场景 */
		guest?: boolean
	}>(),
	{ guest: false }
)

const assistantStore = useAssistantStore()
const userStore = useUserStore()
const fabRef = ref<HTMLElement | null>(null)
const botRef = ref<InstanceType<typeof IceBotMascot> | null>(null)
const dragging = ref(false)
const moving = ref(false)
const pos = ref({ x: 0, y: 0 })
const fabW = 300
const currentForm = ref<IceBotForm>('fly')
const currentAction = ref<IcePetAction>('idle')
const fabH = computed(() => {
	const fly = currentForm.value === 'fly'
	if (assistantStore.dockHidden) return fly ? 188 : 240
	return fly ? 300 : 360
})

const petActions = DOCK_PET_STATES.map(s => ({
	key: s.name,
	short: s.short,
	label: s.label,
	tip: s.tip,
	group: s.group
}))

const actionGroups = computed(() => {
	const defs: Array<{ key: 'react' | 'work'; label: string }> = [
		{ key: 'react', label: '互动' },
		{ key: 'work', label: '工作' }
	]
	return defs
		.map(d => ({
			...d,
			items: petActions.filter(i => i.group === d.key)
		}))
		.filter(g => g.items.length > 0)
})

const formTips: Record<IceBotForm, string> = {
	bot: '变身完成：机体小冰回来啦～',
	fly: '变身完成：飞行头出击！'
}

const actionChip = computed(() => petActions.find(i => i.key === currentAction.value)?.short || '')

const bubbleVisible = ref(false)
const bubbleText = ref('')

let startX = 0
let startY = 0
let originX = 0
let originY = 0
let pointerId = 0
let suppressClick = false
let hideTimer = 0
let idleTimer = 0
let bootTimer = 0

const userName = computed(() =>
	props.guest ? '朋友' : userStore.user?.realName || userStore.user?.username || ''
)

const clamp = (x: number, y: number) => {
	const h = fabH.value
	const maxX = Math.max(8, window.innerWidth - fabW - 8)
	const maxY = Math.max(8, window.innerHeight - h - 12)
	return {
		x: Math.min(maxX, Math.max(8, x)),
		y: Math.min(maxY, Math.max(8, y))
	}
}

const defaultPos = () => clamp(window.innerWidth - fabW - 12, window.innerHeight - fabH.value - 16)

const fabStyle = computed(() => ({
	left: `${pos.value.x}px`,
	top: `${pos.value.y}px`
}))

const clearHideTimer = () => {
	if (hideTimer) {
		window.clearTimeout(hideTimer)
		hideTimer = 0
	}
}

const hideBubble = () => {
	clearHideTimer()
	bubbleVisible.value = false
}

const showBubble = (text: string, duration = 5200) => {
	if (assistantStore.open || dragging.value) return
	bubbleText.value = text
	bubbleVisible.value = true
	clearHideTimer()
	hideTimer = window.setTimeout(() => {
		bubbleVisible.value = false
		hideTimer = 0
	}, duration)
}

const greetNow = () => {
	showBubble(buildGreeting('greet', userName.value), 6500)
	if (currentForm.value === 'fly') {
		botRef.value?.transformTo('bot')
		window.setTimeout(() => botRef.value?.play('waving'), 900)
		return
	}
	botRef.value?.play('waving')
}

const morphNow = () => {
	showBubble(currentForm.value === 'bot' ? '变身中…起飞！' : '变身中…合体！', 1400)
	botRef.value?.transform()
}

const playAction = (key: IcePetAction) => {
	if (currentForm.value === 'fly') {
		showBubble('先变回机体再做动作哦～', 2200)
		botRef.value?.transformTo('bot')
		window.setTimeout(() => botRef.value?.play(key), 900)
		return
	}
	botRef.value?.play(key)
}

const onMorph = (form: IceBotForm) => {
	currentForm.value = form
	showBubble(formTips[form], 3200)
}

const onPetAction = (act: IcePetAction) => {
	currentAction.value = act
	const hit = petActions.find(i => i.key === act)
	if (hit?.tip && act !== 'idle') showBubble(hit.tip, 2200)
}

const scheduleIdleGreet = () => {
	if (idleTimer) window.clearTimeout(idleTimer)
	const delay = 45000 + Math.random() * 45000
	idleTimer = window.setTimeout(() => {
		if (!assistantStore.open && !dragging.value && document.visibilityState === 'visible') {
			showBubble(buildGreeting('idle', userName.value), 4800)
		}
		scheduleIdleGreet()
	}, delay)
}

const openChat = () => {
	hideBubble()
	assistantStore.openPanel()
}

const onBubbleClick = () => {
	hideBubble()
	assistantStore.openPanel()
}

const onClick = () => {
	if (suppressClick || moving.value) return
	botRef.value?.playRandom()
	showBubble(getClickHello(userName.value), 1800)
}

const onPointerDown = (e: PointerEvent) => {
	if (e.button !== 0) return
	const target = e.target as HTMLElement
	if (
		target.closest('.fab-dock') ||
		target.closest('.dock-reveal') ||
		target.closest('.speech-bubble')
	) {
		return
	}
	e.preventDefault()
	const el = fabRef.value
	if (!el) return
	dragging.value = true
	moving.value = false
	suppressClick = false
	pointerId = e.pointerId
	el.setPointerCapture(pointerId)
	startX = e.clientX
	startY = e.clientY
	originX = pos.value.x
	originY = pos.value.y
	window.addEventListener('pointermove', onPointerMove)
	window.addEventListener('pointerup', onPointerUp)
}

const onPointerMove = (e: PointerEvent) => {
	if (!dragging.value) return
	const dx = e.clientX - startX
	const dy = e.clientY - startY
	if (Math.abs(dx) > 4 || Math.abs(dy) > 4) {
		moving.value = true
		suppressClick = true
		hideBubble()
	}
	pos.value = clamp(originX + dx, originY + dy)
}

const onPointerUp = () => {
	window.removeEventListener('pointermove', onPointerMove)
	window.removeEventListener('pointerup', onPointerUp)
	dragging.value = false
	try {
		fabRef.value?.releasePointerCapture(pointerId)
	} catch {
		// ignore
	}
	if (moving.value) {
		assistantStore.setFabPos({ ...pos.value })
	}
	requestAnimationFrame(() => {
		moving.value = false
		setTimeout(() => {
			suppressClick = false
		}, 0)
	})
}

const onResize = () => {
	pos.value = clamp(pos.value.x, pos.value.y)
	assistantStore.setFabPos({ ...pos.value })
}

const onVisibility = () => {
	if (document.visibilityState === 'visible' && !assistantStore.open) {
		showBubble(buildGreeting('hello', userName.value), 4500)
	}
}

watch(
	() => assistantStore.open,
	val => {
		if (val) hideBubble()
		else {
			bootTimer = window.setTimeout(() => {
				showBubble(buildGreeting('hello', userName.value), 5000)
			}, 600)
		}
	}
)

watch(
	() => [assistantStore.dockHidden, currentForm.value] as const,
	() => {
		pos.value = clamp(pos.value.x, pos.value.y)
		assistantStore.setFabPos({ ...pos.value })
	}
)

onMounted(() => {
	pos.value = assistantStore.fabPos ? clamp(assistantStore.fabPos.x, assistantStore.fabPos.y) : defaultPos()
	window.addEventListener('resize', onResize)
	document.addEventListener('visibilitychange', onVisibility)
	bootTimer = window.setTimeout(() => {
		showBubble(buildGreeting('hello', userName.value), 6200)
	}, 900)
	scheduleIdleGreet()
})

onBeforeUnmount(() => {
	window.removeEventListener('resize', onResize)
	document.removeEventListener('visibilitychange', onVisibility)
	window.removeEventListener('pointermove', onPointerMove)
	window.removeEventListener('pointerup', onPointerUp)
	clearHideTimer()
	if (idleTimer) window.clearTimeout(idleTimer)
	if (bootTimer) window.clearTimeout(bootTimer)
})
</script>

<style scoped lang="scss">
.assistant-fab {
	position: fixed;
	z-index: 2600;
	width: 300px;
	display: flex;
	flex-direction: column;
	align-items: center;
	gap: 8px;
	overflow: visible;
	touch-action: none;
	user-select: none;
	cursor: grab;

	&.dragging {
		z-index: 2800;
		cursor: grabbing;
	}

	&.form-fly {
		gap: 2px;

		.fab-stage {
			width: 168px;
			height: 148px;
			align-content: end;
			place-items: end center;
			padding-bottom: 4px;
		}

		.stage-glow {
			top: 48%;
			width: 112px;
			height: 112px;
		}

		.stage-pedestal {
			bottom: 8px;
			width: 78px;
			height: 12px;
		}

		.morph-fab-btn {
			top: 0;
			left: -8px;
		}

		.action-chip {
			top: 0;
			right: -8px;
		}

		.speech-bubble {
			top: 0;
			right: calc(100% - 18px);
		}

		.dock-reveal {
			margin-top: 0;
		}

		.fab-dock {
			margin-top: 2px;
		}
	}
}

.fab-stage {
	position: relative;
	z-index: 3;
	width: 210px;
	height: 224px;
	display: grid;
	place-items: center;
	overflow: visible;
	isolation: isolate;
	transition: width 0.22s ease, height 0.22s ease;
}

.stage-glow {
	position: absolute;
	left: 50%;
	top: 42%;
	z-index: 0;
	width: 150px;
	height: 150px;
	border-radius: 50%;
	background: radial-gradient(circle, rgba(56, 189, 248, 0.22), rgba(56, 189, 248, 0.06) 48%, transparent 72%);
	transform: translate(-50%, -50%);
	pointer-events: none;
	animation: stage-breathe 4.2s ease-in-out infinite;
}

.stage-pedestal {
	position: absolute;
	left: 50%;
	bottom: 18px;
	z-index: 0;
	width: 108px;
	height: 18px;
	border-radius: 50%;
	background: radial-gradient(ellipse, rgba(8, 50, 80, 0.16), transparent 72%);
	transform: translateX(-50%);
	pointer-events: none;
	filter: blur(0.2px);
}

.morph-fab-btn {
	position: absolute;
	left: 0;
	top: 4px;
	z-index: 4;
	height: 24px;
	padding: 0 10px;
	border: 1px solid rgba(14, 165, 233, 0.28);
	border-radius: 999px;
	cursor: pointer;
	font-size: 10px;
	font-weight: 750;
	letter-spacing: 0.04em;
	color: #0369a1;
	background: rgba(255, 255, 255, 0.95);
	box-shadow: 0 4px 12px rgba(8, 50, 80, 0.12);
	backdrop-filter: blur(8px);
	transition:
		transform 0.14s ease,
		background 0.14s ease,
		color 0.14s ease,
		box-shadow 0.14s ease;

	&:hover {
		transform: translateY(-1px);
		color: #fff;
		border-color: transparent;
		background: linear-gradient(135deg, #0284c7, #38bdf8);
		box-shadow: 0 6px 14px rgba(2, 132, 199, 0.28);
	}

	&:active {
		transform: translateY(0) scale(0.97);
	}

	&[data-form='fly'] {
		color: #0284c7;
		background: rgba(224, 242, 254, 0.96);
	}
}

.action-chip {
	position: absolute;
	right: 0;
	top: 4px;
	z-index: 2;
	padding: 3px 9px;
	border-radius: 999px;
	font-size: 10px;
	font-weight: 750;
	letter-spacing: 0.04em;
	pointer-events: none;
	color: #fff;
	background: linear-gradient(135deg, #00a8e8, #38bdf8);
	border: 1px solid rgba(255, 255, 255, 0.35);
	backdrop-filter: blur(8px);
	box-shadow: 0 4px 12px rgba(8, 50, 80, 0.1);
}

.speech-bubble {
	position: absolute;
	right: calc(100% - 4px);
	top: 8px;
	z-index: 2;
	width: max-content;
	max-width: 240px;
	padding: 10px 28px 10px 12px;
	border-radius: 16px 16px 6px 16px;
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

.bubble-close {
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

.bubble-tail {
	position: absolute;
	right: -6px;
	bottom: 14px;
	width: 12px;
	height: 12px;
	background: #fff;
	border-right: 1px solid rgba(0, 168, 232, 0.2);
	border-bottom: 1px solid rgba(0, 168, 232, 0.2);
	transform: rotate(-45deg);
}

.bubble-enter-active,
.bubble-leave-active {
	transition: opacity 0.22s ease, transform 0.22s ease;
}
.bubble-enter-from,
.bubble-leave-to {
	opacity: 0;
	transform: translateX(8px) scale(0.96);
}

.dock-reveal {
	position: relative;
	z-index: 1;
	height: 28px;
	margin-top: 0;
	padding: 0 14px;
	border: 1px solid rgba(0, 168, 232, 0.18);
	border-radius: 999px;
	cursor: pointer;
	font-size: 11px;
	font-weight: 750;
	color: #0f4f6e;
	background: rgba(255, 255, 255, 0.94);
	box-shadow: 0 8px 18px rgba(15, 23, 36, 0.1);
	backdrop-filter: blur(10px);
	transition: transform 0.14s ease, box-shadow 0.14s ease;

	&:hover {
		transform: translateY(-1px);
		box-shadow: 0 10px 22px rgba(15, 23, 36, 0.12);
	}
}

.fab-dock {
	position: relative;
	z-index: 1;
	display: flex;
	flex-direction: column;
	align-items: stretch;
	gap: 6px;
	width: 100%;
	max-width: 300px;
	padding: 8px 10px 10px;
	border-radius: 20px;
	background:
		linear-gradient(180deg, rgba(255, 255, 255, 0.97), rgba(244, 250, 255, 0.94));
	border: 1px solid rgba(0, 168, 232, 0.18);
	box-shadow:
		0 10px 28px rgba(15, 23, 36, 0.1),
		inset 0 1px 0 rgba(255, 255, 255, 0.9);
	backdrop-filter: blur(12px);
	opacity: 0.94;
	transition: opacity 0.18s ease, box-shadow 0.18s ease, transform 0.18s ease;
}

.dock-head {
	display: flex;
	align-items: center;
	justify-content: space-between;
	padding: 0 2px 2px;
}

.dock-head-title {
	font-size: 10px;
	font-weight: 750;
	letter-spacing: 0.06em;
	color: #7aa0b5;
}

.dock-hide-btn {
	height: 22px;
	padding: 0 8px;
	border: none;
	border-radius: 999px;
	cursor: pointer;
	font-size: 10px;
	font-weight: 700;
	color: #64748b;
	background: rgba(148, 163, 184, 0.14);
	transition: background 0.14s ease, color 0.14s ease;

	&:hover {
		color: #0f4f6e;
		background: rgba(0, 168, 232, 0.12);
	}
}

.assistant-fab:hover .fab-dock,
.assistant-fab.dragging .fab-dock {
	opacity: 1;
	transform: translateY(-1px);
	box-shadow:
		0 14px 32px rgba(15, 23, 36, 0.14),
		inset 0 1px 0 rgba(255, 255, 255, 0.95);
}

.dock-row {
	display: flex;
	flex-wrap: wrap;
	align-items: center;
	justify-content: flex-start;
	gap: 5px;
	width: 100%;

	&.tools {
		justify-content: center;
		padding-top: 6px;
		border-top: 1px solid rgba(0, 168, 232, 0.12);
	}
}

.dock-group-label {
	flex: 0 0 auto;
	min-width: 28px;
	margin-right: 2px;
	font-size: 10px;
	font-weight: 750;
	letter-spacing: 0.06em;
	color: #7aa0b5;
}

.dock-btn {
	display: inline-flex;
	align-items: center;
	justify-content: center;
	height: 28px;
	min-width: 40px;
	padding: 0 9px;
	border: none;
	border-radius: 999px;
	cursor: pointer;
	font-size: 11px;
	font-weight: 700;
	line-height: 1;
	white-space: nowrap;
	letter-spacing: 0.02em;
	transition:
		transform 0.14s ease,
		filter 0.14s ease,
		background 0.14s ease,
		color 0.14s ease,
		box-shadow 0.14s ease,
		opacity 0.14s ease;

	&:hover:not(:disabled) {
		transform: translateY(-1px);
		filter: brightness(1.03);
	}

	&:active:not(:disabled) {
		transform: translateY(0) scale(0.97);
	}

	&:disabled {
		opacity: 0.42;
		cursor: not-allowed;
	}

	&.soft {
		color: #0f4f6e;
		background: rgba(0, 168, 232, 0.1);
		border: 1px solid rgba(0, 168, 232, 0.08);

		&.active {
			color: #fff;
			border-color: transparent;
			background: linear-gradient(135deg, #00a8e8, #38bdf8);
			box-shadow: 0 5px 12px rgba(0, 168, 232, 0.3);
		}
	}

	&.accent {
		color: #0369a1;
		background: rgba(125, 211, 252, 0.28);
		border: 1px solid rgba(14, 165, 233, 0.22);

		&.active {
			color: #fff;
			border-color: transparent;
			background: linear-gradient(135deg, #0284c7, #38bdf8);
			box-shadow: 0 5px 12px rgba(2, 132, 199, 0.32);
		}
	}

	&.primary {
		color: #fff;
		background: linear-gradient(135deg, #00a8e8, #2bbef5);
		box-shadow: 0 6px 14px rgba(0, 168, 232, 0.28);
		min-width: 56px;
	}
}

@keyframes stage-breathe {
	0%,
	100% {
		opacity: 0.72;
		transform: translate(-50%, -50%) scale(1);
	}
	50% {
		opacity: 1;
		transform: translate(-50%, -50%) scale(1.06);
	}
}
</style>
