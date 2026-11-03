<template>
	<!-- 表单触发条 -->
	<view class="trigger" :class="{ ok: verified }" @tap="open">
		<view class="trigger-main">
			<text class="trigger-title">安全验证</text>
			<text class="trigger-sub">{{ verified ? verifiedText : triggerHint }}</text>
		</view>
		<text class="trigger-action">{{ verified ? '重新验证' : '去验证' }}</text>
	</view>

	<!-- #ifdef H5 -->
	<teleport to="body">
	<!-- #endif -->
	<view v-if="visible" class="root">
		<view class="mask" @tap="close" @touchmove.stop.prevent></view>
		<view class="panel" @tap.stop>
			<view class="panel-head">
				<view class="head-copy">
					<text class="kicker">ICEJZ · {{ modeLabel }}</text>
					<text class="title">安全验证</text>
					<text class="desc">{{ tip || '请完成下方验证后继续' }}</text>
				</view>
				<view class="close" @tap="close">关闭</view>
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
				<view class="btn primary" :class="{ disabled: !canConfirm || checking }" @tap="confirm">
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
			if (this.mode === 'word') return '点击完成文字点选'
			if (this.mode === 'pow') return '点击进行安全校验'
			if (this.mode === 'turnstile') return '点击完成人机验证'
			return '点击完成图形验证'
		},
		verifiedText() {
			if (this.mode === 'click') return '图案点选已通过'
			if (this.mode === 'slider') return '滑动拼图已通过'
			if (this.mode === 'word') return '文字点选已通过'
			if (this.mode === 'pow') return '算力校验已通过'
			if (this.mode === 'turnstile') return '人机验证已通过'
			return '图形验证已通过'
		},
		/** 交互型需预校验通过；输入型填写后可点确认（确认时再调服务端校验） */
		canConfirm() {
			if (this.checking || this.powRunning) return false
			if (this.localValue === '' || this.localValue == null) return false
			if (['click', 'slider', 'word'].includes(this.mode)) {
				return this.prechecked
			}
			if (this.mode === 'pow' || this.mode === 'turnstile') {
				return this.prechecked
			}
			return true
		},
		confirmHint() {
			if (this.mode === 'click') return '请先点选正确图案'
			if (this.mode === 'slider') return '请先完成拼图'
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

			// 交互型已在字段内预校验；输入型必须在此调服务端真实验证
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
	justify-content: space-between;
	gap: 16rpx;
	padding: 22rpx 24rpx;
	border-radius: 14rpx;
	background: #f8fafc;
	border: 1rpx solid #e2e8f0;
}
.trigger.ok {
	background: rgba(16, 185, 129, 0.08);
	border-color: rgba(16, 185, 129, 0.28);
}
.trigger-main {
	min-width: 0;
	flex: 1;
}
.trigger-title {
	display: block;
	font-size: 28rpx;
	font-weight: 700;
	color: #0f1724;
}
.trigger-sub {
	display: block;
	margin-top: 6rpx;
	font-size: 22rpx;
	color: #94a3b8;
}
.trigger.ok .trigger-sub {
	color: #059669;
}
.trigger-action {
	flex-shrink: 0;
	font-size: 24rpx;
	font-weight: 700;
	color: #0090c8;
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
	background: rgba(15, 23, 36, 0.55);
}
.panel {
	position: relative;
	z-index: 1;
	width: 100%;
	max-width: 860rpx;
	max-height: 86vh;
	display: flex;
	flex-direction: column;
	background: #fff;
	border-radius: 24rpx 24rpx 0 0;
	overflow: hidden;
	box-sizing: border-box;
}
.panel-head {
	flex-shrink: 0;
	display: flex;
	justify-content: space-between;
	align-items: flex-start;
	gap: 16rpx;
	padding: 28rpx 28rpx 16rpx;
}
.head-copy {
	min-width: 0;
	flex: 1;
}
.kicker {
	display: block;
	font-size: 20rpx;
	font-weight: 800;
	letter-spacing: 0.08em;
	color: #00a8e8;
}
.title {
	display: block;
	margin-top: 8rpx;
	font-size: 34rpx;
	font-weight: 760;
	color: #0f1724;
}
.desc {
	display: block;
	margin-top: 8rpx;
	font-size: 22rpx;
	color: #94a3b8;
	line-height: 1.45;
}
.close {
	flex-shrink: 0;
	padding: 12rpx 20rpx;
	border-radius: 999rpx;
	background: #f1f5f9;
	color: #64748b;
	font-size: 24rpx;
	font-weight: 650;
}
.panel-body {
	flex: 1;
	min-height: 0;
	overflow-y: auto;
	padding: 12rpx 28rpx 28rpx;
	-webkit-overflow-scrolling: touch;
}
.panel-foot {
	flex-shrink: 0;
	display: flex;
	gap: 12rpx;
	padding: 20rpx 24rpx calc(24rpx + env(safe-area-inset-bottom));
	border-top: 1rpx solid #eef2f6;
}
.btn {
	min-height: 88rpx;
	padding: 20rpx;
	border-radius: 16rpx;
	font-size: 28rpx;
	font-weight: 740;
	display: flex;
	align-items: center;
	justify-content: center;
	text-align: center;
	box-sizing: border-box;
}
.btn.ghost {
	flex: 0.7;
	background: #f1f5f9;
	color: #475569;
}
.btn.primary {
	flex: 1.3;
	color: #fff;
	background: linear-gradient(135deg, #00a8e8, #3ec6ff);
	box-shadow: 0 10rpx 22rpx rgba(0, 168, 232, 0.26);
}
.btn.disabled {
	opacity: 0.42;
	box-shadow: none;
	pointer-events: none;
}
</style>
