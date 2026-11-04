<template>
	<!-- 表单触发条 -->
	<view class="trigger" :class="{ ok: verified }" @tap="open">
		<view class="trigger-ico" :class="{ ok: verified }">
			<view v-if="verified" class="ico-check" />
			<view v-else class="ico-shield">
				<view class="ico-shield-dot" />
			</view>
		</view>
		<view class="trigger-main">
			<text class="trigger-title">安全验证</text>
			<text class="trigger-sub">{{ verified ? verifiedText : triggerHint }}</text>
		</view>
		<view class="trigger-action" :class="{ ok: verified }">
			{{ verified ? '重新验证' : '去验证' }}
		</view>
	</view>

	<!-- #ifdef H5 -->
	<teleport to="body">
	<!-- #endif -->
	<view v-if="visible" class="root">
		<view class="mask" @tap="close" @touchmove.stop.prevent></view>
		<view class="panel" @tap.stop>
			<view class="panel-glow" />
			<view class="panel-sheen" />
			<view class="handle" />

			<view class="panel-head">
				<view class="head-copy">
					<view class="kicker-row">
						<view class="kicker-dot" />
						<text class="kicker">ICEJZ · {{ modeLabel }}</text>
					</view>
					<text class="title">安全验证</text>
					<text class="desc">{{ tip || '请完成下方验证后继续' }}</text>
				</view>
				<view class="close" @tap="close">
					<view class="close-x" />
				</view>
			</view>

			<view class="panel-body">
				<LoginCaptchaField
					v-model="localValue"
					:captcha-key="captchaKey"
					:mode="mode"
					:tip="tip"
					:image="image"
					:jigsaw-image="jigsawImage"
					:jigsaw-y="jigsawY"
					:words="words"
					:pow-running="powRunning"
					:site-key="siteKey"
					@refresh="onRefresh"
					@verified="onVerified"
					@failed="onFailed"
				/>
			</view>

			<view class="panel-foot">
				<view class="btn ghost" :class="{ disabled: checking }" @tap="onRefresh">刷新</view>
				<view class="btn primary" :class="{ disabled: !canConfirm || checking, ready: canConfirm && !checking }" @tap="confirm">
					{{ footBtnText }}
				</view>
			</view>
		</view>
	</view>
	<!-- #ifdef H5 -->
	</teleport>
	<!-- #endif -->
</template>

<script>
import LoginCaptchaField from './LoginCaptchaField.vue'
import { useCaptchaCheckApi } from '../../api/auth.js'

const MODE_LABEL = {
	input: '输入验证码',
	click: '图案点选',
	slider: '滑动拼图',
	curve: '滑动曲线',
	rotate: '旋转验证',
	angle: '角度验证',
	word: '文字点选',
	pow: '算力校验',
	turnstile: '人机验证'
}

export default {
	name: 'LoginCaptchaPopup',
	components: { LoginCaptchaField },
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
	emits: ['update:modelValue', 'refresh'],
	data() {
		return {
			visible: false,
			localValue: '',
			committed: '',
			prechecked: false,
			checking: false
		}
	},
	computed: {
		verified() {
			return this.committed !== '' && this.committed != null
		},
		modeLabel() {
			return MODE_LABEL[this.mode] || '图形验证'
		},
		triggerHint() {
			if (this.mode === 'click') return '点击完成图案点选'
			if (this.mode === 'slider') return '点击完成滑动拼图'
			if (this.mode === 'curve') return '点击完成滑动曲线'
			if (this.mode === 'rotate') return '点击完成旋转验证'
			if (this.mode === 'angle') return '点击完成角度验证'
			if (this.mode === 'word') return '点击完成文字点选'
			if (this.mode === 'pow') return '点击进行安全校验'
			if (this.mode === 'turnstile') return '点击完成人机验证'
			return '点击完成图形验证'
		},
		verifiedText() {
			if (this.mode === 'click') return '图案点选已通过'
			if (this.mode === 'slider') return '滑动拼图已通过'
			if (this.mode === 'curve') return '滑动曲线已通过'
			if (this.mode === 'rotate') return '旋转验证已通过'
			if (this.mode === 'angle') return '角度验证已通过'
			if (this.mode === 'word') return '文字点选已通过'
			if (this.mode === 'pow') return '算力校验已通过'
			if (this.mode === 'turnstile') return '人机验证已通过'
			return '图形验证已通过'
		},
		canConfirm() {
			if (this.checking || this.powRunning) return false
			if (this.localValue === '' || this.localValue == null) return false
			if (['click', 'slider', 'curve', 'rotate', 'angle', 'word'].includes(this.mode)) {
				return this.prechecked
			}
			if (this.mode === 'pow' || this.mode === 'turnstile') {
				return this.prechecked
			}
			return true
		},
		confirmHint() {
			if (this.mode === 'click') return '请先点选正确图案'
			if (this.mode === 'curve') return '请先拖动滑块摆动绳子使中点对齐'
			if (this.mode === 'slider') return '请先拖动滑块对齐'
			if (this.mode === 'rotate' || this.mode === 'angle') return '请先旋转到正确角度'
			if (this.mode === 'word') return '请按顺序点选文字'
			if (this.mode === 'pow') return '校验进行中…'
			if (this.mode === 'turnstile') return '请先完成人机验证'
			return '请先填写验证码'
		},
		footBtnText() {
			if (this.checking) return '校验中…'
			if (!this.canConfirm) return this.confirmHint
			if (this.prechecked) return '验证通过'
			return '确认验证'
		}
	},
	watch: {
		modelValue(v) {
			if (v === '' || v == null) {
				this.committed = ''
				this.localValue = ''
				this.prechecked = false
			} else if (this.mode === 'pow' || this.mode === 'turnstile') {
				this.localValue = String(v)
				this.prechecked = true
				this.committed = String(v)
			}
		},
		image() {
			if (this.visible) {
				this.localValue = ''
				this.prechecked = false
			}
		}
	},
	beforeUnmount() {
		clearTimeout(this._autoTimer)
	},
	methods: {
		open() {
			this.localValue = ''
			this.prechecked = false
			this.checking = false
			this.visible = true
			this.$emit('refresh')
		},
		close() {
			this.visible = false
			this.localValue = ''
			this.prechecked = false
			this.checking = false
		},
		onRefresh() {
			if (this.checking) return
			this.localValue = ''
			this.prechecked = false
			this.$emit('refresh')
		},
		onVerified(val) {
			this.localValue = String(val)
			this.prechecked = true
			clearTimeout(this._autoTimer)
			this._autoTimer = setTimeout(() => {
				if (this.visible && this.canConfirm) this.commitSuccess(String(val))
			}, 320)
		},
		onFailed() {
			this.localValue = ''
			this.prechecked = false
		},
		async confirm() {
			if (!this.canConfirm || this.checking) return
			const captcha = String(this.localValue)

			if (this.prechecked && ['click', 'slider', 'word', 'pow', 'turnstile'].includes(this.mode)) {
				this.commitSuccess(captcha)
				return
			}

			if (!this.captchaKey) {
				uni.showToast({ title: '验证码已失效，请刷新', icon: 'none' })
				this.onRefresh()
				return
			}

			this.checking = true
			try {
				const { data } = await useCaptchaCheckApi({ key: this.captchaKey, captcha })
				if (data === true) {
					this.prechecked = true
					this.commitSuccess(captcha)
				} else {
					uni.showToast({ title: '验证码错误', icon: 'none' })
					this.localValue = ''
					this.prechecked = false
					this.$emit('update:modelValue', '')
					this.onRefresh()
				}
			} catch (e) {
				uni.showToast({ title: e?.msg || '验证失败，请重试', icon: 'none' })
				this.localValue = ''
				this.prechecked = false
				this.onRefresh()
			} finally {
				this.checking = false
			}
		},
		commitSuccess(captcha) {
			this.committed = captcha
			this.prechecked = true
			this.$emit('update:modelValue', captcha)
			this.visible = false
			this.checking = false
		},
		ensure() {
			if (this.verified) return true
			this.open()
			return false
		},
		reset() {
			this.committed = ''
			this.localValue = ''
			this.prechecked = false
			this.checking = false
			this.$emit('update:modelValue', '')
		}
	}
}
</script>

<style scoped>
.trigger {
	display: flex;
	align-items: center;
	gap: 14rpx;
	padding: 14rpx 16rpx;
	border-radius: 20rpx;
	background: rgba(247, 250, 252, 0.96);
	border: 1rpx solid rgba(232, 238, 245, 0.95);
	box-sizing: border-box;
}
.trigger.ok {
	background: rgba(16, 185, 129, 0.08);
	border-color: rgba(16, 185, 129, 0.28);
}
.trigger-ico {
	width: 52rpx;
	height: 52rpx;
	border-radius: 50%;
	flex-shrink: 0;
	display: flex;
	align-items: center;
	justify-content: center;
	background: linear-gradient(145deg, #00a8e8, #2bb8ef);
	box-shadow: 0 8rpx 16rpx rgba(0, 168, 232, 0.2);
}
.trigger-ico.ok {
	background: linear-gradient(145deg, #34d399, #10b981);
	box-shadow: 0 8rpx 16rpx rgba(16, 185, 129, 0.2);
}
.ico-check {
	width: 16rpx;
	height: 10rpx;
	border-left: 3rpx solid #fff;
	border-bottom: 3rpx solid #fff;
	transform: rotate(-45deg) translate(1rpx, -1rpx);
	box-sizing: border-box;
}
.ico-shield {
	width: 18rpx;
	height: 20rpx;
	border: 3rpx solid #fff;
	border-radius: 4rpx 4rpx 10rpx 10rpx;
	box-sizing: border-box;
	display: flex;
	align-items: center;
	justify-content: center;
}
.ico-shield-dot {
	width: 5rpx;
	height: 5rpx;
	border-radius: 50%;
	background: #fff;
}
.trigger-main {
	min-width: 0;
	flex: 1;
}
.trigger-title {
	display: block;
	font-size: 24rpx;
	font-weight: 720;
	color: #0f1b2d;
}
.trigger-sub {
	display: block;
	margin-top: 2rpx;
	font-size: 20rpx;
	color: #8492a6;
}
.trigger.ok .trigger-sub {
	color: #059669;
}
.trigger-action {
	flex-shrink: 0;
	padding: 10rpx 16rpx;
	border-radius: 999rpx;
	background: rgba(0, 168, 232, 0.1);
	font-size: 22rpx;
	font-weight: 700;
	color: #0284c7;
}
.trigger-action.ok {
	background: rgba(16, 185, 129, 0.12);
	color: #059669;
}

.root {
	position: fixed;
	inset: 0;
	z-index: 4200;
	display: flex;
	align-items: flex-end;
	justify-content: center;
}
.mask {
	position: absolute;
	inset: 0;
	background: rgba(15, 27, 45, 0.42);
	animation: mask-in 0.22s ease;
}
.panel {
	position: relative;
	z-index: 1;
	width: 100%;
	max-width: 860rpx;
	max-height: 86vh;
	display: flex;
	flex-direction: column;
	background: rgba(255, 255, 255, 0.96);
	border-radius: 32rpx 32rpx 0 0;
	overflow: hidden;
	box-sizing: border-box;
	box-shadow: 0 -18rpx 48rpx rgba(15, 35, 55, 0.12);
	animation: panel-up 0.32s cubic-bezier(0.22, 1, 0.36, 1);
}
.panel-glow {
	position: absolute;
	width: 280rpx;
	height: 280rpx;
	right: -80rpx;
	top: -120rpx;
	border-radius: 50%;
	background: rgba(0, 168, 232, 0.14);
	filter: blur(36rpx);
	pointer-events: none;
}
.panel-sheen {
	position: absolute;
	inset: 0;
	pointer-events: none;
	background: linear-gradient(160deg, rgba(255, 255, 255, 0.55) 0%, transparent 36%);
}
.handle {
	position: relative;
	z-index: 1;
	width: 72rpx;
	height: 8rpx;
	margin: 14rpx auto 0;
	border-radius: 999rpx;
	background: #d7e0ea;
}
.panel-head {
	position: relative;
	z-index: 1;
	flex-shrink: 0;
	display: flex;
	justify-content: space-between;
	align-items: flex-start;
	gap: 16rpx;
	padding: 18rpx 28rpx 12rpx;
}
.head-copy {
	min-width: 0;
	flex: 1;
}
.kicker-row {
	display: inline-flex;
	align-items: center;
	gap: 8rpx;
	padding: 6rpx 12rpx;
	border-radius: 999rpx;
	background: rgba(0, 168, 232, 0.08);
}
.kicker-dot {
	width: 8rpx;
	height: 8rpx;
	border-radius: 50%;
	background: #10b981;
	box-shadow: 0 0 0 4rpx rgba(16, 185, 129, 0.14);
}
.kicker {
	font-size: 18rpx;
	font-weight: 750;
	letter-spacing: 0.04em;
	color: #0284c7;
}
.title {
	display: block;
	margin-top: 12rpx;
	font-size: 34rpx;
	font-weight: 800;
	color: #0f1b2d;
}
.desc {
	display: block;
	margin-top: 6rpx;
	font-size: 22rpx;
	color: #8492a6;
	line-height: 1.45;
}
.close {
	flex-shrink: 0;
	width: 56rpx;
	height: 56rpx;
	border-radius: 50%;
	background: rgba(243, 246, 250, 0.96);
	border: 1rpx solid rgba(255, 255, 255, 0.98);
	box-shadow: 0 8rpx 18rpx rgba(15, 35, 55, 0.05);
	display: flex;
	align-items: center;
	justify-content: center;
}
.close-x {
	position: relative;
	width: 18rpx;
	height: 18rpx;
}
.close-x::before,
.close-x::after {
	content: '';
	position: absolute;
	left: 50%;
	top: 50%;
	width: 18rpx;
	height: 3rpx;
	border-radius: 999rpx;
	background: #8492a6;
	margin-left: -9rpx;
	margin-top: -1.5rpx;
}
.close-x::before {
	transform: rotate(45deg);
}
.close-x::after {
	transform: rotate(-45deg);
}
.panel-body {
	position: relative;
	z-index: 1;
	flex: 1;
	min-height: 0;
	overflow-y: auto;
	padding: 8rpx 24rpx 20rpx;
	-webkit-overflow-scrolling: touch;
}
.panel-foot {
	position: relative;
	z-index: 1;
	flex-shrink: 0;
	display: flex;
	gap: 12rpx;
	padding: 14rpx 24rpx calc(18rpx + env(safe-area-inset-bottom));
	border-top: 1rpx solid rgba(238, 242, 247, 0.95);
	background: rgba(255, 255, 255, 0.92);
}
.btn {
	min-height: 80rpx;
	padding: 16rpx 18rpx;
	border-radius: 999rpx;
	font-size: 26rpx;
	font-weight: 720;
	display: flex;
	align-items: center;
	justify-content: center;
	text-align: center;
	box-sizing: border-box;
}
.btn.ghost {
	flex: 0.7;
	background: #f3f6fa;
	color: #5b6b7c;
}
.btn.primary {
	flex: 1.3;
	color: #fff;
	background: linear-gradient(145deg, #00a8e8, #2bb8ef);
	box-shadow: 0 12rpx 24rpx rgba(0, 168, 232, 0.24);
}
.btn.primary.ready {
	box-shadow: 0 14rpx 28rpx rgba(0, 168, 232, 0.3);
}
.btn.disabled {
	opacity: 0.42;
	box-shadow: none;
	pointer-events: none;
}

@keyframes mask-in {
	from { opacity: 0; }
	to { opacity: 1; }
}
@keyframes panel-up {
	from {
		opacity: 0.6;
		transform: translateY(48rpx);
	}
	to {
		opacity: 1;
		transform: translateY(0);
	}
}
</style>
