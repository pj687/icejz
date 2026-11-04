<template>
  <view class="splash" :class="{ leave: leaving, ready: ready }">
    <view class="bg">
      <view class="bg-base" />
      <view class="aurora a1" />
      <view class="aurora a2" />
      <view class="blob b1" />
      <view class="blob b2" />
      <view class="blob b3" />
      <view class="beam beam-a" />
      <view class="beam beam-b" />
      <view class="grid" />
      <view class="grain" />
      <view class="vignette" />
      <view
        v-for="(p, i) in particles"
        :key="'p' + i"
        class="particle"
        :class="p.tone"
        :style="p.style"
      />
      <view class="corner tl"><view class="ch" /><view class="cv" /></view>
      <view class="corner tr"><view class="ch" /><view class="cv" /></view>
      <view class="corner bl"><view class="ch" /><view class="cv" /></view>
      <view class="corner br"><view class="ch" /><view class="cv" /></view>
    </view>

    <view class="stage">
      <view class="mark-row" :class="{ show: phase >= 1 }">
        <view class="mark-line" />
        <text class="mark-text">STUDIO</text>
        <view class="mark-line" />
      </view>

      <view class="orb-wrap" :class="{ show: phase >= 1 }">
        <view class="halo" />
        <view class="halo soft" />
        <view class="ring r1" />
        <view class="ring r2" />
        <view class="ring r3" />
        <view class="tick t1" />
        <view class="tick t2" />
        <view class="tick t3" />
        <view class="tick t4" />
        <view class="orbit">
          <view class="orbit-dot" />
        </view>
        <view class="orbit slow">
          <view class="orbit-dot mini" />
        </view>
        <view class="spark s1" />
        <view class="spark s2" />
        <view class="spark s3" />
        <view class="orb">
          <view class="orb-sheen" />
          <view class="orb-rim" />
          <view class="orb-glow" />
          <image class="mascot" src="/static/mascot/xiaobing-main.png" mode="aspectFit" />
        </view>
      </view>

      <view class="brand" :class="{ show: phase >= 2 }">
        <view class="kicker" :class="{ in: letterStep >= 1 }">
          <view class="kicker-dot" />
          <text class="kicker-text">ICECORE</text>
          <view class="kicker-chip">ENGINE</view>
        </view>
        <view class="wordmark">
          <text
            v-for="(ch, i) in brandLetters"
            :key="i"
            class="letter"
            :class="[ch.tone, { in: letterStep > i + 1 }]"
            :style="{ transitionDelay: i * 70 + 'ms' }"
          >{{ ch.char }}</text>
        </view>
        <view class="brand-rule" :class="{ in: letterStep >= 7 }">
          <view class="rule-diamond" />
          <view class="brand-line" />
          <view class="rule-diamond" />
        </view>
        <text class="slogan" :class="{ in: letterStep >= 7 }">{{ $t('splash.slogan') }}</text>
        <text class="hint" :class="{ in: letterStep >= 8 }">{{ $t('splash.hint') }}</text>
      </view>

      <view class="loader" :class="{ show: phase >= 3, ready: ready }">
        <view class="track">
          <view class="fill" :style="{ width: progress + '%' }">
            <view class="fill-shine" />
            <view class="fill-tip" />
          </view>
        </view>
        <view class="loader-meta">
          <view class="status">
            <view class="status-dot" />
            <text class="loading-text">{{ ready ? readyText : $t('splash.loading') }}</text>
          </view>
          <text class="loading-pct">{{ progress }}%</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
import cache from '@/utils/cache.js'
import { resolvePostAuthRoute } from '@/utils/guide.js'

const HOLD_MS = 1500
const LEAVE_MS = 520
const PROGRESS_START_MS = 1280
const PROGRESS_DURATION_MS = 1400

export default {
  name: 'Splash',
  data() {
    return {
      phase: 0,
      progress: 0,
      letterStep: 0,
      ready: false,
      leaving: false,
      done: false,
      brandLetters: [
        { char: 'I', tone: 'ice' },
        { char: 'C', tone: 'ice' },
        { char: 'E', tone: 'ice' },
        { char: 'J', tone: 'jz' },
        { char: 'Z', tone: 'jz' }
      ],
      particles: [
        { tone: 'cyan', style: { left: '12%', top: '18%', animationDelay: '0s' } },
        { tone: 'soft', style: { left: '78%', top: '22%', animationDelay: '0.6s' } },
        { tone: 'cyan', style: { left: '22%', top: '68%', animationDelay: '1.1s' } },
        { tone: 'soft', style: { left: '86%', top: '58%', animationDelay: '0.3s' } },
        { tone: 'cyan', style: { left: '48%', top: '12%', animationDelay: '1.4s' } },
        { tone: 'soft', style: { left: '64%', top: '76%', animationDelay: '0.9s' } },
        { tone: 'cyan', style: { left: '34%', top: '44%', animationDelay: '1.8s' } },
        { tone: 'soft', style: { left: '70%', top: '36%', animationDelay: '0.5s' } },
        { tone: 'cyan', style: { left: '8%', top: '42%', animationDelay: '1.2s' } },
        { tone: 'soft', style: { left: '92%', top: '48%', animationDelay: '0.8s' } }
      ]
    }
  },
  computed: {
    readyText() {
      return this.$i18n.locale === 'en-US' ? 'Ready' : '准备就绪'
    }
  },
  onLoad() {
    this.runSequence()
  },
  mounted() {
    this.runSequence()
  },
  onUnload() {
    this.clearTimers()
  },
  beforeUnmount() {
    this.clearTimers()
  },
  methods: {
    clearTimers() {
      ;(this._timers || []).forEach((id) => clearTimeout(id))
      this._timers = []
      if (this._raf) {
        clearInterval(this._raf)
        this._raf = null
      }
    },
    later(fn, ms) {
      const id = setTimeout(fn, ms)
      if (!this._timers) this._timers = []
      this._timers.push(id)
      return id
    },
    runLetterReveal() {
      const steps = [0, 1, 2, 3, 4, 5, 6, 7, 8]
      steps.forEach((step, idx) => {
        this.later(() => {
          this.letterStep = step
        }, idx * 100)
      })
    },
    runSequence() {
      if (this._started) return
      this._started = true
      this.later(() => {
        this.phase = 1
      }, 50)
      this.later(() => {
        this.phase = 2
        this.runLetterReveal()
      }, 380)
      this.later(() => {
        this.phase = 3
        this.animateProgress()
      }, PROGRESS_START_MS)
    },
    animateProgress() {
      const start = Date.now()
      this._raf = setInterval(() => {
        const t = Math.min(1, (Date.now() - start) / PROGRESS_DURATION_MS)
        const eased = 1 - Math.pow(1 - t, 3)
        this.progress = Math.round(eased * 100)
        if (t >= 1 && this._raf) {
          clearInterval(this._raf)
          this._raf = null
          this.progress = 100
          this.onAllReady()
        }
      }, 32)
    },
    onAllReady() {
      if (this.ready) return
      this.ready = true
      this.later(() => {
        this.finish()
      }, HOLD_MS)
    },
    finish() {
      if (this.done) return
      this.done = true
      this.progress = 100
      this.leaving = true
      this.later(() => {
        this.goNext()
      }, LEAVE_MS)
    },
    goNext() {
      const token = cache.getToken()
      if (token) {
        const url = resolvePostAuthRoute()
        if (url.includes('/pages/index/')) {
          uni.reLaunch({ url: '/pages/index/index' })
        } else {
          uni.reLaunch({ url })
        }
      } else {
        uni.reLaunch({ url: '/pages/login/login' })
      }
    }
  }
}
</script>

<style scoped>
.splash {
  --ink: #0f1b2d;
  --mute: #8492a6;
  --accent: #00a8e8;
  --accent-soft: #2bb8ef;
  --canvas: #f3f6fa;
  --panel: rgba(255, 255, 255, 0.92);
  position: relative;
  min-height: 100vh;
  overflow: hidden;
  background: var(--canvas);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: opacity 0.45s ease, transform 0.45s ease, filter 0.45s ease;
}

.splash.ready .orb-wrap {
  animation: ready-breathe 1.6s ease-in-out infinite;
}

.splash.leave {
  opacity: 0;
  transform: scale(1.05);
  filter: blur(6px);
}

.bg {
  position: absolute;
  inset: 0;
  pointer-events: none;
}

.bg-base {
  position: absolute;
  inset: 0;
  background:
    radial-gradient(ellipse 85% 55% at 50% -8%, rgba(0, 168, 232, 0.16), transparent 60%),
    radial-gradient(ellipse 55% 42% at 100% 22%, rgba(56, 189, 248, 0.14), transparent 58%),
    radial-gradient(ellipse 50% 38% at 0% 78%, rgba(0, 168, 232, 0.1), transparent 58%),
    linear-gradient(180deg, #eef6fb 0%, #f3f6fa 46%, #f8fafc 100%);
}

.aurora {
  position: absolute;
  border-radius: 50%;
  filter: blur(28px);
  opacity: 0.55;
}

.aurora.a1 {
  width: 520rpx;
  height: 180rpx;
  top: 18%;
  left: 50%;
  margin-left: -260rpx;
  background: linear-gradient(90deg, transparent, rgba(125, 211, 252, 0.35), rgba(0, 168, 232, 0.18), transparent);
  animation: aurora-drift 7.5s ease-in-out infinite;
}

.aurora.a2 {
  width: 380rpx;
  height: 140rpx;
  bottom: 16%;
  right: 4%;
  background: linear-gradient(90deg, transparent, rgba(186, 230, 253, 0.4), transparent);
  animation: aurora-drift 9s ease-in-out infinite reverse;
}

.blob {
  position: absolute;
  border-radius: 50%;
  filter: blur(2px);
}

.blob.b1 {
  width: 540rpx;
  height: 540rpx;
  top: -180rpx;
  right: -140rpx;
  background: radial-gradient(circle, rgba(0, 168, 232, 0.18), transparent 68%);
  animation: float-a 6s ease-in-out infinite;
}

.blob.b2 {
  width: 440rpx;
  height: 440rpx;
  bottom: 4%;
  left: -180rpx;
  background: radial-gradient(circle, rgba(56, 189, 248, 0.16), transparent 70%);
  animation: float-b 7s ease-in-out infinite;
}

.blob.b3 {
  width: 260rpx;
  height: 260rpx;
  top: 40%;
  right: 6%;
  background: radial-gradient(circle, rgba(255, 255, 255, 0.75), transparent 70%);
  animation: float-a 8s ease-in-out infinite reverse;
}

.beam {
  position: absolute;
  width: 2rpx;
  top: -10%;
  bottom: -10%;
  background: linear-gradient(180deg, transparent, rgba(0, 168, 232, 0.22), transparent);
  opacity: 0.28;
  filter: blur(1px);
}

.beam-a {
  left: 22%;
  transform: rotate(16deg);
  animation: beam 8s ease-in-out infinite;
}

.beam-b {
  right: 18%;
  transform: rotate(-12deg);
  opacity: 0.18;
  animation: beam 10s ease-in-out infinite reverse;
}

.grid {
  position: absolute;
  inset: 0;
  opacity: 0.28;
  background-image:
    linear-gradient(rgba(0, 168, 232, 0.08) 1rpx, transparent 1rpx),
    linear-gradient(90deg, rgba(0, 168, 232, 0.08) 1rpx, transparent 1rpx);
  background-size: 56rpx 56rpx;
  mask-image: radial-gradient(circle at 50% 40%, #000 0%, transparent 72%);
}

.grain {
  position: absolute;
  inset: 0;
  opacity: 0.035;
  background-image: radial-gradient(rgba(15, 35, 55, 0.35) 0.5px, transparent 0.5px);
  background-size: 4px 4px;
}

.vignette {
  position: absolute;
  inset: 0;
  background:
    radial-gradient(circle at 50% 42%, transparent 34%, rgba(243, 246, 250, 0.55) 100%),
    linear-gradient(180deg, rgba(255, 255, 255, 0.2), transparent 18%, transparent 78%, rgba(243, 246, 250, 0.5));
}

.corner {
  position: absolute;
  width: 42rpx;
  height: 42rpx;
  opacity: 0.55;
}

.corner .ch,
.corner .cv {
  position: absolute;
  background: linear-gradient(90deg, rgba(0, 168, 232, 0.55), rgba(0, 168, 232, 0.08));
}

.corner .ch {
  width: 42rpx;
  height: 2rpx;
  top: 0;
  left: 0;
}

.corner .cv {
  width: 2rpx;
  height: 42rpx;
  top: 0;
  left: 0;
  background: linear-gradient(180deg, rgba(0, 168, 232, 0.55), rgba(0, 168, 232, 0.08));
}

.corner.tl {
  top: 48rpx;
  left: 40rpx;
}

.corner.tr {
  top: 48rpx;
  right: 40rpx;
  transform: scaleX(-1);
}

.corner.bl {
  bottom: 48rpx;
  left: 40rpx;
  transform: scaleY(-1);
}

.corner.br {
  bottom: 48rpx;
  right: 40rpx;
  transform: scale(-1);
}

.particle {
  position: absolute;
  width: 8rpx;
  height: 8rpx;
  border-radius: 50%;
  animation: particle 3.6s ease-in-out infinite;
}

.particle.cyan {
  background: rgba(0, 168, 232, 0.5);
  box-shadow: 0 0 12rpx rgba(0, 168, 232, 0.28);
}

.particle.soft {
  width: 6rpx;
  height: 6rpx;
  background: rgba(125, 211, 252, 0.7);
  box-shadow: 0 0 10rpx rgba(125, 211, 252, 0.35);
}

.stage {
  position: relative;
  z-index: 1;
  width: 100%;
  padding: 0 56rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.mark-row {
  display: flex;
  align-items: center;
  gap: 14rpx;
  margin-bottom: 28rpx;
  opacity: 0;
  transform: translateY(10rpx);
  transition: opacity 0.55s ease, transform 0.55s cubic-bezier(0.22, 1, 0.36, 1);
}

.mark-row.show {
  opacity: 1;
  transform: translateY(0);
}

.mark-line {
  width: 36rpx;
  height: 2rpx;
  border-radius: 999rpx;
  background: linear-gradient(90deg, transparent, rgba(0, 168, 232, 0.45), transparent);
}

.mark-text {
  font-size: 18rpx;
  font-weight: 700;
  letter-spacing: 0.28em;
  color: #7aa8c4;
}

.orb-wrap {
  position: relative;
  width: 300rpx;
  height: 300rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transform: scale(0.7);
  transition: opacity 0.6s ease, transform 0.75s cubic-bezier(0.22, 1, 0.36, 1);
}

.orb-wrap.show {
  opacity: 1;
  transform: scale(1);
}

.splash.ready .halo {
  animation: pulse-halo 1.4s ease-in-out infinite;
}

.splash.ready .orb {
  box-shadow:
    0 24rpx 48rpx rgba(15, 35, 55, 0.1),
    0 0 36rpx rgba(0, 168, 232, 0.2),
    inset 0 1rpx 0 rgba(255, 255, 255, 0.95),
    inset 0 -8rpx 24rpx rgba(0, 140, 200, 0.06);
}

.halo {
  position: absolute;
  width: 240rpx;
  height: 240rpx;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(0, 168, 232, 0.16), transparent 68%);
  animation: pulse-halo 2.8s ease-in-out infinite;
}

.halo.soft {
  width: 300rpx;
  height: 300rpx;
  background: radial-gradient(circle, rgba(125, 211, 252, 0.12), transparent 70%);
  animation: pulse-halo 3.4s ease-in-out infinite reverse;
}

.ring {
  position: absolute;
  border-radius: 50%;
  border: 2rpx solid rgba(0, 168, 232, 0.14);
  box-sizing: border-box;
}

.ring.r1 {
  width: 248rpx;
  height: 248rpx;
  border-top-color: rgba(0, 168, 232, 0.65);
  border-right-color: rgba(0, 168, 232, 0.12);
  animation: spin 9s linear infinite;
}

.ring.r2 {
  width: 292rpx;
  height: 292rpx;
  border-style: dashed;
  border-color: rgba(0, 168, 232, 0.16);
  animation: spin-rev 16s linear infinite;
}

.ring.r3 {
  width: 220rpx;
  height: 220rpx;
  border-color: rgba(43, 184, 239, 0.2);
  animation: spin 14s linear infinite reverse;
}

.tick {
  position: absolute;
  width: 10rpx;
  height: 2rpx;
  border-radius: 999rpx;
  background: rgba(0, 168, 232, 0.45);
  box-shadow: 0 0 8rpx rgba(0, 168, 232, 0.2);
}

.tick.t1 { top: 8rpx; left: 50%; margin-left: -5rpx; }
.tick.t2 { bottom: 8rpx; left: 50%; margin-left: -5rpx; }
.tick.t3 { left: 8rpx; top: 50%; margin-top: -1rpx; transform: rotate(90deg); }
.tick.t4 { right: 8rpx; top: 50%; margin-top: -1rpx; transform: rotate(90deg); }

.orbit {
  position: absolute;
  width: 292rpx;
  height: 292rpx;
  animation: spin 7.5s linear infinite;
}

.orbit.slow {
  width: 248rpx;
  height: 248rpx;
  animation: spin-rev 11s linear infinite;
}

.orbit-dot {
  position: absolute;
  top: 0;
  left: 50%;
  width: 14rpx;
  height: 14rpx;
  margin-left: -7rpx;
  border-radius: 50%;
  background: #00a8e8;
  box-shadow: 0 0 16rpx rgba(0, 168, 232, 0.55), 0 0 28rpx rgba(43, 184, 239, 0.28);
}

.orbit-dot.mini {
  width: 8rpx;
  height: 8rpx;
  margin-left: -4rpx;
  background: #7dd3fc;
  box-shadow: 0 0 10rpx rgba(125, 211, 252, 0.55);
}

.spark {
  position: absolute;
  width: 12rpx;
  height: 12rpx;
  border-radius: 50%;
  background: #2bb8ef;
  box-shadow: 0 0 14rpx rgba(0, 168, 232, 0.45);
}

.spark.s1 {
  top: 28rpx;
  right: 58rpx;
  animation: pulse 1.8s ease-in-out infinite;
}

.spark.s2 {
  bottom: 42rpx;
  left: 46rpx;
  width: 8rpx;
  height: 8rpx;
  animation: pulse 2.2s ease-in-out infinite 0.35s;
}

.spark.s3 {
  top: 58rpx;
  left: 36rpx;
  width: 6rpx;
  height: 6rpx;
  background: #bae6fd;
  animation: pulse 2.6s ease-in-out infinite 0.7s;
}

.orb {
  position: relative;
  width: 196rpx;
  height: 196rpx;
  border-radius: 50%;
  background: linear-gradient(155deg, rgba(255, 255, 255, 0.96), rgba(234, 247, 253, 0.9) 48%, rgba(223, 242, 251, 0.88));
  border: 2rpx solid rgba(255, 255, 255, 0.98);
  box-shadow:
    0 24rpx 48rpx rgba(15, 35, 55, 0.1),
    0 10rpx 24rpx rgba(0, 168, 232, 0.1),
    inset 0 1rpx 0 rgba(255, 255, 255, 0.95);
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  backdrop-filter: blur(14px);
}

.orb-sheen {
  position: absolute;
  inset: 0;
  background: linear-gradient(125deg, rgba(255, 255, 255, 0.7), transparent 42%);
  pointer-events: none;
}

.orb-rim {
  position: absolute;
  inset: 8rpx;
  border-radius: 50%;
  border: 1rpx solid rgba(0, 168, 232, 0.12);
  pointer-events: none;
}

.orb-glow {
  position: absolute;
  width: 140rpx;
  height: 140rpx;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(0, 168, 232, 0.14), transparent 70%);
  top: -18rpx;
  left: 22rpx;
  pointer-events: none;
}

.mascot {
  width: 136rpx;
  height: 136rpx;
  position: relative;
  z-index: 1;
  animation: bob 2.8s ease-in-out infinite;
}

.brand {
  margin-top: 44rpx;
  text-align: center;
  opacity: 0;
  transform: translateY(24rpx);
  transition: opacity 0.45s ease, transform 0.5s cubic-bezier(0.22, 1, 0.36, 1);
}

.brand.show {
  opacity: 1;
  transform: translateY(0);
}

.kicker {
  display: inline-flex;
  align-items: center;
  gap: 10rpx;
  margin-bottom: 18rpx;
  padding: 8rpx 14rpx 8rpx 18rpx;
  border-radius: 999rpx;
  background: rgba(255, 255, 255, 0.88);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  box-shadow:
    0 10rpx 22rpx rgba(15, 35, 55, 0.05),
    inset 0 0 0 1rpx rgba(0, 168, 232, 0.06);
  opacity: 0;
  transform: translateY(16rpx) scale(0.92);
  transition: opacity 0.45s ease, transform 0.5s cubic-bezier(0.22, 1, 0.36, 1);
}

.kicker.in {
  opacity: 1;
  transform: translateY(0) scale(1);
}

.kicker-dot {
  width: 10rpx;
  height: 10rpx;
  border-radius: 50%;
  background: var(--accent);
  box-shadow: 0 0 0 5rpx rgba(0, 168, 232, 0.14);
  animation: pulse 2s ease-in-out infinite;
}

.kicker-text {
  font-size: 18rpx;
  font-weight: 750;
  letter-spacing: 0.18em;
  color: #0284c7;
}

.kicker-chip {
  margin-left: 2rpx;
  padding: 4rpx 10rpx;
  border-radius: 999rpx;
  font-size: 16rpx;
  font-weight: 700;
  letter-spacing: 0.12em;
  color: #0284c7;
  background: rgba(0, 168, 232, 0.08);
  border: 1rpx solid rgba(0, 168, 232, 0.12);
}

.wordmark {
  line-height: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 2rpx;
  min-height: 88rpx;
}

.letter {
  display: inline-block;
  font-size: 76rpx;
  font-weight: 820;
  letter-spacing: 0.06em;
  opacity: 0;
  transform: translateY(28rpx) scale(0.7);
  filter: blur(8px);
  transition:
    opacity 0.48s cubic-bezier(0.22, 1, 0.36, 1),
    transform 0.55s cubic-bezier(0.22, 1, 0.36, 1),
    filter 0.45s ease;
}

.letter.in {
  opacity: 1;
  transform: translateY(0) scale(1);
  filter: blur(0);
  animation: letter-pop 0.55s cubic-bezier(0.22, 1, 0.36, 1);
}

.letter.ice {
  color: #0f1b2d;
  text-shadow: 0 8rpx 20rpx rgba(15, 35, 55, 0.08);
}

.letter.jz {
  color: #00a8e8;
  text-shadow: 0 0 20rpx rgba(0, 168, 232, 0.18);
}

.brand-rule {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12rpx;
  margin-top: 22rpx;
  opacity: 0;
  transform: scaleX(0.6);
  transition: opacity 0.4s ease, transform 0.55s cubic-bezier(0.22, 1, 0.36, 1);
}

.brand-rule.in {
  opacity: 1;
  transform: scaleX(1);
}

.rule-diamond {
  width: 8rpx;
  height: 8rpx;
  border-radius: 2rpx;
  background: rgba(0, 168, 232, 0.55);
  transform: rotate(45deg);
  box-shadow: 0 0 10rpx rgba(0, 168, 232, 0.25);
}

.brand-line {
  width: 120rpx;
  height: 3rpx;
  border-radius: 999rpx;
  background: linear-gradient(90deg, transparent, rgba(0, 168, 232, 0.55), transparent);
}

.slogan {
  display: block;
  margin-top: 18rpx;
  font-size: 26rpx;
  color: #3d4b5c;
  font-weight: 650;
  letter-spacing: 0.06em;
  opacity: 0;
  transform: translateY(18rpx);
  transition: opacity 0.5s ease 0.05s, transform 0.55s cubic-bezier(0.22, 1, 0.36, 1) 0.05s;
}

.slogan.in {
  opacity: 1;
  transform: translateY(0);
}

.hint {
  display: block;
  margin-top: 10rpx;
  font-size: 22rpx;
  color: #8492a6;
  letter-spacing: 0.04em;
  opacity: 0;
  transform: translateY(14rpx);
  transition: opacity 0.5s ease 0.08s, transform 0.55s cubic-bezier(0.22, 1, 0.36, 1) 0.08s;
}

.hint.in {
  opacity: 1;
  transform: translateY(0);
}

.loader {
  width: 100%;
  max-width: 420rpx;
  margin-top: 56rpx;
  opacity: 0;
  transform: translateY(18rpx);
  transition: opacity 0.5s ease, transform 0.5s ease;
}

.loader.show {
  opacity: 1;
  transform: translateY(0);
}

.loader.ready .track {
  border-color: rgba(0, 168, 232, 0.28);
  box-shadow: 0 0 16rpx rgba(0, 168, 232, 0.1);
}

.loader.ready .fill {
  box-shadow: 0 0 18rpx rgba(0, 168, 232, 0.28);
}

.loader.ready .loading-text,
.loader.ready .loading-pct {
  color: #0284c7;
}

.loader.ready .status-dot {
  background: #00a8e8;
  box-shadow: 0 0 0 5rpx rgba(0, 168, 232, 0.14);
  animation: pulse 1.2s ease-in-out infinite;
}

.track {
  height: 10rpx;
  border-radius: 999rpx;
  background: rgba(232, 238, 245, 0.95);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  overflow: hidden;
  box-shadow: inset 0 1rpx 2rpx rgba(15, 35, 55, 0.04);
  transition: border-color 0.35s ease, box-shadow 0.35s ease;
}

.fill {
  position: relative;
  height: 100%;
  width: 0;
  border-radius: 999rpx;
  background: linear-gradient(90deg, #00a8e8, #2bb8ef 55%, #7dd3fc);
  box-shadow: 0 0 14rpx rgba(0, 168, 232, 0.28);
  transition: width 0.08s linear, box-shadow 0.35s ease;
  overflow: hidden;
}

.fill-shine {
  position: absolute;
  inset: 0;
  background: linear-gradient(110deg, transparent 30%, rgba(255, 255, 255, 0.65) 50%, transparent 70%);
  animation: shine 1.4s ease-in-out infinite;
}

.fill-tip {
  position: absolute;
  top: -4rpx;
  right: -2rpx;
  width: 18rpx;
  height: 18rpx;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.85);
  box-shadow: 0 0 12rpx rgba(0, 168, 232, 0.45);
}

.loader-meta {
  margin-top: 16rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16rpx;
}

.status {
  display: flex;
  align-items: center;
  gap: 10rpx;
  min-width: 0;
}

.status-dot {
  width: 8rpx;
  height: 8rpx;
  border-radius: 50%;
  background: #94a3b8;
  flex-shrink: 0;
  transition: background 0.3s ease, box-shadow 0.3s ease;
}

.loading-text {
  font-size: 20rpx;
  color: #8492a6;
  letter-spacing: 0.14em;
}

.loading-pct {
  font-size: 20rpx;
  font-weight: 700;
  color: #0f1b2d;
  letter-spacing: 0.04em;
  min-width: 64rpx;
  text-align: right;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

@keyframes spin-rev {
  to {
    transform: rotate(-360deg);
  }
}

@keyframes bob {
  0%,
  100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-10rpx);
  }
}

@keyframes pulse {
  0%,
  100% {
    opacity: 0.45;
    transform: scale(0.85);
  }
  50% {
    opacity: 1;
    transform: scale(1.15);
  }
}

@keyframes pulse-halo {
  0%,
  100% {
    transform: scale(0.92);
    opacity: 0.55;
  }
  50% {
    transform: scale(1.08);
    opacity: 0.95;
  }
}

@keyframes float-a {
  0%,
  100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(26rpx);
  }
}

@keyframes float-b {
  0%,
  100% {
    transform: translateY(0) translateX(0);
  }
  50% {
    transform: translateY(-20rpx) translateX(14rpx);
  }
}

@keyframes beam {
  0%,
  100% {
    opacity: 0.12;
  }
  50% {
    opacity: 0.36;
  }
}

@keyframes particle {
  0%,
  100% {
    opacity: 0.25;
    transform: translateY(0);
  }
  50% {
    opacity: 0.95;
    transform: translateY(-14rpx);
  }
}

@keyframes shine {
  0% {
    transform: translateX(-120%);
  }
  100% {
    transform: translateX(120%);
  }
}

@keyframes letter-pop {
  0% {
    transform: translateY(28rpx) scale(0.7);
  }
  70% {
    transform: translateY(-4rpx) scale(1.06);
  }
  100% {
    transform: translateY(0) scale(1);
  }
}

@keyframes ready-breathe {
  0%,
  100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.025);
  }
}

@keyframes aurora-drift {
  0%,
  100% {
    transform: translateX(-12rpx) scaleX(0.96);
    opacity: 0.35;
  }
  50% {
    transform: translateX(16rpx) scaleX(1.06);
    opacity: 0.7;
  }
}
</style>
