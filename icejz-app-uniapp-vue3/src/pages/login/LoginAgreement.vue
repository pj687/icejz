<template>
	<view class="bar">
		<view class="bar-row" @tap="onBarTap">
			<view class="check" :class="{ on: agreed }"></view>
			<view class="bar-text">
				<text class="bar-label">我已阅读并同意</text>
				<view class="bar-links">
					<template v-for="(item, index) in agreements" :key="item.id">
						<text class="a" @tap.stop="open(item.id)">《{{ item.shortTitle }}》</text>
						<text v-if="index < agreements.length - 1" class="sep">、</text>
					</template>
				</view>
			</view>
		</view>
	</view>

	<!-- #ifdef H5 -->
	<teleport to="body">
	<!-- #endif -->
	<view v-if="visible" class="root">
		<view class="mask" @tap="close" @touchmove.prevent></view>

		<view class="panel" @tap.stop @touchmove.stop>
			<!-- 顶栏 -->
			<view class="top">
				<view class="top-left">
					<text class="brand">ICEJZ</text>
					<text class="top-title">{{ current.shortTitle }}</text>
				</view>
				<view class="close" @tap="close">关闭</view>
			</view>

			<!-- 协议切换 -->
			<scroll-view scroll-x class="chips" :show-scrollbar="false">
				<view class="chips-inner">
					<view
						v-for="(item, index) in agreements"
						:key="item.id"
						class="chip"
						:class="{
							active: item.id === activeId,
							done: confirmedMap[item.id]
						}"
						@tap="open(item.id)"
					>
						<text class="chip-n">{{ index + 1 }}</text>
						<text class="chip-t">{{ item.shortTitle }}</text>
					</view>
				</view>
			</scroll-view>

			<view class="meter">
				<view class="meter-fill" :style="{ width: `${(confirmedCount / agreements.length) * 100}%` }"></view>
			</view>
			<text class="meter-label">已同意 {{ confirmedCount }} / {{ agreements.length }}</text>

			<!-- 正文：整块可滚，无内层灰框 -->
			<view :id="bodyId" class="doc" @scroll.passive="onDocScroll" @touchmove.stop>
				<view class="doc-pad">
					<text class="doc-h1">{{ current.title }}</text>
					<text class="doc-meta">更新日期 {{ current.updatedAt }} · 版本 {{ version }}</text>

					<view v-for="(sec, i) in current.sections" :key="i" class="block">
						<text class="h2">{{ sec.heading }}</text>
						<text v-for="(p, j) in sec.paragraphs" :key="j" class="p">{{ p }}</text>
					</view>

					<view class="end-tip" :class="{ on: reachedEnd }">
						{{ reachedEnd ? '已阅读至底部' : '请继续下滑至文末' }}
					</view>
				</view>
			</view>

			<!-- 底栏：滑到文末后主按钮升级为「阅读并同意」 -->
			<view class="bottom">
				<view class="btns">
					<view
						v-if="currentIndex > 0"
						class="btn ghost"
						@tap="open(agreements[currentIndex - 1].id)"
					>上一份</view>
					<view
						class="btn main"
						:class="{ disabled: !canAgree, alone: currentIndex === 0, ready: canAgree }"
						@tap="onConfirm"
					>{{ mainText }}</view>
				</view>
			</view>
		</view>
	</view>
	<!-- #ifdef H5 -->
	</teleport>
	<!-- #endif -->
</template>

<script>
import { AGREEMENTS, AGREEMENT_STORAGE_KEY, AGREEMENT_VERSION } from './agreements.js'

function loadOk() {
	try {
		return uni.getStorageSync(AGREEMENT_STORAGE_KEY) === '1'
	} catch (e) {
		return false
	}
}

function emptyFlags() {
	return Object.fromEntries(AGREEMENTS.map((a) => [a.id, false]))
}

export default {
	name: 'LoginAgreement',
	props: {
		modelValue: { type: Boolean, default: undefined }
	},
	emits: ['update:modelValue'],
	data() {
		const ok = loadOk()
		return {
			version: AGREEMENT_VERSION,
			agreements: AGREEMENTS,
			agreed: typeof this.modelValue === 'boolean' ? this.modelValue : ok,
			visible: false,
			activeId: AGREEMENTS[0].id,
			confirmedMap: ok
				? Object.fromEntries(AGREEMENTS.map((a) => [a.id, true]))
				: emptyFlags(),
			reachedEnd: false,
			bodyId: `agree-doc-${Date.now()}`
		}
	},
	computed: {
		current() {
			return this.agreements.find((a) => a.id === this.activeId) || this.agreements[0]
		},
		currentIndex() {
			return Math.max(0, this.agreements.findIndex((a) => a.id === this.activeId))
		},
		confirmedCount() {
			return this.agreements.filter((a) => this.confirmedMap[a.id]).length
		},
		allDone() {
			return this.agreements.every((a) => this.confirmedMap[a.id])
		},
		alreadyConfirmed() {
			return !!this.confirmedMap[this.activeId]
		},
		canAgree() {
			return this.reachedEnd || this.alreadyConfirmed
		},
		mainText() {
			if (!this.canAgree) return '请滑至文末'
			const next = this.nextUnread()
			if (!this.alreadyConfirmed) {
				return next ? '阅读并同意，下一份' : '阅读并同意'
			}
			if (next) return '下一份未读'
			return '已阅读并同意'
		}
	},
	watch: {
		modelValue(v) {
			if (typeof v === 'boolean') this.agreed = v
		}
	},
	mounted() {
		this.$emit('update:modelValue', this.agreed)
	},
	beforeUnmount() {
		this.unbindDocScroll()
	},
	methods: {
		persist(v) {
			try {
				if (v) uni.setStorageSync(AGREEMENT_STORAGE_KEY, '1')
				else uni.removeStorageSync(AGREEMENT_STORAGE_KEY)
			} catch (e) {
				/* ignore */
			}
		},
		toast(t) {
			uni.showToast({ title: t, icon: 'none' })
		},
		setAgreed(v) {
			this.agreed = v
			this.persist(v)
			this.$emit('update:modelValue', v)
		},
		nextUnread() {
			const i = this.currentIndex
			const ring = [...this.agreements.slice(i + 1), ...this.agreements.slice(0, i)]
			return ring.find((a) => !this.confirmedMap[a.id]) || null
		},
		onBarTap() {
			if (this.agreed) {
				this.setAgreed(false)
				return
			}
			if (this.allDone) {
				this.setAgreed(true)
				return
			}
			const first = this.agreements.find((a) => !this.confirmedMap[a.id]) || this.agreements[0]
			this.open(first.id)
		},
		async open(id) {
			this.activeId = id || this.agreements[0].id
			this.visible = true
			this.reachedEnd = !!this.confirmedMap[this.activeId]
			await this.$nextTick()
			const el = this.getDoc()
			if (el) el.scrollTop = 0
			this.bindDocScroll()
			setTimeout(() => this.checkReachEnd(), 40)
			setTimeout(() => this.checkReachEnd(), 200)
		},
		close() {
			this.unbindDocScroll()
			this.visible = false
			this.reachedEnd = false
		},
		getDoc() {
			// #ifdef H5
			if (typeof document === 'undefined') return null
			return document.getElementById(this.bodyId)
			// #endif
			// #ifndef H5
			return null
			// #endif
		},
		bindDocScroll() {
			// #ifdef H5
			this.unbindDocScroll()
			const el = this.getDoc()
			if (!el) return
			this._onScroll = () => this.checkReachEnd()
			el.addEventListener('scroll', this._onScroll, { passive: true })
			// #endif
		},
		unbindDocScroll() {
			// #ifdef H5
			const el = this.getDoc()
			if (el && this._onScroll) {
				el.removeEventListener('scroll', this._onScroll)
			}
			this._onScroll = null
			// #endif
		},
		onDocScroll(e) {
			const t = e?.target || this.getDoc()
			if (!t) return
			this.markReach(t.scrollTop, t.clientHeight, t.scrollHeight)
		},
		checkReachEnd() {
			const el = this.getDoc()
			if (el) {
				this.markReach(el.scrollTop, el.clientHeight, el.scrollHeight)
				return
			}
			uni.createSelectorQuery()
				.in(this)
				.select('.doc')
				.boundingClientRect()
				.select('.doc-pad')
				.boundingClientRect()
				.exec((res) => {
					const box = res && res[0]
					const pad = res && res[1]
					if (!box || !pad) return
					this.markReach(0, box.height || 0, pad.height || 0)
				})
		},
		markReach(scrollTop, viewport, content) {
			if (!viewport) return
			// 内容不足一屏，或已滚到接近底部
			if (content <= viewport + 12 || scrollTop + viewport >= content - 36) {
				this.reachedEnd = true
			}
		},
		onConfirm() {
			if (!this.canAgree) return
			this.confirmedMap = { ...this.confirmedMap, [this.activeId]: true }
			const next = this.nextUnread()
			if (next) {
				this.open(next.id)
				return
			}
			this.setAgreed(true)
			this.close()
			this.toast('已同意全部协议')
		},
		ensureAgreed() {
			if (this.agreed) return true
			this.toast('请先阅读并同意相关协议')
			const first = this.agreements.find((a) => !this.confirmedMap[a.id]) || this.agreements[0]
			this.open(first.id)
			return false
		}
	}
}
</script>

<style scoped>
.bar {
	margin: 4rpx 0 18rpx;
}
.bar-row {
	display: flex;
	gap: 14rpx;
	align-items: flex-start;
}
.check {
	width: 34rpx;
	height: 34rpx;
	margin-top: 4rpx;
	flex-shrink: 0;
	border-radius: 9rpx;
	border: 2rpx solid #c5d5e2;
	box-sizing: border-box;
	position: relative;
	background: #fff;
}
.check.on {
	border-color: #00a8e8;
	background: linear-gradient(135deg, #00a8e8, #3ec6ff);
}
.check.on::after {
	content: '';
	position: absolute;
	left: 10rpx;
	top: 4rpx;
	width: 8rpx;
	height: 16rpx;
	border: solid #fff;
	border-width: 0 4rpx 4rpx 0;
	transform: rotate(45deg);
}
.bar-text {
	flex: 1;
	min-width: 0;
}
.bar-label {
	display: block;
	font-size: 24rpx;
	color: #5b6b7c;
}
.bar-links {
	margin-top: 4rpx;
	font-size: 24rpx;
	line-height: 1.7;
	color: #6b7c8d;
}
.sep {
	color: #a8b4c0;
}
.a {
	color: #0090c8;
}

.root {
	position: fixed;
	inset: 0;
	z-index: 4000;
	display: flex;
	align-items: flex-end;
	justify-content: center;
}
.mask {
	position: absolute;
	inset: 0;
	background: rgba(15, 23, 36, 0.62);
}
.panel {
	position: relative;
	z-index: 1;
	width: 100%;
	max-width: 860rpx;
	height: 88vh;
	max-height: 88vh;
	display: flex;
	flex-direction: column;
	background: #fff;
	border-radius: 24rpx 24rpx 0 0;
	overflow: hidden;
	box-sizing: border-box;
	padding-bottom: env(safe-area-inset-bottom);
}

.top {
	flex-shrink: 0;
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 16rpx;
	padding: 22rpx 28rpx 10rpx;
}
.top-left {
	min-width: 0;
	flex: 1;
}
.brand {
	display: block;
	font-size: 20rpx;
	font-weight: 800;
	letter-spacing: 0.18em;
	color: #00a8e8;
}
.top-title {
	display: block;
	margin-top: 6rpx;
	font-size: 34rpx;
	font-weight: 760;
	color: #0f1724;
	line-height: 1.25;
}
.close {
	flex-shrink: 0;
	padding: 12rpx 20rpx;
	border-radius: 999rpx;
	font-size: 24rpx;
	font-weight: 650;
	color: #64748b;
	background: #f1f5f9;
}

.chips {
	flex-shrink: 0;
	width: 100%;
	white-space: nowrap;
}
.chips-inner {
	display: inline-flex;
	gap: 12rpx;
	padding: 12rpx 28rpx 8rpx;
}
.chip {
	display: inline-flex;
	align-items: center;
	gap: 8rpx;
	padding: 12rpx 18rpx;
	border-radius: 999rpx;
	background: #f1f5f9;
	color: #64748b;
}
.chip-n {
	font-size: 20rpx;
	font-weight: 800;
	opacity: 0.7;
}
.chip-t {
	font-size: 24rpx;
	font-weight: 650;
}
.chip.active {
	background: #00a8e8;
	color: #fff;
}
.chip.done:not(.active) {
	background: rgba(16, 185, 129, 0.12);
	color: #059669;
}

.meter {
	flex-shrink: 0;
	height: 4rpx;
	margin: 4rpx 28rpx 0;
	border-radius: 999rpx;
	background: #eef2f6;
	overflow: hidden;
}
.meter-fill {
	height: 100%;
	background: #00a8e8;
	transition: width 0.22s ease-out;
}
.meter-label {
	flex-shrink: 0;
	display: block;
	padding: 10rpx 28rpx 8rpx;
	font-size: 22rpx;
	color: #94a3b8;
}

.doc {
	flex: 1 1 auto;
	min-height: 0;
	overflow-x: hidden;
	overflow-y: auto;
	-webkit-overflow-scrolling: touch;
	overscroll-behavior: contain;
	touch-action: pan-y;
	background: #fff;
}
.doc-pad {
	padding: 8rpx 32rpx 40rpx;
}
.doc-h1 {
	display: block;
	font-size: 36rpx;
	font-weight: 780;
	color: #0f1724;
	line-height: 1.35;
}
.doc-meta {
	display: block;
	margin: 10rpx 0 28rpx;
	font-size: 22rpx;
	color: #94a3b8;
}
.block {
	margin-bottom: 28rpx;
}
.h2 {
	display: block;
	margin-bottom: 12rpx;
	font-size: 28rpx;
	font-weight: 740;
	color: #111827;
}
.p {
	display: block;
	margin-bottom: 14rpx;
	font-size: 27rpx;
	line-height: 1.8;
	color: #475569;
}

.end-tip {
	margin-top: 12rpx;
	padding: 18rpx;
	border-radius: 14rpx;
	text-align: center;
	font-size: 22rpx;
	color: #94a3b8;
	background: #f8fafc;
	border: 1rpx dashed #d7e2ec;
}
.end-tip.on {
	color: #059669;
	background: rgba(16, 185, 129, 0.08);
	border-color: rgba(16, 185, 129, 0.3);
}

.bottom {
	flex-shrink: 0;
	padding: 16rpx 24rpx 18rpx;
	border-top: 1rpx solid #eef2f6;
	background: #fff;
}
.btns {
	display: flex;
	gap: 12rpx;
}
.btn {
	min-height: 88rpx;
	padding: 20rpx 18rpx;
	border-radius: 16rpx;
	box-sizing: border-box;
	font-size: 28rpx;
	font-weight: 740;
	display: flex;
	align-items: center;
	justify-content: center;
	text-align: center;
	transition: opacity 0.2s ease-out, transform 0.2s ease-out, box-shadow 0.2s ease-out;
}
.btn.ghost {
	flex: 0.72;
	background: #f1f5f9;
	color: #475569;
}
.btn.main {
	flex: 1.28;
	color: #fff;
	background: #94a3b8;
	box-shadow: none;
}
.btn.main.ready {
	background: linear-gradient(135deg, #00a8e8, #3ec6ff);
	box-shadow: 0 10rpx 22rpx rgba(0, 168, 232, 0.28);
}
.btn.main.alone {
	flex: 1;
}
.btn.disabled {
	opacity: 0.55;
	pointer-events: none;
}
</style>
