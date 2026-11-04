<template>
  <view class="nav-root">
    <view class="nav" :class="[tone]" :style="{ paddingTop: statusBarPx + 'px' }">
      <view class="nav-inner">
        <view v-if="showBack" class="back" @click="onBack">
          <view class="back-ico" />
        </view>
        <view v-else class="back placeholder" />
        <view class="center">
          <text class="title">{{ title }}</text>
          <text v-if="sub" class="sub">{{ sub }}</text>
        </view>
        <view class="right">
          <slot name="right" />
        </view>
      </view>
    </view>
    <ice-toast-host />
    <ice-confirm-host />
  </view>
</template>

<script>
import IceToastHost from '@/components/feedback/IceToastHost.vue'
import IceConfirmHost from '@/components/feedback/IceConfirmHost.vue'

export default {
  name: 'IceNavBar',
  components: { IceToastHost, IceConfirmHost },
  props: {
    title: { type: String, default: '' },
    sub: { type: String, default: '' },
    showBack: { type: Boolean, default: true },
    tone: { type: String, default: 'light' } // light | cyan
  },
  data() {
    return { statusBarPx: 20 }
  },
  created() {
    try {
      this.statusBarPx = uni.getSystemInfoSync().statusBarHeight || 20
    } catch (e) {
      this.statusBarPx = 20
    }
  },
  methods: {
    onBack() {
      const pages = getCurrentPages()
      if (pages.length > 1) {
        uni.navigateBack()
      } else {
        uni.switchTab({ url: '/pages/index/index' })
      }
    }
  }
}
</script>

<style scoped>
.nav-root {
  position: relative;
  z-index: 20;
}

.nav {
  position: relative;
  z-index: 20;
}

.nav.light {
  background: transparent;
}

.nav.cyan {
  background: transparent;
}

.nav-inner {
  height: 88rpx;
  padding: 0 20rpx;
  display: flex;
  align-items: center;
  gap: 8rpx;
}

.back {
  width: 64rpx;
  height: 64rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.nav.light .back {
  background: rgba(255, 255, 255, 0.92);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  box-shadow: 0 10rpx 22rpx rgba(15, 35, 55, 0.06);
}

.nav.cyan .back {
  background: rgba(255, 255, 255, 0.16);
}

.back.placeholder {
  background: transparent;
  border: none;
  box-shadow: none;
}

.back-ico {
  width: 18rpx;
  height: 18rpx;
  border-left: 4rpx solid #0f1b2d;
  border-bottom: 4rpx solid #0f1b2d;
  transform: rotate(45deg);
  margin-left: 6rpx;
  box-sizing: border-box;
}

.nav.cyan .back-ico {
  border-color: #fff;
}

.center {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.title {
  font-size: 32rpx;
  font-weight: 800;
  color: #0f1b2d;
  line-height: 1.2;
}

.nav.cyan .title {
  color: #fff;
}

.sub {
  margin-top: 2rpx;
  font-size: 20rpx;
  color: #8492a6;
}

.nav.cyan .sub {
  color: rgba(255, 255, 255, 0.78);
}

.right {
  min-width: 64rpx;
  display: flex;
  align-items: center;
  justify-content: flex-end;
}
</style>
