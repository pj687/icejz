<template>
  <view class="page">
    <view class="hero-card">
      <text class="hero-title">{{ detail.activityName || '社区活动' }}</text>
      <text class="hero-sub">{{ formatDateRange(detail.startTime, detail.endTime) }}</text>
      <text class="hero-sub">{{ detail.address || '地点待定' }}</text>
      <view class="hero-tags">
        <text class="hero-tag">{{ getSignupStatusText() }}</text>
        <text class="hero-tag light">已报名 {{ detail.signupCount || 0 }}{{ detail.signupLimit ? '/' + detail.signupLimit : '' }}</text>
      </view>
    </view>

    <view class="card">
      <text class="section">活动介绍</text>
      <text class="desc">{{ detail.activityDesc || detail.activityContent || '暂无活动介绍' }}</text>
    </view>

    <view class="card">
      <text class="section">活动安排</text>
      <view class="row"><text>主办方</text><text>{{ detail.organizerName || '社区服务中心' }}</text></view>
      <view class="row"><text>联系人</text><text>{{ detail.contactName || '-' }}</text></view>
      <view class="row"><text>联系电话</text><text>{{ detail.contactMobile || '-' }}</text></view>
      <view class="row"><text>报名时间</text><text>{{ formatDateRange(detail.signupStartTime, detail.signupEndTime) }}</text></view>
    </view>

    <view class="card stats-card">
      <view class="stats-header">
        <text class="section">评价统计</text>
        <text class="stats-action" @tap="goReviewPage">查看全部</text>
      </view>
      <view class="stats-top">
        <view>
          <text class="score-value">{{ stats.averageRating || '0.00' }}</text>
          <text class="score-label">综合评分</text>
        </view>
        <view class="score-summary">
          <text class="summary-item">{{ stats.reviewCount || 0 }} 条评价</text>
          <text class="summary-item">{{ stats.contentCount || 0 }} 条有内容</text>
        </view>
      </view>
      <view class="stars-line">
        <text class="stars-label">五星</text>
        <view class="stars-bar"><view class="stars-fill" :style="{ width: calcRate(stats.fiveStarCount) }"></view></view>
        <text class="stars-count">{{ stats.fiveStarCount || 0 }}</text>
      </view>
      <view class="stars-line">
        <text class="stars-label">四星</text>
        <view class="stars-bar"><view class="stars-fill" :style="{ width: calcRate(stats.fourStarCount) }"></view></view>
        <text class="stars-count">{{ stats.fourStarCount || 0 }}</text>
      </view>
      <view class="stars-line">
        <text class="stars-label">三星</text>
        <view class="stars-bar"><view class="stars-fill" :style="{ width: calcRate(stats.threeStarCount) }"></view></view>
        <text class="stars-count">{{ stats.threeStarCount || 0 }}</text>
      </view>
      <view class="stats-foot">
        <text>匿名评价 {{ stats.anonymousCount || 0 }}</text>
      </view>
    </view>

    <view class="card">
      <view class="stats-header">
        <text class="section">最新评价</text>
        <text class="stats-action" @tap="goReviewPage">更多</text>
      </view>
      <view v-if="!reviewList.length" class="empty-box">
        <text class="empty-text">暂无评价，欢迎参与后留下反馈</text>
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

    <view class="bottom-bar">
      <button class="ghost-btn" @click="goSignup">立即报名</button>
      <button class="primary-btn" @click="goReviewPage">活动评价</button>
    </view>
  </view>
</template>

<script>
import { useActivityDetailApi, useActivityReviewPageApi, useActivityReviewStatsApi } from '../../../api/activity.js';
import cache from '../../../utils/cache.js';

export default {
  name: 'ActivityDetail',
  data() {
    return {
      id: '',
      detail: {},
      stats: {},
      reviewList: []
    };
  },
  async onLoad(query) {
    this.id = query?.id || '';
    if (this.id) {
      await this.loadPageData();
    }
  },
  async onShow() {
    if (this.id) {
      await this.loadReviews();
      await this.loadStats();
    }
  },
  methods: {
    async loadPageData() {
      await Promise.all([this.loadDetail(), this.loadStats(), this.loadReviews()]);
    },
    async loadDetail() {
      try {
        const res = await useActivityDetailApi(this.id);
        this.detail = res.data || {};
      } catch (e) {
        this.detail = {};
      }
    },
    async loadStats() {
      try {
        const res = await useActivityReviewStatsApi(this.id);
        this.stats = res.data || {};
      } catch (e) {
        this.stats = {};
      }
    },
    async loadReviews() {
      try {
        const res = await useActivityReviewPageApi({ activityId: this.id, page: 1, limit: 3 });
        this.reviewList = res.data?.list || [];
      } catch (e) {
        this.reviewList = [];
      }
    },
    goSignup() {
      if (!cache.getToken()) {
        this.toLoginWithTip('报名需要先登录');
        return;
      }
      uni.navigateTo({ url: `/pages/activity/signup/signup?id=${this.id}` });
    },
    goReviewPage() {
      if (!cache.getToken()) {
        this.toLoginWithTip('评价需要先登录');
        return;
      }
      uni.navigateTo({ url: `/pages/activity/review/review?activityId=${this.id}` });
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
    },
    formatDateRange(startTime, endTime) {
      if (!startTime) return '时间待定';
      const start = startTime.replace('T', ' ').slice(0, 16);
      if (!endTime) return start;
      return `${start} - ${endTime.replace('T', ' ').slice(5, 16)}`;
    },
    formatTime(time) {
      return time ? time.replace('T', ' ').slice(0, 16) : '-';
    },
    getSignupStatusText() {
      const now = Date.now();
      const signupStart = this.detail.signupStartTime ? new Date(this.detail.signupStartTime.replace(/-/g, '/')).getTime() : 0;
      const signupEnd = this.detail.signupEndTime ? new Date(this.detail.signupEndTime.replace(/-/g, '/')).getTime() : 0;
      const startTime = this.detail.startTime ? new Date(this.detail.startTime.replace(/-/g, '/')).getTime() : 0;

      if (startTime && now > startTime) return '活动已结束';
      if (signupStart && now < signupStart) return '报名未开始';
      if (signupEnd && now > signupEnd) return '报名已截止';
      if (this.detail.signupLimit && this.detail.signupCount >= this.detail.signupLimit) return '报名已满';
      return '报名进行中';
    },
    buildStars(rating) {
      const count = Number(rating || 0);
      return '★'.repeat(count) + '☆'.repeat(5 - count);
    },
    calcRate(count) {
      const total = Number(this.stats.reviewCount || 0);
      if (!total) return '0%';
      return `${Math.min(100, Math.round((Number(count || 0) / total) * 100))}%`;
    }
  }
};
</script>

<style scoped>
.page { min-height: 100vh; background: #f3f6fb; padding: 24rpx 24rpx 140rpx; }
.hero-card { background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%); border-radius: 24rpx; padding: 30rpx; box-shadow: 0 16rpx 36rpx rgba(15, 23, 42, 0.18); }
.hero-title { display:block; color:#fff; font-size:36rpx; font-weight:700; line-height:1.5; }
.hero-sub { display:block; color:rgba(255,255,255,.78); font-size:22rpx; margin-top:8rpx; }
.hero-tags { display:flex; flex-wrap:wrap; gap:12rpx; margin-top:18rpx; }
.hero-tag { font-size:22rpx; color:#0f766e; background:#ccfbf1; padding:8rpx 16rpx; border-radius:999rpx; }
.hero-tag.light { color:#1e293b; background:rgba(255,255,255,.18); }
.card { background:#fff; border-radius:20rpx; padding:24rpx; margin-top:18rpx; box-shadow: 0 8rpx 24rpx rgba(15, 23, 42, 0.05); }
.section { display:block; color:#111827; font-size:28rpx; font-weight:700; margin-bottom:12rpx; }
.desc { color:#475569; font-size:24rpx; line-height:42rpx; }
.row { display:flex; justify-content:space-between; gap:20rpx; padding:16rpx 0; color:#334155; font-size:24rpx; border-bottom:1rpx solid #eef2f7; }
.row:last-child { border-bottom:none; }
.stats-card { overflow:hidden; }
.stats-header { display:flex; align-items:center; justify-content:space-between; }
.stats-action { color:#00a8e8; font-size:22rpx; }
.stats-top { display:flex; align-items:center; justify-content:space-between; margin-bottom:12rpx; }
.score-value { display:block; color:#111827; font-size:52rpx; font-weight:700; line-height:1.1; }
.score-label { display:block; margin-top:8rpx; color:#64748b; font-size:22rpx; }
.score-summary { display:flex; flex-direction:column; align-items:flex-end; gap:10rpx; }
.summary-item { color:#64748b; font-size:22rpx; }
.stars-line { display:flex; align-items:center; margin-top:14rpx; }
.stars-label { width:72rpx; color:#475569; font-size:22rpx; }
.stars-bar { flex:1; height:14rpx; background:#e2e8f0; border-radius:999rpx; overflow:hidden; }
.stars-fill { height:100%; background:linear-gradient(90deg, #f59e0b 0%, #f97316 100%); border-radius:999rpx; }
.stars-count { width:52rpx; text-align:right; color:#64748b; font-size:22rpx; margin-left:14rpx; }
.stats-foot { margin-top:16rpx; color:#94a3b8; font-size:22rpx; }
.review-item { margin-top:18rpx; padding:18rpx; background:#f8fafc; border-radius:16rpx; }
.review-top { display:flex; align-items:center; justify-content:space-between; }
.review-user { color:#111827; font-size:24rpx; font-weight:600; }
.review-rating { color:#f59e0b; font-size:22rpx; }
.review-content { display:block; margin-top:12rpx; color:#475569; font-size:24rpx; line-height:40rpx; }
.review-time { display:block; margin-top:12rpx; color:#94a3b8; font-size:22rpx; }
.empty-box { padding:24rpx 0 8rpx; text-align:center; }
.empty-text { color:#94a3b8; font-size:24rpx; }
.bottom-bar { position: fixed; left: 0; right: 0; bottom: 0; display:flex; gap:20rpx; padding: 18rpx 24rpx calc(18rpx + env(safe-area-inset-bottom)); background: rgba(255,255,255,.96); box-shadow: 0 -8rpx 24rpx rgba(15, 23, 42, 0.08); }
.ghost-btn, .primary-btn { flex:1; height:88rpx; line-height:88rpx; border-radius:16rpx; font-size:28rpx; }
.ghost-btn { background:#eef2ff; color:#1d4ed8; }
.primary-btn { background:#111827; color:#fff; }
.ghost-btn::after, .primary-btn::after { border:none; }
</style>
