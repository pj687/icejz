<template>
  <view class="page">
    <view class="hero-card">
      <text class="title">活动评价</text>
      <text class="sub">提交活动反馈，并查看其他用户评价</text>
    </view>

    <view class="card" v-if="canReview">
      <text class="section">提交评价</text>
      <view class="stars-box">
        <text
          v-for="star in 5"
          :key="star"
          class="star-item"
          :class="{ active: form.rating >= star }"
          @tap="form.rating = star"
        >★</text>
      </view>
      <view class="switch-row" @tap="toggleAnonymous">
        <text class="switch-label">匿名评价</text>
        <view class="switch-dot" :class="{ active: form.anonymousFlag === 1 }">
          <view class="dot-inner"></view>
        </view>
      </view>
      <textarea class="textarea" v-model="form.content" maxlength="1000" placeholder="欢迎填写本次活动体验、建议或收获" />
      <button class="submit-btn" :loading="submitting" @click="submitReview">提交评价</button>
    </view>

    <view class="card" v-else>
      <text class="section">提交评价</text>
      <text class="tips-text">{{ isLogin ? '需先报名并完成签到后，才能提交活动评价。' : '登录后可查看你的报名状态，并在签到后提交活动评价。' }}</text>
      <button v-if="!isLogin" class="login-btn" @click="toLoginWithTip('登录后可提交活动评价')">立即登录</button>
    </view>

    <view class="card" v-if="myReview">
      <text class="section">我的评价</text>
      <view class="my-review-box">
        <text class="my-review-stars">{{ buildStars(myReview.rating) }}</text>
        <text class="my-review-content">{{ myReview.content || '未填写评价内容' }}</text>
        <text class="my-review-time">{{ formatTime(myReview.reviewTime) }}</text>
      </view>
    </view>

    <view class="card">
      <view class="header-row">
        <text class="section">活动评价列表</text>
        <text class="count-text">共 {{ stats.reviewCount || 0 }} 条</text>
      </view>
      <view class="score-panel">
        <view>
          <text class="avg-value">{{ stats.averageRating || '0.00' }}</text>
          <text class="avg-label">平均评分</text>
        </view>
        <view class="panel-right">
          <text>五星 {{ stats.fiveStarCount || 0 }}</text>
          <text>四星 {{ stats.fourStarCount || 0 }}</text>
          <text>三星 {{ stats.threeStarCount || 0 }}</text>
        </view>
      </view>
      <view v-if="!reviewList.length" class="empty-box">
        <text class="empty-text">还没有评价内容，快来抢先评价吧</text>
      </view>
      <view v-else v-for="item in reviewList" :key="item.id" class="review-item">
        <view class="review-top">
          <text class="review-user">{{ item.userName || '匿名用户' }}</text>
          <text class="review-rating">{{ buildStars(item.rating) }}</text>
        </view>
        <text class="review-content">{{ item.content || '用户未填写评价内容' }}</text>
        <text class="review-time">{{ formatTime(item.reviewTime) }}</text>
      </view>
    </view>
  </view>
</template>

<script>
import {
  useActivityReviewPageApi,
  useActivityReviewStatsApi,
  useActivityReviewSubmitApi,
  useMyActivityReviewPageApi,
  useMyActivitySignupPageApi
} from '../../../api/activity.js';
import cache from '../../../utils/cache.js';

export default {
  name: 'ActivityReview',
  data() {
    return {
      activityId: '',
      submitting: false,
      reviewList: [],
      stats: {},
      myReview: null,
      signupRecord: null,
      form: {
        rating: 5,
        content: '',
        anonymousFlag: 0
      }
    };
  },
  computed: {
    isLogin() {
      return !!cache.getToken();
    },
    canReview() {
      return !!(this.isLogin && this.signupRecord && Number(this.signupRecord.checkinStatus) === 1 && !this.myReview);
    }
  },
  async onLoad(query) {
    this.activityId = query?.activityId || '';
    if (this.activityId) {
      await this.loadPageData();
    }
  },
  async onShow() {
    if (this.activityId) {
      await this.loadPageData();
    }
  },
  methods: {
    async loadPageData() {
      const tasks = [this.loadReviewList(), this.loadStats()];
      if (this.isLogin) {
        tasks.push(this.loadMyReview(), this.loadMySignupRecord());
      } else {
        this.myReview = null;
        this.signupRecord = null;
      }
      await Promise.all(tasks);
    },
    async loadReviewList() {
      try {
        const res = await useActivityReviewPageApi({ activityId: this.activityId, page: 1, limit: 20 });
        this.reviewList = res.data?.list || [];
      } catch (e) {
        this.reviewList = [];
      }
    },
    async loadStats() {
      try {
        const res = await useActivityReviewStatsApi(this.activityId);
        this.stats = res.data || {};
      } catch (e) {
        this.stats = {};
      }
    },
    async loadMyReview() {
      try {
        const res = await useMyActivityReviewPageApi({ activityId: this.activityId, page: 1, limit: 1 });
        this.myReview = res.data?.list?.[0] || null;
      } catch (e) {
        this.myReview = null;
      }
    },
    async loadMySignupRecord() {
      try {
        const res = await useMyActivitySignupPageApi({ activityId: this.activityId, page: 1, limit: 1 });
        this.signupRecord = res.data?.list?.[0] || null;
      } catch (e) {
        this.signupRecord = null;
      }
    },
    toggleAnonymous() {
      this.form.anonymousFlag = this.form.anonymousFlag === 1 ? 0 : 1;
    },
    async submitReview() {
      if (!this.isLogin) {
        this.toLoginWithTip('提交评价需要先登录');
        return;
      }
      if (!this.signupRecord?.id) {
        uni.showToast({ title: '请先报名活动', icon: 'none' });
        return;
      }
      if (!this.form.rating) {
        uni.showToast({ title: '请选择评分', icon: 'none' });
        return;
      }
      if (this.submitting) {
        return;
      }
      this.submitting = true;
      try {
        await useActivityReviewSubmitApi({
          signupId: this.signupRecord.id,
          rating: this.form.rating,
          content: this.form.content,
          anonymousFlag: this.form.anonymousFlag
        });
        uni.showToast({ title: '评价成功', icon: 'success' });
        this.form.content = '';
        this.form.anonymousFlag = 0;
        await this.loadPageData();
      } finally {
        this.submitting = false;
      }
    },
    buildStars(rating) {
      const count = Number(rating || 0);
      return '★'.repeat(count) + '☆'.repeat(5 - count);
    },
    formatTime(time) {
      return time ? time.replace('T', ' ').slice(0, 16) : '-';
    },
    toLoginWithTip(msg) {
      uni.showModal({
        title: '登录提示',
        content: msg,
        confirmText: '去登录',
        cancelText: '稍后',
        success: (res) => {
          if (res.confirm) {
            uni.navigateTo({ url: '/pages/login/login' });
          }
        }
      });
    }
  }
};
</script>

<style scoped>
.page { min-height: 100vh; background:#f4f7fb; padding:24rpx; }
.hero-card { background: linear-gradient(135deg, #111827 0%, #334155 100%); border-radius: 24rpx; padding: 30rpx; box-shadow: 0 16rpx 36rpx rgba(15, 23, 42, 0.14); }
.title { display:block; color:#fff; font-size:36rpx; font-weight:700; }
.sub { display:block; color:rgba(255,255,255,.78); font-size:22rpx; margin-top:8rpx; line-height:1.6; }
.card { background:#fff; border-radius:20rpx; padding:24rpx; margin-top:18rpx; box-shadow:0 8rpx 24rpx rgba(15,23,42,.05); }
.section { display:block; color:#111827; font-size:28rpx; font-weight:700; margin-bottom:12rpx; }
.stars-box { display:flex; align-items:center; gap:14rpx; margin-bottom:18rpx; }
.star-item { font-size:52rpx; color:#cbd5e1; }
.star-item.active { color:#f59e0b; }
.switch-row { display:flex; align-items:center; justify-content:space-between; background:#f8fafc; border-radius:16rpx; padding:18rpx 20rpx; margin-bottom:18rpx; }
.switch-label { color:#334155; font-size:24rpx; }
.switch-dot { width:86rpx; height:48rpx; background:#e2e8f0; border-radius:999rpx; position:relative; transition:all .2s; }
.switch-dot.active { background:#111827; }
.dot-inner { width:40rpx; height:40rpx; background:#fff; border-radius:50%; position:absolute; top:4rpx; left:4rpx; transition:all .2s; }
.switch-dot.active .dot-inner { left:42rpx; }
.textarea { width:100%; min-height:180rpx; border:1rpx solid #e5e7eb; border-radius:14rpx; padding:18rpx 20rpx; font-size:26rpx; background:#fafafa; box-sizing:border-box; }
.submit-btn { margin-top:18rpx; background:#111827; color:#fff; border-radius:16rpx; height:88rpx; line-height:88rpx; font-size:30rpx; }
.submit-btn::after { border:none; }
.login-btn { margin-top:18rpx; background:#00a8e8; color:#fff; border-radius:16rpx; height:84rpx; line-height:84rpx; font-size:28rpx; }
.login-btn::after { border:none; }
.tips-text { color:#64748b; font-size:24rpx; line-height:40rpx; }
.my-review-box { background:#f8fafc; border-radius:16rpx; padding:18rpx; }
.my-review-stars { display:block; color:#f59e0b; font-size:24rpx; }
.my-review-content { display:block; margin-top:12rpx; color:#475569; font-size:24rpx; line-height:40rpx; }
.my-review-time { display:block; margin-top:12rpx; color:#94a3b8; font-size:22rpx; }
.header-row { display:flex; align-items:center; justify-content:space-between; }
.count-text { color:#94a3b8; font-size:22rpx; }
.score-panel { display:flex; justify-content:space-between; align-items:flex-start; background:#f8fafc; border-radius:16rpx; padding:20rpx; margin-bottom:8rpx; }
.avg-value { display:block; color:#111827; font-size:46rpx; font-weight:700; }
.avg-label { display:block; color:#64748b; font-size:22rpx; margin-top:8rpx; }
.panel-right { display:flex; flex-direction:column; align-items:flex-end; gap:8rpx; color:#64748b; font-size:22rpx; }
.review-item { margin-top:18rpx; padding:18rpx; background:#f8fafc; border-radius:16rpx; }
.review-top { display:flex; align-items:center; justify-content:space-between; }
.review-user { color:#111827; font-size:24rpx; font-weight:600; }
.review-rating { color:#f59e0b; font-size:22rpx; }
.review-content { display:block; margin-top:12rpx; color:#475569; font-size:24rpx; line-height:40rpx; }
.review-time { display:block; margin-top:12rpx; color:#94a3b8; font-size:22rpx; }
.empty-box { padding:28rpx 0 10rpx; text-align:center; }
.empty-text { color:#94a3b8; font-size:24rpx; }
</style>
