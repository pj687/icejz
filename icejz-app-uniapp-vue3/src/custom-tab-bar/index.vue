<template>
  <view class="custom-tab-bar">
    <view
      v-for="(item, index) in list"
      :key="index"
      class="tab-item"
      :class="{ active: value === index }"
      @click="onChange(index)"
    >
      <view class="tab-icon">
        <text class="icon">{{ getIcon(item.icon) }}</text>
      </view>
      <text class="tab-text">{{ item.text }}</text>
    </view>
  </view>
</template>

<script>
export default {
  name: 'CustomTabBar',
  data() {
    return {
      value: 0,
      list: [
        { icon: 'home', text: '首页', url: 'pages/index/index' },
        { icon: 'workbench', text: '服务', url: 'pages/workbench/workbench' },
        { icon: 'activity', text: '活动', url: 'pages/activity/activity' },
        { icon: 'user', text: '我的', url: 'pages/usercenter/usercenter' }
      ]
    }
  },
  mounted() {
    this.init()
  },
  methods: {
    onChange(index) {
      this.value = index
      uni.switchTab({
        url: '/' + this.list[index].url
      })
    },
    init() {
      const pages = getCurrentPages()
      const currentPage = pages[pages.length - 1]
      const route = currentPage ? currentPage.route.split('?')[0] : ''
      const active = this.list.findIndex(
        (item) => (item.url.startsWith('/') ? item.url.substr(1) : item.url) === route
      )
      this.value = active >= 0 ? active : 0
    },
    getIcon(icon) {
      const iconMap = {
        home: '⌂',
        workbench: '▦',
        activity: '◎',
        user: '☺'
      }
      return iconMap[icon] || '⌂'
    }
  }
}
</script>

<style scoped>
.custom-tab-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  height: 100rpx;
  background: rgba(255, 255, 255, 0.96);
  display: flex;
  border-top: 1rpx solid rgba(232, 238, 245, 0.95);
  box-shadow: 0 -8rpx 28rpx rgba(15, 23, 36, 0.06);
  z-index: 1000;
  padding-bottom: env(safe-area-inset-bottom);
}

.tab-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 10rpx 0;
}

.tab-icon {
  margin-bottom: 4rpx;
}

.icon {
  font-size: 34rpx;
  color: #9ca3af;
}

.tab-item.active .icon,
.tab-item.active .tab-text {
  color: #00a8e8;
}

.tab-text {
  font-size: 20rpx;
  margin-top: 4rpx;
  color: #9ca3af;
  font-weight: 500;
}
</style>
