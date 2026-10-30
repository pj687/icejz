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
      <text 
        class="tab-text"
        :style="{ color: value === index ? '#FF5F15' : '#666666' }"
      >
        {{ item.text }}
      </text>
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
        {
          icon: 'home',
          text: '首页',
          url: 'pages/index/index'
        },
        {
          icon: 'workbench',
          text: '工作台',
          url: 'pages/workbench/workbench'
        },
        {
          icon: 'user',
          text: '个人中心',
          url: 'pages/usercenter/usercenter'
        }
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
        'home': '🏠',
        'workbench': '⚙️', 
        'user': '👤'
      }
      return iconMap[icon] || '🏠'
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
  background: #ffffff;
  display: flex;
  border-top: 1px solid #e5e5e5;
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
  font-size: 40rpx;
}

.tab-item.active .icon {
  color: #FF5F15;
}

.tab-text {
  font-size: 20rpx;
  margin-top: 4rpx;
}
</style>