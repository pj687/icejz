<template>
  <view class="page">
    <view class="card head">
      <text class="title">记录详情</text>
      <text class="sub">{{ detail.type }}</text>
    </view>

    <view class="card">
      <text class="section">基础信息</text>
      <view class="row"><text>记录时间</text><text>{{ detail.time }}</text></view>
      <view class="row"><text>检测结果</text><text>{{ detail.result }}</text></view>
      <view class="row"><text>检测数值</text><text>{{ detail.value }}</text></view>
    </view>

    <view class="card">
      <text class="section">健康建议</text>
      <text class="desc">当前指标整体平稳，建议继续保持规律作息、清淡饮食，并持续每日监测。如连续三天出现异常，请联系社区医生复诊。</text>
    </view>
  </view>
</template>

<script>
export default {
  name: 'HealthRecordDetail',
  data() {
    return {
      detail: {
        type: '健康记录',
        time: '-',
        result: '-',
        value: '-'
      }
    };
  },
  onLoad(query) {
    try {
      if (query?.data) {
        this.detail = JSON.parse(decodeURIComponent(query.data));
      }
    } catch (e) {}
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
.row { display:flex; justify-content:space-between; padding:14rpx 0; border-bottom:1rpx solid #f1f1f1; font-size:24rpx; color:#333; }
.row:last-child { border-bottom:none; }
.desc { color:#444; font-size:24rpx; line-height:40rpx; }
</style>
