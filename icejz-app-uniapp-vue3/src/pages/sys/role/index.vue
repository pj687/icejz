<template>
  <view class="page ice-subpage">
    <ice-nav-bar :title="$t('sys.roleTitle')" :sub="$t('sys.roleSub')" />

    <view class="body">
      <view v-if="loading" class="empty">
        <view class="empty-mark">···</view>
        <view class="empty-title">{{ $t('sys.loadingRole') }}</view>
      </view>
      <view v-else-if="!list.length" class="empty">
        <view class="empty-mark">角</view>
        <view class="empty-title">{{ $t('sys.emptyRole') }}</view>
        <view class="empty-desc">{{ $t('sys.emptyRoleHint') }}</view>
      </view>

      <view v-for="item in list" :key="item.id" class="card">
        <view class="badge">角</view>
        <view class="main">
          <view class="name">{{ item.name }}</view>
          <view class="code">{{ item.roleCode || item.code || $t('sys.noCode') }}</view>
          <view class="remark">{{ item.remark || $t('sys.noRemark') }}</view>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
import cache from '@/utils/cache.js'
import { useRolePageApi, useRoleListApi } from '@/api/sys.js'
import IceNavBar from '@/components/layout/IceNavBar.vue'

export default {
  components: { IceNavBar },
  data() {
    return {
      loading: false,
      list: []
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
        let list = []
        try {
          const pageRes = await useRolePageApi({ page: 1, limit: 100 })
          list = pageRes.data?.list || []
        } catch (e) {
          const listRes = await useRoleListApi()
          list = listRes.data || []
        }
        this.list = list
      } catch (e) {
        this.list = []
      } finally {
        this.loading = false
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

.empty {
  margin-top: 48rpx;
  padding: 48rpx 24rpx;
  text-align: center;
}

.empty-mark {
  width: 80rpx;
  height: 80rpx;
  margin: 0 auto 16rpx;
  border-radius: 50%;
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

.card {
  display: flex;
  gap: 20rpx;
  margin-top: 16rpx;
  padding: 24rpx;
  border-radius: 28rpx;
  background: rgba(255, 255, 255, 0.94);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  box-shadow: 0 14rpx 36rpx rgba(15, 35, 55, 0.05);
}

.badge {
  width: 72rpx;
  height: 72rpx;
  border-radius: 50%;
  background: linear-gradient(145deg, #00a8e8, #38bdf8);
  color: #fff;
  font-size: 28rpx;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  box-shadow: 0 10rpx 20rpx rgba(0, 168, 232, 0.22);
}

.main {
  flex: 1;
  min-width: 0;
}

.name {
  font-size: 30rpx;
  font-weight: 700;
  color: #0f1724;
}

.code {
  margin-top: 6rpx;
  font-size: 22rpx;
  color: #00a8e8;
}

.remark {
  margin-top: 10rpx;
  font-size: 24rpx;
  color: #7a8899;
  line-height: 1.5;
}
</style>
