<template>
  <view class="page">
    <view class="card head">
      <text class="title">活动报名</text>
      <text class="sub">{{ detail.activityName || '社区活动' }}</text>
    </view>

    <view class="card intro-card">
      <view class="intro-row"><text>活动时间</text><text>{{ formatDateRange(detail.startTime, detail.endTime) }}</text></view>
      <view class="intro-row"><text>活动地点</text><text>{{ detail.address || '地点待定' }}</text></view>
      <view class="intro-row"><text>报名情况</text><text>{{ detail.signupCount || 0 }}{{ detail.signupLimit ? '/' + detail.signupLimit : '' }}</text></view>
      <view class="intro-row"><text>报名状态</text><text :class="statusClass">{{ statusText }}</text></view>
    </view>

    <view class="card">
      <view class="field">
        <text class="label">备注信息</text>
        <textarea class="textarea" v-model="form.remark" maxlength="500" placeholder="如需特殊协助请填写备注" />
      </view>
    </view>

    <button class="submit-btn" :loading="submitting" @click="submit">确认报名</button>
  </view>
</template>

<script>
import { useActivityDetailApi, useActivitySignupApi } from '../../../api/activity.js';

export default {
  name: 'ActivitySignupPage',
  data() {
    return {
      id: '',
      submitting: false,
      detail: {},
      form: {
        remark: ''
      }
    };
  },
  computed: {
    statusText() {
      const now = Date.now();
      const signupStart = this.detail.signupStartTime ? new Date(this.detail.signupStartTime.replace(/-/g, '/')).getTime() : 0;
      const signupEnd = this.detail.signupEndTime ? new Date(this.detail.signupEndTime.replace(/-/g, '/')).getTime() : 0;
      const startTime = this.detail.startTime ? new Date(this.detail.startTime.replace(/-/g, '/')).getTime() : 0;
      if (startTime && now > startTime) return '活动已结束';
      if (signupStart && now < signupStart) return '报名未开始';
      if (signupEnd && now > signupEnd) return '报名已截止';
      if (this.detail.signupLimit && this.detail.signupCount >= this.detail.signupLimit) return '报名已满';
      return '可报名';
    },
    statusClass() {
      return this.statusText === '可报名' ? 'ok' : 'warn';
    }
  },
  async onLoad(query) {
    this.id = query?.id || '';
    if (this.id) {
      await this.loadDetail();
    }
  },
  methods: {
    async loadDetail() {
      try {
        const res = await useActivityDetailApi(this.id);
        this.detail = res.data || {};
      } catch (e) {
        this.detail = {};
      }
    },
    async submit() {
      if (!this.id) {
        uni.showToast({ title: '活动信息不存在', icon: 'none' });
        return;
      }
      if (this.submitting) {
        return;
      }
      this.submitting = true;
      try {
        await useActivitySignupApi({
          activityId: Number(this.id),
          remark: this.form.remark
        });
        uni.showToast({ title: '报名成功', icon: 'success' });
        setTimeout(() => {
          uni.navigateBack({ delta: 1 });
        }, 900);
      } finally {
        this.submitting = false;
      }
    },
    formatDateRange(startTime, endTime) {
      if (!startTime) return '时间待定';
      const start = startTime.replace('T', ' ').slice(0, 16);
      if (!endTime) return start;
      return `${start} - ${endTime.replace('T', ' ').slice(5, 16)}`;
    }
  }
};
</script>

<style scoped>
.page { min-height: 100vh; background: #f6f8fc; padding: 24rpx; }
.card { background: #fff; border-radius: 20rpx; padding: 24rpx; margin-bottom: 18rpx; box-shadow: 0 8rpx 24rpx rgba(15, 23, 42, 0.05); }
.head { background: linear-gradient(135deg, #111827 0%, #1f2937 100%); }
.title { display:block; color:#fff; font-size:34rpx; font-weight:700; }
.sub { display:block; color:rgba(255,255,255,.78); font-size:22rpx; margin-top:8rpx; }
.intro-row { display:flex; justify-content:space-between; gap:20rpx; padding:14rpx 0; color:#334155; font-size:24rpx; border-bottom:1rpx solid #eef2f7; }
.intro-row:last-child { border-bottom:none; }
.ok { color:#16a34a; }
.warn { color:#dc2626; }
.field { margin-bottom: 8rpx; }
.label { display:block; color:#334155; font-size:24rpx; margin-bottom:10rpx; }
.textarea { width:100%; min-height:180rpx; border:1rpx solid #e5e7eb; border-radius:14rpx; padding:18rpx 20rpx; font-size:26rpx; background:#fafafa; box-sizing:border-box; }
.submit-btn { margin-top: 18rpx; background:#111827; color:#fff; border-radius:16rpx; height:88rpx; line-height:88rpx; font-size:30rpx; }
.submit-btn::after { border: none; }
</style>
