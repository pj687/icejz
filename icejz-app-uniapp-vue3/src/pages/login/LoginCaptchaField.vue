<template>
	<view class="captcha-field" :data-mode="mode">
		<!-- 滑动拼图 / 滑动曲线 -->
		<view v-if="mode === 'slider' || mode === 'curve'" class="panel slider-panel" :class="statusClass">
			<view class="panel-head">
				<text class="badge">{{ mode === 'curve' ? '滑动曲线' : '滑动拼图' }}</text>
				<text class="tip">{{ tip || (mode === 'curve' ? '拖动滑块摆动绳子，使中点对齐' : '向右拖动滑块完成拼图') }}</text>
			</view>
			<view class="puzzle-stage">
				<image v-if="image" :src="image" mode="widthFix" class="puzzle-bg" />
				<!-- 拼图块必须用定宽高容器 -->
				<view v-if="mode === 'slider' && jigsawImage" class="puzzle-piece" :style="pieceStyle">
					<image :src="jigsawImage" mode="scaleToFill" class="puzzle-piece-img" />
				</view>
				<!-- V 绳子：两端钉死在底图端点，滑块只摆中点 -->
				<svg
					v-if="mode === 'curve' && curveMeta"
					class="curve-rope-overlay"
					:viewBox="'0 0 ' + PUZZLE_W + ' ' + PUZZLE_H"
					preserveAspectRatio="none"
				>
					<path
						fill="none"
						stroke="rgba(255,255,255,0.32)"
						stroke-width="13"
						stroke-linecap="round"
						stroke-linejoin="round"
						:d="curveRopeD"
					/>
					<path
						fill="none"
						stroke="#ffffff"
						stroke-width="5.5"
						stroke-linecap="round"
						stroke-linejoin="round"
						:d="curveRopeD"
					/>
					<circle
						:cx="curveVertex.x"
						:cy="curveVertex.y"
						r="6.5"
						fill="#ffffff"
						stroke="#00a8e8"
						stroke-width="2.4"
					/>
				</svg>
				<view v-if="status === 'ok'" class="mask ok">{{ mode === 'curve' ? '绳子已对齐' : '拼图已对齐' }}</view>
				<view v-else-if="status === 'fail'" class="mask fail">未对齐</view>
			</view>
			<view
				class="slider-track"
				:class="{ busy: checking || status === 'ok', active: dragging }"
				@touchstart.stop.prevent="onTrackStart"
				@touchmove.stop.prevent="onTrackMove"
				@touchend.stop.prevent="onTrackEnd"
				@touchcancel.stop.prevent="onTrackEnd"
				@mousedown.stop.prevent="onMouseDown"
			>
				<view class="slider-fill" :style="{ width: sliderPercent + '%' }">
					<view class="slider-fill-shine" />
				</view>
				<view class="slider-thumb" :class="[status, { drag: dragging }]" :style="thumbStyle">
					<view class="thumb-ring" />
					<view class="thumb-core">
						<text class="thumb-icon">{{ status === 'ok' ? '✓' : status === 'fail' ? '!' : '››' }}</text>
					</view>
				</view>
				<text v-if="sliderX === 0 && status === 'idle' && !dragging" class="slider-placeholder">
					{{ mode === 'curve' ? '拖动滑块摆动绳子，使中点对齐' : '拖动滑块对齐缺口' }}
				</text>
			</view>
			<text class="status-text" :class="status">{{ sliderHint }}</text>
		</view>

		<!-- 旋转 / 角度 -->
		<view v-else-if="mode === 'rotate' || mode === 'angle'" class="panel rotate-panel" :class="statusClass">
			<view class="panel-head">
				<text class="badge">{{ mode === 'angle' ? '角度验证' : '旋转验证' }}</text>
				<text class="tip">{{ tip || (mode === 'angle' ? '旋转指针至正上方' : '将图片旋转至正向') }}</text>
			</view>
			<view class="rotate-stage">
				<image
					v-if="image"
					:src="image"
					mode="aspectFit"
					class="rotate-img"
					:style="{ transform: 'rotate(' + rotateDeg + 'deg)' }"
				/>
				<text v-else class="loading">加载中</text>
				<view v-if="status === 'ok'" class="mask ok">角度正确</view>
				<view v-else-if="status === 'fail'" class="mask fail">角度错误</view>
			</view>
			<view
				class="slider-track"
				:class="{ busy: checking || status === 'ok', active: dragging }"
				@touchstart.stop.prevent="onTrackStart"
				@touchmove.stop.prevent="onTrackMove"
				@touchend.stop.prevent="onTrackEnd"
				@touchcancel.stop.prevent="onTrackEnd"
				@mousedown.stop.prevent="onMouseDown"
			>
				<view class="slider-fill" :style="{ width: sliderPercent + '%' }">
					<view class="slider-fill-shine" />
				</view>
				<view class="slider-thumb" :class="[status, { drag: dragging }]" :style="thumbStyle">
					<view class="thumb-ring" />
					<view class="thumb-core">
						<text class="thumb-icon">{{ status === 'ok' ? '✓' : status === 'fail' ? '!' : '↻' }}</text>
					</view>
				</view>
				<text v-if="sliderX === 0 && status === 'idle' && !dragging" class="slider-placeholder">拖动滑块旋转</text>
			</view>
			<text class="status-text" :class="status">{{ rotateHint }}</text>
		</view>

		<!-- 文字点选 -->
		<view v-else-if="mode === 'word'" class="panel word-panel" :class="statusClass">
			<view class="panel-head">
				<text class="badge">文字点选</text>
				<text class="tip">{{ tip || '请依次点击图中文字' }}</text>
			</view>
			<view class="puzzle-stage" :class="{ locked: checking || status === 'ok' }" @tap="onWordTap">
				<image v-if="image" :src="image" mode="widthFix" class="puzzle-bg" />
				<view
					v-for="(p, i) in wordMarks"
					:key="i"
					class="mark"
					:class="{ done: status === 'ok', fail: status === 'fail' }"
					:style="{ left: p.left + 'px', top: p.top + 'px' }"
				>
					<text>{{ status === 'fail' ? '!' : status === 'ok' ? '✓' : i + 1 }}</text>
				</view>
				<view v-if="status === 'ok'" class="mask ok">验证通过</view>
				<view v-else-if="status === 'fail'" class="mask fail">顺序或位置错误</view>
			</view>
			<view class="panel-foot">
				<text class="status-text" :class="status">{{ wordHint }}</text>
				<text class="link" @tap.stop="onRefresh">换一张</text>
			</view>
		</view>

		<!-- 图案点选 -->
		<view v-else-if="mode === 'click'" class="panel click-panel" :class="statusClass">
			<view class="panel-head">
				<text class="badge">图案点选</text>
				<text class="tip">{{ tip || '请点击图中指定图案' }}</text>
			</view>
			<view class="puzzle-stage" :class="{ locked: checking || status === 'ok' }" @tap="onPatternTap">
				<image v-if="image" :src="image" mode="widthFix" class="puzzle-bg" />
				<text v-else class="loading">加载中</text>
				<view
					v-if="patternMark"
					class="mark"
					:class="{ done: status === 'ok', fail: status === 'fail' }"
					:style="{ left: patternMark.left + 'px', top: patternMark.top + 'px' }"
				>
					<text>{{ status === 'fail' ? '!' : '✓' }}</text>
				</view>
				<view v-if="status === 'ok'" class="mask ok">验证通过</view>
				<view v-else-if="status === 'fail'" class="mask fail">选择错误</view>
			</view>
			<view class="panel-foot">
				<text class="status-text" :class="status">{{ clickHint }}</text>
				<text class="link" @tap.stop="onRefresh">换一张</text>
			</view>
		</view>

		<!-- PoW -->
		<view v-else-if="mode === 'pow'" class="panel pow-panel">
			<view class="panel-head">
				<text class="badge">安全校验</text>
				<text class="tip">{{ tip || '正在进行安全校验…' }}</text>
			</view>
			<view class="pow-body">
				<view v-if="powRunning" class="spinner"></view>
				<text class="pow-text">
					{{ powRunning ? '校验中，请稍候…' : modelValue !== '' ? '校验通过，可继续' : '准备中…' }}
				</text>
			</view>
			<text class="link center" :class="{ disabled: powRunning }" @tap="onRefresh">重新校验</text>
		</view>

		<!-- Turnstile -->
		<view v-else-if="mode === 'turnstile'" class="panel turnstile-panel">
			<view class="panel-head">
				<text class="badge">人机验证</text>
				<text class="tip">请完成下方验证</text>
			</view>
			<!-- #ifdef H5 -->
			<view v-if="siteKey" :id="turnstileBoxId" class="turnstile-box"></view>
			<view v-else class="warn">未配置 Turnstile 站点密钥，请到后台「验证码配置」中设置，或改用其它类型</view>
			<!-- #endif -->
			<!-- #ifndef H5 -->
			<view class="warn">小程序端暂不支持 Turnstile，请在后台将该端改为滑动拼图 / 点选 / 输入型</view>
			<!-- #endif -->
			<text class="link center" @tap="onRefresh">刷新</text>
		</view>

		<!-- 输入型：输入框 + 验证码并排，尺寸紧凑 -->
		<view v-else class="input-panel">
			<view class="input-row">
				<input
					class="field-input"
					:value="modelValue"
					:placeholder="tip || '请输入验证码'"
					maxlength="8"
					@input="onInput"
				/>
				<view class="captcha-thumb" @tap="onRefresh">
					<image v-if="image" :src="image" mode="aspectFit" class="thumb-img" />
					<text v-else class="loading">加载中</text>
				</view>
			</view>
			<text class="input-hint">看不清可点右侧图片刷新</text>
		</view>
	</view>
</template>

<script>
import { useCaptchaCheckApi } from '../../api/auth.js'

const PUZZLE_W = 310
const PUZZLE_H = 155
const PIECE = 42
const PIECE_CANVAS = PIECE + Math.max(6, Math.floor(PIECE / 5))

function parseCurveMeta(list) {
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

function buildVRopeD(lx, ly, vx, vy, rx, ry) {
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

export default {
	name: 'LoginCaptchaField',
	props: {
		modelValue: { type: [String, Number], default: '' },
		captchaKey: { type: String, default: '' },
		mode: { type: String, default: 'input' },
		tip: { type: String, default: '' },
		image: { type: String, default: '' },
		jigsawImage: { type: String, default: '' },
		jigsawY: { type: Number, default: 0 },
		words: { type: Array, default: () => [] },
		powRunning: { type: Boolean, default: false },
		siteKey: { type: String, default: '' }
	},
	emits: ['update:modelValue', 'refresh', 'verified', 'failed'],
	data() {
		return {
			PUZZLE_W,
			PUZZLE_H,
			sliderX: 0,
			wordMarks: [],
			wordCoords: [],
			patternMark: null,
			status: 'idle', // idle | ok | fail
			checking: false,
			dragging: false,
			trackLeft: 0,
			trackWidth: 1,
			turnstileBoxId: `cf-ts-${Math.random().toString(36).slice(2, 9)}`,
			turnstileWidgetId: null
		}
	},
	computed: {
		statusClass() {
			return { ok: this.status === 'ok', fail: this.status === 'fail' }
		},
		curveMeta() {
			return this.mode === 'curve' ? parseCurveMeta(this.words) : null
		},
		sliderMax() {
			const meta = this.curveMeta
			if (this.mode === 'curve' && meta) return Math.max(1, meta.travel)
			return PUZZLE_W - PIECE
		},
		sliderPercent() {
			return (this.sliderX / this.sliderMax) * 100
		},
		rotateDeg() {
			return Math.round((this.sliderX / this.sliderMax) * 360)
		},
		/** 滑块始终完整落在轨道内：left% + translateX(-同%) */
		thumbStyle() {
			const p = this.sliderPercent
			return {
				left: p + '%',
				transform: `translate(-${p}%, -50%)`
			}
		},
		pieceStyle() {
			const top = this.jigsawY || 0
			const size = PIECE_CANVAS
			return {
				left: (this.sliderX / PUZZLE_W) * 100 + '%',
				top: (top / PUZZLE_H) * 100 + '%',
				width: (size / PUZZLE_W) * 100 + '%',
				height: (size / PUZZLE_H) * 100 + '%'
			}
		},
		curveVertex() {
			const meta = this.curveMeta
			if (!meta) return { x: 0, y: 0 }
			const ox = Math.min(this.sliderMax, Math.max(0, this.sliderX))
			return { x: meta.vertexBase + ox, y: meta.deepY }
		},
		curveRopeD() {
			const meta = this.curveMeta
			if (!meta) return ''
			const ox = Math.min(this.sliderMax, Math.max(0, this.sliderX))
			return buildVRopeD(meta.leftX, meta.leftY, meta.vertexBase + ox, meta.deepY, meta.rightX, meta.rightY)
		},
		sliderHint() {
			if (this.checking) return '正在校验…'
			if (this.status === 'ok') return this.mode === 'curve' ? '绳子已对齐，可继续' : '拼图已对齐，可继续'
			if (this.status === 'fail') return '未对齐，正在换一张…'
			return this.mode === 'curve'
				? '两端已固定在底图端点，拖动滑块摆动中点对齐'
				: '拖动滑块，使拼图块嵌入缺口'
		},
		rotateHint() {
			if (this.checking) return '正在校验角度…'
			if (this.status === 'ok') return '角度正确，可继续'
			if (this.status === 'fail') return '角度错误，正在换一张…'
			return this.mode === 'angle' ? '拖动滑块，将指针旋至正上方' : '拖动滑块，将图片旋转至正向'
		},
		wordHint() {
			const need = this.words.length || 3
			if (this.checking) return '正在校验点选…'
			if (this.status === 'ok') return '验证通过，可继续'
			if (this.status === 'fail') return '点选错误，正在换一张…'
			return `已点 ${this.wordMarks.length}/${need}，按提示依次点击`
		},
		clickHint() {
			if (this.checking) return '正在校验图案…'
			if (this.status === 'ok') return '验证通过，可继续'
			if (this.status === 'fail') return '选择错误，正在换一张…'
			return '点击正确图案后才会通过验证'
		}
	},
	watch: {
		image() {
			this.resetLocal(false)
		},
		mode() {
			this.resetLocal(false)
			this.$nextTick(() => {
				if (this.mode === 'turnstile') this.renderTurnstile()
			})
		},
		siteKey() {
			if (this.mode === 'turnstile') this.$nextTick(() => this.renderTurnstile())
		},
		modelValue(v) {
			if (this.mode === 'pow' && v !== '' && v != null) {
				this.status = 'ok'
				this.$emit('verified', String(v))
			}
		}
	},
	mounted() {
		if (this.mode === 'turnstile') this.renderTurnstile()
	},
	beforeUnmount() {
		this.unbindMouse()
		this.destroyTurnstile()
	},
	methods: {
		resetLocal(clearEmit = true) {
			this.sliderX = 0
			this.wordMarks = []
			this.wordCoords = []
			this.patternMark = null
			this.status = 'idle'
			this.checking = false
			this.dragging = false
			if (clearEmit) this.$emit('update:modelValue', '')
		},
		onRefresh() {
			this.resetLocal(true)
			this.$emit('refresh')
		},
		onInput(e) {
			this.$emit('update:modelValue', e.detail.value)
		},
		measureTrack() {
			return new Promise((resolve) => {
				uni.createSelectorQuery()
					.in(this)
					.select('.slider-track')
					.boundingClientRect((rect) => {
						if (rect && rect.width) {
							this.trackLeft = rect.left
							this.trackWidth = rect.width
						}
						resolve(rect)
					})
					.exec()
			})
		},
		applyClientX(clientX) {
			const ratio = Math.min(1, Math.max(0, (clientX - this.trackLeft) / this.trackWidth))
			this.sliderX = Math.round(ratio * this.sliderMax)
		},
		async onTrackStart(e) {
			if (this.checking || this.status === 'ok') return
			this.status = 'idle'
			this.$emit('update:modelValue', '')
			this.dragging = true
			await this.measureTrack()
			const t = e.touches?.[0] || e.changedTouches?.[0]
			if (t) this.applyClientX(t.clientX)
		},
		onTrackMove(e) {
			if (!this.dragging) return
			const t = e.touches?.[0] || e.changedTouches?.[0]
			if (t) this.applyClientX(t.clientX)
		},
		async onTrackEnd() {
			if (!this.dragging) return
			this.dragging = false
			if (this.sliderX < 8) {
				this.sliderX = 0
				this.status = 'idle'
				this.$emit('update:modelValue', '')
				return
			}
			if (this.mode === 'rotate' || this.mode === 'angle') {
				await this.precheck(String(this.rotateDeg))
				return
			}
			await this.precheck(String(this.sliderX))
		},
		async onMouseDown(e) {
			// #ifdef H5
			if (this.checking || this.status === 'ok') return
			this.status = 'idle'
			this.$emit('update:modelValue', '')
			this.dragging = true
			await this.measureTrack()
			this.applyClientX(e.clientX)
			this._onMouseMove = (ev) => {
				if (!this.dragging) return
				this.applyClientX(ev.clientX)
			}
			this._onMouseUp = () => {
				this.onTrackEnd()
				this.unbindMouse()
			}
			window.addEventListener('mousemove', this._onMouseMove)
			window.addEventListener('mouseup', this._onMouseUp)
			// #endif
		},
		unbindMouse() {
			// #ifdef H5
			if (this._onMouseMove) window.removeEventListener('mousemove', this._onMouseMove)
			if (this._onMouseUp) window.removeEventListener('mouseup', this._onMouseUp)
			this._onMouseMove = null
			this._onMouseUp = null
			// #endif
		},
		resolveTapPoint(e, selector) {
			return new Promise((resolve) => {
				uni.createSelectorQuery()
					.in(this)
					.select(selector)
					.boundingClientRect()
					.selectViewport()
					.scrollOffset()
					.exec((res) => {
						const rect = res?.[0]
						const scroll = res?.[1] || { scrollLeft: 0, scrollTop: 0 }
						if (!rect || !rect.width) {
							resolve(null)
							return
						}
						const touch = e?.touches?.[0] || e?.changedTouches?.[0]
						let pageX
						let pageY
						if (touch) {
							pageX = touch.clientX
							pageY = touch.clientY
						} else {
							// 小程序 tap：detail 为页面坐标
							pageX = (e?.detail?.x ?? 0) - (scroll.scrollLeft || 0)
							pageY = (e?.detail?.y ?? 0) - (scroll.scrollTop || 0)
						}
						const relX = pageX - rect.left
						const relY = pageY - rect.top
						if (relX < 0 || relY < 0 || relX > rect.width || relY > rect.height) {
							resolve(null)
							return
						}
						resolve({
							relX,
							relY,
							x: Math.round((relX / rect.width) * PUZZLE_W),
							y: Math.round((relY / Math.max(1, rect.height)) * PUZZLE_H)
						})
					})
			})
		},
		async onWordTap(e) {
			if (this.checking || this.status === 'ok') return
			const point = await this.resolveTapPoint(e, '.puzzle-stage')
			if (!point) return
			const need = this.words.length || 3
			if (this.status === 'fail') this.status = 'idle'
			if (this.wordMarks.length >= need) {
				this.wordMarks = []
				this.wordCoords = []
			}
			this.wordMarks.push({ left: point.relX, top: point.relY })
			this.wordCoords.push(`${point.x},${point.y}`)
			this.$emit('update:modelValue', '')
			if (this.wordCoords.length < need) return
			await this.precheck(this.wordCoords.join('|'))
		},
		async onPatternTap(e) {
			if (this.checking || this.status === 'ok') return
			const point = await this.resolveTapPoint(e, '.puzzle-stage')
			if (!point) {
				this.onRefresh()
				return
			}
			this.patternMark = { left: point.relX, top: point.relY }
			this.status = 'idle'
			this.$emit('update:modelValue', '')
			await this.precheck(`${point.x},${point.y}`)
		},
		async precheck(captcha) {
			if (!this.captchaKey) {
				uni.showToast({ title: '验证码已失效，请刷新', icon: 'none' })
				this.onRefresh()
				return
			}
			this.checking = true
			try {
				const { data } = await useCaptchaCheckApi({ key: this.captchaKey, captcha })
				if (data === true) {
					this.status = 'ok'
					this.$emit('update:modelValue', captcha)
					this.$emit('verified', captcha)
				} else {
					this.status = 'fail'
					this.$emit('update:modelValue', '')
					this.$emit('failed')
					setTimeout(() => this.onRefresh(), 650)
				}
			} catch (e) {
				this.status = 'fail'
				this.$emit('update:modelValue', '')
				this.$emit('failed')
				setTimeout(() => this.onRefresh(), 650)
			} finally {
				this.checking = false
			}
		},
		loadTurnstileScript() {
			return new Promise((resolve, reject) => {
				// #ifdef H5
				if (window.turnstile) {
					resolve()
					return
				}
				const exist = document.querySelector('script[data-cf-turnstile]')
				if (exist) {
					exist.addEventListener('load', () => resolve())
					exist.addEventListener('error', () => reject(new Error('script failed')))
					return
				}
				const s = document.createElement('script')
				s.src = 'https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit'
				s.async = true
				s.dataset.cfTurnstile = '1'
				s.onload = () => resolve()
				s.onerror = () => reject(new Error('script failed'))
				document.head.appendChild(s)
				// #endif
				// #ifndef H5
				reject(new Error('not h5'))
				// #endif
			})
		},
		async renderTurnstile() {
			// #ifdef H5
			if (!this.siteKey) return
			try {
				await this.loadTurnstileScript()
				this.destroyTurnstile()
				const el = document.getElementById(this.turnstileBoxId)
				if (!window.turnstile || !el) return
				el.innerHTML = ''
				this.turnstileWidgetId = window.turnstile.render(el, {
					sitekey: this.siteKey,
					callback: (token) => {
						this.status = 'ok'
						this.$emit('update:modelValue', token)
						this.$emit('verified', token)
					},
					'expired-callback': () => {
						this.status = 'idle'
						this.$emit('update:modelValue', '')
					},
					'error-callback': () => {
						this.status = 'fail'
						this.$emit('update:modelValue', '')
					}
				})
			} catch (e) {
				// ignore
			}
			// #endif
		},
		destroyTurnstile() {
			// #ifdef H5
			try {
				if (window.turnstile && this.turnstileWidgetId != null) {
					window.turnstile.remove(this.turnstileWidgetId)
				}
			} catch (e) {
				// ignore
			}
			this.turnstileWidgetId = null
			// #endif
		}
	}
}
</script>

<style scoped>
.captcha-field {
	width: 100%;
}
.panel {
	display: flex;
	flex-direction: column;
	gap: 14rpx;
	padding: 18rpx;
	border-radius: 24rpx;
	border: 1rpx solid rgba(232, 238, 245, 0.95);
	background: rgba(247, 250, 252, 0.96);
	box-sizing: border-box;
	box-shadow: 0 10rpx 24rpx rgba(15, 35, 55, 0.04);
}
.panel.ok {
	border-color: rgba(16, 185, 129, 0.35);
	background: rgba(16, 185, 129, 0.05);
}
.panel.fail {
	border-color: rgba(239, 68, 68, 0.35);
	background: rgba(239, 68, 68, 0.04);
}
.panel-head {
	display: flex;
	align-items: center;
	gap: 12rpx;
	min-width: 0;
}
.badge {
	flex-shrink: 0;
	height: 40rpx;
	padding: 0 14rpx;
	border-radius: 999rpx;
	font-size: 20rpx;
	font-weight: 720;
	color: #0284c7;
	background: rgba(0, 168, 232, 0.12);
	display: flex;
	align-items: center;
}
.tip {
	flex: 1;
	min-width: 0;
	font-size: 24rpx;
	font-weight: 650;
	color: #3d4b5c;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}
.puzzle-stage {
	position: relative;
	width: 100%;
	min-height: 0;
	line-height: 0;
	overflow: hidden;
	border-radius: 18rpx;
	background: #eef6fb;
	border: 1rpx solid rgba(213, 230, 240, 0.9);
	box-shadow: inset 0 1rpx 0 rgba(255, 255, 255, 0.8);
}
/* 点选类保留最小高度，避免空图时塌陷 */
.word-panel .puzzle-stage,
.click-panel .puzzle-stage {
	min-height: 280rpx;
	line-height: normal;
}
.puzzle-stage.locked {
	pointer-events: none;
}
.puzzle-bg {
	width: 100%;
	display: block;
	vertical-align: top;
}
.puzzle-piece {
	position: absolute;
	left: 0;
	top: 0;
	z-index: 2;
	box-sizing: border-box;
	pointer-events: none;
	overflow: visible;
}
.puzzle-piece-img {
	width: 100%;
	height: 100%;
	display: block;
	filter: drop-shadow(0 4rpx 10rpx rgba(0, 0, 0, 0.4));
}
.curve-rope-overlay {
	position: absolute;
	left: 0;
	top: 0;
	width: 100%;
	height: 100%;
	z-index: 3;
	pointer-events: none;
}
.rotate-stage {
	position: relative;
	width: 100%;
	min-height: 360rpx;
	border-radius: 18rpx;
	background: #f1f5f9;
	border: 1rpx solid rgba(213, 230, 240, 0.9);
	display: flex;
	align-items: center;
	justify-content: center;
	overflow: hidden;
	box-sizing: border-box;
	padding: 24rpx;
}
.rotate-img {
	width: 320rpx;
	height: 320rpx;
	display: block;
	border-radius: 16rpx;
	transition: transform 0.05s linear;
}
.mask {
	position: absolute;
	left: 0;
	right: 0;
	bottom: 0;
	z-index: 3;
	padding: 8rpx 12rpx;
	text-align: center;
	font-size: 22rpx;
	font-weight: 720;
	color: #fff;
}
.mask.ok {
	background: rgba(16, 185, 129, 0.88);
}
.mask.fail {
	background: rgba(239, 68, 68, 0.88);
}
.mark {
	position: absolute;
	z-index: 4;
	width: 44rpx;
	height: 44rpx;
	margin-left: -22rpx;
	margin-top: -22rpx;
	border-radius: 50%;
	background: linear-gradient(135deg, #00a8e8, #0284c7);
	color: #fff;
	font-size: 22rpx;
	font-weight: 740;
	display: flex;
	align-items: center;
	justify-content: center;
	pointer-events: none;
	box-shadow: 0 0 0 4rpx #fff, 0 6rpx 14rpx rgba(0, 144, 200, 0.35);
}
.mark.done {
	background: linear-gradient(135deg, #34d399, #059669);
}
.mark.fail {
	background: linear-gradient(135deg, #f87171, #dc2626);
}
.slider-track {
	position: relative;
	height: 96rpx;
	border-radius: 999rpx;
	background:
		linear-gradient(180deg, #f4f8fb 0%, #eef4f8 100%);
	overflow: visible;
	touch-action: none;
	user-select: none;
	border: 1rpx solid rgba(198, 218, 232, 0.95);
	box-shadow:
		inset 0 2rpx 8rpx rgba(15, 40, 70, 0.06),
		0 8rpx 18rpx rgba(15, 35, 55, 0.04);
	box-sizing: border-box;
}
.slider-track.active {
	border-color: rgba(0, 168, 232, 0.55);
	box-shadow:
		inset 0 2rpx 8rpx rgba(0, 168, 232, 0.08),
		0 0 0 6rpx rgba(0, 168, 232, 0.08),
		0 8rpx 18rpx rgba(15, 35, 55, 0.04);
}
.slider-track.busy {
	pointer-events: none;
	opacity: 0.88;
}
.slider-fill {
	position: absolute;
	left: 0;
	top: 0;
	bottom: 0;
	z-index: 1;
	overflow: hidden;
	background: linear-gradient(90deg, rgba(0, 168, 232, 0.22), rgba(43, 184, 239, 0.55));
	border-radius: 999rpx;
	pointer-events: none;
}
.slider-fill-shine {
	position: absolute;
	inset: 0;
	background: linear-gradient(110deg, transparent 20%, rgba(255, 255, 255, 0.45) 48%, transparent 72%);
	animation: slider-shine 2.8s ease-in-out infinite;
}
.slider-thumb {
	position: absolute;
	top: 50%;
	left: 0;
	z-index: 3;
	width: 84rpx;
	height: 84rpx;
	border-radius: 50%;
	box-sizing: border-box;
	pointer-events: none;
	display: flex;
	align-items: center;
	justify-content: center;
	transform: translate(0, -50%);
}
.thumb-ring {
	position: absolute;
	inset: -6rpx;
	border-radius: 50%;
	background: radial-gradient(circle, rgba(0, 168, 232, 0.28), transparent 70%);
	opacity: 0.75;
	animation: thumb-pulse 2.2s ease-in-out infinite;
}
.thumb-core {
	position: relative;
	z-index: 1;
	width: 100%;
	height: 100%;
	border-radius: 50%;
	background: linear-gradient(145deg, #2ec0f5 0%, #00a8e8 48%, #0284c7 100%);
	border: 3rpx solid rgba(255, 255, 255, 0.95);
	box-shadow:
		0 10rpx 22rpx rgba(0, 144, 200, 0.38),
		0 2rpx 0 rgba(255, 255, 255, 0.35) inset,
		0 -4rpx 10rpx rgba(2, 100, 160, 0.25) inset;
	display: flex;
	align-items: center;
	justify-content: center;
	color: #fff;
	overflow: hidden;
}
.slider-thumb.drag .thumb-core {
	transform: scale(1.06);
	box-shadow:
		0 14rpx 28rpx rgba(0, 144, 200, 0.45),
		0 2rpx 0 rgba(255, 255, 255, 0.4) inset;
}
.slider-thumb.drag .thumb-ring {
	opacity: 1;
	transform: scale(1.12);
}
.slider-thumb.ok .thumb-core {
	background: linear-gradient(145deg, #34d399 0%, #10b981 50%, #059669 100%);
	box-shadow: 0 10rpx 22rpx rgba(16, 185, 129, 0.38);
}
.slider-thumb.ok .thumb-ring {
	background: radial-gradient(circle, rgba(16, 185, 129, 0.3), transparent 70%);
	animation: none;
}
.slider-thumb.fail .thumb-core {
	background: linear-gradient(145deg, #f87171 0%, #ef4444 50%, #dc2626 100%);
	box-shadow: 0 10rpx 22rpx rgba(239, 68, 68, 0.38);
}
.slider-thumb.fail .thumb-ring {
	background: radial-gradient(circle, rgba(239, 68, 68, 0.3), transparent 70%);
	animation: none;
}
.thumb-icon {
	display: block;
	width: 78rpx;
	height: 78rpx;
	line-height: 78rpx;
	text-align: center;
	font-size: 52rpx;
	font-weight: 820;
	letter-spacing: -2rpx;
	text-shadow: 0 2rpx 4rpx rgba(0, 60, 100, 0.25);
}
.slider-placeholder {
	position: absolute;
	inset: 0;
	z-index: 2;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 22rpx;
	color: #8492a6;
	pointer-events: none;
	padding-left: 72rpx;
	box-sizing: border-box;
}
@keyframes slider-shine {
	0%,
	55% {
		transform: translateX(-120%);
	}
	80%,
	100% {
		transform: translateX(120%);
	}
}
@keyframes thumb-pulse {
	0%,
	100% {
		opacity: 0.45;
		transform: scale(0.96);
	}
	50% {
		opacity: 0.9;
		transform: scale(1.08);
	}
}
.panel-foot {
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 12rpx;
}
.status-text {
	font-size: 22rpx;
	color: #64748b;
	line-height: 1.4;
}
.status-text.ok {
	color: #059669;
	font-weight: 650;
}
.status-text.fail {
	color: #dc2626;
	font-weight: 650;
}
.link {
	flex-shrink: 0;
	font-size: 22rpx;
	font-weight: 700;
	color: #0284c7;
	padding: 8rpx 14rpx;
	border-radius: 999rpx;
	background: rgba(0, 168, 232, 0.08);
}
.link.center {
	align-self: center;
}
.link.disabled {
	opacity: 0.45;
	pointer-events: none;
}
.pow-body {
	min-height: 88rpx;
	display: flex;
	align-items: center;
	justify-content: center;
	gap: 12rpx;
}
.pow-text {
	font-size: 26rpx;
	color: #475569;
	font-weight: 600;
}
.spinner {
	width: 28rpx;
	height: 28rpx;
	border-radius: 50%;
	border: 4rpx solid #c5e2f2;
	border-top-color: #00a8e8;
	animation: spin 0.8s linear infinite;
}
@keyframes spin {
	to {
		transform: rotate(360deg);
	}
}
.warn {
	padding: 18rpx 16rpx;
	border-radius: 12rpx;
	background: #fff7ed;
	border: 1rpx solid #fed7aa;
	color: #b45309;
	font-size: 22rpx;
	line-height: 1.5;
}
.turnstile-box {
	min-height: 130rpx;
	display: flex;
	justify-content: center;
}
.input-panel {
	width: 100%;
	box-sizing: border-box;
	padding: 4rpx 0;
}
.input-row {
	display: flex;
	align-items: stretch;
	gap: 12rpx;
	width: 100%;
	box-sizing: border-box;
}
.field-input {
	flex: 1;
	min-width: 0;
	width: 0;
	height: 96rpx;
	padding: 0 24rpx;
	border-radius: 22rpx;
	background: #f7fafc;
	border: 1rpx solid rgba(232, 238, 245, 0.95);
	font-size: 28rpx;
	color: #0f1b2d;
	box-sizing: border-box;
}
.field-input:focus {
	border-color: rgba(0, 168, 232, 0.42);
	background: #fff;
	box-shadow: 0 0 0 6rpx rgba(0, 168, 232, 0.08);
}
.captcha-thumb {
	width: 260rpx;
	flex: none;
	height: 96rpx;
	border-radius: 22rpx;
	overflow: hidden;
	background: #fff;
	border: 1rpx solid rgba(212, 230, 242, 0.95);
	box-shadow: 0 8rpx 18rpx rgba(15, 35, 55, 0.04);
	display: flex;
	align-items: center;
	justify-content: center;
	box-sizing: border-box;
}
.thumb-img {
	width: 100%;
	height: 100%;
	display: block;
}
.input-hint {
	display: block;
	margin-top: 10rpx;
	padding-left: 8rpx;
	font-size: 20rpx;
	color: #8492a6;
	line-height: 1.4;
}
.loading {
	font-size: 22rpx;
	color: #94a3b8;
	line-height: 1.4;
}
</style>
