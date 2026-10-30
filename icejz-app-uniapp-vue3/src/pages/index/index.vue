<template>
    <view class="home-page">
        <!-- 顶部 Hero -->
        <view class="hero-card">
            <view class="hero-top">
                <view>
                    <text class="hero-title">朝夕守护</text>
                    <text class="hero-subtitle">{{ greeting }}，{{ displayName }}</text>
                </view>
                <image :src="displayAvatar" class="hero-avatar" mode="aspectFill" />
            </view>
            <view class="hero-tags">
                <text class="hero-tag" v-for="role in roleNames" :key="role">{{ role }}</text>
                <text class="hero-tag accent" v-if="isLoggedIn">已登录</text>
                <text class="hero-tag" v-else @tap="goLogin">点击登录</text>
            </view>
        </view>

        <!-- 未登录引导 -->
        <view class="login-card" v-if="!isLoggedIn" @tap="goLogin">
            <text class="login-card-text">登录后查看个人健康数据、预约记录与档案信息 →</text>
        </view>

        <!-- 老人档案卡 -->
        <view class="section-card" v-if="isLoggedIn && elderArchive">
            <view class="section-header">
                <text class="section-title">长者档案</text>
                <text class="section-link" @tap="goElderArchive">查看详情 ›</text>
            </view>
            <view class="profile-row">
                <image :src="elderArchive.avatar || '/static/logo.png'" class="avatar" mode="aspectFill" />
                <view class="profile-info">
                    <text class="name">{{ elderArchive.realName }}</text>
                    <text class="meta">{{ elderArchive.healthStatus || '健康状态待更新' }}</text>
                </view>
            </view>
            <view class="status-grid">
                <view class="status-item" @tap="goHealthMonitor">
                    <text class="status-label">最新血压</text>
                    <text class="status-value">{{ latestBP }}</text>
                </view>
                <view class="status-item">
                    <text class="status-label">紧急联系人</text>
                    <text class="status-value">{{ familyCount }}人</text>
                </view>
                <view class="status-item" @tap="goBookings">
                    <text class="status-label">待处理预约</text>
                    <text class="status-value">{{ pendingBookings }}项</text>
                </view>
            </view>
        </view>

        <!-- 健康数据快览（老人角色） -->
        <view class="section-card" v-if="isLoggedIn && healthSummary">
            <view class="section-header">
                <text class="section-title">{{ isFamilyRole ? '家属关注的健康概览' : '今日健康' }}</text>
                <text class="section-link" @tap="goHealthMonitor">{{ isFamilyRole ? '查看详情 ›' : '录入数据 ›' }}</text>
            </view>
            <view class="health-grid">
                <view class="health-item" v-for="m in healthMetrics" :key="m.type" @tap="goHealthMonitor">
                    <text class="health-icon">{{ m.icon }}</text>
                    <text class="health-val">{{ m.val }}</text>
                    <text class="health-label">{{ m.label }}</text>
                </view>
            </view>
            <view class="alert-tip" v-if="alertCount > 0" @tap="goAlerts">
                <text class="alert-tip-text">⚠️ {{ alertCount }} 条健康预警待处理</text>
                <text class="alert-tip-arrow">›</text>
            </view>
        </view>

        <!-- 近期预约 -->
        <view class="section-card" v-if="isLoggedIn && bookingList.length">
            <view class="section-header">
                <text class="section-title">近期预约</text>
            </view>
            <view v-for="item in bookingList.slice(0,3)" :key="item.id" class="booking-item" @tap="goBookingDetail(item)">
                <view class="booking-left">
                    <text class="booking-name">{{ item.serviceName }}</text>
                    <text class="booking-time">{{ item.bookingTime ? item.bookingTime.slice(0,16) : '-' }}</text>
                </view>
                <text class="booking-status" :class="statusClass(item.status)">{{ statusLabel(item.status) }}</text>
            </view>
        </view>

        <!-- 系统介绍 -->
        <view class="section-card intro-card">
            <text class="section-title">关于朝夕守护</text>
            <text class="intro-desc">朝夕守护是面向社区老年群体的智慧养老服务平台，整合上门照护、康复理疗、健康监测、活动组织等核心服务，让长者与家属随时掌握健康动态，让服务触手可及。</text>
            <view class="feature-list">
                <view class="feature-item" v-for="f in features" :key="f.title">
                    <text class="feature-icon">{{ f.icon }}</text>
                    <view>
                        <text class="feature-title">{{ f.title }}</text>
                        <text class="feature-desc">{{ f.desc }}</text>
                    </view>
                </view>
            </view>
        </view>
    </view>
</template>

<script>
import cache from '../../utils/cache.js';
import { useUserMemberSummaryApi, useHealthSummaryApi, useHealthAlertListApi, useBookingListApi } from '../../api/user.js';

export default {
    name: 'Index',
    data() {
        return {
            isLoggedIn: false,
            user: {},
            elderArchive: null,
            familyCount: 0,
            healthSummary: null,
            alertCount: 0,
            bookingList: [],
            pendingBookings: 0,
            features: [
                { icon: '🏠', title: '上门照护', desc: '专业护工上门提供生活照料、陪同就医等服务' },
                { icon: '🏃', title: '康复理疗', desc: '个性化康复训练计划，提升长者行动能力' },
                { icon: '❤️', title: '健康监测', desc: '血压、血糖、心率等指标持续记录与预警' },
                { icon: '👨‍👩‍👧', title: '家属协同', desc: '家属实时掌握老人健康动态与服务进展' }
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
                { type: 'blood_pressure', label: '血压', icon: '❤️' },
                { type: 'blood_sugar',    label: '血糖', icon: '🩸' },
                { type: 'heart_rate',     label: '心率', icon: '💓' },
                { type: 'oxygen',         label: '血氧', icon: '🫁' }
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

                // 老人/家属角色加载健康数据
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
        goLogin() { uni.navigateTo({ url: '/pages/login/login' }); },
        goElderArchive() { uni.navigateTo({ url: '/pages/usercenter/elder-archive/list' }); },
        goHealthMonitor() { uni.navigateTo({ url: '/pages/services/health-monitor/health-monitor' }); },
        goAlerts() { uni.navigateTo({ url: '/pages/services/health-monitor/alert/alert' }); },
        goBookings() { uni.navigateTo({ url: '/pages/services/home-care/booking/booking' }); },
        goBookingDetail(item) { uni.navigateTo({ url: `/pages/services/home-care/booking/booking?id=${item.id}` }); },
        statusLabel(s) { return ['待确认','已确认','服务中','已完成','已取消'][s] || '-'; },
        statusClass(s) { return s === 3 ? 'done' : s === 4 ? 'cancel' : s === 0 ? 'pending' : 'active'; }
    }
};
</script>

<style scoped>
.home-page {
  min-height: 100vh;
  background:
    radial-gradient(circle at top right, rgba(0, 168, 232, 0.1), transparent 36%),
    #f4f7fb;
  padding: 24rpx 24rpx 48rpx;
}

.hero-card {
  background:
    radial-gradient(circle at 90% 10%, rgba(62, 198, 255, 0.35), transparent 36%),
    linear-gradient(135deg, #121a28 0%, #143047 55%, #0c6f9c 100%);
  border-radius: 28rpx;
  padding: 34rpx 30rpx;
  margin-bottom: 20rpx;
  box-shadow: 0 16rpx 40rpx rgba(15, 23, 36, 0.16);
}
.hero-top { display:flex; justify-content:space-between; align-items:flex-start; }
.hero-title { display:block; color:#fff; font-size:42rpx; font-weight:700; letter-spacing:1rpx; }
.hero-subtitle { display:block; color:rgba(255,255,255,0.72); font-size:24rpx; margin-top:10rpx; }
.hero-avatar {
  width: 84rpx;
  height: 84rpx;
  border-radius: 42rpx;
  border: 3rpx solid rgba(255,255,255,0.35);
  box-shadow: 0 8rpx 20rpx rgba(0,0,0,0.2);
}
.hero-tags { display:flex; gap:12rpx; margin-top:20rpx; flex-wrap:wrap; }
.hero-tag {
  background: rgba(255,255,255,0.12);
  color:#fff;
  font-size:20rpx;
  padding:8rpx 16rpx;
  border-radius:999rpx;
}
.hero-tag.accent { background:#00a8e8; }

.login-card {
  background:#fff;
  border-radius:20rpx;
  padding:26rpx;
  margin-bottom:20rpx;
  text-align:center;
  border: 1rpx solid rgba(0,168,232,0.12);
  box-shadow: 0 8rpx 24rpx rgba(15,23,36,0.04);
}
.login-card-text { color:#00a8e8; font-size:26rpx; font-weight:600; }

.section-card {
  background:#fff;
  border-radius:24rpx;
  padding:26rpx;
  margin-bottom:20rpx;
  border: 1rpx solid rgba(232,238,245,0.95);
  box-shadow: 0 8rpx 24rpx rgba(15,23,36,0.04);
}
.section-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:18rpx; }
.section-title { color:#111827; font-size:30rpx; font-weight:700; }
.section-link { color:#00a8e8; font-size:22rpx; }

.profile-row { display:flex; align-items:center; gap:18rpx; }
.avatar { width:84rpx; height:84rpx; border-radius:42rpx; }
.name { display:block; color:#111827; font-size:30rpx; font-weight:600; }
.meta { display:block; color:#6b7280; font-size:22rpx; margin-top:6rpx; }
.status-grid { display:flex; justify-content:space-between; margin-top:20rpx; gap:12rpx; }
.status-item {
  flex:1;
  background: linear-gradient(180deg, #f7fbfe, #f2f8fc);
  border: 1rpx solid rgba(0,168,232,0.08);
  border-radius:16rpx;
  padding:16rpx;
  text-align:center;
}
.status-label { display:block; color:#6b7280; font-size:20rpx; }
.status-value { display:block; color:#111827; font-size:28rpx; font-weight:700; margin-top:6rpx; }

.health-grid { display:grid; grid-template-columns:repeat(4,1fr); gap:12rpx; }
.health-item {
  background: linear-gradient(180deg, #f7fbfe, #f2f8fc);
  border-radius:16rpx;
  padding:16rpx 8rpx;
  text-align:center;
}
.health-icon { display:block; font-size:28rpx; }
.health-val { display:block; color:#111827; font-size:24rpx; font-weight:700; margin-top:6rpx; }
.health-label { display:block; color:#9ca3af; font-size:18rpx; margin-top:4rpx; }
.alert-tip {
  display:flex;
  align-items:center;
  justify-content:space-between;
  background:#fff5f5;
  border-radius:14rpx;
  padding:14rpx 16rpx;
  margin-top:16rpx;
}
.alert-tip-text { color:#ef4444; font-size:24rpx; font-weight:600; }
.alert-tip-arrow { color:#ef4444; font-size:28rpx; }

.booking-item { display:flex; justify-content:space-between; align-items:center; padding:16rpx 0; border-bottom:1rpx solid #eef3f8; }
.booking-item:last-child { border-bottom:none; }
.booking-name { display:block; color:#111827; font-size:26rpx; font-weight:600; }
.booking-time { display:block; color:#9ca3af; font-size:20rpx; margin-top:4rpx; }
.booking-status { font-size:22rpx; padding:6rpx 14rpx; border-radius:999rpx; }
.booking-status.pending { background:#fef3c7; color:#d97706; }
.booking-status.active { background:#e8f7fd; color:#00a8e8; }
.booking-status.done { background:#f1f5f9; color:#64748b; }
.booking-status.cancel { background:#fee2e2; color:#ef4444; }

.quick-grid { display:flex; flex-wrap:wrap; margin-top:16rpx; }
.quick-item { width:25%; display:flex; flex-direction:column; align-items:center; margin-top:16rpx; }
.quick-icon {
  width:76rpx;
  height:76rpx;
  border-radius:24rpx;
  display:flex;
  align-items:center;
  justify-content:center;
  box-shadow: 0 8rpx 18rpx rgba(0,168,232,0.18);
}
.quick-icon-text { color:#fff; font-size:28rpx; font-weight:700; }
.quick-name { margin-top:10rpx; color:#374151; font-size:24rpx; }

.intro-desc { display:block; color:#4b5563; font-size:24rpx; line-height:1.8; margin-bottom:20rpx; }
.feature-list { display:flex; flex-direction:column; gap:16rpx; }
.feature-item {
  display:flex;
  align-items:flex-start;
  gap:16rpx;
  padding:18rpx;
  background: linear-gradient(180deg, #f7fbfe, #f2f8fc);
  border-radius:16rpx;
  border: 1rpx solid rgba(0,168,232,0.06);
}
.feature-icon { font-size:36rpx; flex-shrink:0; }
.feature-title { display:block; color:#111827; font-size:26rpx; font-weight:600; }
.feature-desc { display:block; color:#6b7280; font-size:22rpx; margin-top:4rpx; line-height:1.6; }
</style>
