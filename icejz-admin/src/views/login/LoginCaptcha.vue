<template>
	<div class="login-captcha-field" :data-mode="mode">
		<!-- 滑动拼图 / 滑动曲线 -->
		<div v-if="mode === 'slider' || mode === 'curve'" class="captcha-panel slider-wrap">
			<div class="panel-head compact">
				<span class="panel-badge">{{ mode === 'curve' ? '滑动曲线' : '滑动拼图' }}</span>
				<span class="panel-tip">{{ tip || (mode === 'curve' ? '拖动滑块摆动绳子，使中点对齐' : '向右拖动滑块完成拼图') }}</span>
			</div>
			<div class="puzzle-stage" ref="puzzleRef">
				<img v-if="image" :src="image" class="puzzle-bg" alt="拼图底图" draggable="false" />
				<!-- V 绳子：两端钉死在底图端点，滑块只摆中点 -->
				<svg
					v-if="mode === 'curve' && curveMeta"
					class="curve-rope-overlay"
					:viewBox="`0 0 ${puzzleW} ${puzzleH}`"
					preserveAspectRatio="none"
					aria-hidden="true"
				>
					<path
						ref="curveRopeGlowRef"
						fill="none"
						stroke="rgba(255,255,255,0.35)"
						stroke-width="14"
						stroke-linecap="round"
						stroke-linejoin="round"
						:d="curveRopeD"
					/>
					<path
						ref="curveRopeRef"
						fill="none"
						stroke="#ffffff"
						stroke-width="5.5"
						stroke-linecap="round"
						stroke-linejoin="round"
						:d="curveRopeD"
					/>
					<circle
						ref="curveVertexRef"
						:cx="curveVertex.x"
						:cy="curveVertex.y"
						r="7"
						fill="#ffffff"
						stroke="#00a8e8"
						stroke-width="2.5"
					/>
				</svg>
				<img
					v-if="mode === 'slider' && jigsawImage"
					ref="pieceRef"
					:src="jigsawImage"
					class="puzzle-piece"
					:class="{ dragging }"
					:style="pieceBaseStyle"
					alt="滑块"
					draggable="false"
				/>
				<button type="button" class="mini-refresh" title="刷新" @click="refresh">
					<svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2.4">
						<path d="M21 12a9 9 0 1 1-2.5-6.2" />
						<path d="M21 3v6h-6" />
					</svg>
				</button>
				<div v-if="sliderStatus === 'ok'" class="puzzle-ok-mask">{{ mode === 'curve' ? '绳子已对齐' : '拼图已对齐' }}</div>
				<div v-else-if="sliderStatus === 'fail'" class="puzzle-fail-mask">未对齐</div>
			</div>

			<div
				class="slide-track"
				:class="{
					active: dragging,
					ok: sliderStatus === 'ok',
					fail: sliderStatus === 'fail',
					busy: checking
				}"
				ref="trackRef"
				@mousedown.prevent="onDragStart"
				@touchstart.prevent="onDragStart"
			>
				<div ref="fillRef" class="slide-fill"></div>
				<div ref="thumbRef" class="slide-thumb">
					<svg v-if="sliderStatus === 'ok'" viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="3">
						<path d="M5 13l4 4L19 7" />
					</svg>
					<svg v-else-if="sliderStatus === 'fail'" viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="3">
						<path d="M6 6l12 12M18 6L6 18" />
					</svg>
					<svg v-else viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2.4">
						<path d="M9 6l6 6-6 6" />
					</svg>
				</div>
				<span v-show="!dragging && sliderX === 0 && sliderStatus === 'idle'" class="slide-tip">
					{{ mode === 'curve' ? '拖动滑块摆动绳子，使中点对齐' : '拖动滑块对齐缺口' }}
				</span>
			</div>
			<div class="slider-hint" :class="sliderStatus">{{ sliderHintText }}</div>
		</div>

		<!-- 旋转 / 角度验证码 -->
		<div v-else-if="mode === 'rotate' || mode === 'angle'" class="captcha-panel rotate-wrap">
			<div class="panel-head compact">
				<span class="panel-badge">{{ mode === 'angle' ? '角度验证' : '旋转验证' }}</span>
				<span class="panel-tip">{{ tip || (mode === 'angle' ? '旋转指针至正上方' : '将图片旋转至正向') }}</span>
			</div>
			<div class="rotate-stage">
				<img
					v-if="image"
					:src="image"
					class="rotate-img"
					:style="{ transform: `rotate(${rotateDeg}deg)` }"
					alt="旋转验证码"
					draggable="false"
				/>
				<button type="button" class="mini-refresh" title="刷新" @click="refresh">
					<svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2.4">
						<path d="M21 12a9 9 0 1 1-2.5-6.2" />
						<path d="M21 3v6h-6" />
					</svg>
				</button>
				<div v-if="sliderStatus === 'ok'" class="puzzle-ok-mask">验证通过</div>
				<div v-else-if="sliderStatus === 'fail'" class="puzzle-fail-mask">角度不正确</div>
			</div>
			<div
				class="slide-track"
				:class="{
					active: dragging,
					ok: sliderStatus === 'ok',
					fail: sliderStatus === 'fail',
					busy: checking
				}"
				ref="trackRef"
				@mousedown.prevent="onDragStart"
				@touchstart.prevent="onDragStart"
			>
				<div ref="fillRef" class="slide-fill"></div>
				<div ref="thumbRef" class="slide-thumb">
					<svg v-if="sliderStatus === 'ok'" viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="3">
						<path d="M5 13l4 4L19 7" />
					</svg>
					<svg v-else-if="sliderStatus === 'fail'" viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="3">
						<path d="M6 6l12 12M18 6L6 18" />
					</svg>
					<svg v-else viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2.4">
						<path d="M9 6l6 6-6 6" />
					</svg>
				</div>
				<span v-show="!dragging && sliderX === 0 && sliderStatus === 'idle'" class="slide-tip">拖动滑块旋转</span>
			</div>
			<div class="slider-hint" :class="sliderStatus">{{ rotateHintText }}</div>
		</div>

		<!-- 文字点选：点满后先预校验，通过才写入 captcha 允许登录 -->
		<div v-else-if="mode === 'word'" class="captcha-panel word-wrap" :class="clickStatus">
			<div class="panel-head">
				<span class="panel-badge">文字点选</span>
				<span class="panel-tip">{{ tip || '请依次点击图中文字' }}</span>
			</div>
			<div
				class="word-stage"
				:class="{ locked: clickStatus === 'ok' || checking }"
				@click="onWordClick"
			>
				<img v-if="image" :src="image" alt="点选验证码" />
				<span
					v-for="(p, i) in wordClicks"
					:key="i"
					class="word-mark"
					:class="{ done: clickStatus === 'ok', fail: clickStatus === 'fail' }"
					:style="{ left: p.x + 'px', top: p.y + 'px' }"
				>
					{{ clickStatus === 'fail' ? '!' : clickStatus === 'ok' ? '✓' : i + 1 }}
				</span>
				<div v-if="clickStatus === 'ok'" class="puzzle-ok-mask">验证通过</div>
				<div v-else-if="clickStatus === 'fail'" class="puzzle-fail-mask">顺序或位置错误</div>
				<button type="button" class="mini-refresh" title="刷新" @click.stop="refresh">
					<svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2.4">
						<path d="M21 12a9 9 0 1 1-2.5-6.2" />
						<path d="M21 3v6h-6" />
					</svg>
				</button>
			</div>
			<div class="panel-foot">
				<span class="word-progress" :class="{ ok: clickStatus === 'ok', fail: clickStatus === 'fail' }">
					{{ wordHintText }}
				</span>
				<button type="button" class="link-btn" :disabled="checking" @click="refresh">换一张</button>
			</div>
		</div>

		<!-- 图案点选：点选后先预校验，通过才写入 captcha 允许登录 -->
		<div v-else-if="mode === 'click'" class="captcha-panel click-wrap" :class="clickStatus">
			<div class="panel-head">
				<span class="panel-badge">图案点选</span>
				<span class="panel-tip">{{ tip || '请点击图中指定图案' }}</span>
			</div>
			<div
				class="word-stage"
				:class="{ locked: clickStatus === 'ok' || checking }"
				title="点击图中指定图案"
				@click="onPatternClick"
			>
				<img v-if="image" :src="image" alt="点选图案验证码" />
				<span v-else class="captcha-loading stage-loading">加载中</span>
				<span
					v-if="patternMark"
					class="word-mark"
					:class="{ done: clickStatus === 'ok', fail: clickStatus === 'fail' }"
					:style="{ left: patternMark.x + 'px', top: patternMark.y + 'px' }"
				>
					{{ clickStatus === 'fail' ? '!' : '✓' }}
				</span>
				<div v-if="clickStatus === 'ok'" class="puzzle-ok-mask">验证通过</div>
				<div v-else-if="clickStatus === 'fail'" class="puzzle-fail-mask">选择错误</div>
				<button type="button" class="mini-refresh" title="刷新" @click.stop="refresh">
					<svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2.4">
						<path d="M21 12a9 9 0 1 1-2.5-6.2" />
						<path d="M21 3v6h-6" />
					</svg>
				</button>
			</div>
			<div class="panel-foot">
				<span class="word-progress" :class="{ ok: clickStatus === 'ok', fail: clickStatus === 'fail' }">
					{{ clickHintText }}
				</span>
				<button type="button" class="link-btn" :disabled="checking" @click="refresh">换一张</button>
			</div>
		</div>

		<!-- PoW -->
		<div v-else-if="mode === 'pow'" class="captcha-panel pow-wrap">
			<div class="panel-head">
				<span class="panel-badge">安全校验</span>
				<span class="panel-tip">{{ tip || '正在进行安全校验…' }}</span>
			</div>
			<div class="pow-status">
				<span v-if="powRunning" class="pow-spin" />
				<span>{{ powRunning ? '校验中，请稍候…' : modelValue !== '' ? '校验通过' : '准备中…' }}</span>
				<button type="button" class="link-btn" :disabled="powRunning" @click="refresh">重试</button>
			</div>
		</div>

		<!-- Turnstile -->
		<div v-else-if="mode === 'turnstile'" class="captcha-panel turnstile-wrap">
			<div class="panel-head">
				<span class="panel-badge">人机验证</span>
				<span class="panel-tip">请完成下方验证</span>
			</div>
			<div v-if="!siteKey" class="turnstile-warn">未配置 Turnstile 站点密钥，请到「系统管理 · 验证码配置」中设置</div>
			<div v-else :id="turnstileBoxId" class="turnstile-box"></div>
			<div class="panel-foot">
				<span class="word-progress">Cloudflare Turnstile</span>
				<button type="button" class="link-btn" @click="refresh">刷新</button>
			</div>
		</div>

		<!-- 输入型：输够位数后自动校验（也可回车），通过才写入；登录前再兜底校验 -->
		<div v-else class="input-wrap" :class="inputStatus">
			<div class="captcha-row">
				<el-input
					v-model="inputDraft"
					class="captcha-input"
					:class="{ ok: inputStatus === 'ok', fail: inputStatus === 'fail' }"
					:placeholder="tip || $t('app.captcha')"
					size="large"
					maxlength="8"
					:disabled="checking"
					@blur="onInputBlur"
					@keyup.enter.prevent="checkInputCaptcha"
				>
					<template #prefix>
						<div class="input-icon">
							<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
								<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
							</svg>
						</div>
					</template>
					<template v-if="checking || inputStatus === 'ok' || inputStatus === 'fail'" #suffix>
						<span class="input-ok-icon" :class="checking ? 'idle' : inputStatus">
							{{ checking ? '…' : inputStatus === 'ok' ? '✓' : '!' }}
						</span>
					</template>
				</el-input>
				<button type="button" class="captcha-box" title="点击刷新验证码" @click="refresh">
					<img v-if="image" :src="image" alt="验证码" />
					<span v-else class="captcha-loading">加载中</span>
					<span class="captcha-refresh">刷新</span>
				</button>
			</div>
			<div class="input-hint" :class="inputStatus">{{ inputHintText }}</div>
		</div>
	</div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onBeforeUnmount, nextTick, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { useCaptchaApi, useCaptchaCheckApi } from '@/api/auth'

const DEFAULT_PUZZLE_W = 310
const DEFAULT_PUZZLE_H = 155
const DEFAULT_PIECE = 42

type CurveMeta = {
	leftX: number
	leftY: number
	rightX: number
	rightY: number
	deepY: number
	vertexBase: number
	travel: number
}

const parseCurveMeta = (list: string[]): CurveMeta | null => {
	if (!list || list.length < 4) return null
	const [lxs, lys] = String(list[0]).split(',')
	const [rxs, rys] = String(list[1]).split(',')
	const deepY = Number(list[2])
	const [vbs, tvs] = String(list[3]).split(',')
	const leftX = Number(lxs)
	const leftY = Number(lys)
	const rightX = Number(rxs)
	const rightY = Number(rys)
	const vertexBase = Number(vbs)
	const travel = Number(tvs)
	if (![leftX, leftY, rightX, rightY, deepY, vertexBase, travel].every(Number.isFinite)) return null
	return { leftX, leftY, rightX, rightY, deepY, vertexBase, travel }
}

/** 与后端 buildVRopePath 同公式；两端绝对坐标固定，仅中点随滑块移动 */
const buildVRopeD = (lx: number, ly: number, vx: number, vy: number, rx: number, ry: number) => {
	const c1x = lx + (vx - lx) * 0.3
	const c1y = ly + (vy - ly) * 0.68
	const c2x = vx - (vx - lx) * 0.36
	const c2y = vy - (vy - ly) * 0.04
	const c3x = vx + (rx - vx) * 0.36
	const c3y = vy - (vy - ry) * 0.04
	const c4x = rx - (rx - vx) * 0.3
	const c4y = ry + (vy - ry) * 0.68
	return `M ${lx} ${ly} C ${c1x} ${c1y} ${c2x} ${c2y} ${vx} ${vy} C ${c3x} ${c3y} ${c4x} ${c4y} ${rx} ${ry}`
}

const props = withDefaults(
	defineProps<{
		modelValue: string
		captchaKey: string
		/** 验证码通道：pc / app / sms */
		channel?: string
	}>(),
	{
		channel: 'pc'
	}
)

const emit = defineEmits<{
	'update:modelValue': [value: string]
	'update:captchaKey': [value: string]
}>()

const image = ref('')
const jigsawImage = ref('')
const jigsawY = ref(0)
const tip = ref('')
const mode = ref('input')
const type = ref('spec')
const words = ref<string[]>([])
const siteKey = ref('')
const challenge = ref('')
const difficulty = ref(3)
const puzzleW = ref(DEFAULT_PUZZLE_W)
const puzzleH = ref(DEFAULT_PUZZLE_H)
const jigsawW = ref(DEFAULT_PIECE + Math.max(6, Math.floor(DEFAULT_PIECE / 5)))
const pieceSize = ref(DEFAULT_PIECE)
const sliderX = ref(0)
const dragging = ref(false)
const checking = ref(false)
const sliderStatus = ref<'idle' | 'ok' | 'fail'>('idle')
const clickStatus = ref<'idle' | 'ok' | 'fail'>('idle')
const inputStatus = ref<'idle' | 'ok' | 'fail'>('idle')
const inputDraft = ref('')
const wordClicks = ref<Array<{ x: number; y: number; sx: number; sy: number }>>([])
const patternMark = ref<{ x: number; y: number } | null>(null)
const powRunning = ref(false)
const puzzleRef = ref<HTMLElement | null>(null)
const trackRef = ref<HTMLElement | null>(null)
const pieceRef = ref<HTMLImageElement | null>(null)
const curveRopeRef = ref<SVGPathElement | null>(null)
const curveRopeGlowRef = ref<SVGPathElement | null>(null)
const curveVertexRef = ref<SVGCircleElement | null>(null)
const fillRef = ref<HTMLElement | null>(null)
const thumbRef = ref<HTMLElement | null>(null)
const turnstileBoxId = `cf-turnstile-${Math.random().toString(36).slice(2, 9)}`
let turnstileWidgetId: string | number | null = null
let powToken = 0
let trackLeft = 0
let trackWidth = 1
let stageWidth = 1
let captchaKeyLocal = ''
let rafId = 0
let pendingClientX: number | null = null
/** 拖动中的逻辑坐标（不走 Vue 响应式，避免每帧重渲染） */
let liveX = 0

const curveMeta = computed(() => (mode.value === 'curve' ? parseCurveMeta(words.value) : null))
const sliderMax = computed(() => {
	if (mode.value === 'curve' && curveMeta.value) {
		return Math.max(1, curveMeta.value.travel)
	}
	return Math.max(1, puzzleW.value - pieceSize.value)
})
const rotateDeg = computed(() => Math.round((sliderX.value / sliderMax.value) * 360))
const curveVertex = computed(() => {
	const meta = curveMeta.value
	if (!meta) return { x: 0, y: 0 }
	const ox = Math.min(sliderMax.value, Math.max(0, sliderX.value))
	return { x: meta.vertexBase + ox, y: meta.deepY }
})
const curveRopeD = computed(() => {
	const meta = curveMeta.value
	if (!meta) return ''
	const ox = Math.min(sliderMax.value, Math.max(0, sliderX.value))
	return buildVRopeD(meta.leftX, meta.leftY, meta.vertexBase + ox, meta.deepY, meta.rightX, meta.rightY)
})

const paintCurveRope = (offsetX: number) => {
	const meta = curveMeta.value
	if (!meta) return
	const ox = Math.min(sliderMax.value, Math.max(0, offsetX))
	const vx = meta.vertexBase + ox
	const d = buildVRopeD(meta.leftX, meta.leftY, vx, meta.deepY, meta.rightX, meta.rightY)
	const rope = curveRopeRef.value
	const glow = curveRopeGlowRef.value
	const vertex = curveVertexRef.value
	if (rope) rope.setAttribute('d', d)
	if (glow) glow.setAttribute('d', d)
	if (vertex) {
		vertex.setAttribute('cx', String(vx))
		vertex.setAttribute('cy', String(meta.deepY))
	}
}

/** 仅静态布局（宽/高定位），位移用 DOM transform */
const pieceBaseStyle = computed(() => {
	const w = jigsawW.value
	const top = jigsawY.value || 0
	return {
		width: `${(w / puzzleW.value) * 100}%`,
		top: `${(top / puzzleH.value) * 100}%`,
		left: '0'
	}
})
const sliderHintText = computed(() => {
	if (checking.value && (mode.value === 'slider' || mode.value === 'curve')) return '正在校验…'
	if (sliderStatus.value === 'ok') {
		return mode.value === 'curve' ? '绳子已对齐，可继续登录' : '拼图已对齐，可继续登录'
	}
	if (sliderStatus.value === 'fail') return '未对齐，请重试'
	if (dragging.value) {
		return mode.value === 'curve' ? '继续拖动，使中点对齐绳影' : '拖动拼图块对齐右侧缺口'
	}
	return mode.value === 'curve'
		? '两端已固定在底图端点，拖动滑块摆动中点对齐'
		: '拖动滑块，使拼图块嵌入缺口'
})
const rotateHintText = computed(() => {
	if (checking.value) return '正在校验角度…'
	if (sliderStatus.value === 'ok') return '角度正确，可继续登录'
	if (sliderStatus.value === 'fail') return '角度错误，请重试'
	return mode.value === 'angle' ? '拖动滑块，将指针旋至正上方' : '拖动滑块，将图片旋转至正向'
})

const clickHintText = computed(() => {
	if (checking.value && mode.value === 'click') return '正在校验图案…'
	if (clickStatus.value === 'ok') return '验证通过，可继续登录'
	if (clickStatus.value === 'fail') return '选择错误，正在换一张…'
	return '点击正确图案后才会通过验证'
})

const wordHintText = computed(() => {
	const need = words.value.length || 3
	if (checking.value && mode.value === 'word') return '正在校验点选…'
	if (clickStatus.value === 'ok') return '验证通过，可继续登录'
	if (clickStatus.value === 'fail') return '点选错误，正在换一张…'
	return `已点 ${wordClicks.value.length}/${need}，按提示依次点击`
})

const inputHintText = computed(() => {
	if (checking.value && mode.value === 'input') return '正在校验验证码…'
	if (inputStatus.value === 'ok') return '验证通过，可继续登录'
	if (inputStatus.value === 'fail') return '验证码错误，正在换一张…'
	return '输入完成后会自动校验，也可按回车'
})

/** 并发回车/失焦/自动校验共用同一 Promise */
let inputCheckPromise: Promise<boolean> | null = null
let inputDebounceTimer: number | undefined

const clearInputDebounce = () => {
	if (inputDebounceTimer != null) {
		window.clearTimeout(inputDebounceTimer)
		inputDebounceTimer = undefined
	}
}

/** 输入变更：清空旧通过态；位数足够时防抖自动校验 */
watch(inputDraft, val => {
	if (mode.value !== 'input') return
	const next = (val || '').trim()
	if (inputStatus.value === 'ok' && next === (props.modelValue || '').trim()) return
	if (inputStatus.value !== 'idle') inputStatus.value = 'idle'
	if (props.modelValue) {
		emit('update:modelValue', '')
	}
	clearInputDebounce()
	// 常见图形码 4～5 位，输到 4 位起自动校验
	if (next.length >= 4) {
		inputDebounceTimer = window.setTimeout(() => {
			checkInputCaptcha({ silentEmpty: true })
		}, 380)
	}
})

const onInputBlur = () => {
	if (mode.value !== 'input') return
	clearInputDebounce()
	if (inputDraft.value.trim()) {
		checkInputCaptcha({ silentEmpty: true })
	}
}

/** 直接写 DOM，拖动帧不触发 Vue 更新 */
const paintSlider = (x: number) => {
	liveX = x
	const max = sliderMax.value
	const ratio = Math.min(1, Math.max(0, max > 0 ? x / max : 0))
	const piecePx = (x / puzzleW.value) * stageWidth

	if (mode.value === 'curve') {
		paintCurveRope(x)
	} else if (mode.value === 'slider') {
		const piece = pieceRef.value
		if (piece) {
			piece.style.transform = `translate3d(${piecePx}px,0,0)`
		}
	}
	if (mode.value === 'rotate' || mode.value === 'angle') {
		sliderX.value = Math.round(x)
	}
	const fill = fillRef.value
	if (fill) {
		fill.style.transform = `scaleX(${ratio})`
	}
	const thumb = thumbRef.value
	if (thumb) {
		// 让圆钮在轨道内完整可见：两端各留半颗宽度
		const thumbW = 26
		const tx = thumbW / 2 + ratio * Math.max(0, trackWidth - thumbW)
		thumb.style.transform = `translate3d(${tx}px,-50%,0) translateX(-50%)`
	}
}

const resetSliderDom = () => {
	liveX = 0
	paintSlider(0)
}

const refresh = async () => {
	powToken++
	powRunning.value = false
	wordClicks.value = []
	patternMark.value = null
	sliderX.value = 0
	liveX = 0
	dragging.value = false
	checking.value = false
	sliderStatus.value = 'idle'
	clickStatus.value = 'idle'
	inputStatus.value = 'idle'
	inputDraft.value = ''
	clearInputDebounce()
	inputCheckPromise = null
	emit('update:modelValue', '')

	const { data } = await useCaptchaApi(props.channel)
	const typeModeMap: Record<string, string> = {
		pattern: 'click',
		block_puzzle: 'slider',
		click_word: 'word',
		curve: 'curve',
		rotate: 'rotate',
		angle: 'angle',
		pow: 'pow',
		turnstile: 'turnstile',
		spec: 'input',
		number: 'input',
		chinese: 'input',
		arithmetic: 'input'
	}
	image.value = data.image || ''
	jigsawImage.value = data.jigsawImage || ''
	jigsawY.value = data.jigsawY || 0
	tip.value = data.tip || ''
	type.value = data.type || 'spec'
	mode.value = data.mode || typeModeMap[type.value] || 'input'
	words.value = data.words || []
	siteKey.value = data.siteKey || ''
	challenge.value = data.challenge || ''
	difficulty.value = data.difficulty || 3
	puzzleW.value = data.puzzleWidth || DEFAULT_PUZZLE_W
	puzzleH.value = data.puzzleHeight || DEFAULT_PUZZLE_H
	pieceSize.value = data.pieceSize || DEFAULT_PIECE
	jigsawW.value = data.jigsawWidth || pieceSize.value + Math.max(6, Math.floor(pieceSize.value / 5))
	captchaKeyLocal = data.key || ''
	emit('update:captchaKey', captchaKeyLocal)

	await nextTick()
	measureLayout()
	resetSliderDom()
	if (mode.value === 'curve') {
		paintCurveRope(0)
	}
	if (mode.value === 'pow' && challenge.value) {
		runPow(challenge.value, difficulty.value, powToken)
	}
	if (mode.value === 'turnstile') {
		renderTurnstile()
	}
}

const measureLayout = () => {
	const track = trackRef.value
	if (track) {
		const rect = track.getBoundingClientRect()
		trackLeft = rect.left
		trackWidth = Math.max(1, rect.width)
	}
	const stage = puzzleRef.value
	if (stage) {
		stageWidth = Math.max(1, stage.clientWidth)
	}
}

const flushDragX = () => {
	rafId = 0
	if (pendingClientX == null) return
	const ratio = Math.min(1, Math.max(0, (pendingClientX - trackLeft) / trackWidth))
	paintSlider(ratio * sliderMax.value)
	pendingClientX = null
}

const queueClientX = (clientX: number) => {
	pendingClientX = clientX
	if (rafId) return
	rafId = requestAnimationFrame(flushDragX)
}

const onDragStart = (e: MouseEvent | TouchEvent) => {
	if (sliderStatus.value === 'ok' || checking.value) return
	sliderStatus.value = 'idle'
	emit('update:modelValue', '')
	dragging.value = true
	measureLayout()
	const clientX = 'touches' in e ? e.touches[0]?.clientX : e.clientX
	if (clientX != null) {
		pendingClientX = null
		if (rafId) {
			cancelAnimationFrame(rafId)
			rafId = 0
		}
		const ratio = Math.min(1, Math.max(0, (clientX - trackLeft) / trackWidth))
		paintSlider(ratio * sliderMax.value)
	}

	window.addEventListener('mousemove', onDragMove, { passive: true })
	window.addEventListener('mouseup', onDragEnd)
	window.addEventListener('touchmove', onDragMove, { passive: false })
	window.addEventListener('touchend', onDragEnd)
	window.addEventListener('touchcancel', onDragEnd)
}

const onDragMove = (e: MouseEvent | TouchEvent) => {
	if (!dragging.value) return
	if ('touches' in e) e.preventDefault()
	const clientX = 'touches' in e ? e.touches[0]?.clientX : e.clientX
	if (clientX != null) queueClientX(clientX)
}

const onDragEnd = async () => {
	if (!dragging.value) return
	dragging.value = false
	unbindDrag()
	if (rafId) {
		cancelAnimationFrame(rafId)
		rafId = 0
		flushDragX()
	}

	sliderX.value = Math.round(liveX)
	paintSlider(sliderX.value)

	if (sliderX.value < 8) {
		sliderX.value = 0
		resetSliderDom()
		sliderStatus.value = 'idle'
		emit('update:modelValue', '')
		return
	}

	const captcha =
		mode.value === 'rotate' || mode.value === 'angle'
			? String(Math.round((sliderX.value / sliderMax.value) * 360))
			: String(sliderX.value)
	checking.value = true
	try {
		const { data } = await useCaptchaCheckApi({ key: captchaKeyLocal || props.captchaKey, captcha })
		if (data === true) {
			emit('update:modelValue', captcha)
			sliderStatus.value = 'ok'
		} else {
			sliderStatus.value = 'fail'
			emit('update:modelValue', '')
			setTimeout(() => refresh(), 450)
		}
	} catch {
		sliderStatus.value = 'fail'
		emit('update:modelValue', '')
		setTimeout(() => refresh(), 450)
	} finally {
		checking.value = false
	}
}

const unbindDrag = () => {
	window.removeEventListener('mousemove', onDragMove)
	window.removeEventListener('mouseup', onDragEnd)
	window.removeEventListener('touchmove', onDragMove)
	window.removeEventListener('touchend', onDragEnd)
	window.removeEventListener('touchcancel', onDragEnd)
}

const onPatternClick = async (e: MouseEvent) => {
	if (checking.value || clickStatus.value === 'ok') return
	const stage = e.currentTarget as HTMLElement
	const img = stage.querySelector('img')
	if (!img) {
		refresh()
		return
	}
	const rect = img.getBoundingClientRect()
	const relX = e.clientX - rect.left
	const relY = e.clientY - rect.top
	if (relX < 0 || relY < 0 || relX > rect.width || relY > rect.height) return
	const x = Math.round((relX / rect.width) * 310)
	const y = Math.round((relY / rect.height) * 155)
	const captcha = `${x},${y}`
	patternMark.value = { x: relX, y: relY }
	clickStatus.value = 'idle'
	emit('update:modelValue', '')
	checking.value = true
	try {
		const { data } = await useCaptchaCheckApi({ key: captchaKeyLocal || props.captchaKey, captcha })
		if (data === true) {
			emit('update:modelValue', captcha)
			clickStatus.value = 'ok'
		} else {
			clickStatus.value = 'fail'
			emit('update:modelValue', '')
			window.setTimeout(() => refresh(), 450)
		}
	} catch {
		clickStatus.value = 'fail'
		emit('update:modelValue', '')
		window.setTimeout(() => refresh(), 450)
	} finally {
		checking.value = false
	}
}

const checkInputCaptcha = async (opts?: { silentEmpty?: boolean }) => {
	if (mode.value !== 'input') return false
	if (inputCheckPromise) return inputCheckPromise

	const captcha = inputDraft.value.trim()
	if (!captcha) {
		inputStatus.value = 'idle'
		emit('update:modelValue', '')
		if (!opts?.silentEmpty) ElMessage.warning('请输入验证码')
		return false
	}
	if (inputStatus.value === 'ok' && captcha === (props.modelValue || '').trim()) {
		return true
	}
	const key = captchaKeyLocal || props.captchaKey
	if (!key) {
		inputStatus.value = 'fail'
		emit('update:modelValue', '')
		ElMessage.error('验证码已失效，请刷新')
		window.setTimeout(() => refresh(), 450)
		return false
	}

	inputCheckPromise = (async () => {
		checking.value = true
		try {
			const res = await useCaptchaCheckApi({ key, captcha })
			const ok = res?.data === true
			if (ok) {
				inputStatus.value = 'ok'
				emit('update:modelValue', captcha)
				return true
			}
			inputStatus.value = 'fail'
			emit('update:modelValue', '')
			ElMessage.error('验证码错误')
			window.setTimeout(() => refresh(), 650)
			return false
		} catch {
			inputStatus.value = 'fail'
			emit('update:modelValue', '')
			ElMessage.error('验证失败，请重试')
			window.setTimeout(() => refresh(), 650)
			return false
		} finally {
			checking.value = false
			inputCheckPromise = null
		}
	})()

	return inputCheckPromise
}

/** 登录提交前调用：交互型已预校验；输入型自动补一次服务端校验 */
const ensureVerified = async () => {
	clearInputDebounce()
	if (mode.value === 'input') {
		const ok = await checkInputCaptcha()
		if (!ok) {
			ElMessage.warning('请先通过图形验证码校验')
		}
		return ok
	}
	if (['slider', 'click', 'word', 'pow', 'turnstile'].includes(mode.value)) {
		const ok = props.modelValue !== '' && props.modelValue != null
		if (!ok) ElMessage.warning('请先完成验证码')
		return ok
	}
	return props.modelValue !== '' && props.modelValue != null
}

const onWordClick = async (e: MouseEvent) => {
	if (checking.value || clickStatus.value === 'ok') return
	const stage = e.currentTarget as HTMLElement
	const img = stage.querySelector('img')
	if (!img) {
		refresh()
		return
	}
	const rect = img.getBoundingClientRect()
	const relX = e.clientX - rect.left
	const relY = e.clientY - rect.top
	if (relX < 0 || relY < 0 || relX > rect.width || relY > rect.height) return

	const x = Math.round((relX / rect.width) * 310)
	const y = Math.round((relY / rect.height) * 155)
	const need = words.value.length || 3
	if (clickStatus.value === 'fail') {
		clickStatus.value = 'idle'
	}
	if (wordClicks.value.length >= need) {
		wordClicks.value = []
		emit('update:modelValue', '')
	}
	wordClicks.value.push({ x: relX, y: relY, sx: x, sy: y })
	emit('update:modelValue', '')
	if (wordClicks.value.length < need) return

	const captcha = wordClicks.value.map(p => `${p.sx},${p.sy}`).join('|')
	checking.value = true
	try {
		const { data } = await useCaptchaCheckApi({ key: captchaKeyLocal || props.captchaKey, captcha })
		if (data === true) {
			emit('update:modelValue', captcha)
			clickStatus.value = 'ok'
		} else {
			clickStatus.value = 'fail'
			emit('update:modelValue', '')
			window.setTimeout(() => refresh(), 650)
		}
	} catch {
		clickStatus.value = 'fail'
		emit('update:modelValue', '')
		window.setTimeout(() => refresh(), 650)
	} finally {
		checking.value = false
	}
}

const sha256Hex = async (text: string) => {
	const buf = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(text))
	return [...new Uint8Array(buf)].map(b => b.toString(16).padStart(2, '0')).join('')
}

const runPow = async (chal: string, diff: number, token: number) => {
	powRunning.value = true
	const prefix = '0'.repeat(Math.max(2, Math.min(diff, 5)))
	let nonce = 0
	try {
		while (token === powToken) {
			const hash = await sha256Hex(chal + nonce)
			if (hash.startsWith(prefix)) {
				emit('update:modelValue', String(nonce))
				break
			}
			nonce++
			if (nonce % 200 === 0) {
				await new Promise(r => setTimeout(r, 0))
			}
		}
	} finally {
		if (token === powToken) {
			powRunning.value = false
		}
	}
}

const loadTurnstileScript = () =>
	new Promise<void>((resolve, reject) => {
		if ((window as any).turnstile) {
			resolve()
			return
		}
		const exist = document.querySelector('script[data-cf-turnstile]')
		if (exist) {
			exist.addEventListener('load', () => resolve())
			exist.addEventListener('error', () => reject(new Error('Turnstile script failed')))
			return
		}
		const s = document.createElement('script')
		s.src = 'https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit'
		s.async = true
		s.dataset.cfTurnstile = '1'
		s.onload = () => resolve()
		s.onerror = () => reject(new Error('Turnstile script failed'))
		document.head.appendChild(s)
	})

const renderTurnstile = async () => {
	if (!siteKey.value) return
	try {
		await loadTurnstileScript()
		const ts = (window as any).turnstile
		const el = document.getElementById(turnstileBoxId)
		if (!ts || !el) return
		el.innerHTML = ''
		turnstileWidgetId = ts.render(el, {
			sitekey: siteKey.value,
			callback: (token: string) => emit('update:modelValue', token),
			'expired-callback': () => emit('update:modelValue', ''),
			'error-callback': () => emit('update:modelValue', '')
		})
	} catch {
		// ignore
	}
}

onMounted(() => {
	refresh()
})

onBeforeUnmount(() => {
	powToken++
	clearInputDebounce()
	unbindDrag()
	if (rafId) {
		cancelAnimationFrame(rafId)
		rafId = 0
	}
	const ts = (window as any).turnstile
	if (ts && turnstileWidgetId != null) {
		try {
			ts.remove(turnstileWidgetId)
		} catch {
			// ignore
		}
	}
})

defineExpose({ refresh, ensureVerified, checkInputCaptcha })
</script>

<style lang="scss" scoped>
.login-captcha-field {
	width: 100%;
}

.captcha-panel {
	width: 100%;
	display: flex;
	flex-direction: column;
	gap: 10px;
	padding: 12px;
	border-radius: 16px;
	border: 1px solid rgba(196, 220, 236, 0.95);
	background:
		linear-gradient(180deg, rgba(255, 255, 255, 0.96), rgba(241, 248, 252, 0.92)),
		radial-gradient(circle at top right, rgba(0, 168, 232, 0.08), transparent 42%);
	box-shadow:
		0 10px 24px rgba(15, 55, 80, 0.06),
		inset 0 1px 0 rgba(255, 255, 255, 0.9);
	box-sizing: border-box;
}

.slider-wrap.captcha-panel,
.click-wrap.captcha-panel,
.word-wrap.captcha-panel {
	gap: 8px;
	padding: 10px;
}

.panel-head {
	display: flex;
	align-items: center;
	gap: 10px;
	min-width: 0;

	&.compact {
		margin-bottom: -2px;
	}
}

.panel-badge {
	flex: none;
	height: 24px;
	padding: 0 10px;
	border-radius: 999px;
	display: inline-flex;
	align-items: center;
	font-size: 11px;
	font-weight: 700;
	letter-spacing: 0.04em;
	color: #0284c7;
	background: rgba(0, 168, 232, 0.12);
	border: 1px solid rgba(0, 168, 232, 0.18);
}

.panel-tip {
	min-width: 0;
	flex: 1;
	font-size: 13px;
	font-weight: 650;
	color: #0f4c66;
	line-height: 1.35;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.panel-foot {
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 8px;
	padding: 0 2px;
}

.slider-wrap {
	width: 100%;
	max-width: 360px;
	margin: 0 auto;
	gap: 8px;
	padding: 10px;
}

.rotate-wrap {
	width: 100%;
	max-width: 360px;
	margin: 0 auto;
	gap: 8px;
	padding: 10px;
}

.rotate-stage {
	position: relative;
	width: 100%;
	min-height: 220px;
	border-radius: 12px;
	overflow: hidden;
	border: 1px solid rgba(180, 210, 230, 0.9);
	background: linear-gradient(180deg, #e8f4fb, #d7eaf6);
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 16px;
	box-sizing: border-box;
	user-select: none;
}

.rotate-img {
	width: 180px;
	height: 180px;
	border-radius: 12px;
	display: block;
	transition: transform 0.05s linear;
	will-change: transform;
}

.click-wrap,
.word-wrap {
	width: 100%;
}

.pow-wrap,
.turnstile-wrap {
	width: 100%;
}

.puzzle-stage {
	position: relative;
	width: 100%;
	border-radius: 12px;
	overflow: hidden;
	border: 1px solid rgba(180, 210, 230, 0.9);
	background:
		linear-gradient(180deg, #e8f4fb, #d7eaf6);
	box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.7);
	user-select: none;
	touch-action: none;
}

.puzzle-bg {
	display: block;
	width: 100%;
	height: auto;
	pointer-events: none;
}

.curve-rope-overlay {
	position: absolute;
	inset: 0;
	width: 100%;
	height: 100%;
	pointer-events: none;
	z-index: 2;
	filter: drop-shadow(0 0 5px rgba(255, 255, 255, 0.55));
}

.puzzle-piece {
	position: absolute;
	height: auto !important;
	display: block;
	pointer-events: none;
	z-index: 2;
	will-change: transform;
	transform: translate3d(0, 0, 0);
	backface-visibility: hidden;
	// 不用 drop-shadow（合成层重绘贵），改轻量阴影
	box-shadow: 0 1px 3px rgba(0, 0, 0, 0.2);

	&.dragging {
		box-shadow: none;
	}

	&.round {
		height: unset !important;
		aspect-ratio: 1;
		border-radius: 50%;
		overflow: hidden;
		object-fit: cover;
		box-shadow: 0 2px 8px rgba(0, 0, 0, 0.28);
	}
}

.puzzle-ok-mask,
.puzzle-fail-mask {
	position: absolute;
	inset: auto 0 0 0;
	padding: 4px 8px;
	color: #fff;
	font-size: 11px;
	font-weight: 700;
	text-align: center;
	z-index: 3;
}
.puzzle-ok-mask {
	background: rgba(16, 185, 129, 0.88);
}
.puzzle-fail-mask {
	background: rgba(239, 68, 68, 0.88);
}

.mini-refresh {
	position: absolute;
	right: 8px;
	top: 8px;
	width: 30px;
	height: 30px;
	border: 1px solid rgba(255, 255, 255, 0.22);
	border-radius: 10px;
	background: rgba(15, 23, 36, 0.42);
	backdrop-filter: blur(8px);
	color: #fff;
	cursor: pointer;
	display: flex;
	align-items: center;
	justify-content: center;
	z-index: 4;
	transition: background 0.15s ease, transform 0.15s ease;

	svg {
		width: 13px;
		height: 13px;
	}

	&:hover {
		background: rgba(15, 23, 36, 0.68);
		transform: translateY(-1px);
	}
}

.slide-track {
	position: relative;
	height: 42px;
	border-radius: 999px;
	background: linear-gradient(180deg, #f7fbfe, #eef4f8);
	border: 1px solid #d7e6f0;
	overflow: hidden;
	cursor: pointer;
	user-select: none;
	touch-action: none;
	box-shadow: inset 0 1px 2px rgba(15, 55, 80, 0.04);

	&.active .slide-fill {
		background: linear-gradient(90deg, rgba(0, 168, 232, 0.35), rgba(62, 198, 255, 0.55));
	}

	&.ok {
		border-color: rgba(16, 185, 129, 0.45);
		background: rgba(16, 185, 129, 0.08);

		.slide-fill {
			background: linear-gradient(90deg, #34d399, #10b981);
		}

		.slide-thumb {
			border-color: #10b981;
			color: #059669;
		}
	}

	&.fail {
		border-color: rgba(239, 68, 68, 0.4);
		.slide-thumb {
			border-color: #ef4444;
			color: #dc2626;
		}
	}

	&.busy {
		pointer-events: none;
		opacity: 0.85;
	}
}

.slide-fill {
	position: absolute;
	left: 0;
	top: 0;
	bottom: 0;
	width: 100%;
	background: linear-gradient(90deg, rgba(0, 168, 232, 0.2), rgba(62, 198, 255, 0.4));
	border-radius: 999px;
	pointer-events: none;
	transform: scaleX(0);
	transform-origin: left center;
	will-change: transform;
}

.slide-thumb {
	position: absolute;
	left: 0;
	top: 50%;
	width: 30px;
	height: 30px;
	border-radius: 50%;
	background: linear-gradient(180deg, #fff, #f3faff);
	border: 2px solid #00a8e8;
	color: #00a8e8;
	box-shadow: 0 4px 12px rgba(0, 144, 200, 0.28);
	display: flex;
	align-items: center;
	justify-content: center;
	box-sizing: border-box;
	pointer-events: none;
	z-index: 2;
	transform: translate3d(0, -50%, 0) translateX(-50%);
	will-change: transform;

	svg {
		width: 13px;
		height: 13px;
	}
}

.slide-tip {
	position: absolute;
	inset: 0;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 12px;
	color: #94a3b8;
	pointer-events: none;
	letter-spacing: 0.02em;
	padding-left: 10px;
}

.slider-hint {
	font-size: 11px;
	color: #6b7280;
	min-height: 14px;
	line-height: 1.3;
	text-align: center;

	&.ok {
		color: #059669;
		font-weight: 600;
	}

	&.fail {
		color: #dc2626;
	}
}

.input-wrap {
	width: 100%;
	display: flex;
	flex-direction: column;
	gap: 6px;
}

.captcha-row {
	display: grid;
	grid-template-columns: minmax(0, 1fr) 200px;
	gap: 12px;
	width: 100%;
	align-items: stretch;
}

.captcha-input {
	width: 100%;
	min-width: 0;

	&.ok :deep(.el-input__wrapper) {
		box-shadow: 0 0 0 1px rgba(16, 185, 129, 0.45) inset !important;
	}

	&.fail :deep(.el-input__wrapper) {
		box-shadow: 0 0 0 1px rgba(239, 68, 68, 0.45) inset !important;
	}
}

.input-ok-icon {
	font-size: 14px;
	font-weight: 700;
	color: #94a3b8;

	&.ok {
		color: #059669;
	}

	&.fail {
		color: #dc2626;
	}
}

.input-hint {
	font-size: 11px;
	line-height: 1.35;
	color: #94a3b8;
	min-height: 14px;
	padding-left: 2px;

	&.ok {
		color: #059669;
		font-weight: 600;
	}

	&.fail {
		color: #dc2626;
		font-weight: 600;
	}
}

.input-icon {
	width: 22px;
	height: 22px;
	border-radius: 8px;
	display: flex;
	align-items: center;
	justify-content: center;
	color: #8b93a7;
	background: rgba(0, 168, 232, 0.06);

	svg {
		width: 15px;
		height: 15px;
	}
}

:deep(.el-input__wrapper.is-focus) .input-icon {
	color: #00a8e8;
	background: rgba(0, 168, 232, 0.12);
}

.captcha-box {
	position: relative;
	width: 200px;
	min-height: 50px;
	height: 50px;
	padding: 0;
	border: 1px solid #d4e6f2;
	border-radius: 13px;
	overflow: hidden;
	cursor: pointer;
	background:
		linear-gradient(135deg, rgba(0, 168, 232, 0.06), transparent),
		#eef5fa;
	box-shadow:
		inset 0 1px 0 rgba(255, 255, 255, 0.7),
		0 6px 14px rgba(0, 120, 170, 0.08);
	flex-shrink: 0;
	transition: transform 0.15s ease, box-shadow 0.15s ease;

	img {
		width: 100%;
		height: 100%;
		object-fit: cover;
		display: block;
		pointer-events: none;
	}

	.captcha-loading {
		display: flex;
		align-items: center;
		justify-content: center;
		height: 100%;
		font-size: 12px;
		color: #8b93a7;
	}

	.captcha-refresh {
		position: absolute;
		right: 8px;
		bottom: 6px;
		padding: 3px 9px;
		border-radius: 999px;
		font-size: 11px;
		color: #fff;
		background: rgba(0, 144, 200, 0.78);
		opacity: 0;
		transition: all 0.2s ease;
		pointer-events: none;
	}

	&:hover {
		transform: translateY(-1px);
		box-shadow:
			inset 0 1px 0 rgba(255, 255, 255, 0.7),
			0 10px 18px rgba(0, 120, 170, 0.12);

		.captcha-refresh {
			opacity: 1;
		}
	}
}

.word-stage {
	position: relative;
	width: 100%;
	border-radius: 14px;
	overflow: hidden;
	border: 1px solid rgba(180, 210, 230, 0.95);
	background:
		linear-gradient(180deg, #eef7fc, #e2eef6);
	box-shadow:
		inset 0 1px 0 rgba(255, 255, 255, 0.75),
		0 8px 18px rgba(15, 55, 80, 0.08);
	user-select: none;
	cursor: pointer;
	transition: box-shadow 0.18s ease, border-color 0.18s ease;

	&:hover {
		border-color: rgba(0, 168, 232, 0.35);
		box-shadow:
			inset 0 1px 0 rgba(255, 255, 255, 0.8),
			0 12px 24px rgba(0, 144, 200, 0.12);
	}

	img {
		display: block;
		width: 100%;
		height: auto;
	}

	.stage-loading {
		display: flex;
		align-items: center;
		justify-content: center;
		min-height: 140px;
		font-size: 12px;
		color: #8b93a7;
	}
}

.word-mark {
	position: absolute;
	width: 24px;
	height: 24px;
	margin: -12px 0 0 -12px;
	border-radius: 50%;
	background: linear-gradient(135deg, #00a8e8, #0284c7);
	color: #fff;
	font-size: 12px;
	font-weight: 700;
	display: flex;
	align-items: center;
	justify-content: center;
	pointer-events: none;
	box-shadow:
		0 0 0 2px #fff,
		0 4px 10px rgba(0, 144, 200, 0.35);
	animation: mark-pop 0.22s ease;

	&.done {
		background: linear-gradient(135deg, #34d399, #059669);
		box-shadow:
			0 0 0 2px #fff,
			0 4px 10px rgba(16, 185, 129, 0.35);
	}
}

.pow-status {
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 8px;
	min-height: 44px;
	padding: 0 4px 2px;
	font-size: 13px;
	color: #475569;
}

.word-progress {
	font-size: 12px;
	color: #64748b;

	&.ok {
		color: #059669;
		font-weight: 650;
	}

	&.fail {
		color: #dc2626;
		font-weight: 650;
	}
}

.word-stage.locked {
	cursor: default;
	pointer-events: none;
}

.word-stage.locked .mini-refresh {
	pointer-events: auto;
}

.word-mark.fail {
	background: linear-gradient(135deg, #f87171, #dc2626);
	box-shadow:
		0 0 0 2px #fff,
		0 4px 10px rgba(239, 68, 68, 0.35);
}

.click-wrap.ok .word-stage,
.word-wrap.ok .word-stage {
	border-color: rgba(16, 185, 129, 0.45);
}

.click-wrap.fail .word-stage,
.word-wrap.fail .word-stage {
	border-color: rgba(239, 68, 68, 0.4);
}

.link-btn {
	border: none;
	background: rgba(0, 168, 232, 0.08);
	color: #0284c7;
	cursor: pointer;
	font-size: 12px;
	font-weight: 700;
	padding: 5px 10px;
	border-radius: 999px;
	transition: background 0.15s ease, color 0.15s ease;

	&:hover:not(:disabled) {
		background: rgba(0, 168, 232, 0.16);
		color: #0369a1;
	}

	&:disabled {
		opacity: 0.55;
		cursor: not-allowed;
	}
}

.pow-spin {
	width: 14px;
	height: 14px;
	border: 2px solid #c5e2f2;
	border-top-color: #00a8e8;
	border-radius: 50%;
	display: inline-block;
	animation: spin 0.8s linear infinite;
	margin-right: 6px;
	vertical-align: middle;
}

.turnstile-warn {
	font-size: 12px;
	color: #b45309;
	background: #fff7ed;
	border: 1px solid #fed7aa;
	border-radius: 10px;
	padding: 10px 12px;
}

.turnstile-box {
	min-height: 65px;
}

@keyframes spin {
	to {
		transform: rotate(360deg);
	}
}

@keyframes mark-pop {
	from {
		transform: scale(0.6);
		opacity: 0.4;
	}
	to {
		transform: scale(1);
		opacity: 1;
	}
}

@media (max-width: 480px) {
	.captcha-panel {
		padding: 10px;
		border-radius: 14px;
	}

	.captcha-row {
		grid-template-columns: minmax(0, 1fr) 150px;
	}

	.captcha-box {
		width: 150px;
	}

	.panel-tip {
		white-space: normal;
	}
}
</style>
