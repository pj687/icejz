<template>
  <view class="guide" :class="'tone-' + current.tone">
    <view class="bg" aria-hidden="true">
      <view class="bg-base" />
      <view class="aurora a1" />
      <view class="aurora a2" />
      <view class="blob b1" />
      <view class="blob b2" />
      <view class="beam" />
      <view class="grid" />
      <view class="grain" />
      <view class="vignette" />
      <view class="corner tl"><view class="ch" /><view class="cv" /></view>
      <view class="corner tr"><view class="ch" /><view class="cv" /></view>
      <view class="corner bl"><view class="ch" /><view class="cv" /></view>
      <view class="corner br"><view class="ch" /><view class="cv" /></view>
    </view>

    <view class="chrome" :style="{ paddingTop: statusBarPx + 6 + 'px' }">
      <view class="mark-row">
        <view class="mark-line" />
        <text class="mark-text">STUDIO</text>
        <view class="mark-line" />
      </view>
      <view class="skip-btn" @click="finish">{{ $t('guide.skip') }}</view>
    </view>

    <view class="progress">
      <view class="track">
        <view class="fill" :style="{ width: progressPct + '%' }">
          <view class="fill-tip" />
        </view>
      </view>
      <text class="progress-lab">{{ progressText }}</text>
    </view>

    <swiper class="board" :current="step" :duration="420" @change="onSwipe">
      <swiper-item v-for="(item, index) in steps" :key="item.key">
        <view class="pane" :class="{ on: index === step }">
          <view class="orb-wrap">
            <view class="halo" />
            <view class="halo soft" />
            <view class="ring r1" />
            <view class="ring r2" />
            <view class="orbit">
              <view class="orbit-dot" />
            </view>
            <view class="orbit slow">
              <view class="orbit-dot mini" />
            </view>
            <view class="tick t1" />
            <view class="tick t2" />
            <view class="tick t3" />
            <view class="tick t4" />

            <view class="orb" :class="item.tone">
              <view class="orb-sheen" />
              <view class="orb-rim" />

              <!-- welcome -->
              <view v-if="item.key === 'welcome'" class="viz welcome">
                <view class="logo-frame">
                  <image class="logo" src="/static/logo.png" mode="aspectFill" />
                </view>
                <view class="wm">
                  <text class="ice">ICE</text><text class="jz">JZ</text>
                </view>
              </view>

              <!-- workbench: abstract dashboard mosaic -->
              <view v-else-if="item.key === 'workbench'" class="viz mosaic">
                <view class="tile a">
                  <view class="spark" />
                  <view class="bar b1" />
                  <view class="bar b2" />
                  <view class="bar b3" />
                </view>
                <view class="tile b">
                  <image src="/static/tab/work-active.svg" mode="aspectFit" />
                </view>
                <view class="tile c">
                  <view class="dot on" />
                  <view class="dot" />
                  <view class="dot" />
                </view>
              </view>

              <!-- assistant -->
              <view v-else-if="item.key === 'assistant'" class="viz bot">
                <image class="mascot" src="/static/mascot/xiaobing-main.png" mode="aspectFit" />
              </view>

              <!-- security -->
              <view v-else class="viz safe">
                <view class="shield">
                  <image src="/static/icons/lock.svg" mode="aspectFit" />
                </view>
                <view class="safe-gems">
                  <view class="gem"><image src="/static/icons/profile.svg" mode="aspectFit" /></view>
                  <view class="gem"><image src="/static/icons/device.svg" mode="aspectFit" /></view>
                  <view class="gem"><image src="/static/tab/me-active.svg" mode="aspectFit" /></view>
                </view>
              </view>
            </view>
          </view>

          <view class="copy">
            <view class="meta">
              <text class="num">{{ item.num }}</text>
              <view class="meta-rule" />
              <text class="kicker">{{ item.kicker }}</text>
            </view>
            <text class="title">{{ item.title }}</text>
            <text class="desc">{{ item.desc }}</text>
            <view class="feats">
              <view v-for="chip in item.chips" :key="chip" class="feat">
                <view class="feat-diamond" />
                <text>{{ chip }}</text>
              </view>
            </view>
          </view>
        </view>
      </swiper-item>
    </swiper>

    <view class="footer">
      <view class="ctrl back" :class="{ ghost: step <= 0 }" @click="prev">
        <text>‹</text>
      </view>
      <view v-if="!isLast" class="ctrl skip-foot" @click="finish">
        {{ $t('guide.skip') }}
      </view>
      <view class="ctrl primary" :class="{ final: isLast }" @click="next">
        <view class="primary-sheen" />
        <text>{{ isLast ? $t('guide.start') : $t('guide.next') }}</text>
        <text v-if="!isLast" class="arrow">›</text>
      </view>
    </view>
  </view>
</template>

<script>
import { markGuideDone } from '@/utils/guide.js'

export default {
  name: 'Guide',
  data() {
    return {
      statusBarPx: 20,
      step: 0
    }
  },
  computed: {
    steps() {
      void this.$i18n.locale
      return [
        {
          key: 'welcome',
          tone: 'cyan',
          num: '01',
          kicker: this.$t('guide.s1Kicker'),
          title: this.$t('guide.s1Title'),
          desc: this.$t('guide.s1Desc'),
          chips: [this.$t('guide.s1Chip1'), this.$t('guide.s1Chip2'), this.$t('guide.s1Chip3')]
        },
        {
          key: 'workbench',
          tone: 'sky',
          num: '02',
          kicker: this.$t('guide.s2Kicker'),
          title: this.$t('guide.s2Title'),
          desc: this.$t('guide.s2Desc'),
          chips: [this.$t('guide.s2Chip1'), this.$t('guide.s2Chip2'), this.$t('guide.s2Chip3')]
        },
        {
          key: 'assistant',
          tone: 'mint',
          num: '03',
          kicker: this.$t('guide.s3Kicker'),
          title: this.$t('guide.s3Title'),
          desc: this.$t('guide.s3Desc'),
          chips: [this.$t('guide.s3Chip1'), this.$t('guide.s3Chip2'), this.$t('guide.s3Chip3')]
        },
        {
          key: 'security',
          tone: 'violet',
          num: '04',
          kicker: this.$t('guide.s4Kicker'),
          title: this.$t('guide.s4Title'),
          desc: this.$t('guide.s4Desc'),
          chips: [this.$t('guide.s4Chip1'), this.$t('guide.s4Chip2'), this.$t('guide.s4Chip3')]
        }
      ]
    },
    current() {
      return this.steps[this.step] || this.steps[0]
    },
    isLast() {
      return this.step >= this.steps.length - 1
    },
    progressText() {
      return this.$t('guide.stepProgress', {
        current: this.step + 1,
        total: this.steps.length
      })
    },
    progressPct() {
      const total = this.steps.length || 1
      return Math.round(((this.step + 1) / total) * 100)
    }
  },
  created() {
    try {
      this.statusBarPx = uni.getSystemInfoSync().statusBarHeight || 20
    } catch (e) {
      this.statusBarPx = 20
    }
  },
  methods: {
    onSwipe(e) {
      this.step = Number(e.detail.current) || 0
    },
    prev() {
      if (this.step <= 0) return
      this.step -= 1
    },
    next() {
      if (this.isLast) {
        this.finish()
        return
      }
      this.step += 1
    },
    finish() {
      markGuideDone()
      uni.switchTab({ url: '/pages/index/index' })
    }
  }
}
</script>

<style scoped>
.guide {
  --ink: #0d1a2a;
  --mute: #6a7c8f;
  --cyan: #00a8e8;
  position: relative;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background: #eef5fa;
  transition: background 0.4s ease;
}

.guide.tone-sky { background: #edf4fb; }
.guide.tone-mint { background: #eef8f5; }
.guide.tone-violet { background: #eef2fa; }

.bg {
  position: absolute;
  inset: 0;
  pointer-events: none;
  overflow: hidden;
}

.bg-base {
  position: absolute;
  inset: 0;
  background:
    radial-gradient(ellipse 90% 55% at 50% -8%, rgba(0, 168, 232, 0.18), transparent 58%),
    radial-gradient(ellipse 50% 40% at 100% 30%, rgba(56, 189, 248, 0.1), transparent 55%),
    linear-gradient(180deg, #e8f4fb 0%, #eef5fa 48%, #f5f8fb 100%);
}

.aurora {
  position: absolute;
  border-radius: 50%;
  filter: blur(28px);
  opacity: 0.45;
}

.aurora.a1 {
  width: 560rpx;
  height: 180rpx;
  top: 18%;
  left: 50%;
  margin-left: -280rpx;
  background: linear-gradient(90deg, transparent, rgba(125, 211, 252, 0.4), transparent);
  animation: aurora 9s ease-in-out infinite;
}

.aurora.a2 {
  width: 400rpx;
  height: 140rpx;
  bottom: 22%;
  right: -40rpx;
  background: linear-gradient(90deg, transparent, rgba(186, 230, 253, 0.35), transparent);
  animation: aurora 11s ease-in-out infinite reverse;
}

.blob {
  position: absolute;
  border-radius: 50%;
}

.b1 {
  width: 460rpx;
  height: 460rpx;
  top: -160rpx;
  right: -140rpx;
  background: radial-gradient(circle, rgba(0, 168, 232, 0.2), transparent 68%);
  animation: float-a 8s ease-in-out infinite;
}

.b2 {
  width: 340rpx;
  height: 340rpx;
  bottom: 8%;
  left: -150rpx;
  background: radial-gradient(circle, rgba(56, 189, 248, 0.14), transparent 70%);
  animation: float-b 9s ease-in-out infinite;
}

.beam {
  position: absolute;
  top: 8%;
  left: 50%;
  width: 2rpx;
  height: 280rpx;
  margin-left: -1rpx;
  background: linear-gradient(180deg, transparent, rgba(0, 168, 232, 0.35), transparent);
  opacity: 0.5;
}

.grid {
  position: absolute;
  inset: 0;
  opacity: 0.2;
  background-image:
    linear-gradient(rgba(0, 168, 232, 0.08) 1rpx, transparent 1rpx),
    linear-gradient(90deg, rgba(0, 168, 232, 0.08) 1rpx, transparent 1rpx);
  background-size: 48rpx 48rpx;
  mask-image: radial-gradient(circle at 50% 32%, #000 0%, transparent 70%);
}

.grain {
  position: absolute;
  inset: 0;
  opacity: 0.035;
  background-image: radial-gradient(rgba(15, 40, 70, 0.9) 0.6rpx, transparent 0.6rpx);
  background-size: 6rpx 6rpx;
}

.vignette {
  position: absolute;
  inset: 0;
  background: radial-gradient(circle at 50% 40%, transparent 40%, rgba(238, 245, 250, 0.55) 100%);
}

.corner {
  position: absolute;
  width: 36rpx;
  height: 36rpx;
  opacity: 0.35;
}

.corner.tl { top: 28rpx; left: 24rpx; }
.corner.tr { top: 28rpx; right: 24rpx; }
.corner.bl { bottom: 28rpx; left: 24rpx; }
.corner.br { bottom: 28rpx; right: 24rpx; }

.ch,
.cv {
  position: absolute;
  background: rgba(15, 40, 70, 0.45);
}

.ch { height: 2rpx; width: 100%; }
.cv { width: 2rpx; height: 100%; }

.corner.tl .ch, .corner.tl .cv { top: 0; left: 0; }
.corner.tr .ch { top: 0; right: 0; }
.corner.tr .cv { top: 0; right: 0; }
.corner.bl .ch { bottom: 0; left: 0; }
.corner.bl .cv { bottom: 0; left: 0; }
.corner.br .ch { bottom: 0; right: 0; }
.corner.br .cv { bottom: 0; right: 0; }

.chrome {
  position: relative;
  z-index: 5;
  padding: 0 28rpx 0;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.mark-row {
  display: flex;
  align-items: center;
  gap: 14rpx;
}

.mark-line {
  width: 28rpx;
  height: 2rpx;
  background: linear-gradient(90deg, transparent, rgba(15, 40, 70, 0.28));
}

.mark-row .mark-line:last-child {
  background: linear-gradient(90deg, rgba(15, 40, 70, 0.28), transparent);
}

.mark-text {
  font-size: 18rpx;
  font-weight: 750;
  letter-spacing: 0.28em;
  color: rgba(15, 40, 70, 0.45);
}

.skip-btn {
  min-width: 96rpx;
  height: 56rpx;
  padding: 0 22rpx;
  border-radius: 999rpx;
  background: rgba(255, 255, 255, 0.92);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  box-shadow: 0 8rpx 18rpx rgba(15, 35, 55, 0.06);
  font-size: 24rpx;
  font-weight: 700;
  color: #5b6b7c;
  display: flex;
  align-items: center;
  justify-content: center;
}

.progress {
  position: relative;
  z-index: 5;
  margin: 18rpx 36rpx 0;
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.track {
  flex: 1;
  height: 6rpx;
  border-radius: 999rpx;
  background: rgba(15, 40, 70, 0.08);
  overflow: visible;
}

.fill {
  position: relative;
  height: 100%;
  border-radius: 999rpx;
  background: linear-gradient(90deg, #00a8e8, #38bdf8);
  box-shadow: 0 0 14rpx rgba(0, 168, 232, 0.35);
  transition: width 0.35s cubic-bezier(0.22, 1, 0.36, 1);
}

.fill-tip {
  position: absolute;
  right: -6rpx;
  top: 50%;
  width: 14rpx;
  height: 14rpx;
  margin-top: -7rpx;
  border-radius: 50%;
  background: #fff;
  border: 3rpx solid #00a8e8;
  box-shadow: 0 0 12rpx rgba(0, 168, 232, 0.45);
}

.progress-lab {
  font-size: 20rpx;
  font-weight: 720;
  color: #8492a6;
  letter-spacing: 0.08em;
  min-width: 64rpx;
  text-align: right;
}

.board {
  position: relative;
  z-index: 2;
  flex: 1;
  min-height: 0;
  width: 100%;
}

.pane {
  height: 100%;
  box-sizing: border-box;
  padding: 8rpx 32rpx 0;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.pane .orb-wrap,
.pane .copy {
  opacity: 0.55;
  transform: translateY(16rpx) scale(0.985);
  transition: opacity 0.45s ease, transform 0.45s cubic-bezier(0.22, 1, 0.36, 1);
}

.pane.on .orb-wrap,
.pane.on .copy {
  opacity: 1;
  transform: translateY(0) scale(1);
}

.orb-wrap {
  position: relative;
  width: 420rpx;
  height: 420rpx;
  margin-top: 12rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.halo {
  position: absolute;
  width: 320rpx;
  height: 320rpx;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(0, 168, 232, 0.22), transparent 68%);
  animation: breathe 3.4s ease-in-out infinite;
}

.halo.soft {
  width: 380rpx;
  height: 380rpx;
  background: radial-gradient(circle, rgba(255, 255, 255, 0.55), transparent 70%);
  animation-delay: 0.4s;
}

.ring {
  position: absolute;
  border-radius: 50%;
  border: 1rpx solid rgba(0, 168, 232, 0.16);
}

.ring.r1 { width: 300rpx; height: 300rpx; }
.ring.r2 {
  width: 360rpx;
  height: 360rpx;
  border-style: dashed;
  border-color: rgba(0, 168, 232, 0.22);
  animation: spin 28s linear infinite;
}

.orbit {
  position: absolute;
  width: 360rpx;
  height: 360rpx;
  animation: spin 14s linear infinite;
}

.orbit.slow { animation-duration: 22s; animation-direction: reverse; }

.orbit-dot {
  position: absolute;
  top: 8rpx;
  left: 50%;
  width: 10rpx;
  height: 10rpx;
  margin-left: -5rpx;
  border-radius: 50%;
  background: #00a8e8;
  box-shadow: 0 0 12rpx rgba(0, 168, 232, 0.5);
}

.orbit-dot.mini {
  width: 7rpx;
  height: 7rpx;
  margin-left: -3.5rpx;
  background: #7dd3fc;
}

.tick {
  position: absolute;
  width: 2rpx;
  height: 14rpx;
  background: rgba(0, 168, 232, 0.35);
  border-radius: 2rpx;
}

.tick.t1 { top: 18rpx; left: 50%; margin-left: -1rpx; }
.tick.t2 { bottom: 18rpx; left: 50%; margin-left: -1rpx; }
.tick.t3 { left: 18rpx; top: 50%; margin-top: -7rpx; width: 14rpx; height: 2rpx; }
.tick.t4 { right: 18rpx; top: 50%; margin-top: -7rpx; width: 14rpx; height: 2rpx; }

.orb {
  position: relative;
  z-index: 2;
  width: 260rpx;
  height: 260rpx;
  border-radius: 50%;
  background: linear-gradient(160deg, #ffffff 0%, #e7f5fb 55%, #d5eef8 100%);
  border: 4rpx solid rgba(255, 255, 255, 0.95);
  box-shadow:
    0 22rpx 48rpx rgba(0, 120, 180, 0.18),
    inset 0 1rpx 0 rgba(255, 255, 255, 0.95);
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
}

.orb.sky {
  background: linear-gradient(160deg, #ffffff 0%, #e8f2ff 55%, #d9e9ff 100%);
}

.orb.mint {
  background: linear-gradient(160deg, #ffffff 0%, #e6f8f3 55%, #d2f1e8 100%);
}

.orb.violet {
  background: linear-gradient(160deg, #ffffff 0%, #eceffc 55%, #dde3f8 100%);
}

.orb-sheen {
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.7), transparent 42%);
  pointer-events: none;
}

.orb-rim {
  position: absolute;
  inset: 10rpx;
  border-radius: 50%;
  border: 1rpx solid rgba(255, 255, 255, 0.65);
  pointer-events: none;
}

.viz {
  position: relative;
  z-index: 1;
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.welcome {
  flex-direction: column;
  gap: 10rpx;
}

.logo-frame {
  width: 96rpx;
  height: 96rpx;
  border-radius: 28rpx;
  overflow: hidden;
  background: #fff;
  box-shadow: 0 10rpx 22rpx rgba(0, 140, 200, 0.18);
}

.logo { width: 100%; height: 100%; }

.wm { line-height: 1; }
.ice, .jz {
  font-size: 28rpx;
  font-weight: 840;
  letter-spacing: 0.04em;
}
.ice { color: var(--ink); }
.jz { color: var(--cyan); }

.mosaic {
  gap: 10rpx;
  padding: 28rpx;
}

.tile {
  border-radius: 18rpx;
  background: rgba(255, 255, 255, 0.88);
  box-shadow: 0 8rpx 18rpx rgba(15, 40, 70, 0.08);
}

.tile.a {
  width: 88rpx;
  height: 100rpx;
  padding: 14rpx 12rpx;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  gap: 6rpx;
  position: relative;
}

.tile.a .spark {
  position: absolute;
  top: 12rpx;
  left: 12rpx;
  width: 12rpx;
  height: 12rpx;
  border-radius: 50%;
  background: #00a8e8;
}

.tile.a .bar {
  height: 8rpx;
  border-radius: 999rpx;
  background: linear-gradient(90deg, #7dd3fc, #00a8e8);
}
.tile.a .b1 { width: 70%; }
.tile.a .b2 { width: 100%; }
.tile.a .b3 { width: 48%; }

.tile.b {
  width: 72rpx;
  height: 72rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  align-self: flex-start;
  margin-top: 8rpx;
}

.tile.b image { width: 32rpx; height: 32rpx; }

.tile.c {
  position: absolute;
  bottom: 36rpx;
  right: 36rpx;
  width: 96rpx;
  height: 40rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8rpx;
}

.tile.c .dot {
  width: 10rpx;
  height: 10rpx;
  border-radius: 50%;
  background: #c9d7e4;
}

.tile.c .dot.on { background: #00a8e8; }

.mascot {
  width: 190rpx;
  height: 190rpx;
  filter: drop-shadow(0 12rpx 20rpx rgba(15, 90, 80, 0.12));
}

.safe {
  flex-direction: column;
  gap: 18rpx;
}

.shield {
  width: 88rpx;
  height: 88rpx;
  border-radius: 28rpx;
  background: rgba(255, 255, 255, 0.92);
  box-shadow: 0 10rpx 22rpx rgba(0, 140, 200, 0.12);
  display: flex;
  align-items: center;
  justify-content: center;
}

.shield image { width: 36rpx; height: 36rpx; }

.safe-gems {
  display: flex;
  gap: 10rpx;
}

.gem {
  width: 44rpx;
  height: 44rpx;
  border-radius: 14rpx;
  background: rgba(255, 255, 255, 0.92);
  box-shadow: 0 6rpx 14rpx rgba(15, 40, 70, 0.08);
  display: flex;
  align-items: center;
  justify-content: center;
}

.gem image { width: 22rpx; height: 22rpx; }

.copy {
  width: 100%;
  max-width: 620rpx;
  margin-top: 28rpx;
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  transition-delay: 0.06s;
}

.meta {
  display: flex;
  align-items: center;
  gap: 14rpx;
}

.num {
  font-size: 24rpx;
  font-weight: 820;
  letter-spacing: 0.12em;
  color: var(--cyan);
}

.meta-rule {
  width: 28rpx;
  height: 2rpx;
  background: rgba(0, 168, 232, 0.35);
}

.kicker {
  font-size: 20rpx;
  font-weight: 750;
  letter-spacing: 0.16em;
  color: #5b7390;
}

.title {
  display: block;
  margin-top: 16rpx;
  font-size: 44rpx;
  font-weight: 840;
  color: var(--ink);
  line-height: 1.25;
  letter-spacing: 0.01em;
}

.desc {
  display: block;
  margin-top: 14rpx;
  font-size: 25rpx;
  line-height: 1.7;
  color: var(--mute);
  max-width: 560rpx;
}

.feats {
  margin-top: 24rpx;
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 10rpx 22rpx;
}

.feat {
  display: inline-flex;
  align-items: center;
  gap: 8rpx;
  font-size: 22rpx;
  font-weight: 680;
  color: #3f5568;
}

.feat-diamond {
  width: 8rpx;
  height: 8rpx;
  background: #00a8e8;
  transform: rotate(45deg);
  box-shadow: 0 0 0 4rpx rgba(0, 168, 232, 0.12);
}

.footer {
  position: relative;
  z-index: 5;
  padding: 10rpx 32rpx calc(22rpx + env(safe-area-inset-bottom));
  display: flex;
  align-items: center;
  gap: 14rpx;
}

.ctrl {
  height: 92rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.back {
  width: 92rpx;
  border-radius: 28rpx;
  background: rgba(255, 255, 255, 0.88);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  box-shadow: 0 10rpx 22rpx rgba(15, 35, 55, 0.06);
  color: #3d4f61;
  font-size: 40rpx;
  font-weight: 600;
  flex-shrink: 0;
  transition: opacity 0.2s ease;
}

.back.ghost {
  opacity: 0;
  pointer-events: none;
}

.skip-foot {
  min-width: 148rpx;
  padding: 0 24rpx;
  border-radius: 28rpx;
  background: rgba(255, 255, 255, 0.92);
  border: 1rpx solid rgba(231, 238, 245, 0.98);
  box-shadow: 0 10rpx 22rpx rgba(15, 35, 55, 0.05);
  color: #5b6b7c;
  font-size: 28rpx;
  font-weight: 700;
  flex-shrink: 0;
}

.primary {
  position: relative;
  overflow: hidden;
  flex: 1;
  border-radius: 28rpx;
  background: linear-gradient(145deg, #00a8e8, #2bb8ef);
  box-shadow: 0 16rpx 32rpx rgba(0, 168, 232, 0.28);
  color: #fff;
  font-size: 30rpx;
  font-weight: 750;
  gap: 8rpx;
}

.primary.final {
  background: linear-gradient(145deg, #00a8e8 0%, #0ea5e9 48%, #14b8a6 100%);
}

.primary-sheen {
  position: absolute;
  inset: 0;
  background: linear-gradient(110deg, transparent 30%, rgba(255, 255, 255, 0.28) 48%, transparent 66%);
  transform: translateX(-120%);
  animation: glint 3.6s ease-in-out infinite;
}

.arrow {
  font-size: 34rpx;
  line-height: 1;
  opacity: 0.9;
}

@keyframes aurora {
  0%, 100% { transform: translateX(0); opacity: 0.35; }
  50% { transform: translateX(18rpx); opacity: 0.65; }
}

@keyframes float-a {
  0%, 100% { transform: translate(0, 0); }
  50% { transform: translate(12rpx, 10rpx); }
}

@keyframes float-b {
  0%, 100% { transform: translate(0, 0); }
  50% { transform: translate(-10rpx, 8rpx); }
}

@keyframes breathe {
  0%, 100% { transform: scale(0.94); opacity: 0.55; }
  50% { transform: scale(1.05); opacity: 1; }
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

@keyframes glint {
  0%, 55% { transform: translateX(-120%); }
  75%, 100% { transform: translateX(120%); }
}
</style>
