<template>
  <view class="page">
    <view class="card head">
      <text class="title">康复理疗</text>
      <text class="sub">依据评估结果制定康复训练与理疗计划</text>
    </view>

    <view class="card" v-if="loading">
      <text class="section">加载中...</text>
    </view>

    <view class="card" v-else>
      <text class="section">可预约课程</text>
      <view v-if="services.length === 0" class="empty-tip">暂无可预约康复课程</view>
      <view v-for="item in services" :key="item.id" class="item" @tap="goDetail(item)">
        <view>
          <text class="name">{{ item.serviceName }}</text>
          <text class="meta">{{ item.durationMinutes }}分钟 · ¥{{ item.price }}/次</text>
          <text class="desc-text" v-if="item.targetGroup">适用：{{ item.targetGroup }}</text>
        </view>
        <view class="right-wrap">
          <text class="tag">可预约</text>
          <text class="link">查看详情 ></text>
        </view>
      </view>
    </view>

    <!-- 我的预约 -->
    <view class="card" v-if="bookings.length">
      <view class="section-row">
        <text class="section">我的预约</text>
        <text class="sub-link" @tap="goAllBookings">查看全部 ></text>
      </view>
      <view v-for="item in bookings.slice(0,3)" :key="item.id" class="item booking-item" @tap="goBookingDetail(item)">
        <view>
          <text class="name">{{ item.serviceName }}</text>
          <text class="meta">{{ item.bookingTime }} · {{ item.address || '地址待填写' }}</text>
        </view>
        <text class="tag" :class="statusClass(item.status)">{{ statusLabel(item.status) }}</text>
      </view>
    </view>
  </view>
</template>

<script>
import { useServiceItemListApi, useBookingListApi } from '../../../api/user.js';
import cache from '../../../utils/cache.js';

export default {
  name: 'Rehab',
  data() {
    return { loading: true, services: [], bookings: [] };
  },
  async onShow() {
    await this.loadData();
  },
  methods: {
    async loadData() {
      this.loading = true;
      try {
        const [svcRes, bookRes] = await Promise.all([
          useServiceItemListApi('rehab'),
          cache.getToken() ? useBookingListApi({ page: 1, limit: 5, elderUserId: cache.getUserInfo()?.id }) : Promise.resolve(null)
        ]);
        this.services = svcRes?.data || [];
        this.bookings = (bookRes?.data?.list || []).filter(b => {
          // 只显示康复类预约（通过服务名称模糊判断，或全部显示）
          return true;
        });
      } catch (e) {
        console.error('rehab loadData error', e);
      } finally {
        this.loading = false;
      }
    },
    goDetail(item) {
      uni.navigateTo({ url: `/pages/services/rehab/detail/detail?id=${item.id}` });
    },
    goBookingDetail(item) {
      uni.navigateTo({ url: `/pages/services/home-care/booking/booking?id=${item.id}` });
    },
    goAllBookings() {
      uni.navigateTo({ url: '/pages/services/home-care/booking/booking' });
    },
    statusLabel(s) {
      return ['待确认', '已确认', '服务中', '已完成', '已取消'][s] || '-';
    },
    statusClass(s) {
      return s === 3 ? 'done' : s === 4 ? 'cancel' : 'dark';
    }
  }
};
</script>

<style scoped>
.page { min-height: 100vh; background: #f6f6f6; padding: 24rpx; }
.card { background: #fff; border-radius: 18rpx; padding: 24rpx; margin-bottom: 18rpx; }
.head { background: #111; }
.title { display:block; color:#fff; font-size:36rpx; font-weight:700; }
.sub { display:block; color:#d3d3d3; font-size:23rpx; margin-top:10rpx; }
.section { display:block; color:#111; font-size:28rpx; font-weight:600; margin-bottom:10rpx; }
.section-row { display:flex; justify-content:space-between; align-items:center; }
.sub-link { font-size:22rpx; color:#666; }
.item { display:flex; justify-content:space-between; align-items:center; padding:16rpx; background:#f8f8f8; border-radius:12rpx; margin-top:12rpx; }
.name { display:block; font-size:26rpx; color:#111; }
.meta { display:block; font-size:22rpx; color:#888; margin-top:6rpx; }
.desc-text { display:block; font-size:20rpx; color:#aaa; margin-top:4rpx; }
.right-wrap { display:flex; flex-direction:column; align-items:flex-end; }
.tag { font-size:22rpx; color:#111; background:#ececec; padding:6rpx 12rpx; border-radius:999rpx; }
.tag.dark { color:#fff; background:#111; }
.tag.done { color:#fff; background:#22c55e; }
.tag.cancel { color:#fff; background:#ef4444; }
.link { margin-top:8rpx; font-size:20rpx; color:#666; }
.booking-item { border:1rpx solid #efefef; }
.empty-tip { color:#aaa; font-size:24rpx; padding:20rpx 0; text-align:center; }
</style>
