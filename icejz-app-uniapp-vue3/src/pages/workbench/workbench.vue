<template>
    <view class="service-page">
        <view class="top-card">
            <view class="top-info">
                <view>
                    <text class="title">服务大厅</text>
                    <text class="subtitle">可预约上门照护、健康管理、社区活动</text>
                </view>
                <view class="user-tag" v-if="isLoggedIn">
                    <text class="user-name">{{ userName }}</text>
                </view>
            </view>
        </view>

        <!-- 快捷服务入口 -->
        <view class="section-card">
            <text class="section-title">快捷服务</text>
            <view class="service-grid">
                <view class="service-item" v-for="item in quickServices" :key="item.id" @tap="onClick(item)">
                    <view class="service-icon" :style="{ background: item.color }">
                        <text class="icon-text">{{ item.icon }}</text>
                    </view>
                    <text class="service-name">{{ item.name }}</text>
                </view>
            </view>
        </view>

        <!-- 推荐服务（来自后端，仅展示可预约服务） -->
        <view class="section-card" v-if="bookableFeaturedServices.length">
            <view class="section-row">
                <text class="section-title">推荐服务</text>
                <text class="section-note">{{ bookableFeaturedServices.length }} 项可预约</text>
            </view>
            <view v-for="item in bookableFeaturedServices" :key="item.id" class="service-list-item" @tap="goServiceDetail(item)">
                <view class="svc-left">
                    <view class="svc-dot" :style="{ background: categoryColor(item.category) }"></view>
                    <view>
                        <text class="svc-name">{{ item.serviceName }}</text>
                        <text class="svc-meta">{{ item.durationMinutes }}分钟 · {{ categoryLabel(item.category) }}</text>
                    </view>
                </view>
                <view class="svc-right">
                    <text class="svc-price">¥{{ item.price }}</text>
                    <text class="svc-btn">预约</text>
                </view>
            </view>
        </view>

        <!-- 我的预约 -->
        <view class="section-card" v-if="isLoggedIn">
            <view class="section-row">
                <text class="section-title">我的预约</text>
            </view>
            <view v-if="bookingList.length === 0" class="empty-tip">暂无预约记录</view>
            <view v-for="item in bookingList" :key="item.id" class="order-item" @tap="goBookingDetail(item)">
                <view>
                    <text class="order-title">{{ item.serviceName }}</text>
                    <text class="order-desc">{{ item.bookingTime }} · {{ item.address || '地址待填写' }}</text>
                </view>
                <text class="order-status" :class="statusClass(item.status)">{{ statusLabel(item.status) }}</text>
            </view>
        </view>

        <!-- 未登录提示 -->
        <view class="section-card login-tip" v-if="!isLoggedIn" @tap="goLogin">
            <text class="login-tip-text">登录后查看我的预约与订单 →</text>
        </view>
    </view>
</template>

<script>
import { useServiceItemListApi, useBookingListApi } from '../../api/user.js';
import cache from '../../utils/cache.js';

export default {
    name: 'Workbench',
    data() {
        return {
            isLoggedIn: false,
            userName: '',
            featuredServices: [],
            bookingList: [],
            quickServices: [
                { id: 1, name: '上门照护', icon: '护', color: '#111827', path: '/pages/services/home-care/home-care' },
                { id: 2, name: '康复理疗', icon: '康', color: '#00a8e8', path: '/pages/services/rehab/rehab' },
                { id: 3, name: '健康监测', icon: '健', color: '#16a34a', path: '/pages/services/health-monitor/health-monitor' },
                { id: 4, name: '活动报名', icon: '活', color: '#9333ea', path: '/pages/activity/activity', isTabBar: true }
            ]
        };
    },
    computed: {
        bookableFeaturedServices() {
            return this.featuredServices
                .filter(item => ['home_care', 'rehab'].includes(item.category) && item.status === 1)
                .slice(0, 4);
        }
    },
    async onShow() {
        const token = cache.getToken();
        const user = cache.getUserInfo() || {};
        this.isLoggedIn = !!token;
        this.userName = user.realName || user.username || '';
        await this.loadData();
    },
    methods: {
        async loadData() {
            try {
                // 服务列表（无需登录）
                const svcRes = await useServiceItemListApi('');
                this.featuredServices = svcRes?.data || [];
            } catch (e) {
                console.error('load services error', e);
            }

            if (!this.isLoggedIn) return;

            try {
                // 我的预约（需要登录）
                const user = cache.getUserInfo() || {};
                const bookRes = await useBookingListApi({ page: 1, limit: 5, elderUserId: user.id });
                this.bookingList = bookRes?.data?.list || [];
            } catch (e) {
                console.error('load bookings error', e);
            }
        },
        onClick(item) {
            if (item.isTabBar) {
                uni.switchTab({ url: item.path });
                return;
            }
            uni.navigateTo({ url: item.path });
        },
        goServiceDetail(item) {
            uni.navigateTo({ url: `/pages/services/home-care/detail/detail?id=${item.id}` });
        },
        goBookingDetail(item) {
            uni.navigateTo({ url: `/pages/services/home-care/booking/booking?id=${item.id}` });
        },
        goAllBookings() {
            uni.navigateTo({ url: '/pages/services/home-care/booking/booking' });
        },
        goLogin() {
            uni.navigateTo({ url: '/pages/login/login' });
        },
        statusLabel(s) {
            return ['待确认', '已确认', '服务中', '已完成', '已取消'][s] || '-';
        },
        statusClass(s) {
            return { 0: 'pending', 1: 'confirmed', 2: 'serving', 3: 'done', 4: 'cancel' }[s] || '';
        },
        categoryLabel(c) {
            return { home_care: '上门照护', rehab: '康复理疗', health: '健康监测', other: '其他' }[c] || c;
        },
        categoryColor(c) {
            return { home_care: '#111827', rehab: '#00a8e8', health: '#16a34a', other: '#0c6f9c' }[c] || '#888';
        }
    }
};
</script>

<style scoped>
.service-page {
  min-height: 100vh;
  background:
    radial-gradient(circle at top right, rgba(0, 168, 232, 0.1), transparent 36%),
    #f4f7fb;
  padding: 24rpx;
}

.top-card {
  background:
    radial-gradient(circle at 90% 10%, rgba(62, 198, 255, 0.3), transparent 36%),
    linear-gradient(135deg, #121a28 0%, #0c6f9c 100%);
  border-radius: 28rpx;
  padding: 34rpx 30rpx;
  margin-bottom: 24rpx;
  box-shadow: 0 16rpx 40rpx rgba(15, 23, 36, 0.16);
}
.top-info { display: flex; justify-content: space-between; align-items: flex-start; }
.title { display: block; color: #fff; font-size: 40rpx; font-weight: 700; }
.subtitle { display: block; color: rgba(255,255,255,0.72); font-size: 24rpx; margin-top: 8rpx; }
.user-tag { background: rgba(255,255,255,0.12); padding: 10rpx 18rpx; border-radius: 999rpx; }
.user-name { color: #fff; font-size: 24rpx; }

.section-card {
  background: #fff;
  border-radius: 24rpx;
  padding: 26rpx;
  margin-bottom: 20rpx;
  border: 1rpx solid rgba(232,238,245,0.95);
  box-shadow: 0 8rpx 24rpx rgba(15,23,36,0.04);
}
.section-title { color: #111827; font-size: 30rpx; font-weight: 700; }
.section-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16rpx; }
.section-note { color: #00a8e8; font-size: 22rpx; }

.service-grid { display: flex; flex-wrap: wrap; margin-top: 16rpx; }
.service-item { width: 25%; display: flex; flex-direction: column; align-items: center; margin-top: 18rpx; }
.service-icon {
  width: 76rpx;
  height: 76rpx;
  border-radius: 24rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8rpx 18rpx rgba(0,168,232,0.16);
}
.icon-text { color: #fff; font-size: 28rpx; font-weight: 700; }
.service-name { margin-top: 10rpx; color: #374151; font-size: 24rpx; }

.service-list-item { display: flex; justify-content: space-between; align-items: center; padding: 18rpx 0; border-bottom: 1rpx solid #eef3f8; }
.service-list-item:last-child { border-bottom: none; }
.svc-left { display: flex; align-items: center; gap: 16rpx; flex: 1; }
.svc-dot { width: 10rpx; height: 10rpx; border-radius: 50%; flex-shrink: 0; }
.svc-name { display: block; color: #111827; font-size: 26rpx; font-weight: 600; }
.svc-meta { display: block; color: #6b7280; font-size: 22rpx; margin-top: 4rpx; }
.svc-right { display: flex; flex-direction: column; align-items: flex-end; gap: 8rpx; }
.svc-price { color: #ef4444; font-size: 26rpx; font-weight: 700; }
.svc-btn { background: #00a8e8; color: #fff; font-size: 22rpx; padding: 8rpx 20rpx; border-radius: 999rpx; box-shadow: 0 6rpx 14rpx rgba(0,168,232,0.25); }

.order-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 16rpx;
  padding: 18rpx;
  border-radius: 16rpx;
  background: linear-gradient(180deg, #f7fbfe, #f2f8fc);
  border: 1rpx solid rgba(0,168,232,0.06);
}
.order-title { display: block; color: #111827; font-size: 26rpx; }
.order-desc { display: block; color: #6b7280; font-size: 22rpx; margin-top: 6rpx; }
.order-status { font-size: 24rpx; font-weight: 600; padding: 6rpx 14rpx; border-radius: 999rpx; }
.order-status.pending { background: #fef3c7; color: #d97706; }
.order-status.confirmed { background: #e8f7fd; color: #00a8e8; }
.order-status.serving { background: #dcfce7; color: #16a34a; }
.order-status.done { background: #f1f5f9; color: #64748b; }
.order-status.cancel { background: #fee2e2; color: #ef4444; }

.empty-tip { color: #9ca3af; font-size: 24rpx; padding: 20rpx 0; text-align: center; }

.login-tip { display: flex; justify-content: center; align-items: center; padding: 32rpx; }
.login-tip-text { color: #00a8e8; font-size: 28rpx; font-weight: 600; }
</style>
