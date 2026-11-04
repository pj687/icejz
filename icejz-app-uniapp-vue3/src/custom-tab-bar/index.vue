<template>
  <view class="tab-root">
    <view class="dock-wrap">
      <view class="dock">
        <view
          class="dock-indicator"
          :style="{ transform: 'translateX(' + indicatorX + '%)' }"
        />
        <view
          v-for="(item, index) in list"
          :key="item.url"
          class="dock-item"
          :class="{ active: value === index }"
          @click="onChange(index)"
        >
          <image
            class="ico"
            :src="value === index ? item.activeIcon : item.icon"
            mode="aspectFit"
          />
          <text class="label">{{ item.text }}</text>
        </view>
      </view>
    </view>
    <ice-toast-host />
  </view>
</template>

<script>
import IceToastHost from '@/components/feedback/IceToastHost.vue'

export default {
  name: 'CustomTabBar',
  components: { IceToastHost },
  data() {
    return {
      value: 0
    }
  },
  computed: {
    list() {
      void this.$i18n.locale
      return [
        {
          text: this.$t('tab.home'),
          url: 'pages/index/index',
          icon: '/static/tab/home.svg',
          activeIcon: '/static/tab/home-active.svg'
        },
        {
          text: this.$t('tab.workbench'),
          url: 'pages/workbench/workbench',
          icon: '/static/tab/work.svg',
          activeIcon: '/static/tab/work-active.svg'
        },
        {
          text: this.$t('tab.mine'),
          url: 'pages/usercenter/usercenter',
          icon: '/static/tab/me.svg',
          activeIcon: '/static/tab/me-active.svg'
        }
      ]
    },
    indicatorX() {
      return this.value * 100
    }
  },
  mounted() {
    this.hideNative()
    this.init()
  },
  methods: {
    hideNative() {
      try {
        uni.hideTabBar({ animation: false })
      } catch (e) {
        // ignore
      }
    },
    onChange(index) {
      if (this.value === index) return
      this.value = index
      uni.switchTab({ url: '/' + this.list[index].url })
    },
    init() {
      this.hideNative()
      const pages = getCurrentPages()
      const currentPage = pages[pages.length - 1]
      const route = currentPage ? currentPage.route.split('?')[0] : ''
      const active = this.list.findIndex(
        (item) => (item.url.startsWith('/') ? item.url.slice(1) : item.url) === route
      )
      this.value = active >= 0 ? active : 0
    }
  }
}
</script>

<style scoped>
.tab-root {
  position: relative;
  z-index: 1000;
}

.dock-wrap {
  position: fixed;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 1000;
  padding: 16rpx 28rpx calc(10rpx + env(safe-area-inset-bottom));
  pointer-events: none;
  background: transparent;
}

.dock {
  position: relative;
  pointer-events: auto;
  height: 108rpx;
  display: flex;
  align-items: stretch;
  border-radius: 999rpx;
  background: #ffffff;
  border: 1rpx solid rgba(12, 21, 32, 0.08);
  box-shadow:
    0 14rpx 32rpx rgba(12, 21, 32, 0.12),
    0 2rpx 0 rgba(255, 255, 255, 0.85) inset;
  overflow: hidden;
}

.dock-indicator {
  position: absolute;
  top: 10rpx;
  bottom: 10rpx;
  left: 10rpx;
  width: calc((100% - 20rpx) / 3);
  border-radius: 999rpx;
  background: linear-gradient(160deg, #00a8e8 0%, #0ea5e9 100%);
  box-shadow: 0 10rpx 24rpx rgba(0, 168, 232, 0.28);
  transition: transform 0.32s cubic-bezier(0.22, 1, 0.36, 1);
  z-index: 0;
}

.dock-item {
  position: relative;
  z-index: 1;
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4rpx;
}

.ico {
  width: 40rpx;
  height: 40rpx;
  transition: transform 0.28s ease;
}

.dock-item.active .ico {
  transform: translateY(-2rpx) scale(1.05);
  filter: brightness(0) invert(1);
}

.label {
  font-size: 20rpx;
  color: #7d8b9a;
  font-weight: 600;
  transition: color 0.2s ease;
}

.dock-item.active .label {
  color: #fff;
}
</style>
