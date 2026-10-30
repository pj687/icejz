<template>
  <view class="page">
    <view class="hero-card">
      <view>
        <text class="title">我的活动</text>
        <text class="sub">集中查看已报名、已签到、待评价、已评价的活动记录</text>
      </view>
      <view class="hero-badge">下拉可刷新</view>
    </view>

    <view class="card stats-card">
      <view class="stats-item accent-blue">
        <text class="stats-value">{{ stats.signedUp }}</text>
        <text class="stats-label">已报名</text>
      </view>
      <view class="stats-item accent-green">
        <text class="stats-value">{{ stats.checkedIn }}</text>
        <text class="stats-label">已签到</text>
      </view>
      <view class="stats-item accent-amber">
        <text class="stats-value">{{ stats.pendingReview }}</text>
        <text class="stats-label">待评价</text>
      </view>
      <view class="stats-item accent-slate">
        <text class="stats-value">{{ stats.reviewed }}</text>
        <text class="stats-label">已评价</text>
      </view>
    </view>

    <view class="card filter-card">
      <view class="tab-row">
        <view
          v-for="item in tabs"
          :key="item.key"
          class="tab-item"
          :class="{ active: activeTab === item.key }"
          @tap="activeTab = item.key"
        >
          <text>{{ item.label }}</text>
          <text class="tab-badge" v-if="getTabCount(item.key) > 0">{{ getTabCount(item.key) }}</text>
        </view>
      </view>
    </view>

    <view class="card list-card">
      <view class="header-row">
        <text class="section">活动记录</text>
        <text class="count-text">共 {{ filteredList.length }} 条</text>
      </view>

      <view v-if="loading" class="empty-box">
        <text class="empty-text">活动记录加载中...</text>
      </view>

      <view v-else-if="!filteredList.length" class="empty-box rich-empty">
        <text class="empty-icon">◎</text>
        <text class="empty-title">当前分类下暂无活动记录</text>
        <text class="empty-desc">你可以返回活动页报名参与，完成签到后即可评价</text>
      </view>

      <view v-else v-for="item in filteredList" :key="item.id" class="activity-item">
        <view class="item-top">
          <view class="item-main" @tap="goDetail(item.activityId)">
            <text class="activity-name">{{ item.activityName || '社区活动' }}</text>
            <text class="activity-time">报名时间：{{ formatTime(item.signupTime) }}</text>
            <text class="activity-time" v-if="item.checkinTime">签到时间：{{ formatTime(item.checkinTime) }}</text>
          </view>
          <view class="status-pill" :class="getStatusClass(item)">{{ getStatusText(item) }}</view>
        </view>

        <view class="tag-row">
          <text class="mini-tag blue" v-if="Number(item.signupStatus) === 1">已报名</text>
          <text class="mini-tag green" v-if="Number(item.checkinStatus) === 1">已签到</text>
          <text class="mini-tag amber" v-if="!item.reviewed && Number(item.checkinStatus) === 1">待评价</text>
          <text class="mini-tag slate" v-if="item.reviewed">已评价</text>
        </view>

        <view class="action-row">
          <text class="link-btn ghost" @tap="goDetail(item.activityId)">活动详情</text>
          <text
            class="link-btn"
            :class="item.reviewed ? 'view-btn' : 'review-btn'"
            @tap="goReview(item.activityId)"
          >
            {{ item.reviewed ? '查看评价' : '去评价' }}
          </text>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
import { useMyActivitySignupPageApi, useMyActivityReviewPageApi } from '../../../api/activity.js';

export default {
  name: 'MyActivity',
  data() {
    return {
      loading: false,
      activeTab: 'all',
      signupList: [],
      reviewMap: {},
      tabs: [
        { key: 'all', label: '全部' },
        { key: 'signedUp', label: '已报名' },
        { key: 'checkedIn', label: '已签到' },
        { key: 'pendingReview', label: '待评价' },
        { key: 'reviewed', label: '已评价' }
      ]
    };
  },
  computed: {
    mergedList() {
      return this.signupList.map((item) => ({
        ...item,
        reviewed: !!this.reviewMap[item.activityId],
        reviewInfo: this.reviewMap[item.activityId] || null
      }));
    },
    filteredList() {
      const list = this.mergedList;
      switch (this.activeTab) {
        case 'signedUp':
          return list.filter((item) => Number(item.signupStatus) === 1);
        case 'checkedIn':
          return list.filter((item) => Number(item.checkinStatus) === 1);
        case 'pendingReview':
          return list.filter((item) => Number(item.checkinStatus) === 1 && !item.reviewed);
        case 'reviewed':
          return list.filter((item) => item.reviewed);
        default:
          return list;
      }
    },
    stats() {
      const list = this.mergedList;
      return {
        signedUp: list.filter((item) => Number(item.signupStatus) === 1).length,
        checkedIn: list.filter((item) => Number(item.checkinStatus) === 1).length,
        pendingReview: list.filter((item) => Number(item.checkinStatus) === 1 && !item.reviewed).length,
        reviewed: list.filter((item) => item.reviewed).length
      };
    }
  },
  onShow() {
    this.loadPageData();
  },
  onPullDownRefresh() {
    this.loadPageData(true);
  },
  methods: {
    async loadPageData(withRefreshTip = false) {
      this.loading = true;
      try {
        const [signupRes, reviewRes] = await Promise.all([
          useMyActivitySignupPageApi({ page: 1, limit: 100 }),
          useMyActivityReviewPageApi({ page: 1, limit: 100 })
        ]);

        this.signupList = (signupRes.data?.list || []).sort((a, b) => {
          const aTime = new Date((a.signupTime || '').replace(/-/g, '/')).getTime() || 0;
          const bTime = new Date((b.signupTime || '').replace(/-/g, '/')).getTime() || 0;
          return bTime - aTime;
        });

        const reviews = reviewRes.data?.list || [];
        this.reviewMap = reviews.reduce((acc, item) => {
          if (item.activityId) {
            acc[item.activityId] = item;
          }
          return acc;
        }, {});

        if (withRefreshTip) {
          uni.showToast({ title: '已刷新', icon: 'none' });
        }
      } catch (e) {
        this.signupList = [];
        this.reviewMap = {};
      } finally {
        this.loading = false;
        uni.stopPullDownRefresh();
      }
    },
    getStatusText(item) {
      if (item.reviewed) return '已评价';
      if (Number(item.checkinStatus) === 1) return '待评价';
      if (Number(item.signupStatus) === 1) return '已报名';
      return '未知状态';
    },
    getStatusClass(item) {
      if (item.reviewed) return 'status-slate';
      if (Number(item.checkinStatus) === 1) return 'status-amber';
      return 'status-blue';
    },
    getTabCount(tabKey) {
      const list = this.mergedList;
      switch (tabKey) {
        case 'signedUp':
          return list.filter((item) => Number(item.signupStatus) === 1).length;
        case 'checkedIn':
          return list.filter((item) => Number(item.checkinStatus) === 1).length;
        case 'pendingReview':
          return list.filter((item) => Number(item.checkinStatus) === 1 && !item.reviewed).length;
        case 'reviewed':
          return list.filter((item) => item.reviewed).length;
        default:
          return list.length;
      }
    },
    formatTime(time) {
      return time ? time.replace('T', ' ').slice(0, 16) : '-';
    },
    goDetail(activityId) {
      if (!activityId) return;
      uni.navigateTo({ url: `/pages/activity/detail/detail?id=${activityId}` });
    },
    goReview(activityId) {
      if (!activityId) return;
      uni.navigateTo({ url: `/pages/activity/review/review?activityId=${activityId}` });
    }
  }
};
</script>

<style scoped>
.page { min-height:100vh; background:linear-gradient(180deg, #f4f7fb 0%, #eef2f7 100%); padding:24rpx; }
.hero-card { background:linear-gradient(135deg, #0f172a 0%, #334155 100%); border-radius:24rpx; padding:30rpx; box-shadow:0 16rpx 36rpx rgba(15,23,42,.14); display:flex; justify-content:space-between; gap:20rpx; }
.title { display:block; color:#fff; font-size:36rpx; font-weight:700; }
.sub { display:block; color:rgba(255,255,255,.78); font-size:22rpx; margin-top:8rpx; line-height:1.6; }
.hero-badge { flex-shrink:0; color:#e8f7fd; background:rgba(255,255,255,.12); border:1rpx solid rgba(255,255,255,.18); border-radius:999rpx; padding:10rpx 18rpx; font-size:20rpx; height:max-content; }
.card { background:#fff; border-radius:22rpx; padding:24rpx; margin-top:18rpx; box-shadow:0 8rpx 24rpx rgba(15,23,42,.05); }
.stats-card { display:grid; grid-template-columns:repeat(2, 1fr); gap:16rpx; }
.stats-item { border-radius:18rpx; padding:22rpx; }
.stats-value { display:block; font-size:40rpx; font-weight:700; color:#0f172a; }
.stats-label { display:block; margin-top:8rpx; font-size:22rpx; color:#475569; }
.accent-blue { background:#eff6ff; }
.accent-green { background:#ecfdf5; }
.accent-amber { background:#fffbeb; }
.accent-slate { background:#f8fafc; }
.tab-row { display:flex; flex-wrap:wrap; gap:16rpx; }
.tab-item { display:flex; align-items:center; gap:10rpx; padding:14rpx 24rpx; border-radius:999rpx; font-size:24rpx; color:#475569; background:#f8fafc; }
.tab-item.active { background:#111827; color:#fff; }
.tab-badge { min-width:34rpx; height:34rpx; line-height:34rpx; text-align:center; padding:0 8rpx; border-radius:999rpx; background:rgba(255,255,255,.18); font-size:20rpx; }
.header-row { display:flex; align-items:center; justify-content:space-between; }
.section { color:#111827; font-size:28rpx; font-weight:700; }
.count-text { color:#94a3b8; font-size:22rpx; }
.activity-item { margin-top:18rpx; padding:22rpx; background:linear-gradient(180deg, #f8fafc 0%, #f1f5f9 100%); border-radius:18rpx; box-shadow: inset 0 0 0 1rpx #eef2f7; }
.item-top { display:flex; justify-content:space-between; gap:18rpx; }
.item-main { flex:1; }
.activity-name { display:block; color:#111827; font-size:28rpx; font-weight:600; line-height:1.5; }
.activity-time { display:block; margin-top:8rpx; color:#64748b; font-size:22rpx; }
.status-pill { padding:8rpx 16rpx; border-radius:999rpx; font-size:22rpx; font-weight:600; height:max-content; }
.status-blue { color:#1d4ed8; background:#e8f7fd; }
.status-amber { color:#b45309; background:#fef3c7; }
.status-slate { color:#475569; background:#e2e8f0; }
.tag-row { display:flex; flex-wrap:wrap; gap:10rpx; margin-top:16rpx; }
.mini-tag { padding:6rpx 12rpx; border-radius:999rpx; font-size:20rpx; }
.mini-tag.blue { color:#1d4ed8; background:#e8f7fd; }
.mini-tag.green { color:#047857; background:#d1fae5; }
.mini-tag.amber { color:#b45309; background:#fef3c7; }
.mini-tag.slate { color:#475569; background:#e2e8f0; }
.action-row { display:flex; justify-content:flex-end; gap:20rpx; margin-top:18rpx; }
.link-btn { font-size:24rpx; padding:12rpx 24rpx; border-radius:999rpx; }
.link-btn.ghost { color:#475569; background:#e2e8f0; }
.review-btn { color:#fff; background:#f59e0b; font-weight:600; }
.view-btn { color:#00a8e8; background:#e8f7fd; font-weight:600; }
.empty-box { padding:36rpx 0 16rpx; text-align:center; }
.rich-empty { padding:44rpx 0 28rpx; }
.empty-icon { display:block; font-size:44rpx; color:#cbd5e1; }
.empty-title { display:block; margin-top:12rpx; color:#475569; font-size:26rpx; font-weight:600; }
.empty-desc { display:block; margin-top:10rpx; color:#94a3b8; font-size:22rpx; }
.empty-text { color:#94a3b8; font-size:24rpx; }
</style>
