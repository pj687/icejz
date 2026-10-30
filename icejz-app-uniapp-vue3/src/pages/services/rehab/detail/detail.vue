<template>
  <view class="page">
    <view class="card head">
      <text class="title">{{ detail.serviceName || '康复课程' }}</text>
      <text class="sub">{{ detail.durationMinutes }}分钟 · ¥{{ detail.price }}/次</text>
    </view>

    <view class="card">
      <text class="section">课程说明</text>
      <text class="desc">{{ detail.serviceDesc || '课程由社区康复师团队执行，结合长者当前身体状态制定个性化训练内容。' }}</text>
    </view>

    <view class="card">
      <text class="section">课程信息</text>
      <view class="row"><text>适用人群</text><text>{{ detail.targetGroup || '不限' }}</text></view>
      <view class="row"><text>单次时长</text><text>{{ detail.durationMinutes }} 分钟</text></view>
      <view class="row"><text>课程价格</text><text>¥{{ detail.price }} / 次</text></view>
    </view>

    <button class="btn" @click="goBooking">立即预约</button>
  </view>
</template>

<script>
import { useServiceItemDetailApi } from '../../../../api/user.js';

export default {
  name: 'RehabDetail',
  data() {
    return { detail: {} };
  },
  onLoad(query) {
    if (query?.id) {
      useServiceItemDetailApi(query.id).then(res => { this.detail = res?.data || {}; });
    } else if (query?.data) {
      try { this.detail = JSON.parse(decodeURIComponent(query.data)); } catch (e) {}
    }
  },
  methods: {
    goBooking() {
      uni.navigateTo({
        url: `/pages/services/home-care/booking/booking?serviceItemId=${this.detail.id}&serviceName=${encodeURIComponent(this.detail.serviceName || '')}`
      });
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
</style>
