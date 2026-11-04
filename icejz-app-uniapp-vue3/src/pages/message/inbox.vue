<template>
  <view class="page ice-subpage">
    <ice-nav-bar :title="$t('message.title')" :sub="$t('message.sub')">
      <template #right>
        <view class="stat-chip">
          <text class="stat-num">{{ unreadCount }}</text>
        </view>
      </template>
    </ice-nav-bar>

    <view class="body ice-soft-body">
    <view class="panel">
      <view class="panel-head">
        <text class="panel-title">{{ $t('message.list') }}</text>
        <text class="panel-action" @click="onReadAll">{{ $t('message.readAll') }}</text>
      </view>

      <view v-if="loading" class="empty">
        <view class="empty-mark">···</view>
        <view class="empty-title">{{ $t('message.syncing') }}</view>
      </view>
      <view v-else-if="!list.length" class="empty">
        <view class="empty-mark">信</view>
        <view class="empty-title">{{ $t('message.empty') }}</view>
        <view class="empty-desc">{{ $t('message.emptyHint') }}</view>
      </view>

      <view
        v-for="item in list"
        :key="item.id"
        class="msg-item"
        :class="{ 'is-unread': item.readStatus === 0 }"
        @click="onOpen(item.id)"
      >
        <view v-if="item.readStatus === 0" class="msg-dot" />
        <view class="msg-body">
          <view class="msg-top">
            <view class="msg-title">{{ item.title }}</view>
            <view class="msg-time">{{ item.sendTime || item.createTime }}</view>
          </view>
          <view class="msg-meta">{{ item.senderName || $t('message.system') }}</view>
          <view class="msg-content">{{ item.content }}</view>
        </view>
      </view>
    </view>
    </view>
  </view>
</template>

<script>
import cache from '@/utils/cache.js'
import {
  useMessageMyPageApi,
  useMessageUnreadCountApi,
  useMessageMyApi,
  useMessageReadAllApi
} from '@/api/message.js'
import IceNavBar from '@/components/layout/IceNavBar.vue'

export default {
  components: { IceNavBar },
  data() {
    return {
      loading: false,
      list: [],
      unreadCount: 0
    }
  },
  onShow() {
    if (!cache.getToken()) {
      uni.reLaunch({ url: '/pages/login/login' })
      return
    }
    this.loadData()
  },
  methods: {
    async loadData() {
      this.loading = true
      try {
        const [pageRes, unreadRes] = await Promise.all([
          useMessageMyPageApi({ page: 1, limit: 50 }),
          useMessageUnreadCountApi()
        ])
        this.list = pageRes.data?.list || []
        this.unreadCount = unreadRes.data || 0
      } catch (e) {
        this.list = []
        this.unreadCount = 0
      } finally {
        this.loading = false
      }
    },
    async onOpen(id) {
      try {
        const { data } = await useMessageMyApi(id)
        uni.showModal({
          title: data?.title || this.$t('message.detail'),
          content: data?.content || this.$t('message.noContent'),
          showCancel: false
        })
        this.loadData()
      } catch (err) {
        // request 层已 toast
      }
    },
    async onReadAll() {
      try {
        await useMessageReadAllApi()
        uni.showToast({ title: this.$t('message.allReadOk'), icon: 'success' })
        this.loadData()
      } catch (e) {
        // ignore
      }
    }
  }
}
</script>

<style scoped>
.page {
  min-height: 100vh;
  box-sizing: border-box;
}

.body {
  padding: 8rpx 28rpx 48rpx;
}

.stat-chip {
  min-width: 56rpx;
  height: 56rpx;
  padding: 0 12rpx;
  border-radius: 999rpx;
  background: rgba(255, 255, 255, 0.92);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  box-shadow: 0 10rpx 22rpx rgba(15, 35, 55, 0.06);
  display: flex;
  align-items: center;
  justify-content: center;
}

.stat-num {
  font-size: 26rpx;
  font-weight: 800;
  color: #00a8e8;
}

.panel {
  margin-top: 8rpx;
  padding: 26rpx 22rpx;
  border-radius: 28rpx;
  background: rgba(255, 255, 255, 0.94);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  box-shadow: 0 14rpx 36rpx rgba(15, 35, 55, 0.05);
}

.panel-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8rpx;
}

.panel-title {
  font-size: 30rpx;
  font-weight: 700;
  color: #0c1520;
}

.panel-action {
  font-size: 24rpx;
  color: #00a8e8;
  font-weight: 600;
}

.empty {
  padding: 64rpx 24rpx;
  text-align: center;
}

.empty-mark {
  width: 80rpx;
  height: 80rpx;
  margin: 0 auto 16rpx;
  border-radius: 24rpx;
  background: rgba(0, 168, 232, 0.12);
  color: #00a8e8;
  font-size: 32rpx;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
}

.empty-title {
  font-size: 28rpx;
  font-weight: 600;
  color: #0f1724;
}

.empty-desc {
  margin-top: 8rpx;
  font-size: 22rpx;
  color: #7a8899;
}

.msg-item {
  position: relative;
  display: flex;
  gap: 16rpx;
  padding: 24rpx 12rpx;
  border-bottom: 1rpx solid #eef2f6;
}

.msg-item:last-child {
  border-bottom: none;
}

.msg-item.is-unread {
  background: rgba(0, 168, 232, 0.06);
  margin: 0 -12rpx;
  padding-left: 24rpx;
  padding-right: 24rpx;
  border-radius: 20rpx;
}

.msg-dot {
  width: 14rpx;
  height: 14rpx;
  margin-top: 12rpx;
  border-radius: 50%;
  background: #00a8e8;
  flex-shrink: 0;
}

.msg-body {
  flex: 1;
  min-width: 0;
}

.msg-top {
  display: flex;
  justify-content: space-between;
  gap: 16rpx;
}

.msg-title {
  flex: 1;
  font-size: 28rpx;
  font-weight: 600;
  color: #0f1724;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.msg-time {
  flex-shrink: 0;
  font-size: 20rpx;
  color: #7a8899;
}

.msg-meta {
  margin-top: 6rpx;
  font-size: 22rpx;
  color: #00a8e8;
}

.msg-content {
  margin-top: 8rpx;
  font-size: 24rpx;
  color: #7a8899;
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
