<template>
  <view class="page">
    <view class="card head">
      <text class="title">{{ detail.serviceName || '服务详情' }}</text>
      <text class="sub">{{ detail.durationMinutes }}分钟 · ¥{{ detail.price }}/次</text>
    </view>

    <view class="card">
      <text class="section">服务说明</text>
      <text class="desc">{{ detail.serviceDesc || '暂无详细说明' }}</text>
    </view>

    <view class="card">
      <text class="section">服务信息</text>
      <view class="row"><text>适用人群</text><text>{{ detail.targetGroup || '不限' }}</text></view>
      <view class="row"><text>服务时长</text><text>{{ detail.durationMinutes }} 分钟</text></view>
      <view class="row"><text>服务价格</text><text>¥{{ detail.price }} / 次</text></view>
    </view>

    <button
      class="btn"
      :class="{ 'btn-disabled': hasBooked }"
      :disabled="hasBooked"
      @click="goBooking"
    >{{ hasBooked ? '已预约' : '立即预约' }}</button>
  </view>
</template>

<script>
import { useServiceItemDetailApi, useBookingListApi } from '../../../../api/user.js';

export default {
  name: 'HomeCareDetail',
  data() {
    return {
      detail: {},
      hasBooked: false
    };
  },
  onLoad(query) {
    if (query?.id) {
      useServiceItemDetailApi(query.id).then(res => {
        this.detail = res?.data || {};
        this.checkBooked(query.id);
      });
    } else if (query?.data) {
      try {
        this.detail = JSON.parse(decodeURIComponent(query.data));
        if (this.detail.id) this.checkBooked(this.detail.id);
      } catch (e) {}
    }
  },
  methods: {
    async checkBooked(serviceItemId) {
      try {
        const res = await useBookingListApi({ serviceItemId, page: 1, limit: 10 });
        const list = res?.data?.list || res?.data?.records || [];
        // 存在未取消的预约（状态 0待确认 1已确认 2服务中 3已完成，4已取消）
        this.hasBooked = list.some(b => b.status !== 4);
      } catch (e) {
        this.hasBooked = false;
      }
    },
    goBooking() {
      if (this.hasBooked) return;
      uni.navigateTo({ url: `/pages/services/home-care/booking/booking?serviceItemId=${this.detail.id}&serviceName=${encodeURIComponent(this.detail.serviceName || '')}` });
    }
  }
};
</script>

<style scoped>
.page { min-height:100vh; background:#f6f6f6; padding:24rpx; }
.card { background:#fff; border-radius:18rpx; padding:24rpx; margin-bottom:18rpx; }
.head { background:#111; }
.title { display:block; color:#fff; font-size:34rpx; font-weight:700; }
.sub { display:block; color:#d3d3d3; font-size:22rpx; margin-top:8rpx; }
.section { display:block; color:#111; font-size:28rpx; font-weight:600; margin-bottom:10rpx; }
.desc { color:#444; font-size:24rpx; line-height:40rpx; }
.row { display:flex; justify-content:space-between; padding:14rpx 0; border-bottom:1rpx solid #f1f1f1; font-size:24rpx; color:#333; }
.row:last-child { border-bottom:none; }
.btn { margin-top:20rpx; background:#111; color:#fff; border-radius:14rpx; height:88rpx; line-height:88rpx; font-size:30rpx; }
.btn::after { border:none; }
.btn-disabled { background:#999; color:#eee; }
</style>
