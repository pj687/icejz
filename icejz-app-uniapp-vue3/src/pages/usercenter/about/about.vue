<template>
  <view class="page ice-subpage">
    <view class="bg" aria-hidden="true">
      <view class="bg-base" />
      <view class="blob b1" />
      <view class="blob b2" />
      <view class="blob b3" />
      <view class="mesh" />
    </view>

    <ice-nav-bar :title="$t('about.title')" :sub="$t('brand.tagline')" />

    <view class="body">
      <view class="stage">
        <view class="stage-glow g1" />
        <view class="stage-glow g2" />
        <view class="stage-lines" />

        <view class="kicker">
          <view class="kicker-dot" />
          <text class="kicker-text">ICECORE</text>
          <view class="kicker-chip">ENGINE</view>
        </view>

        <view class="orb-wrap">
          <view class="halo" />
          <view class="ring r1" />
          <view class="ring r2" />
          <view class="orbit">
            <view class="orbit-dot" />
          </view>
          <view class="logo-wrap">
            <image class="brand-logo" src="/static/logo.png" mode="aspectFill" />
            <view class="logo-pulse" />
            <view class="logo-shine" />
          </view>
        </view>

        <view class="wordmark">
          <text class="wm-ice">ICE</text><text class="wm-jz">JZ</text>
        </view>
        <text class="slogan">{{ $t('brand.slogan') }}</text>
        <text class="tagline">{{ $t('brand.tagline') }}</text>

        <view class="pill-row">
          <text v-for="(pill, i) in pills" :key="i" class="pill">{{ pill }}</text>
        </view>
      </view>

      <view class="section">
        <view class="section-head">
          <view class="section-mark" />
          <view class="section-copy">
            <text class="section-title">{{ $t('about.intro') }}</text>
            <text class="section-sub">{{ $t('about.introSub') }}</text>
          </view>
        </view>
        <view class="intro-panel">
          <view class="intro-glow" />
          <view class="intro-accent" />
          <text class="intro-text">{{ $t('brand.aboutIntro') }}</text>
        </view>
      </view>

      <view class="section">
        <view class="section-head">
          <view class="section-mark" />
          <view class="section-copy">
            <text class="section-title">{{ $t('about.features') }}</text>
            <text class="section-sub">{{ $t('about.featuresSub') }}</text>
          </view>
        </view>
        <view class="feature-grid">
          <view
            v-for="(item, index) in featureList"
            :key="item.title"
            class="feature"
            :style="{ animationDelay: index * 70 + 'ms' }"
          >
            <view class="feature-ico" :class="'tone-' + (index % 4)">
              <image class="feature-img" :src="item.icon" mode="aspectFit" />
            </view>
            <view class="feature-top">
              <text class="feature-index">0{{ index + 1 }}</text>
              <view class="feature-mark" :class="'tone-' + (index % 4)" />
            </view>
            <text class="feature-title">{{ item.title }}</text>
            <text class="feature-desc">{{ item.desc }}</text>
          </view>
        </view>
      </view>

      <view class="meta">
        <view class="meta-glow" />
        <view class="meta-head">
          <view class="meta-badge">
            <view class="meta-live" />
            <text class="meta-ver">{{ version }}</text>
          </view>
          <text class="meta-head-sub">{{ $t('about.version') }}</text>
        </view>
        <view class="meta-rows">
          <view class="meta-row">
            <view class="meta-ico tone-cyan">
              <image class="meta-img" src="/static/icons/about.svg" mode="aspectFit" />
            </view>
            <text class="meta-label">{{ $t('about.version') }}</text>
            <text class="meta-value">{{ version }}</text>
          </view>
          <view class="meta-row">
            <view class="meta-ico tone-deep">
              <image class="meta-img" src="/static/icons/settings.svg" mode="aspectFit" />
            </view>
            <text class="meta-label">{{ $t('about.tech') }}</text>
            <text class="meta-value">{{ $t('brand.poweredBy') }}</text>
          </view>
          <view class="meta-row last">
            <view class="meta-ico tone-slate">
              <image class="meta-img" src="/static/icons/profile.svg" mode="aspectFit" />
            </view>
            <text class="meta-label">{{ $t('about.copyright') }}</text>
            <text class="meta-value">{{ $t('brand.footer') }}</text>
          </view>
        </view>
      </view>

      <text class="foot-note">{{ $t('about.thanks') }}</text>
    </view>
  </view>
</template>

<script>
import IceNavBar from '@/components/layout/IceNavBar.vue'
import brand from '@/config/brand.js'

const FEATURE_ICONS = [
  '/static/icons/lock.svg',
  '/static/icons/settings.svg',
  '/static/icons/org.svg',
  '/static/icons/about.svg'
]

export default {
  name: 'About',
  components: { IceNavBar },
  data() {
    return {
      version: brand.version || 'v1.0.3'
    }
  },
  computed: {
    pills() {
      void this.$i18n.locale
      return String(this.$t('brand.homeLine'))
        .split(/[·•]/)
        .map((s) => s.trim())
        .filter(Boolean)
    },
    featureList() {
      void this.$i18n.locale
      return [1, 2, 3, 4].map((n, index) => ({
        title: this.$t(`brand.feature${n}Title`),
        desc: this.$t(`brand.feature${n}Desc`),
        icon: FEATURE_ICONS[index]
      }))
    }
  }
}
</script>

<style scoped>
.page {
  position: relative;
  min-height: 100vh;
  background: #f3f6fa;
  box-sizing: border-box;
  overflow: hidden;
}

.bg {
  position: absolute;
  inset: 0;
  overflow: hidden;
  pointer-events: none;
  z-index: 0;
}

.bg-base {
  position: absolute;
  inset: 0;
  background:
    radial-gradient(ellipse 90% 50% at 50% -8%, rgba(0, 168, 232, 0.14), transparent 58%),
    linear-gradient(180deg, #eef6fb 0%, #f3f6fa 42%, #f7f9fc 100%);
}

.blob {
  position: absolute;
  border-radius: 50%;
  filter: blur(2rpx);
}

.b1 {
  width: 520rpx;
  height: 520rpx;
  top: -160rpx;
  right: -140rpx;
  background: radial-gradient(circle, rgba(0, 168, 232, 0.18), transparent 68%);
  animation: drift 9s ease-in-out infinite;
}

.b2 {
  width: 360rpx;
  height: 360rpx;
  top: 420rpx;
  left: -160rpx;
  background: radial-gradient(circle, rgba(56, 189, 248, 0.14), transparent 70%);
  animation: drift 11s ease-in-out infinite reverse;
}

.b3 {
  width: 280rpx;
  height: 280rpx;
  bottom: 120rpx;
  right: -80rpx;
  background: radial-gradient(circle, rgba(8, 121, 168, 0.1), transparent 72%);
}

.mesh {
  position: absolute;
  inset: 0;
  opacity: 0.28;
  background-image:
    linear-gradient(rgba(15, 35, 55, 0.03) 1rpx, transparent 1rpx),
    linear-gradient(90deg, rgba(15, 35, 55, 0.03) 1rpx, transparent 1rpx);
  background-size: 48rpx 48rpx;
  mask-image: linear-gradient(180deg, rgba(0, 0, 0, 0.4), transparent 72%);
}

.body {
  position: relative;
  z-index: 1;
  padding: 4rpx 28rpx 64rpx;
}

.stage {
  position: relative;
  overflow: hidden;
  margin-top: 8rpx;
  padding: 36rpx 28rpx 34rpx;
  border-radius: 36rpx;
  background:
    linear-gradient(160deg, rgba(232, 247, 253, 0.96) 0%, rgba(255, 255, 255, 0.98) 42%, #ffffff 100%);
  border: 1rpx solid rgba(220, 234, 244, 0.95);
  box-shadow:
    0 18rpx 44rpx rgba(15, 35, 55, 0.06),
    0 2rpx 0 rgba(255, 255, 255, 0.95) inset;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}

.stage-glow {
  position: absolute;
  border-radius: 50%;
  pointer-events: none;
}

.g1 {
  width: 280rpx;
  height: 280rpx;
  top: -80rpx;
  left: -60rpx;
  background: radial-gradient(circle, rgba(0, 168, 232, 0.16), transparent 70%);
}

.g2 {
  width: 240rpx;
  height: 240rpx;
  right: -40rpx;
  bottom: -80rpx;
  background: radial-gradient(circle, rgba(56, 189, 248, 0.14), transparent 70%);
}

.stage-lines {
  position: absolute;
  inset: 0;
  pointer-events: none;
  opacity: 0.4;
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.55), transparent 40%),
    linear-gradient(180deg, transparent, rgba(232, 244, 250, 0.28));
}

.kicker {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: center;
  gap: 10rpx;
  padding: 8rpx 16rpx;
  border-radius: 999rpx;
  background: rgba(255, 255, 255, 0.82);
  border: 1rpx solid rgba(186, 230, 253, 0.9);
  box-shadow: 0 8rpx 18rpx rgba(0, 140, 200, 0.08);
}

.kicker-dot {
  width: 10rpx;
  height: 10rpx;
  border-radius: 50%;
  background: #00a8e8;
  box-shadow: 0 0 0 6rpx rgba(0, 168, 232, 0.14);
  animation: blink 2.2s ease-in-out infinite;
}

.kicker-text {
  font-size: 20rpx;
  font-weight: 800;
  letter-spacing: 0.14em;
  color: #0879a8;
}

.kicker-chip {
  padding: 2rpx 10rpx;
  border-radius: 999rpx;
  font-size: 18rpx;
  font-weight: 700;
  letter-spacing: 0.08em;
  color: #fff;
  background: linear-gradient(135deg, #00a8e8, #0879a8);
}

.orb-wrap {
  position: relative;
  width: 220rpx;
  height: 220rpx;
  margin-top: 28rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.halo {
  position: absolute;
  inset: 18rpx;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(0, 168, 232, 0.22), transparent 68%);
  animation: pulse 3s ease-in-out infinite;
}

.ring {
  position: absolute;
  border-radius: 50%;
  border: 1rpx solid rgba(0, 168, 232, 0.18);
  pointer-events: none;
}

.r1 {
  inset: 8rpx;
}

.r2 {
  inset: -6rpx;
  border-style: dashed;
  border-color: rgba(0, 168, 232, 0.22);
  animation: spin 18s linear infinite;
}

.orbit {
  position: absolute;
  inset: -6rpx;
  animation: spin 10s linear infinite;
}

.orbit-dot {
  position: absolute;
  top: 10rpx;
  left: 50%;
  width: 12rpx;
  height: 12rpx;
  margin-left: -6rpx;
  border-radius: 50%;
  background: #00a8e8;
  box-shadow: 0 0 16rpx rgba(0, 168, 232, 0.55);
}

.logo-wrap {
  position: relative;
  z-index: 1;
  width: 132rpx;
  height: 132rpx;
  border-radius: 40rpx;
  padding: 8rpx;
  background: linear-gradient(145deg, #ffffff, #e8f7fd 55%, #d5eef9);
  box-shadow:
    0 16rpx 36rpx rgba(0, 140, 200, 0.18),
    inset 0 1rpx 0 rgba(255, 255, 255, 0.95);
  box-sizing: border-box;
}

.brand-logo {
  width: 100%;
  height: 100%;
  border-radius: 32rpx;
  display: block;
  background: #eaf7fd;
}

.logo-pulse {
  position: absolute;
  inset: -12rpx;
  border-radius: 48rpx;
  border: 2rpx solid rgba(0, 168, 232, 0.28);
  animation: pulse 2.8s ease-in-out infinite;
  pointer-events: none;
}

.logo-shine {
  position: absolute;
  inset: 8rpx;
  border-radius: 32rpx;
  overflow: hidden;
  pointer-events: none;
}

.logo-shine::before {
  content: '';
  position: absolute;
  top: -40%;
  left: -30%;
  width: 56%;
  height: 180%;
  background: linear-gradient(110deg, transparent, rgba(255, 255, 255, 0.45), transparent);
  transform: rotate(18deg);
  animation: shine 3.6s ease-in-out infinite;
}

.wordmark {
  position: relative;
  z-index: 1;
  margin-top: 18rpx;
  line-height: 1;
}

.wm-ice,
.wm-jz {
  font-size: 64rpx;
  font-weight: 800;
  letter-spacing: 0.04em;
}

.wm-ice {
  color: #3d4b5c;
}

.wm-jz {
  color: #2bb8ef;
}

.slogan {
  position: relative;
  z-index: 1;
  margin-top: 16rpx;
  font-size: 26rpx;
  font-weight: 650;
  color: #3d4b5c;
}

.tagline {
  position: relative;
  z-index: 1;
  margin-top: 8rpx;
  font-size: 22rpx;
  color: #8492a6;
}

.pill-row {
  position: relative;
  z-index: 1;
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 12rpx;
  margin-top: 28rpx;
}

.pill {
  padding: 10rpx 18rpx;
  border-radius: 999rpx;
  font-size: 20rpx;
  font-weight: 650;
  color: #0879a8;
  background: rgba(255, 255, 255, 0.86);
  border: 1rpx solid rgba(186, 230, 253, 0.9);
  box-shadow: 0 6rpx 14rpx rgba(0, 140, 200, 0.06);
}

.section {
  margin-top: 34rpx;
}

.section-head {
  display: flex;
  align-items: flex-start;
  gap: 14rpx;
  padding: 0 4rpx 16rpx;
}

.section-mark {
  width: 8rpx;
  height: 36rpx;
  margin-top: 6rpx;
  border-radius: 999rpx;
  background: linear-gradient(180deg, #3ec6ff 0%, #00a8e8 55%, #0879a8 100%);
  box-shadow: 0 8rpx 16rpx rgba(0, 168, 232, 0.28);
  flex-shrink: 0;
}

.section-copy {
  min-width: 0;
  flex: 1;
}

.section-title {
  display: block;
  font-size: 32rpx;
  font-weight: 800;
  color: #0f1b2d;
  letter-spacing: 0.02em;
}

.section-sub {
  display: block;
  margin-top: 6rpx;
  font-size: 22rpx;
  color: #8492a6;
}

.intro-panel {
  position: relative;
  overflow: hidden;
  padding: 28rpx 26rpx 28rpx 32rpx;
  border-radius: 30rpx;
  background:
    linear-gradient(165deg, rgba(255, 255, 255, 0.98) 0%, rgba(246, 251, 254, 0.96) 100%);
  border: 1rpx solid rgba(220, 234, 244, 0.95);
  box-shadow:
    0 14rpx 36rpx rgba(15, 35, 55, 0.05),
    0 2rpx 0 rgba(255, 255, 255, 0.95) inset;
}

.intro-glow {
  position: absolute;
  top: -60rpx;
  right: -40rpx;
  width: 180rpx;
  height: 180rpx;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(0, 168, 232, 0.1), transparent 70%);
  pointer-events: none;
}

.intro-accent {
  position: absolute;
  left: 0;
  top: 22rpx;
  bottom: 22rpx;
  width: 6rpx;
  border-radius: 999rpx;
  background: linear-gradient(180deg, #00a8e8, #38bdf8);
}

.intro-text {
  position: relative;
  z-index: 1;
  display: block;
  font-size: 25rpx;
  line-height: 1.75;
  color: #3d4b5c;
}

.feature-grid {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  width: 100%;
  box-sizing: border-box;
}

.feature {
  position: relative;
  /* 避免 CSS grid / calc(% - rpx) 在部分机型失效导致贴左缩窄 */
  flex: 0 0 48.5%;
  width: 48.5%;
  max-width: 48.5%;
  box-sizing: border-box;
  margin-bottom: 16rpx;
  padding: 22rpx 20rpx 24rpx;
  border-radius: 28rpx;
  background:
    linear-gradient(165deg, rgba(255, 255, 255, 0.98) 0%, rgba(246, 251, 254, 0.96) 100%);
  border: 1rpx solid rgba(220, 234, 244, 0.95);
  box-shadow:
    0 12rpx 30rpx rgba(15, 35, 55, 0.045),
    0 2rpx 0 rgba(255, 255, 255, 0.95) inset;
  animation: rise 0.55s ease both;
}

.feature-ico {
  width: 64rpx;
  height: 64rpx;
  border-radius: 20rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 16rpx;
  box-shadow:
    0 8rpx 16rpx rgba(0, 140, 200, 0.08),
    inset 0 1rpx 0 rgba(255, 255, 255, 0.9);
}

.feature-ico.tone-0 {
  background: linear-gradient(145deg, #e8f8fe, #d5f0fb 55%, #c5e9f7);
}

.feature-ico.tone-1 {
  background: linear-gradient(145deg, #e6f4fb, #cfe6f4 55%, #b9dceb);
}

.feature-ico.tone-2 {
  background: linear-gradient(145deg, #eef8ff, #dceffc 55%, #cfe7f8);
}

.feature-ico.tone-3 {
  background: linear-gradient(145deg, #f2f6fa, #e6edf4 55%, #dbe5ef);
}

.feature-img {
  width: 30rpx;
  height: 30rpx;
}

.feature-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12rpx;
}

.feature-index {
  font-size: 22rpx;
  font-weight: 800;
  letter-spacing: 0.06em;
  color: #00a8e8;
}

.feature-mark {
  width: 16rpx;
  height: 16rpx;
  border-radius: 7rpx;
  transform: rotate(18deg);
}

.feature-mark.tone-0 {
  background: linear-gradient(135deg, #00a8e8, #38bdf8);
}

.feature-mark.tone-1 {
  background: linear-gradient(135deg, #0879a8, #00a8e8);
}

.feature-mark.tone-2 {
  background: linear-gradient(135deg, #38bdf8, #7dd3fc);
}

.feature-mark.tone-3 {
  background: linear-gradient(135deg, #0ea5c9, #67e8f9);
}

.feature-title {
  display: block;
  font-size: 28rpx;
  font-weight: 750;
  color: #0f1b2d;
  word-break: break-word;
}

.feature-desc {
  display: block;
  margin-top: 10rpx;
  font-size: 22rpx;
  line-height: 1.55;
  color: #8492a6;
  word-break: break-word;
}

.meta {
  position: relative;
  overflow: hidden;
  margin-top: 28rpx;
  padding: 20rpx 16rpx 12rpx;
  border-radius: 30rpx;
  background:
    linear-gradient(165deg, rgba(255, 255, 255, 0.98) 0%, rgba(246, 251, 254, 0.96) 100%);
  border: 1rpx solid rgba(220, 234, 244, 0.95);
  box-shadow:
    0 14rpx 36rpx rgba(15, 35, 55, 0.05),
    0 2rpx 0 rgba(255, 255, 255, 0.95) inset;
}

.meta-glow {
  position: absolute;
  top: -70rpx;
  right: -40rpx;
  width: 180rpx;
  height: 180rpx;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(0, 168, 232, 0.12), transparent 70%);
  pointer-events: none;
}

.meta-head {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16rpx;
  padding: 4rpx 8rpx 12rpx;
}

.meta-badge {
  display: inline-flex;
  align-items: center;
  gap: 10rpx;
  padding: 8rpx 16rpx;
  border-radius: 999rpx;
  background: rgba(0, 168, 232, 0.08);
  border: 1rpx solid rgba(0, 168, 232, 0.14);
}

.meta-live {
  width: 12rpx;
  height: 12rpx;
  border-radius: 50%;
  background: #22c55e;
  box-shadow: 0 0 0 6rpx rgba(34, 197, 94, 0.16);
  animation: blink 2s ease-in-out infinite;
}

.meta-ver {
  font-size: 22rpx;
  font-weight: 800;
  letter-spacing: 0.04em;
  color: #0879a8;
}

.meta-head-sub {
  font-size: 20rpx;
  color: #9aa8b6;
  font-weight: 600;
}

.meta-rows {
  position: relative;
  z-index: 1;
}

.meta-row {
  display: flex;
  align-items: center;
  gap: 14rpx;
  padding: 16rpx 10rpx;
  border-radius: 20rpx;
  margin-bottom: 4rpx;
}

.meta-row.last {
  margin-bottom: 0;
}

.meta-ico {
  width: 56rpx;
  height: 56rpx;
  border-radius: 18rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  box-shadow: inset 0 1rpx 0 rgba(255, 255, 255, 0.9);
}

.meta-ico.tone-cyan {
  background: linear-gradient(145deg, #e8f8fe, #d5f0fb 55%, #c5e9f7);
}

.meta-ico.tone-deep {
  background: linear-gradient(145deg, #e6f4fb, #cfe6f4 55%, #b9dceb);
}

.meta-ico.tone-slate {
  background: linear-gradient(145deg, #f2f6fa, #e6edf4 55%, #dbe5ef);
}

.meta-img {
  width: 26rpx;
  height: 26rpx;
}

.meta-label {
  flex-shrink: 0;
  font-size: 24rpx;
  color: #8492a6;
}

.meta-value {
  flex: 1;
  min-width: 0;
  font-size: 24rpx;
  font-weight: 680;
  color: #0f1b2d;
  text-align: right;
}

.foot-note {
  display: block;
  margin-top: 28rpx;
  text-align: center;
  font-size: 22rpx;
  color: #9aa8b6;
  letter-spacing: 0.04em;
}

@keyframes pulse {
  0%,
  100% {
    opacity: 0.45;
    transform: scale(0.96);
  }
  50% {
    opacity: 1;
    transform: scale(1.04);
  }
}

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

@keyframes blink {
  0%,
  100% {
    opacity: 0.55;
  }
  50% {
    opacity: 1;
  }
}

@keyframes drift {
  0%,
  100% {
    transform: translate3d(0, 0, 0);
  }
  50% {
    transform: translate3d(18rpx, -14rpx, 0);
  }
}

@keyframes rise {
  from {
    opacity: 0;
    transform: translateY(16rpx);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes shine {
  0%,
  55% {
    transform: translateX(0) rotate(18deg);
    opacity: 0;
  }
  70% {
    opacity: 0.85;
  }
  100% {
    transform: translateX(260%) rotate(18deg);
    opacity: 0;
  }
}
</style>
