<template>
  <view class="page ice-subpage">
    <ice-nav-bar :title="$t('sys.userTitle')" :sub="$t('sys.userSub')" />

    <view class="body">
      <view class="search-bar">
        <input
          class="search-input"
          :placeholder="$t('sys.searchUsername')"
          v-model="keyword"
          confirm-type="search"
          @confirm="onSearch"
        />
        <view class="search-btn" @click="onSearch">{{ $t('common.search') }}</view>
      </view>

      <view v-if="!loading && list.length" class="result-tip">共 {{ total }} 人</view>

      <view v-if="loading" class="empty">
        <view class="empty-mark">···</view>
        <view class="empty-title">{{ $t('sys.loadingUser') }}</view>
      </view>
      <view v-else-if="!list.length" class="empty">
        <view class="empty-mark">用</view>
        <view class="empty-title">{{ $t('sys.emptyUser') }}</view>
        <view class="empty-desc">{{ $t('sys.emptyUserHint') }}</view>
      </view>

      <view v-for="item in list" :key="item.id" class="card">
        <view class="avatar">{{ item._initial }}</view>
        <view class="card-main">
          <view class="row">
            <view class="name">{{ item.realName || item.username }}</view>
            <view class="status" :class="item._on ? 'on' : 'off'">
              {{ item._on ? $t('sys.normal') : $t('sys.disabled') }}
            </view>
          </view>
          <view class="meta">@{{ item.username }}</view>
          <view class="tags">
            <view class="tag">{{ $t('sys.mobile') }} {{ item.mobile || '-' }}</view>
            <view class="tag">{{ $t('sys.email') }} {{ item.email || '-' }}</view>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
import cache from '@/utils/cache.js'
import { useUserPageApi } from '@/api/sys.js'
import IceNavBar from '@/components/layout/IceNavBar.vue'

function normalizeUserList(payload) {
  if (!payload) return []
  if (Array.isArray(payload)) return payload
  if (Array.isArray(payload.list)) return payload.list
  if (Array.isArray(payload.records)) return payload.records
  return []
}

export default {
  components: { IceNavBar },
  data() {
    return {
      loading: false,
      keyword: '',
      list: [],
      total: 0
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
    onSearch() {
      this.loadData()
    },
    async loadData() {
      this.loading = true
      try {
        const params = {
          page: 1,
          limit: 50
        }
        const keyword = String(this.keyword || '').trim()
        if (keyword) params.username = keyword

        const res = await useUserPageApi(params)
        const raw = normalizeUserList(res && res.data)
        this.list = raw.map((item) => {
          const name = item.realName || item.username || '?'
          return {
            ...item,
            _initial: String(name).slice(0, 1),
            _on: Number(item.status) === 1
          }
        })
        this.total = Number((res && res.data && res.data.total) || this.list.length) || 0
      } catch (e) {
        this.list = []
        this.total = 0
        uni.showToast({
          title: (e && e.msg) || this.$t('sys.emptyUserHint'),
          icon: 'none'
        })
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

.search-bar {
  display: flex;
  gap: 12rpx;
}

.search-input {
  flex: 1;
  height: 76rpx;
  padding: 0 28rpx;
  border-radius: 999rpx;
  background: rgba(255, 255, 255, 0.94);
  border: 1rpx solid rgba(255, 255, 255, 0.98);
  box-shadow: 0 10rpx 24rpx rgba(15, 35, 55, 0.05);
  font-size: 26rpx;
}

.search-btn {
  width: 140rpx;
  height: 76rpx;
  border-radius: 999rpx;
  background: linear-gradient(145deg, #00a8e8, #2bb8ef);
  color: #fff;
  font-size: 26rpx;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 10rpx 22rpx rgba(0, 168, 232, 0.24);
}

.result-tip {
  margin: 18rpx 8rpx 4rpx;
  font-size: 22rpx;
  color: #8492a6;
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

.avatar {
  width: 80rpx;
  height: 80rpx;
  border-radius: 50%;
  background: linear-gradient(145deg, #00a8e8, #38bdf8);
  color: #fff;
  font-size: 32rpx;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  box-shadow: 0 10rpx 20rpx rgba(0, 168, 232, 0.22);
}

.card-main {
  flex: 1;
  min-width: 0;
}

.row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12rpx;
}

.name {
  font-size: 30rpx;
  font-weight: 700;
  color: #0f1724;
}

.status {
  flex-shrink: 0;
  padding: 6rpx 14rpx;
  border-radius: 999rpx;
  font-size: 20rpx;
  font-weight: 650;
}

.status.on {
  background: #dcfce7;
  color: #15803d;
}

.status.off {
  background: #fee2e2;
  color: #dc2626;
}

.meta {
  margin-top: 6rpx;
  font-size: 22rpx;
  color: #00a8e8;
}

.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 10rpx;
  margin-top: 14rpx;
}

.tag {
  padding: 8rpx 14rpx;
  border-radius: 999rpx;
  background: #f4f7fb;
  font-size: 20rpx;
  color: #64748b;
}
</style>
