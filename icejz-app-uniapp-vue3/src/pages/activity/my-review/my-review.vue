<template>
  <view class="page">
    <view class="hero-card">
      <view>
        <text class="title">我的活动评价</text>
        <text class="sub">查看你已提交的活动评价记录与评分信息</text>
      </view>
      <view class="hero-badge">支持下拉刷新</view>
    </view>

    <view class="card">
      <view class="filter-row">
        <input class="search-input" v-model="activityId" type="number" placeholder="按活动ID筛选（可选）" />
        <text class="search-btn" @tap="reloadList">查询</text>
      </view>
    </view>

    <view class="card">
      <view class="header-row">
        <text class="section">评价记录</text>
        <text class="count-text">共 {{ total }} 条</text>
      </view>
      <view v-if="loading && !reviewList.length" class="empty-box">
        <text class="empty-text">评价记录加载中...</text>
      </view>
      <view v-else-if="!reviewList.length" class="empty-box">
        <text class="empty-text">暂无评价记录</text>
      </view>
      <view v-else v-for="item in reviewList" :key="item.id" class="review-item">
        <view class="review-top">
          <view>
            <text class="review-activity">{{ item.activityName || '社区活动' }}</text>
            <text class="review-time">{{ formatTime(item.reviewTime) }}</text>
          </view>
          <text class="review-rating">{{ buildStars(item.rating) }}</text>
        </view>
        <text class="review-content">{{ item.content || '未填写评价内容' }}</text>
        <view class="review-foot">
          <text class="review-tag">{{ Number(item.anonymousFlag) === 1 ? '匿名评价' : '实名评价' }}</text>
          <text class="review-link" @tap="goActivityReview(item.activityId)">查看活动评价</text>
        </view>
      </view>

      <view v-if="reviewList.length" class="load-more-wrap">
        <text v-if="loadingMore" class="load-more-text">加载中...</text>
        <text v-else-if="finished" class="load-more-text">没有更多了</text>
        <text v-else class="load-more-text action" @tap="loadMore">点击加载更多</text>
      </view>
    </view>
  </view>
</template>

<script>
import { useMyActivityReviewPageApi } from '../../../api/activity.js';

export default {
  name: 'MyActivityReview',
  data() {
    return {
      activityId: '',
      total: 0,
      page: 1,
      limit: 10,
      loading: false,
      loadingMore: false,
      finished: false,
      reviewList: []
    };
  },
  onShow() {
    this.reloadList();
  },
  onPullDownRefresh() {
    this.reloadList(true);
  },
  onReachBottom() {
    this.loadMore();
  },
  methods: {
    buildParams(page) {
      const params = { page, limit: this.limit };
      if (this.activityId) {
        params.activityId = Number(this.activityId);
      }
      return params;
    },
    async reloadList(withToast = false) {
      this.page = 1;
      this.finished = false;
      this.loading = true;
      try {
        const res = await useMyActivityReviewPageApi(this.buildParams(1));
        const list = res.data?.list || [];
        this.reviewList = list;
        this.total = Number(res.data?.total || 0);
        this.finished = list.length < this.limit || this.reviewList.length >= this.total;
        if (withToast) {
          uni.showToast({ title: '已刷新', icon: 'none' });
        }
      } catch (e) {
        this.reviewList = [];
        this.total = 0;
        this.finished = true;
      } finally {
        this.loading = false;
        uni.stopPullDownRefresh();
      }
    },
    async loadMore() {
      if (this.loading || this.loadingMore || this.finished) {
        return;
      }
      this.loadingMore = true;
      try {
        const nextPage = this.page + 1;
        const res = await useMyActivityReviewPageApi(this.buildParams(nextPage));
        const list = res.data?.list || [];
        this.page = nextPage;
        this.reviewList = this.reviewList.concat(list);
        this.total = Number(res.data?.total || this.total || 0);
        this.finished = list.length < this.limit || this.reviewList.length >= this.total;
      } finally {
        this.loadingMore = false;
      }
    },
    buildStars(rating) {
      const count = Number(rating || 0);
      return '★'.repeat(count) + '☆'.repeat(5 - count);
    },
    formatTime(time) {
      return time ? time.replace('T', ' ').slice(0, 16) : '-';
    },
    goActivityReview(activityId) {
      if (!activityId) {
        return;
      }
      uni.navigateTo({ url: `/pages/activity/review/review?activityId=${activityId}` });
    }
  }
};
</script>

<style scoped>
.page { min-height:100vh; background:#f4f7fb; padding:24rpx; }
.hero-card { background: linear-gradient(135deg, #0f172a 0%, #334155 100%); border-radius:24rpx; padding:30rpx; box-shadow:0 16rpx 36rpx rgba(15,23,42,.14); display:flex; justify-content:space-between; gap:20rpx; }
.title { display:block; color:#fff; font-size:36rpx; font-weight:700; }
.sub { display:block; color:rgba(255,255,255,.78); font-size:22rpx; margin-top:8rpx; }
.hero-badge { flex-shrink:0; color:#e8f7fd; background:rgba(255,255,255,.12); border:1rpx solid rgba(255,255,255,.18); border-radius:999rpx; padding:10rpx 18rpx; font-size:20rpx; height:max-content; }
.card { background:#fff; border-radius:20rpx; padding:24rpx; margin-top:18rpx; box-shadow:0 8rpx 24rpx rgba(15,23,42,.05); }
.filter-row { display:flex; align-items:center; gap:16rpx; }
.search-input { flex:1; height:80rpx; background:#f8fafc; border:1rpx solid #e5e7eb; border-radius:14rpx; padding:0 20rpx; font-size:24rpx; }
.search-btn { width:120rpx; height:80rpx; line-height:80rpx; text-align:center; background:#111827; color:#fff; border-radius:14rpx; font-size:24rpx; }
.header-row { display:flex; align-items:center; justify-content:space-between; }
.section { color:#111827; font-size:28rpx; font-weight:700; }
.count-text { color:#94a3b8; font-size:22rpx; }
.review-item { margin-top:18rpx; padding:18rpx; background:#f8fafc; border-radius:16rpx; }
.review-top { display:flex; justify-content:space-between; gap:18rpx; }
.review-activity { display:block; color:#111827; font-size:26rpx; font-weight:600; line-height:1.5; }
.review-time { display:block; margin-top:10rpx; color:#94a3b8; font-size:22rpx; }
.review-rating { color:#f59e0b; font-size:22rpx; }
.review-content { display:block; margin-top:14rpx; color:#475569; font-size:24rpx; line-height:40rpx; }
.review-foot { display:flex; align-items:center; justify-content:space-between; margin-top:14rpx; }
.review-tag { color:#0f766e; background:#ccfbf1; font-size:20rpx; padding:6rpx 12rpx; border-radius:999rpx; }
.review-link { color:#00a8e8; font-size:22rpx; }
.load-more-wrap { padding:24rpx 0 4rpx; text-align:center; }
.load-more-text { color:#94a3b8; font-size:22rpx; }
.load-more-text.action { color:#00a8e8; }
.empty-box { padding:30rpx 0 12rpx; text-align:center; }
.empty-text { color:#94a3b8; font-size:24rpx; }
</style>
