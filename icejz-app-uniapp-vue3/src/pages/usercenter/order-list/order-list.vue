<template>
  <view class="page">
    <view class="hero-card">
      <text class="hero-title">我的服务订单</text>
      <text class="hero-sub">查看已完成服务，并评价护工服务表现</text>
    </view>

    <view class="tabs">
      <view v-for="tab in tabs" :key="tab.value" class="tab" :class="{ active: status === tab.value }" @tap="switchTab(tab.value)">{{ tab.label }}</view>
    </view>

    <view v-if="orders.length" class="order-list">
      <view v-for="item in orders" :key="item.id" class="order-card">
        <view class="order-head">
          <view>
            <text class="service-name">{{ item.serviceName || '服务订单' }}</text>
            <text class="order-no">{{ item.orderNo }}</text>
          </view>
          <text class="status-tag" :class="`status-${item.status}`">{{ statusLabel(item.status) }}</text>
        </view>
        <view class="info-row"><text>护工</text><text>{{ item.workerName || '待分配' }}</text></view>
        <view class="info-row"><text>老人</text><text>{{ item.elderName || '-' }}</text></view>
        <view class="info-row"><text>服务时间</text><text>{{ item.serviceTime || '-' }}</text></view>
        <view class="info-row"><text>服务地址</text><text>{{ item.address || '-' }}</text></view>
        <view v-if="item.rating" class="review-box">
          <text class="review-stars">{{ '★'.repeat(item.rating) }}</text>
          <text class="review-text">{{ item.review || '已评价' }}</text>
        </view>
        <view class="action-row">
          <button v-if="item.status === 2" class="review-btn" @tap="openReview(item)">评价护工</button>
          <button v-else-if="item.status === 4" class="disabled-btn">已完成评价</button>
        </view>
      </view>
    </view>

    <view v-else class="empty-card">
      <text class="empty-title">暂无服务订单</text>
      <text class="empty-desc">服务完成后会在这里显示，可对护工服务进行评价。</text>
    </view>

    <view v-if="showReview" class="popup-mask" @tap="closeReview">
      <view class="review-popup" @tap.stop>
        <view class="popup-header">
          <text class="popup-title">评价护工服务</text>
          <text class="popup-close" @tap="closeReview">×</text>
        </view>
        <view class="rating-row">
          <text v-for="n in 5" :key="n" class="star" :class="{ active: reviewForm.rating >= n }" @tap="reviewForm.rating = n">★</text>
        </view>
        <textarea v-model="reviewForm.review" class="review-input" maxlength="200" placeholder="请填写对护工服务态度、护理质量等方面的评价" />
        <view class="popup-actions">
          <button class="cancel-btn" @tap="closeReview">取消</button>
          <button class="submit-btn" @tap="submitReview">提交评价</button>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
import { useOrderListApi, useOrderReviewApi } from '../../../api/user.js';

export default {
  data() {
    return {
      status: '',
      orders: [],
      showReview: false,
      activeOrder: null,
      reviewForm: { rating: 5, review: '' },
      tabs: [
        { label: '全部', value: '' },
        { label: '待评价', value: 2 },
        { label: '已评价', value: 4 }
      ]
    };
  },
  onShow() {
    this.loadOrders();
  },
  methods: {
    async loadOrders() {
      try {
        const params = { page: 1, limit: 50 };
        if (this.status !== '') params.status = this.status;
        const res = await useOrderListApi(params);
        this.orders = res?.data?.list || [];
      } catch (e) {
        console.error('load orders error', e);
      }
    },
    switchTab(status) {
      this.status = status;
      this.loadOrders();
    },
    statusLabel(status) {
      return ['待服务', '服务中', '已完成', '已取消', '已评价'][status] || '-';
    },
    openReview(item) {
      this.activeOrder = item;
      this.reviewForm = { rating: 5, review: '' };
      this.showReview = true;
    },
    closeReview() {
      this.showReview = false;
      this.activeOrder = null;
    },
    async submitReview() {
      if (!this.activeOrder?.id) return;
      if (!this.reviewForm.rating) {
        uni.showToast({ title: '请选择评分', icon: 'none' });
        return;
      }
      try {
        await useOrderReviewApi(this.activeOrder.id, this.reviewForm.rating, this.reviewForm.review || '');
        uni.showToast({ title: '评价成功', icon: 'success' });
        this.closeReview();
        this.loadOrders();
      } catch (e) {
        uni.showToast({ title: '评价失败，请稍后重试', icon: 'none' });
      }
    }
  }
};
</script>

<style scoped>
.page { min-height: 100vh; background: #f6f7fb; padding: 24rpx; }
.hero-card { padding: 30rpx; border-radius: 26rpx; background: linear-gradient(135deg, #121a28, #00a8e8); color: #fff; }
.hero-title { display: block; font-size: 38rpx; font-weight: 700; }
.hero-sub { display: block; margin-top: 10rpx; color: #e8f7fd; font-size: 24rpx; }
.tabs { display: flex; gap: 14rpx; margin: 22rpx 0; }
.tab { padding: 14rpx 28rpx; border-radius: 999rpx; background: #fff; color: #64748b; font-size: 24rpx; }
.tab.active { background: #111827; color: #fff; }
.order-list { display: flex; flex-direction: column; gap: 18rpx; }
.order-card, .empty-card { background: #fff; border-radius: 24rpx; padding: 24rpx; box-shadow: 0 12rpx 30rpx rgba(15,23,42,.06); }
.order-head { display: flex; justify-content: space-between; gap: 18rpx; }
.service-name { display: block; color: #111827; font-size: 30rpx; font-weight: 700; }
.order-no { display: block; margin-top: 8rpx; color: #94a3b8; font-size: 20rpx; }
.status-tag { height: 44rpx; line-height: 44rpx; padding: 0 18rpx; border-radius: 999rpx; background: #e0f2fe; color: #0369a1; font-size: 22rpx; white-space: nowrap; }
.status-4 { background: #ecfdf5; color: #047857; }
.info-row { margin-top: 16rpx; display: flex; justify-content: space-between; gap: 20rpx; color: #64748b; font-size: 24rpx; }
.info-row text:last-child { color: #111827; text-align: right; flex: 1; }
.review-box { margin-top: 20rpx; padding: 18rpx; border-radius: 16rpx; background: #fffbeb; }
.review-stars { color: #f59e0b; font-size: 28rpx; }
.review-text { display: block; margin-top: 8rpx; color: #92400e; font-size: 22rpx; }
.action-row { margin-top: 22rpx; }
.review-btn, .disabled-btn { width: 100%; height: 82rpx; line-height: 82rpx; border-radius: 18rpx; border: none; font-size: 28rpx; font-weight: 700; }
.review-btn { background: linear-gradient(135deg, #121a28, #00a8e8); color: #fff; }
.disabled-btn { background: #f1f5f9; color: #94a3b8; }
.review-btn::after, .disabled-btn::after, .cancel-btn::after, .submit-btn::after { border: none; }
.empty-title { display: block; text-align: center; color: #111827; font-size: 30rpx; font-weight: 700; }
.empty-desc { display: block; margin-top: 12rpx; text-align: center; color: #94a3b8; font-size: 24rpx; }
.popup-mask { position: fixed; inset: 0; background: rgba(15,23,42,.48); z-index: 999; display: flex; align-items: flex-end; }
.review-popup { width: 100%; background: #fff; border-radius: 28rpx 28rpx 0 0; padding: 28rpx; }
.popup-header { display: flex; justify-content: space-between; align-items: center; }
.popup-title { color: #111827; font-size: 32rpx; font-weight: 700; }
.popup-close { color: #94a3b8; font-size: 44rpx; }
.rating-row { margin: 28rpx 0; text-align: center; }
.star { color: #cbd5e1; font-size: 58rpx; margin: 0 6rpx; }
.star.active { color: #f59e0b; }
.review-input { width: 100%; min-height: 180rpx; padding: 20rpx; box-sizing: border-box; border-radius: 18rpx; background: #f8fafc; color: #111827; font-size: 26rpx; }
.popup-actions { display: grid; grid-template-columns: repeat(2, 1fr); gap: 16rpx; margin-top: 24rpx; }
.cancel-btn, .submit-btn { height: 84rpx; line-height: 84rpx; border-radius: 18rpx; border: none; font-size: 28rpx; font-weight: 700; }
.cancel-btn { background: #f1f5f9; color: #334155; }
.submit-btn { background: linear-gradient(135deg, #121a28, #00a8e8); color: #fff; }
</style>
