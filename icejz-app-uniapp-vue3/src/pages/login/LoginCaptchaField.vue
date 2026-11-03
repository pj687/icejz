<template>
	<view class="captcha-field" :data-mode="mode">
		<!-- 滑动拼图 -->
		<view v-if="mode === 'slider'" class="panel slider-panel" :class="statusClass">
			<view class="panel-head">
				<text class="badge">滑动拼图</text>
				<text class="tip">{{ tip || '向右拖动滑块完成拼图' }}</text>
			</view>
			<view class="puzzle-stage">
				<image v-if="image" :src="image" mode="widthFix" class="puzzle-bg" />
				<!-- 拼图块必须用定宽高容器：绝对定位 + widthFix 在 H5/小程序上经常高度为 0 -->
				<view v-if="jigsawImage" class="puzzle-piece" :style="pieceStyle">
					<image :src="jigsawImage" mode="scaleToFill" class="puzzle-piece-img" />
				</view>
				<view v-if="status === 'ok'" class="mask ok">拼图已对齐</view>
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
				<view class="slider-fill" :style="{ width: sliderPercent + '%' }"></view>
				<view class="slider-thumb" :class="status" :style="thumbStyle">
					<text class="thumb-icon">{{ status === 'ok' ? '✓' : status === 'fail' ? '!' : '››' }}</text>
				</view>
				<text v-if="sliderX === 0 && status === 'idle' && !dragging" class="slider-placeholder">拖动滑块对齐缺口</text>
			</view>
			<text class="status-text" :class="status">{{ sliderHint }}</text>
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
const SLIDER_MAX = PUZZLE_W - PIECE

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
		sliderPercent() {
			return (this.sliderX / SLIDER_MAX) * 100
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
			return {
				left: (this.sliderX / PUZZLE_W) * 100 + '%',
				top: ((this.jigsawY || 0) / PUZZLE_H) * 100 + '%',
				width: (PIECE_CANVAS / PUZZLE_W) * 100 + '%',
				height: (PIECE_CANVAS / PUZZLE_H) * 100 + '%'
			}
		},
		sliderHint() {
			if (this.checking) return '正在校验位置…'
			if (this.status === 'ok') return '拼图已对齐，可继续'
			if (this.status === 'fail') return '未对齐，正在换一张…'
			return '拖动滑块，使拼图块嵌入缺口'
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
			this.sliderX = Math.round(ratio * SLIDER_MAX)
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
	padding: 16rpx;
	border-radius: 18rpx;
	border: 1rpx solid #dceaf3;
	background: linear-gradient(180deg, #ffffff, #f3f9fc);
	box-sizing: border-box;
}
.panel.ok {
	border-color: rgba(16, 185, 129, 0.35);
}
.panel.fail {
	border-color: rgba(239, 68, 68, 0.35);
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
	color: #0f4c66;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}
.puzzle-stage {
	position: relative;
	width: 100%;
	overflow: hidden;
	border-radius: 14rpx;
	background: #e8f2f8;
	border: 1rpx solid #d5e6f0;
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
	height: 72rpx;
	border-radius: 999rpx;
	background: linear-gradient(180deg, #f7fbfe, #eef4f8);
	overflow: hidden;
	touch-action: none;
	user-select: none;
	border: 1rpx solid #d7e6f0;
	box-sizing: border-box;
}
.slider-track.active {
	border-color: rgba(0, 168, 232, 0.45);
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
	background: linear-gradient(90deg, rgba(0, 168, 232, 0.28), rgba(62, 198, 255, 0.5));
	border-radius: 999rpx;
	pointer-events: none;
}
.slider-thumb {
	position: absolute;
	top: 50%;
	left: 0;
	z-index: 3;
	width: 64rpx;
	height: 64rpx;
	border-radius: 50%;
	background: linear-gradient(180deg, #ffffff, #f3faff);
	border: 4rpx solid #00a8e8;
	box-shadow: 0 6rpx 16rpx rgba(0, 144, 200, 0.35);
	box-sizing: border-box;
	pointer-events: none;
	display: flex;
	align-items: center;
	justify-content: center;
	color: #00a8e8;
	transform: translate(0, -50%);
}
.slider-thumb.ok {
	border-color: #10b981;
	color: #059669;
}
.slider-thumb.fail {
	border-color: #ef4444;
	color: #dc2626;
}
.thumb-icon {
	font-size: 28rpx;
	font-weight: 800;
	line-height: 1;
	letter-spacing: -4rpx;
}
.slider-placeholder {
	position: absolute;
	inset: 0;
	z-index: 2;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 22rpx;
	color: #94a3b8;
	pointer-events: none;
	padding-left: 56rpx;
	box-sizing: border-box;
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
	height: 112rpx;
	padding: 0 20rpx;
	border-radius: 14rpx;
	background: #f8fafc;
	border: 1rpx solid #e2e8f0;
	font-size: 28rpx;
	box-sizing: border-box;
}
.captcha-thumb {
	width: 280rpx;
	flex: none;
	height: 112rpx;
	border-radius: 14rpx;
	overflow: hidden;
	background: #fff;
	border: 1rpx solid #d4e6f2;
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
	font-size: 20rpx;
	color: #94a3b8;
	line-height: 1.4;
}
.loading {
	font-size: 22rpx;
	color: #94a3b8;
	line-height: 1.4;
}
</style>
