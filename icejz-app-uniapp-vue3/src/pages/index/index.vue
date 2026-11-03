<template>
    <view class="home">
        <view class="hero">
            <view class="hero-top">
                <view class="hero-copy">
                    <text class="brand">{{ brand.name }}</text>
                    <text class="slogan">{{ brand.slogan }}</text>
                    <text class="hello">{{ greeting }}，{{ displayName }}</text>
                </view>
                <image :src="displayAvatar" class="avatar" mode="aspectFill" />
            </view>
            <view class="hero-foot">
                <text class="role" v-for="role in roleNames" :key="role">{{ role }}</text>
                <text class="role accent" v-if="isLoggedIn">已登录</text>
                <text class="role" v-else @tap="goLogin">去登录</text>
                <text class="hero-tip">{{ brand.tagline }}</text>
            </view>
        </view>

        <view class="login-cta" v-if="!isLoggedIn" @tap="goLogin">
            <view>
                <text class="cta-title">登录后开始使用</text>
                <text class="cta-desc">查看健康数据、预约记录与档案信息</text>
            </view>
            <text class="cta-arrow">›</text>
        </view>

        <view class="quick-block">
            <view class="section-head">
                <text class="section-title">常用服务</text>
            </view>
            <view class="quick-grid">
                <view class="quick" v-for="item in quickServices" :key="item.name" @tap="onQuick(item)">
                    <view class="quick-icon" :style="{ background: item.color }">{{ item.icon }}</view>
                    <text class="quick-name">{{ item.name }}</text>
                </view>
            </view>
        </view>

        <view class="panel" v-if="isLoggedIn && elderArchive">
            <view class="section-head">
                <text class="section-title">长者档案</text>
                <text class="section-link" @tap="goElderArchive">详情</text>
            </view>
            <view class="elder-row">
                <image :src="elderArchive.avatar || '/static/logo.png'" class="elder-avatar" mode="aspectFill" />
                <view class="elder-info">
                    <text class="elder-name">{{ elderArchive.realName }}</text>
                    <text class="elder-meta">{{ elderArchive.healthStatus || '健康状态待更新' }}</text>
                </view>
            </view>
            <view class="stat-row">
                <view class="stat" @tap="goHealthMonitor">
                    <text class="stat-label">血压</text>
                    <text class="stat-value">{{ latestBP }}</text>
                </view>
                <view class="stat">
                    <text class="stat-label">联系人</text>
                    <text class="stat-value">{{ familyCount }}</text>
                </view>
                <view class="stat" @tap="goBookings">
                    <text class="stat-label">待办预约</text>
                    <text class="stat-value">{{ pendingBookings }}</text>
                </view>
            </view>
        </view>

        <view class="panel" v-if="isLoggedIn && healthSummary">
            <view class="section-head">
                <text class="section-title">{{ isFamilyRole ? '健康关注' : '今日健康' }}</text>
                <text class="section-link" @tap="goHealthMonitor">{{ isFamilyRole ? '详情' : '录入' }}</text>
            </view>
            <view class="health-grid">
                <view class="health" v-for="m in healthMetrics" :key="m.type" @tap="goHealthMonitor">
                    <text class="health-mark">{{ m.icon }}</text>
                    <text class="health-val">{{ m.val }}</text>
                    <text class="health-label">{{ m.label }}</text>
                </view>
            </view>
            <view class="alert" v-if="alertCount > 0" @tap="goAlerts">
                <text class="alert-text">{{ alertCount }} 条健康预警待处理</text>
                <text class="alert-arrow">›</text>
            </view>
        </view>

        <view class="panel" v-if="isLoggedIn && bookingList.length">
            <view class="section-head">
                <text class="section-title">近期预约</text>
            </view>
            <view class="booking" v-for="item in bookingList.slice(0, 3)" :key="item.id" @tap="goBookingDetail(item)">
                <view>
                    <text class="booking-name">{{ item.serviceName }}</text>
                    <text class="booking-time">{{ item.bookingTime ? item.bookingTime.slice(0, 16) : '-' }}</text>
                </view>
                <text class="booking-status" :class="statusClass(item.status)">{{ statusLabel(item.status) }}</text>
            </view>
        </view>

        <view class="story">
            <text class="story-kicker">ABOUT</text>
            <text class="story-title">{{ brand.storyTitle }}</text>
            <text class="story-desc">{{ brand.storyDesc }}</text>
            <view class="story-list">
                <text class="story-item" v-for="f in brand.features" :key="f.title">{{ f.title }} · {{ f.desc }}</text>
            </view>
        </view>
    </view>
</template>

<script>
import cache from '../../utils/cache.js';
import brand from '../../config/brand.js';
import { useUserMemberSummaryApi, useHealthSummaryApi, useHealthAlertListApi, useBookingListApi } from '../../api/user.js';

export default {
    name: 'Index',
    data() {
        return {
            brand,
            isLoggedIn: false,
            user: {},
            elderArchive: null,
            familyCount: 0,
            healthSummary: null,
            alertCount: 0,
            bookingList: [],
            pendingBookings: 0,
            quickServices: [
                { name: '上门照护', icon: '护', color: '#121a28', path: '/pages/services/home-care/home-care' },
                { name: '康复理疗', icon: '康', color: '#00a8e8', path: '/pages/services/rehab/rehab' },
                { name: '健康监测', icon: '健', color: '#0c6f9c', path: '/pages/services/health-monitor/health-monitor' },
                { name: '社区活动', icon: '活', color: '#0ea5e9', path: '/pages/activity/activity', tab: true }
            ]
        };
    },
    computed: {
        displayName() {
            return this.user?.realName || this.user?.username || '朋友';
        },
        displayAvatar() {
            return this.user?.avatar || '/static/logo.png';
        },
        greeting() {
            const h = new Date().getHours();
            if (h < 6) return '夜深了';
            if (h < 12) return '早上好';
            if (h < 14) return '中午好';
            if (h < 18) return '下午好';
            return '晚上好';
        },
        roleNames() {
            const roleIdList = Array.isArray(this.user?.roleIdList) ? this.user.roleIdList : [];
            const map = { 302: '家属', 303: '老人' };
            return roleIdList.map(id => map[id]).filter(Boolean);
        },
        isElderRole() {
            return (this.user?.roleIdList || []).includes(303);
        },
        isFamilyRole() {
            return (this.user?.roleIdList || []).includes(302) && !this.isElderRole;
        },
        latestBP() {
            const bp = this.healthSummary?.blood_pressure;
            if (!bp) return '--';
            return bp.value2 ? `${bp.value1}/${bp.value2}` : `${bp.value1}`;
        },
        healthMetrics() {
            if (!this.healthSummary) return [];
            const configs = [
                { type: 'blood_pressure', label: '血压', icon: '压' },
                { type: 'blood_sugar', label: '血糖', icon: '糖' },
                { type: 'heart_rate', label: '心率', icon: '率' },
                { type: 'oxygen', label: '血氧', icon: '氧' }
            ];
            return configs.map(c => {
                const rec = this.healthSummary[c.type];
                let val = '--';
                if (rec) val = rec.value2 ? `${rec.value1}/${rec.value2}` : `${rec.value1}`;
                return { ...c, val };
            });
        }
    },
    async onShow() {
        const token = cache.getToken();
        this.isLoggedIn = !!token;
        this.user = cache.getUserInfo() || {};
        if (this.isLoggedIn) {
            await this.loadData();
        }
    },
    methods: {
        async loadData() {
            try {
                const [summaryRes, alertRes, bookRes] = await Promise.all([
                    useUserMemberSummaryApi(),
                    useHealthAlertListApi({ status: 0, limit: 5 }),
                    useBookingListApi({ page: 1, limit: 5, elderUserId: this.user.id })
                ]);

                const summary = summaryRes?.data || {};
                this.elderArchive = summary.elderArchive || null;
                this.familyCount = Number(summary.familyBindingCount || 0);
                this.alertCount = alertRes?.data?.total || 0;
                this.bookingList = bookRes?.data?.list || [];
                this.pendingBookings = this.bookingList.filter(b => b.status === 0 || b.status === 1).length;

                if (this.isElderRole) {
                    const healthRes = await useHealthSummaryApi();
                    this.healthSummary = healthRes?.data || null;
                } else if (this.isFamilyRole && summary.elderArchive?.memberUserId) {
                    const healthRes = await useHealthSummaryApi(summary.elderArchive.memberUserId);
                    this.healthSummary = healthRes?.data || null;
                }
            } catch (e) {
                console.error('index loadData error', e);
            }
        },
        onQuick(item) {
            if (item.tab) {
                uni.switchTab({ url: item.path });
                return;
            }
            uni.navigateTo({ url: item.path });
        },
        goLogin() { uni.navigateTo({ url: '/pages/login/login' }); },
        goElderArchive() { uni.navigateTo({ url: '/pages/usercenter/elder-archive/list' }); },
        goHealthMonitor() { uni.navigateTo({ url: '/pages/services/health-monitor/health-monitor' }); },
        goAlerts() { uni.navigateTo({ url: '/pages/services/health-monitor/alert/alert' }); },
        goBookings() { uni.navigateTo({ url: '/pages/services/home-care/booking/booking' }); },
        goBookingDetail(item) { uni.navigateTo({ url: `/pages/services/home-care/booking/booking?id=${item.id}` }); },
        statusLabel(s) { return ['待确认', '已确认', '服务中', '已完成', '已取消'][s] || '-'; },
        statusClass(s) { return s === 3 ? 'done' : s === 4 ? 'cancel' : s === 0 ? 'pending' : 'active'; }
    }
};
</script>

<style scoped>
.home {
  min-height: 100vh;
  padding: 24rpx 24rpx 48rpx;
  background:
    radial-gradient(circle at 100% 0%, rgba(0, 168, 232, 0.12), transparent 40%),
    #eef3f8;
}

.hero {
  padding: 36rpx 30rpx 28rpx;
  border-radius: 32rpx;
  background:
    radial-gradient(circle at 90% 12%, rgba(62, 198, 255, 0.34), transparent 40%),
    linear-gradient(160deg, #101826 0%, #163247 58%, #0b6f9b 100%);
  box-shadow: 0 18rpx 42rpx rgba(16, 24, 38, 0.18);
}

.hero-top {
  display: flex;
  justify-content: space-between;
  gap: 20rpx;
}

.brand {
  display: block;
  color: #fff;
  font-size: 48rpx;
  font-weight: 700;
  letter-spacing: 2rpx;
  line-height: 1.15;
}

.slogan {
  display: block;
  margin-top: 12rpx;
  color: #3ec6ff;
  font-size: 28rpx;
  font-weight: 600;
}

.hello {
  display: block;
  margin-top: 16rpx;
  color: rgba(255, 255, 255, 0.72);
  font-size: 24rpx;
}

.avatar {
  width: 92rpx;
  height: 92rpx;
  border-radius: 46rpx;
  border: 3rpx solid rgba(255, 255, 255, 0.28);
  flex-shrink: 0;
}

.hero-foot {
  margin-top: 24rpx;
  padding-top: 20rpx;
  border-top: 1rpx solid rgba(255, 255, 255, 0.12);
  display: flex;
  flex-wrap: wrap;
  gap: 12rpx;
  align-items: center;
}

.role {
  padding: 8rpx 16rpx;
  border-radius: 999rpx;
  background: rgba(255, 255, 255, 0.12);
  color: #fff;
  font-size: 20rpx;
}

.role.accent {
  background: #00a8e8;
}

.hero-tip {
  width: 100%;
  margin-top: 4rpx;
  color: rgba(255, 255, 255, 0.55);
  font-size: 22rpx;
}

.login-cta {
  margin-top: 18rpx;
  padding: 28rpx 26rpx;
  border-radius: 24rpx;
  background: #fff;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 10rpx 28rpx rgba(15, 23, 36, 0.04);
}

.cta-title {
  display: block;
  color: #111827;
  font-size: 30rpx;
  font-weight: 700;
}

.cta-desc {
  display: block;
  margin-top: 8rpx;
  color: #64748b;
  font-size: 22rpx;
}

.cta-arrow {
  color: #00a8e8;
  font-size: 40rpx;
  font-weight: 700;
}

.quick-block,
.panel,
.story {
  margin-top: 18rpx;
  padding: 28rpx 24rpx;
  border-radius: 28rpx;
  background: #fff;
  box-shadow: 0 10rpx 28rpx rgba(15, 23, 36, 0.04);
}

.section-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;
}

.section-title {
  color: #111827;
  font-size: 30rpx;
  font-weight: 700;
}

.section-link {
  color: #00a8e8;
  font-size: 22rpx;
}

.quick-grid {
  display: flex;
  flex-wrap: wrap;
}

.quick {
  width: 25%;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.quick-icon {
  width: 80rpx;
  height: 80rpx;
  border-radius: 24rpx;
  color: #fff;
  font-size: 28rpx;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 10rpx 20rpx rgba(0, 168, 232, 0.14);
}

.quick-name {
  margin-top: 12rpx;
  color: #374151;
  font-size: 22rpx;
}

.elder-row {
  display: flex;
  align-items: center;
  gap: 18rpx;
}

.elder-avatar {
  width: 80rpx;
  height: 80rpx;
  border-radius: 40rpx;
}

.elder-name {
  display: block;
  color: #111827;
  font-size: 30rpx;
  font-weight: 600;
}

.elder-meta {
  display: block;
  margin-top: 6rpx;
  color: #64748b;
  font-size: 22rpx;
}

.stat-row {
  display: flex;
  gap: 12rpx;
  margin-top: 20rpx;
}

.stat {
  flex: 1;
  padding: 18rpx 12rpx;
  border-radius: 18rpx;
  background: #f4f8fb;
  text-align: center;
}

.stat-label {
  display: block;
  color: #64748b;
  font-size: 20rpx;
}

.stat-value {
  display: block;
  margin-top: 8rpx;
  color: #111827;
  font-size: 30rpx;
  font-weight: 700;
}

.health-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12rpx;
}

.health {
  padding: 16rpx 8rpx;
  border-radius: 18rpx;
  background: #f4f8fb;
  text-align: center;
}

.health-mark {
  display: flex;
  width: 40rpx;
  height: 40rpx;
  margin: 0 auto;
  border-radius: 12rpx;
  background: #00a8e8;
  color: #fff;
  font-size: 20rpx;
  font-weight: 700;
  align-items: center;
  justify-content: center;
}

.health-val {
  display: block;
  margin-top: 10rpx;
  color: #111827;
  font-size: 24rpx;
  font-weight: 700;
}

.health-label {
  display: block;
  margin-top: 4rpx;
  color: #94a3b8;
  font-size: 18rpx;
}

.alert {
  margin-top: 16rpx;
  padding: 16rpx 18rpx;
  border-radius: 16rpx;
  background: #fff5f5;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.alert-text {
  color: #ef4444;
  font-size: 24rpx;
  font-weight: 600;
}

.alert-arrow {
  color: #ef4444;
  font-size: 28rpx;
}

.booking {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 18rpx 0;
  border-top: 1rpx solid #eef2f7;
}

.booking:first-of-type {
  border-top: none;
  padding-top: 0;
}

.booking-name {
  display: block;
  color: #111827;
  font-size: 26rpx;
  font-weight: 600;
}

.booking-time {
  display: block;
  margin-top: 6rpx;
  color: #94a3b8;
  font-size: 20rpx;
}

.booking-status {
  font-size: 22rpx;
  padding: 6rpx 14rpx;
  border-radius: 999rpx;
}

.booking-status.pending { background: #fef3c7; color: #d97706; }
.booking-status.active { background: #e8f7fd; color: #00a8e8; }
.booking-status.done { background: #f1f5f9; color: #64748b; }
.booking-status.cancel { background: #fee2e2; color: #ef4444; }

.story-kicker {
  display: block;
  color: #00a8e8;
  font-size: 18rpx;
  letter-spacing: 3rpx;
}

.story-title {
  display: block;
  margin-top: 12rpx;
  color: #111827;
  font-size: 32rpx;
  font-weight: 700;
  line-height: 1.35;
}

.story-desc {
  display: block;
  margin-top: 12rpx;
  color: #64748b;
  font-size: 24rpx;
  line-height: 1.7;
}

.story-list {
  margin-top: 20rpx;
}

.story-item {
  display: block;
  padding: 16rpx 0;
  border-top: 1rpx solid #eef2f7;
  color: #374151;
  font-size: 24rpx;
  line-height: 1.5;
}

.story-item:first-child {
  border-top: none;
  padding-top: 0;
}
</style>
