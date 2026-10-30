<template>
    <view class="activity-page">
        <view class="banner-card">
            <view>
                <text class="banner-title">社区活动</text>
                <text class="banner-subtitle">丰富长者生活，促进邻里互助与健康管理</text>
            </view>
            <view class="banner-badge">支持下拉刷新</view>
        </view>

        <view class="section-card quick-card">
            <view class="quick-entry with-border" @tap="goMyActivities">
                <view>
                    <text class="quick-title">我的活动</text>
                    <text class="quick-subtitle">集中查看报名、签到、待评价、已评价记录</text>
                </view>
                <text class="quick-arrow">></text>
            </view>
            <view class="quick-entry" @tap="goMyReviews">
                <view>
                    <text class="quick-title">我的活动评价</text>
                    <text class="quick-subtitle">查看已提交的活动评价记录</text>
                </view>
                <text class="quick-arrow">></text>
            </view>
        </view>

        <view class="section-card">
            <view class="section-header">
                <text class="section-title">近期活动</text>
                <text class="section-action" @tap="fetchActivityList(true)">刷新</text>
            </view>

            <view v-if="loading" class="empty-wrap">
                <text class="empty-text">活动加载中...</text>
            </view>

            <view v-else-if="!activityList.length" class="empty-wrap rich-empty">
                <text class="empty-icon">◇</text>
                <text class="empty-title">暂无活动数据</text>
                <text class="empty-desc">稍后下拉刷新，或等待管理员发布新活动</text>
            </view>

            <view v-else v-for="item in activityList" :key="item.id" class="activity-item" @tap="goDetail(item)">
                <view class="activity-main">
                    <text class="activity-name">{{ item.activityName }}</text>
                    <text class="activity-meta">{{ formatDateRange(item.startTime, item.endTime) }}</text>
                    <text class="activity-meta">{{ item.address || '地点待定' }}</text>
                    <text class="activity-meta light">{{ buildCapacityText(item) }}</text>
                </view>
                <view class="right-wrap">
                    <view class="activity-status" :class="getStatusClass(item)">{{ getStatusText(item) }}</view>
                    <text class="detail-link">查看详情 ></text>
                </view>
            </view>
        </view>

        <view class="section-card">
            <view class="section-header">
                <text class="section-title">活动统计</text>
            </view>
            <view class="stats-grid">
                <view class="stats-item">
                    <text class="stats-label">活动总数</text>
                    <text class="stats-value">{{ stats.total }}</text>
                </view>
                <view class="stats-item">
                    <text class="stats-label">报名中</text>
                    <text class="stats-value">{{ stats.signing }}</text>
                </view>
                <view class="stats-item">
                    <text class="stats-label">已结束</text>
                    <text class="stats-value">{{ stats.finished }}</text>
                </view>
            </view>
        </view>
    </view>
</template>

<script>
import { useActivityPageApi } from '../../api/activity.js';

export default {
    name: 'Activity',
    data() {
        return {
            loading: false,
            activityList: []
        };
    },
    computed: {
        stats() {
            return {
                total: this.activityList.length,
                signing: this.activityList.filter((item) => this.getStatusText(item) === '报名中').length,
                finished: this.activityList.filter((item) => this.getStatusText(item) === '已结束').length
            };
        }
    },
    onShow() {
        this.fetchActivityList();
    },
    onPullDownRefresh() {
        this.fetchActivityList(true);
    },
    methods: {
        async fetchActivityList(withRefreshTip = false) {
            this.loading = true;
            try {
                const res = await useActivityPageApi({ page: 1, limit: 50, publishStatus: 1 });
                this.activityList = res.data?.list || [];
                if (withRefreshTip) {
                    uni.showToast({ title: '已刷新', icon: 'none' });
                }
            } catch (e) {
                this.activityList = [];
            } finally {
                this.loading = false;
                uni.stopPullDownRefresh();
            }
        },
        goDetail(item) {
            uni.navigateTo({
                url: `/pages/activity/detail/detail?id=${item.id}`
            });
        },
        goMyActivities() {
            uni.navigateTo({
                url: '/pages/activity/my-activity/my-activity'
            });
        },
        goMyReviews() {
            uni.navigateTo({
                url: '/pages/activity/my-review/my-review'
            });
        },
        getStatusText(item) {
            const now = Date.now();
            const signupStart = item.signupStartTime ? new Date(item.signupStartTime.replace(/-/g, '/')).getTime() : 0;
            const signupEnd = item.signupEndTime ? new Date(item.signupEndTime.replace(/-/g, '/')).getTime() : 0;
            const startTime = item.startTime ? new Date(item.startTime.replace(/-/g, '/')).getTime() : 0;

            if (startTime && now > startTime) {
                return '已结束';
            }
            if (signupStart && now < signupStart) {
                return '未开始';
            }
            if (signupEnd && now > signupEnd) {
                return '报名截止';
            }
            if (item.signupLimit && item.signupCount >= item.signupLimit) {
                return '已满员';
            }
            return '报名中';
        },
        getStatusClass(item) {
            const status = this.getStatusText(item);
            if (status === '报名中') return 'status-open';
            if (status === '未开始') return 'status-ready';
            return 'status-full';
        },
        formatDateRange(startTime, endTime) {
            if (!startTime) {
                return '时间待定';
            }
            const start = startTime.replace('T', ' ').slice(0, 16);
            if (!endTime) {
                return start;
            }
            return `${start} - ${endTime.replace('T', ' ').slice(5, 16)}`;
        },
        buildCapacityText(item) {
            const limit = item.signupLimit || 0;
            const count = item.signupCount || 0;
            if (!limit) {
                return `已报名 ${count} 人`;
            }
            return `已报名 ${count}/${limit} 人`;
        }
    }
};
</script>

<style scoped>
.activity-page {
    min-height: 100vh;
    background: linear-gradient(180deg, #f4f7fb 0%, #eef2f7 100%);
    padding: 24rpx;
}

.banner-card {
    background: linear-gradient(135deg, #111827 0%, #1f2937 100%);
    border-radius: 24rpx;
    padding: 34rpx 30rpx;
    margin-bottom: 22rpx;
    box-shadow: 0 16rpx 36rpx rgba(17, 24, 39, 0.16);
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 20rpx;
}

.banner-title {
    display: block;
    color: #fff;
    font-size: 40rpx;
    font-weight: 700;
}

.banner-subtitle {
    display: block;
    color: rgba(255, 255, 255, 0.78);
    font-size: 24rpx;
    margin-top: 10rpx;
    line-height: 1.6;
}

.banner-badge {
    flex-shrink: 0;
    color: #e8f7fd;
    background: rgba(255, 255, 255, 0.12);
    border: 1rpx solid rgba(255, 255, 255, 0.18);
    border-radius: 999rpx;
    padding: 10rpx 18rpx;
    font-size: 20rpx;
}

.section-card {
    background: rgba(255, 255, 255, 0.96);
    border-radius: 24rpx;
    padding: 24rpx;
    margin-bottom: 20rpx;
    box-shadow: 0 8rpx 24rpx rgba(15, 23, 42, 0.06);
}

.quick-card {
    padding: 0;
    overflow: hidden;
}

.quick-entry {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 26rpx 24rpx;
}

.quick-entry.with-border {
    border-bottom: 1rpx solid #eef2f7;
}

.quick-title {
    display: block;
    color: #111827;
    font-size: 28rpx;
    font-weight: 600;
}

.quick-subtitle {
    display: block;
    margin-top: 8rpx;
    color: #6b7280;
    font-size: 22rpx;
}

.quick-arrow {
    color: #9ca3af;
    font-size: 28rpx;
    font-weight: 700;
}

.section-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.section-title {
    font-size: 30rpx;
    color: #111827;
    font-weight: 700;
}

.section-action {
    font-size: 22rpx;
    color: #00a8e8;
    background: #eff6ff;
    padding: 8rpx 18rpx;
    border-radius: 999rpx;
}

.activity-item {
    margin-top: 18rpx;
    border-radius: 18rpx;
    background: linear-gradient(180deg, #f8fafc 0%, #f1f5f9 100%);
    padding: 22rpx;
    display: flex;
    justify-content: space-between;
    align-items: center;
    box-shadow: inset 0 0 0 1rpx #eef2f7;
}

.activity-main {
    flex: 1;
    margin-right: 16rpx;
}

.activity-name {
    display: block;
    color: #111827;
    font-size: 28rpx;
    font-weight: 600;
    line-height: 1.5;
}

.activity-meta {
    display: block;
    color: #6b7280;
    font-size: 22rpx;
    margin-top: 8rpx;
}

.activity-meta.light {
    color: #94a3b8;
}

.right-wrap {
    display: flex;
    flex-direction: column;
    align-items: flex-end;
}

.activity-status {
    font-size: 22rpx;
    padding: 8rpx 16rpx;
    border-radius: 999rpx;
    font-weight: 600;
}

.detail-link {
    margin-top: 10rpx;
    font-size: 20rpx;
    color: #64748b;
}

.status-open {
    color: #0f766e;
    background: #ccfbf1;
}

.status-ready {
    color: #1d4ed8;
    background: #e8f7fd;
}

.status-full {
    color: #6b7280;
    background: #e5e7eb;
}

.stats-grid {
    margin-top: 16rpx;
    display: flex;
    justify-content: space-between;
}

.stats-item {
    width: 31%;
    background: linear-gradient(180deg, #f8fafc 0%, #f1f5f9 100%);
    border-radius: 16rpx;
    padding: 18rpx 16rpx;
    text-align: center;
}

.stats-label {
    display: block;
    color: #64748b;
    font-size: 22rpx;
}

.stats-value {
    display: block;
    color: #111827;
    font-size: 34rpx;
    font-weight: 700;
    margin-top: 8rpx;
}

.empty-wrap {
    padding: 36rpx 0 20rpx;
    text-align: center;
}

.rich-empty {
    padding: 44rpx 0 28rpx;
}

.empty-icon {
    display: block;
    font-size: 44rpx;
    color: #cbd5e1;
}

.empty-title {
    display: block;
    margin-top: 12rpx;
    color: #475569;
    font-size: 26rpx;
    font-weight: 600;
}

.empty-desc {
    display: block;
    margin-top: 10rpx;
    color: #94a3b8;
    font-size: 22rpx;
}

.empty-text {
    color: #94a3b8;
    font-size: 24rpx;
}
</style>
