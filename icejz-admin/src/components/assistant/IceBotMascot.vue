<template>
	<div
		class="ice-bot"
		:class="[
			size,
			form,
			{
				talking,
				bounce: bounce && form === 'bot' && action === 'idle' && !morphing && !greeting && !isDancing,
				badge,
				morphing,
				greeting,
				dancing: isDancing,
				pet,
				sprite: useSprite
			}
		]"
		:aria-label="name"
	>
		<div
			class="bot-figure"
			:class="{ settling, greeting, dancing: isDancing }"
			@click.stop="onFigureClick"
			@dblclick.stop="onFigureDblClick"
		>
			<template v-if="useSprite || morphPlaying">
				<span class="bot-ground-shadow" aria-hidden="true"></span>
				<div
					class="bot-sprite-clip"
					:class="{ morph: morphPlaying, dancing: isDancing }"
					:style="{ ...clipStyle, ...morphClipExtra }"
				>
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
			<template v-if="morphPlaying">
				<span class="morph-aura" aria-hidden="true"></span>
				<span class="morph-ring morph-ring-a" aria-hidden="true"></span>
				<span class="morph-ring morph-ring-b" aria-hidden="true"></span>
				<span class="morph-burst" aria-hidden="true"></span>
				<span class="morph-spark s1" aria-hidden="true"></span>
				<span class="morph-spark s2" aria-hidden="true"></span>
				<span class="morph-spark s3" aria-hidden="true"></span>
				<span class="morph-spark s4" aria-hidden="true"></span>
				<span class="morph-spark s5" aria-hidden="true"></span>
				<span class="morph-spark s6" aria-hidden="true"></span>
			</template>
			<template v-if="(greeting || isDancing) && !morphPlaying">
				<span class="greet-halo" aria-hidden="true"></span>
				<span class="greet-dot d1" aria-hidden="true"></span>
				<span class="greet-dot d2" aria-hidden="true"></span>
				<span class="greet-dot d3" aria-hidden="true"></span>
				<span class="greet-dot d4" aria-hidden="true"></span>
			</template>
			<span v-if="talking && !morphPlaying && !greeting && !isDancing" class="talk-glow" aria-hidden="true"></span>
		</div>
		<span v-if="showName" class="bot-name">{{ formLabel }}</span>
	</div>
</template>

<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import {
	DANCE_SHEET,
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
	/** 单击请求变身（由父级决定流程，与变身按钮一致） */
	'morph-request': []
	dblclick: []
}>()

const BOT_SRC = '/mascot/xiaobing-main.png?v=8'
const FLY_SRC = '/mascot/xiaobing-head.png?v=2'

const innerForm = ref<IceBotForm>(normalizeForm(props.form))
const innerAction = ref<IcePetAction>(props.action)
const morphing = ref(false)
const morphPlaying = ref(false)
const morphRow = ref(0)
const morphProgress = ref(0)
const settling = ref(false)
const greeting = ref(false)
const frame = ref(0)
const sheetUrl = ref(PET_SHEET.src)
const morphSheetUrl = ref(MORPH_SHEET.src)
const danceSheetUrl = ref(DANCE_SHEET.src)

let morphTimer = 0
let morphRaf = 0
let settleTimer = 0
let holdTimer = 0
let greetTimer = 0
let frameTimer = 0
let frameDir = 1
let autoMorphTimer = 0
let autoActionTimer = 0
let clickDelayTimer = 0

/** easeInOutCubic：中间帧更快、首尾更稳 */
const easeInOutCubic = (t: number) =>
	t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2

const morphClipExtra = computed(() => {
	if (!morphPlaying.value) return {}
	const p = morphProgress.value
	const pulse = Math.sin(p * Math.PI)
	const scale = 1 + pulse * 0.08
	const rot = (pulse - 0.5) * 4
	return {
		transform: `scale(${scale.toFixed(4)}) rotate(${rot.toFixed(2)}deg)`,
		filter: `drop-shadow(0 10px 16px rgba(5, 70, 102, 0.14)) drop-shadow(0 0 ${
			12 + pulse * 22
		}px rgba(56, 189, 248, ${0.28 + pulse * 0.45})) brightness(${1 + pulse * 0.12})`
	}
})

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
const isDancing = computed(() => form.value === 'bot' && action.value === 'dance' && !morphPlaying.value)
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

const danceSheetStyle = computed(() => {
	const scale = PET_SIZE_SCALE[props.size]
	const { cellW, width, height, sequence } = DANCE_SHEET
	const step = frame.value % sequence.length
	const col = sequence[step] ?? 0
	return {
		width: `${width * scale}px`,
		height: `${height * scale}px`,
		backgroundImage: `url(${danceSheetUrl.value})`,
		transform: `translate(${-col * cellW * scale}px, 0)`
	}
})

const activeSheetStyle = computed(() => {
	if (morphPlaying.value) return morphSheetStyle.value
	if (isDancing.value) return danceSheetStyle.value
	return petSheetStyle.value
})

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
	if (morphRaf) {
		window.cancelAnimationFrame(morphRaf)
		morphRaf = 0
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
	frameDir = 1
	const meta = stateMeta.value
	const ms = Math.max(70, Math.round(1000 / Math.max(0.5, meta.fps)))
	frameTimer = window.setInterval(() => {
		if (!useSprite.value) return
		const m = stateMeta.value
		// 合拍手势舞：按 sequence 节拍步进（frame = 序列下标）
		if (innerAction.value === 'dance') {
			const len = DANCE_SHEET.sequence.length
			const next = frame.value + 1
			if (next >= len) {
				frame.value = m.loop ? 0 : frame.value
				if (!m.loop) backToIdle()
				return
			}
			frame.value = next
			return
		}
		if (m.pingPong && m.loop && m.frames > 1) {
			let next = frame.value + frameDir
			if (next >= m.frames) {
				frameDir = -1
				next = m.frames - 2
			} else if (next < 0) {
				frameDir = 1
				next = 1
			}
			frame.value = Math.max(0, Math.min(m.frames - 1, next))
			return
		}
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

const clearGreetTimer = () => {
	if (greetTimer) {
		window.clearTimeout(greetTimer)
		greetTimer = 0
	}
	greeting.value = false
}

const play = (next: IcePetAction) => {
	if (morphing.value) return
	const meta = PET_STATE_MAP[next]
	if (!meta) return
	if (next !== 'dance') clearGreetTimer()
	clearHoldTimer()
	innerAction.value = next
	frame.value = 0
	frameDir = 1
	emit('update:action', next)
	emit('action', next)
	startFrameLoop()

	if (next !== 'idle' && meta.loop && meta.holdMs > 0) {
		holdTimer = window.setTimeout(() => {
			if (innerAction.value === next) backToIdle()
		}, meta.holdMs)
	}
}

/** 打招呼入口：跳奶龙舞 */
const greet = () => {
	if (morphing.value) return
	if (innerForm.value !== 'bot') {
		transformTo('bot')
		greetTimer = window.setTimeout(() => {
			if (innerForm.value === 'bot' && !morphing.value) greet()
		}, (MORPH_SHEET.durationMs || 720) + 180)
		return
	}
	clearGreetTimer()
	clearHoldTimer()
	greeting.value = true
	play('dance')
	greetTimer = window.setTimeout(() => {
		greeting.value = false
		greetTimer = 0
	}, PET_STATE_MAP.dance.holdMs + 80)
}

const finishMorph = (next: IceBotForm) => {
	clearFrameTimer()
	window.clearTimeout(morphTimer)
	morphPlaying.value = false
	morphing.value = false
	morphProgress.value = 0
	innerForm.value = next
	emit('update:form', next)
	emit('morph', next)
	settling.value = true
	window.clearTimeout(settleTimer)
	settleTimer = window.setTimeout(() => {
		settling.value = false
	}, 420)
	if (next === 'bot') play('idle')
}

const playMorphSequence = (next: IceBotForm) => {
	clearHoldTimer()
	clearFrameTimer()
	window.clearTimeout(settleTimer)
	settling.value = false
	innerAction.value = 'idle'
	morphing.value = true
	morphPlaying.value = true
	morphProgress.value = 0
	morphRow.value = next === 'fly' ? MORPH_SHEET.rowBotToFly : MORPH_SHEET.rowFlyToBot
	frame.value = 0

	const total = MORPH_SHEET.frames
	const duration = Math.max(480, MORPH_SHEET.durationMs || Math.round((1000 / MORPH_SHEET.fps) * total))
	const started = performance.now()

	const tick = (now: number) => {
		if (!morphPlaying.value) return
		const raw = Math.min(1, (now - started) / duration)
		// 帧序列匀速播放，避免中间帧被缓动挤在一起；光效单独缓动
		morphProgress.value = easeInOutCubic(raw)
		const idx = Math.min(total - 1, Math.floor(raw * total))
		if (idx !== frame.value) frame.value = idx
		if (raw >= 1) {
			finishMorph(next)
			return
		}
		morphRaf = window.requestAnimationFrame(tick)
	}
	morphRaf = window.requestAnimationFrame(tick)

	window.clearTimeout(morphTimer)
	morphTimer = window.setTimeout(() => {
		if (morphPlaying.value) finishMorph(next)
	}, duration + 320)
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
			(MORPH_SHEET.durationMs || MORPH_SHEET.frames * Math.round(1000 / MORPH_SHEET.fps)) + 160
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
		// 延迟通知父级，避免双击打开对话时误触发；完整步骤由父级 morphNow 编排
		if (morphing.value) return
		clearClickDelay()
		clickDelayTimer = window.setTimeout(() => {
			clickDelayTimer = 0
			if (!morphing.value) emit('morph-request')
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
	const danceProbe = new Image()
	danceProbe.onerror = () => {
		danceSheetUrl.value = DANCE_SHEET.fallbackSrc
	}
	danceProbe.src = DANCE_SHEET.src
	if (props.pet) play(props.action || 'idle')
})

onBeforeUnmount(() => {
	clearAuto()
	clearHoldTimer()
	clearFrameTimer()
	clearGreetTimer()
	clearClickDelay()
	window.clearTimeout(morphTimer)
	window.clearTimeout(settleTimer)
})

defineExpose({
	transform,
	transformTo,
	play,
	playRandom,
	greet,
	form,
	action,
	morphing,
	greeting
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
	transform-origin: center 58%;
	will-change: transform, filter;
	transition: filter 0.2s ease;

	&.morph {
		animation: morph-sheet-shimmy 0.72s cubic-bezier(0.22, 1, 0.36, 1) both;
	}
}

.bot-sprite-sheet {
	background-repeat: no-repeat;
	background-position: 0 0;
	background-size: 100% 100%;
	pointer-events: none;
	will-change: transform;
	image-rendering: auto;
	backface-visibility: hidden;
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

.bot-figure.settling {
	animation: morph-settle 0.42s cubic-bezier(0.22, 1, 0.36, 1) both;
}

.bot-figure.greeting:not(.dancing) {
	animation: greet-sway 1.05s ease-in-out infinite;
}

.ice-bot.greeting .bot-sprite-clip,
.ice-bot.dancing .bot-sprite-clip {
	filter:
		drop-shadow(0 10px 16px rgba(5, 70, 102, 0.14))
		drop-shadow(0 0 14px rgba(56, 189, 248, 0.35));
}

.greet-halo {
	position: absolute;
	inset: 10% 12% 28%;
	z-index: 0;
	border-radius: 50%;
	background: radial-gradient(circle, rgba(125, 211, 252, 0.42), transparent 70%);
	pointer-events: none;
	animation: greet-halo-pulse 1.2s ease-in-out infinite;
}

.greet-dot {
	position: absolute;
	z-index: 3;
	left: 50%;
	top: 36%;
	width: 7px;
	height: 7px;
	border-radius: 50%;
	background: radial-gradient(circle, #fff 0%, #7dd3fc 55%, transparent 75%);
	box-shadow: 0 0 8px rgba(125, 211, 252, 0.85);
	pointer-events: none;
	opacity: 0;
}

.greet-dot.d1 { animation: greet-dot-pop 1.4s 0.05s ease-out infinite; --gx: -34px; --gy: -28px; }
.greet-dot.d2 { animation: greet-dot-pop 1.35s 0.22s ease-out infinite; --gx: 36px; --gy: -22px; width: 5px; height: 5px; }
.greet-dot.d3 { animation: greet-dot-pop 1.45s 0.38s ease-out infinite; --gx: -28px; --gy: 10px; width: 6px; height: 6px; }
.greet-dot.d4 { animation: greet-dot-pop 1.3s 0.15s ease-out infinite; --gx: 30px; --gy: 16px; width: 5px; height: 5px; }

.morph-aura {
	position: absolute;
	inset: 6%;
	z-index: 0;
	border-radius: 50%;
	background:
		radial-gradient(circle at 50% 42%, rgba(125, 211, 252, 0.55), transparent 62%),
		radial-gradient(circle at 50% 60%, rgba(14, 165, 233, 0.28), transparent 70%);
	pointer-events: none;
	animation: morph-aura-pulse 0.72s ease-out both;
	filter: blur(1px);
}

.morph-ring {
	position: absolute;
	left: 50%;
	top: 48%;
	z-index: 2;
	width: 42%;
	aspect-ratio: 1;
	border-radius: 50%;
	border: 2px solid rgba(125, 211, 252, 0.85);
	box-shadow:
		0 0 12px rgba(56, 189, 248, 0.55),
		inset 0 0 10px rgba(186, 230, 253, 0.35);
	pointer-events: none;
	transform: translate(-50%, -50%) scale(0.35);
}

.morph-ring-a {
	animation: morph-ring-expand 0.72s cubic-bezier(0.16, 1, 0.3, 1) both;
}

.morph-ring-b {
	border-color: rgba(186, 230, 253, 0.7);
	animation: morph-ring-expand 0.72s 0.08s cubic-bezier(0.16, 1, 0.3, 1) both;
}

.morph-burst {
	position: absolute;
	inset: 10%;
	z-index: 1;
	border-radius: 50%;
	background:
		radial-gradient(circle, rgba(224, 242, 254, 0.75) 0%, rgba(94, 200, 240, 0.35) 32%, transparent 70%);
	pointer-events: none;
	animation: burst 0.72s cubic-bezier(0.22, 1, 0.36, 1) both;
	mix-blend-mode: screen;
}

.morph-spark {
	position: absolute;
	z-index: 3;
	left: 50%;
	top: 48%;
	width: 6px;
	height: 6px;
	border-radius: 50%;
	background: radial-gradient(circle, #fff 0%, #7dd3fc 45%, transparent 72%);
	box-shadow: 0 0 8px rgba(125, 211, 252, 0.9);
	pointer-events: none;
	opacity: 0;
}

.morph-spark.s1 { animation: morph-spark-fly 0.7s 0.02s ease-out both; --dx: -38px; --dy: -46px; }
.morph-spark.s2 { animation: morph-spark-fly 0.68s 0.06s ease-out both; --dx: 42px; --dy: -40px; width: 5px; height: 5px; }
.morph-spark.s3 { animation: morph-spark-fly 0.74s 0.04s ease-out both; --dx: -48px; --dy: 12px; width: 4px; height: 4px; }
.morph-spark.s4 { animation: morph-spark-fly 0.7s 0.1s ease-out both; --dx: 46px; --dy: 18px; }
.morph-spark.s5 { animation: morph-spark-fly 0.66s 0.08s ease-out both; --dx: -12px; --dy: -58px; width: 5px; height: 5px; }
.morph-spark.s6 { animation: morph-spark-fly 0.72s 0.12s ease-out both; --dx: 16px; --dy: 44px; width: 4px; height: 4px; }

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
		transform: scale(0.35);
	}
	28% {
		opacity: 0.95;
		transform: scale(1.08);
	}
	100% {
		opacity: 0;
		transform: scale(1.78);
	}
}

@keyframes morph-aura-pulse {
	0% {
		opacity: 0;
		transform: scale(0.7);
	}
	40% {
		opacity: 1;
		transform: scale(1.05);
	}
	100% {
		opacity: 0;
		transform: scale(1.35);
	}
}

@keyframes morph-ring-expand {
	0% {
		opacity: 0;
		transform: translate(-50%, -50%) scale(0.28);
		filter: blur(0);
	}
	18% {
		opacity: 1;
	}
	100% {
		opacity: 0;
		transform: translate(-50%, -50%) scale(2.15);
		filter: blur(1.5px);
	}
}

@keyframes morph-spark-fly {
	0% {
		opacity: 0;
		transform: translate(-50%, -50%) scale(0.4);
	}
	18% {
		opacity: 1;
	}
	100% {
		opacity: 0;
		transform: translate(calc(-50% + var(--dx)), calc(-50% + var(--dy))) scale(0.2);
	}
}

@keyframes morph-sheet-shimmy {
	0% {
		opacity: 0.72;
	}
	18% {
		opacity: 1;
	}
	100% {
		opacity: 1;
	}
}

@keyframes morph-settle {
	0% {
		transform: scale(1.06);
		filter: brightness(1.12);
	}
	100% {
		transform: scale(1);
		filter: brightness(1);
	}
}

@keyframes greet-sway {
	0%,
	100% {
		transform: translateY(0) rotate(-1.2deg);
	}
	50% {
		transform: translateY(-4px) rotate(1.4deg);
	}
}


@keyframes greet-halo-pulse {
	0%,
	100% {
		opacity: 0.45;
		transform: scale(0.92);
	}
	50% {
		opacity: 0.95;
		transform: scale(1.08);
	}
}

@keyframes greet-dot-pop {
	0% {
		opacity: 0;
		transform: translate(-50%, -50%) scale(0.3);
	}
	22% {
		opacity: 1;
	}
	100% {
		opacity: 0;
		transform: translate(calc(-50% + var(--gx)), calc(-50% + var(--gy))) scale(0.2);
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
