<template>
	<div
		class="ice-bot"
		:class="[
			size,
			form,
			{
				talking,
				bounce: bounce && form === 'bot' && action === 'idle' && !morphing,
				badge,
				morphing,
				pet,
				sprite: useSprite
			}
		]"
		:aria-label="name"
	>
		<div class="bot-figure" @click.stop="onFigureClick" @dblclick.stop="onFigureDblClick">
			<template v-if="useSprite || morphPlaying">
				<span class="bot-ground-shadow" aria-hidden="true"></span>
				<div class="bot-sprite-clip" :class="{ morph: morphPlaying }" :style="clipStyle">
					<div class="bot-sprite-sheet" :style="activeSheetStyle" />
				</div>
			</template>
			<img
				v-else
				class="bot-core"
				:src="coreSrc"
				:alt="name"
				draggable="false"
			/>
			<span v-if="morphPlaying" class="morph-burst" aria-hidden="true"></span>
			<span v-if="talking && !morphPlaying" class="talk-glow" aria-hidden="true"></span>
		</div>
		<span v-if="showName" class="bot-name">{{ formLabel }}</span>
	</div>
</template>

<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import {
	MORPH_SHEET,
	PET_SHEET,
	PET_SIZE_SCALE,
	PET_STATE_MAP,
	RANDOM_PET_STATES,
	type IcePetAction,
	type IcePetState
} from './petStates'

export type { IcePetAction, IcePetState }
export type IceBotForm = 'bot' | 'fly'
export type IceBotFormLegacy = IceBotForm | 'head' | 'drone'

const FORM_CYCLE: IceBotForm[] = ['bot', 'fly']

const normalizeForm = (f: IceBotFormLegacy | undefined): IceBotForm => {
	if (f === 'head' || f === 'drone') return 'fly'
	if (f === 'fly' || f === 'bot') return f
	return 'fly'
}

const props = withDefaults(
	defineProps<{
		name?: string
		size?: 'sm' | 'md' | 'lg' | 'xl'
		talking?: boolean
		bounce?: boolean
		showName?: boolean
		badge?: boolean
		form?: IceBotFormLegacy
		action?: IcePetAction
		pet?: boolean
		clickToMorph?: boolean
		autoMorphMs?: number
		autoActionMs?: number
		morphDuration?: number
	}>(),
	{
		name: '小冰',
		size: 'md',
		talking: false,
		bounce: true,
		showName: false,
		badge: false,
		form: 'fly',
		action: 'idle',
		pet: false,
		clickToMorph: false,
		autoMorphMs: 0,
		autoActionMs: 0,
		morphDuration: 1100
	}
)

const emit = defineEmits<{
	'update:form': [IceBotForm]
	'update:action': [IcePetAction]
	morph: [IceBotForm]
	action: [IcePetAction]
	dblclick: []
}>()

const BOT_SRC = '/mascot/xiaobing-main.png?v=8'
const FLY_SRC = '/mascot/xiaobing-head.png?v=2'

const innerForm = ref<IceBotForm>(normalizeForm(props.form))
const innerAction = ref<IcePetAction>(props.action)
const morphing = ref(false)
const morphPlaying = ref(false)
const morphRow = ref(0)
const frame = ref(0)
const sheetUrl = ref(PET_SHEET.src)
const morphSheetUrl = ref(MORPH_SHEET.src)

let morphTimer = 0
let holdTimer = 0
let frameTimer = 0
let autoMorphTimer = 0
let autoActionTimer = 0
let clickDelayTimer = 0

watch(
	() => props.form,
	val => {
		const next = normalizeForm(val)
		if (next !== innerForm.value && !morphing.value) innerForm.value = next
	}
)

watch(
	() => props.action,
	val => {
		if (val && val !== innerAction.value) play(val)
	}
)

const form = computed(() => innerForm.value)
const action = computed(() => innerAction.value)
const useSprite = computed(() => props.pet && form.value === 'bot' && !morphPlaying.value)
const formLabel = computed(() => (form.value === 'fly' ? `${props.name}·飞行` : props.name))
const coreSrc = computed(() => (form.value === 'fly' ? FLY_SRC : BOT_SRC))
const stateMeta = computed(() => PET_STATE_MAP[innerAction.value] || PET_STATE_MAP.idle)

const clipStyle = computed(() => {
	const scale = PET_SIZE_SCALE[props.size]
	return {
		width: `${PET_SHEET.cellW * scale}px`,
		height: `${PET_SHEET.cellH * scale}px`
	}
})

const petSheetStyle = computed(() => {
	const scale = PET_SIZE_SCALE[props.size]
	const { cellW, cellH, width, height } = PET_SHEET
	const col = frame.value % stateMeta.value.frames
	const row = stateMeta.value.row
	return {
		width: `${width * scale}px`,
		height: `${height * scale}px`,
		backgroundImage: `url(${sheetUrl.value})`,
		transform: `translate(${-col * cellW * scale}px, ${-row * cellH * scale}px)`
	}
})

const morphSheetStyle = computed(() => {
	const scale = PET_SIZE_SCALE[props.size]
	const { cellW, cellH, width, height, frames } = MORPH_SHEET
	const col = Math.min(frame.value, frames - 1)
	const row = morphRow.value
	return {
		width: `${width * scale}px`,
		height: `${height * scale}px`,
		backgroundImage: `url(${morphSheetUrl.value})`,
		transform: `translate(${-col * cellW * scale}px, ${-row * cellH * scale}px)`
	}
})

const activeSheetStyle = computed(() => (morphPlaying.value ? morphSheetStyle.value : petSheetStyle.value))

const clearHoldTimer = () => {
	if (holdTimer) {
		window.clearTimeout(holdTimer)
		holdTimer = 0
	}
}

const clearFrameTimer = () => {
	if (frameTimer) {
		window.clearInterval(frameTimer)
		frameTimer = 0
	}
}

const backToIdle = () => {
	clearHoldTimer()
	if (innerAction.value === 'idle') {
		startFrameLoop()
		return
	}
	innerAction.value = 'idle'
	frame.value = 0
	emit('update:action', 'idle')
	startFrameLoop()
}

const startFrameLoop = () => {
	clearFrameTimer()
	if (!useSprite.value) return
	const meta = stateMeta.value
	const ms = Math.max(80, Math.round(1000 / Math.max(0.5, meta.fps)))
	frameTimer = window.setInterval(() => {
		if (!useSprite.value) return
		const m = stateMeta.value
		const next = frame.value + 1
		if (next >= m.frames) {
			if (innerAction.value === 'idle' || m.loop) {
				frame.value = 0
				return
			}
			backToIdle()
			return
		}
		frame.value = next
	}, ms)
}

const play = (next: IcePetAction) => {
	if (morphing.value) return
	const meta = PET_STATE_MAP[next]
	if (!meta) return
	clearHoldTimer()
	innerAction.value = next
	frame.value = 0
	emit('update:action', next)
	emit('action', next)
	startFrameLoop()

	if (next !== 'idle' && meta.loop && meta.holdMs > 0) {
		holdTimer = window.setTimeout(() => {
			if (innerAction.value === next) backToIdle()
		}, meta.holdMs)
	}
}

const finishMorph = (next: IceBotForm) => {
	clearFrameTimer()
	morphPlaying.value = false
	morphing.value = false
	innerForm.value = next
	emit('update:form', next)
	emit('morph', next)
	if (next === 'bot') play('idle')
}

const playMorphSequence = (next: IceBotForm) => {
	clearHoldTimer()
	clearFrameTimer()
	innerAction.value = 'idle'
	morphing.value = true
	morphPlaying.value = true
	morphRow.value = next === 'fly' ? MORPH_SHEET.rowBotToFly : MORPH_SHEET.rowFlyToBot
	frame.value = 0

	const ms = Math.max(70, Math.round(1000 / MORPH_SHEET.fps))
	const total = MORPH_SHEET.frames
	frameTimer = window.setInterval(() => {
		const nextFrame = frame.value + 1
		if (nextFrame >= total) {
			finishMorph(next)
			return
		}
		frame.value = nextFrame
	}, ms)

	// safety: never hang if interval stalls
	window.clearTimeout(morphTimer)
	morphTimer = window.setTimeout(() => {
		if (morphPlaying.value) finishMorph(next)
	}, ms * total + 240)
}

const transformTo = (next: IceBotForm) => {
	if (morphing.value || next === innerForm.value) return
	if (props.pet) {
		playMorphSequence(next)
		return
	}
	// 非桌宠场景保留轻量 CSS 过渡
	clearHoldTimer()
	clearFrameTimer()
	innerAction.value = 'idle'
	frame.value = 0
	morphing.value = true
	window.clearTimeout(morphTimer)
	morphTimer = window.setTimeout(() => {
		innerForm.value = next
		emit('update:form', next)
		emit('morph', next)
		morphTimer = window.setTimeout(() => {
			morphing.value = false
		}, props.morphDuration * 0.35)
	}, props.morphDuration * 0.45)
}

const transform = () => {
	const idx = FORM_CYCLE.indexOf(innerForm.value)
	transformTo(FORM_CYCLE[(idx + 1) % FORM_CYCLE.length])
}

const playRandom = () => {
	if (innerForm.value !== 'bot') {
		transformTo('bot')
		window.setTimeout(
			() => play(RANDOM_PET_STATES[Math.floor(Math.random() * RANDOM_PET_STATES.length)]),
			MORPH_SHEET.frames * Math.round(1000 / MORPH_SHEET.fps) + 120
		)
		return
	}
	play(RANDOM_PET_STATES[Math.floor(Math.random() * RANDOM_PET_STATES.length)])
}

const clearClickDelay = () => {
	if (clickDelayTimer) {
		window.clearTimeout(clickDelayTimer)
		clickDelayTimer = 0
	}
}

const onFigureClick = () => {
	if (props.clickToMorph) {
		// 延迟变身，避免双击打开对话时误触发
		clearClickDelay()
		clickDelayTimer = window.setTimeout(() => {
			clickDelayTimer = 0
			transform()
		}, 220)
		return
	}
	if (props.pet) playRandom()
}

const onFigureDblClick = () => {
	clearClickDelay()
	emit('dblclick')
}

const clearAuto = () => {
	if (autoMorphTimer) {
		window.clearInterval(autoMorphTimer)
		autoMorphTimer = 0
	}
	if (autoActionTimer) {
		window.clearInterval(autoActionTimer)
		autoActionTimer = 0
	}
}

const setupAuto = () => {
	clearAuto()
	if (props.autoMorphMs > 0) {
		autoMorphTimer = window.setInterval(() => {
			if (!morphing.value && document.visibilityState === 'visible') transform()
		}, props.autoMorphMs)
	}
	if (props.autoActionMs > 0) {
		autoActionTimer = window.setInterval(() => {
			if (
				!morphing.value &&
				innerForm.value === 'bot' &&
				innerAction.value === 'idle' &&
				document.visibilityState === 'visible'
			) {
				playRandom()
			}
		}, props.autoActionMs)
	}
}

watch(useSprite, val => {
	if (val) startFrameLoop()
	else if (!morphPlaying.value) clearFrameTimer()
})

watch([() => props.autoMorphMs, () => props.autoActionMs], setupAuto)

onMounted(() => {
	if ((innerForm.value as string) === 'drone') {
		innerForm.value = 'fly'
		emit('update:form', 'fly')
	}
	setupAuto()
	const probe = new Image()
	probe.onerror = () => {
		sheetUrl.value = PET_SHEET.fallbackSrc
	}
	probe.src = PET_SHEET.src
	const morphProbe = new Image()
	morphProbe.onerror = () => {
		morphSheetUrl.value = MORPH_SHEET.fallbackSrc
	}
	morphProbe.src = MORPH_SHEET.src
	if (props.pet) play(props.action || 'idle')
})

onBeforeUnmount(() => {
	clearAuto()
	clearHoldTimer()
	clearFrameTimer()
	clearClickDelay()
	window.clearTimeout(morphTimer)
})

defineExpose({
	transform,
	transformTo,
	play,
	playRandom,
	form,
	action,
	morphing
})
</script>

<style scoped lang="scss">
.ice-bot {
	display: inline-flex;
	flex-direction: column;
	align-items: center;
	gap: 6px;
	user-select: none;
}

.bot-figure {
	position: relative;
	display: grid;
	place-items: center;
	overflow: visible;
}

.ice-bot.badge .bot-figure {
	border-radius: 50%;
	background:
		radial-gradient(circle at 35% 28%, #ffffff 0%, #f3faff 58%, #e4f3fb 100%);
	border: 1px solid rgba(0, 168, 232, 0.16);
	box-shadow:
		0 10px 24px rgba(5, 70, 102, 0.14),
		inset 0 1px 0 rgba(255, 255, 255, 0.9);
	overflow: hidden;
}

.ice-bot.pet .bot-figure {
	cursor: pointer;
}

.bot-ground-shadow {
	position: absolute;
	left: 50%;
	bottom: 7%;
	z-index: 0;
	width: 48%;
	height: 12px;
	border-radius: 50%;
	background: radial-gradient(ellipse, rgba(5, 70, 102, 0.22), transparent 74%);
	transform: translateX(-50%);
	pointer-events: none;
	transition: width 0.25s ease, opacity 0.25s ease;
}

.ice-bot.sprite.bounce .bot-ground-shadow {
	animation: shadow-breathe 3.6s ease-in-out infinite;
}

.bot-sprite-clip {
	position: relative;
	z-index: 1;
	overflow: hidden;
	background: transparent;
	border: none;
	outline: none;
	contain: layout paint;
	filter: drop-shadow(0 10px 16px rgba(5, 70, 102, 0.14));

	&.morph {
		filter:
			drop-shadow(0 10px 16px rgba(5, 70, 102, 0.14))
			drop-shadow(0 0 18px rgba(56, 189, 248, 0.45));
	}
}

.bot-sprite-sheet {
	background-repeat: no-repeat;
	background-position: 0 0;
	background-size: 100% 100%;
	pointer-events: none;
	will-change: transform;
	image-rendering: auto;
}

.ice-bot.sprite .bot-figure,
.ice-bot.morphing .bot-figure {
	width: auto;
	height: auto;
}

.bot-core {
	display: block;
	width: 100%;
	height: auto;
	object-fit: contain;
	user-select: none;
	pointer-events: none;
	transform: translateY(2%);
	background: transparent;
	transform-origin: center bottom;
	filter: drop-shadow(0 8px 14px rgba(5, 70, 102, 0.16));
}

.ice-bot.fly .bot-core {
	width: 78%;
	transform-origin: center center;
	animation: head-hover 2.8s ease-in-out infinite;
}

.morph-burst {
	position: absolute;
	inset: 12%;
	border-radius: 50%;
	background: radial-gradient(circle, rgba(94, 200, 240, 0.5), transparent 72%);
	pointer-events: none;
	animation: burst 0.9s ease-out both;
}

.ice-bot.sm .bot-figure {
	width: 56px;
	height: 56px;
}
.ice-bot.md .bot-figure {
	width: 108px;
	height: 108px;
}
.ice-bot.lg .bot-figure {
	width: 168px;
	height: 168px;
}
.ice-bot.xl .bot-figure {
	width: 200px;
	height: 200px;
}

.ice-bot.sm:not(.badge) .bot-core {
	width: 52px;
}
.ice-bot.md:not(.badge):not(.fly) .bot-core {
	width: 108px;
}
.ice-bot.lg:not(.badge):not(.fly) .bot-core {
	width: 156px;
}
.ice-bot.xl:not(.badge):not(.fly) .bot-core {
	width: 188px;
}

.ice-bot.sm.fly:not(.badge) .bot-core {
	width: 40px;
}
.ice-bot.md.fly:not(.badge) .bot-core {
	width: 78px;
}
.ice-bot.lg.fly:not(.badge) .bot-core {
	width: 112px;
}
.ice-bot.xl.fly:not(.badge) .bot-core {
	width: 136px;
}

.ice-bot.bounce .bot-figure {
	animation: xb-float 3.6s ease-in-out infinite;
}

.ice-bot.pet.bounce .bot-figure {
	animation: xb-float-soft 4.2s ease-in-out infinite;
}

.talk-glow {
	position: absolute;
	inset: 18% 16% 42%;
	border-radius: 40%;
	background: radial-gradient(circle, rgba(62, 198, 255, 0.42), transparent 70%);
	pointer-events: none;
	animation: xb-pulse 0.9s ease-in-out infinite;
}

.bot-name {
	font-size: 13px;
	font-weight: 750;
	letter-spacing: 0.08em;
	color: #007eb8;
}

@keyframes xb-float {
	0%,
	100% {
		transform: translateY(0);
	}
	50% {
		transform: translateY(-6px);
	}
}

@keyframes xb-float-soft {
	0%,
	100% {
		transform: translateY(0);
	}
	50% {
		transform: translateY(-3px);
	}
}

@keyframes head-hover {
	0%,
	100% {
		transform: translateY(-2%);
	}
	50% {
		transform: translateY(-10%);
	}
}

@keyframes burst {
	0% {
		opacity: 0;
		transform: scale(0.4);
	}
	35% {
		opacity: 1;
		transform: scale(1.15);
	}
	100% {
		opacity: 0;
		transform: scale(1.65);
	}
}

@keyframes xb-pulse {
	0%,
	100% {
		opacity: 0.4;
		transform: scale(0.96);
	}
	50% {
		opacity: 0.95;
		transform: scale(1.06);
	}
}

@keyframes shadow-breathe {
	0%,
	100% {
		width: 48%;
		opacity: 0.9;
	}
	50% {
		width: 42%;
		opacity: 0.65;
	}
}
</style>
