<template>
  <view class="page">
    <view class="card head">
      <text class="title">活动报名</text>
      <text class="sub">查看活动信息并完成线上报名</text>
    </view>

    <view class="card">
      <text class="section">可报名活动</text>
      <view v-for="item in activityList" :key="item.id" class="item">
        <view>
          <text class="name">{{ item.name }}</text>
          <text class="meta">{{ item.time }} · {{ item.place }}</text>
        </view>
        <view class="right">
          <text class="quota">{{ item.quota }}</text>
          <text class="btn">报名</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
export default {
  name: 'ActivitySignup',
  data() {
    return {
      activityList: [
        { id: 1, name: '社区健康讲座', time: '周三 14:00', place: '社区活动中心', quota: '剩余 18 人' },
        { id: 2, name: '长者手工课堂', time: '周四 09:30', place: '幸福里文化室', quota: '剩余 9 人' },
        { id: 3, name: '邻里合唱排练', time: '周六 16:00', place: '社区礼堂', quota: '剩余 12 人' }
      ]
    };
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
.item { display:flex; justify-content:space-between; align-items:center; padding:16rpx; background:#f8f8f8; border-radius:12rpx; margin-top:12rpx; }
.name { display:block; font-size:26rpx; color:#111; }
.meta { display:block; font-size:22rpx; color:#888; margin-top:6rpx; }
.right { display:flex; flex-direction:column; align-items:flex-end; }
.quota { font-size:22rpx; color:#666; }
.btn { margin-top:8rpx; font-size:22rpx; color:#fff; background:#111; padding:6rpx 14rpx; border-radius:999rpx; }
</style>
