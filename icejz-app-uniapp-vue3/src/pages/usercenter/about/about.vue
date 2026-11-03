<template>
    <view class="about-container">
        <view class="hero-card">
            <image src="/static/logo.png" mode="aspectFit" class="logo-image" />
            <text class="about-title">{{ brand.name }}</text>
            <text class="about-subtitle">{{ brand.slogan }}</text>
        </view>

        <view class="about-card">
            <view class="about-section">
                <text class="section-title">系统简介</text>
                <text class="section-text">{{ brand.aboutIntro }}</text>
            </view>

            <view class="about-section">
                <text class="section-title">核心功能</text>
                <view class="feature-row" v-for="item in features" :key="item.title">
                    <view class="feature-dot"></view>
                    <view>
                        <text class="feature-title">{{ item.title }}</text>
                        <text class="section-text">{{ item.desc }}</text>
                    </view>
                </view>
            </view>

            <view class="about-section last">
                <text class="section-title">版本信息</text>
                <text class="section-text">当前版本：v1.0.0</text>
                <text class="section-text">技术底座：ICEJZ</text>
            </view>
        </view>
    </view>
</template>

<script>
import brand from '../../../config/brand.js';

export default {
    name: 'About',
    data() {
        return {
            brand,
            features: [
                { title: '长者档案管理', desc: '基础信息、健康状态与服务记录统一管理。' },
                { title: '服务预约协同', desc: '支持上门照护、康复理疗、健康随访等服务流程。' },
                { title: '订单与提醒', desc: '服务进度可视化，关键节点消息提醒。' },
                { title: '账号与安全', desc: '支持多端登录、权限控制与数据安全管理。' }
            ]
        };
    }
};
</script>

<style scoped>
.about-container {
    min-height: 100vh;
    background:
        radial-gradient(circle at top right, rgba(0, 168, 232, 0.1), transparent 36%),
        #f4f7fb;
    padding: 28rpx 24rpx 48rpx;
}

.hero-card {
    background:
        radial-gradient(circle at 90% 10%, rgba(62, 198, 255, 0.32), transparent 36%),
        linear-gradient(135deg, #121a28 0%, #143047 55%, #0c6f9c 100%);
    border-radius: 28rpx;
    padding: 40rpx 30rpx;
    margin-bottom: 20rpx;
    display: flex;
    flex-direction: column;
    align-items: center;
    box-shadow: 0 16rpx 40rpx rgba(15, 23, 36, 0.16);
}

.logo-image {
    width: 120rpx;
    height: 120rpx;
    border-radius: 28rpx;
    background: rgba(255, 255, 255, 0.12);
    margin-bottom: 18rpx;
}

.about-title {
    color: #fff;
    font-size: 40rpx;
    font-weight: 700;
}

.about-subtitle {
    margin-top: 10rpx;
    color: rgba(255, 255, 255, 0.75);
    font-size: 24rpx;
}

.about-card {
    background: #ffffff;
    border-radius: 24rpx;
    padding: 32rpx 28rpx;
    border: 1rpx solid rgba(232, 238, 245, 0.95);
    box-shadow: 0 8rpx 24rpx rgba(15, 23, 36, 0.04);
}

.about-section {
    margin-bottom: 28rpx;
}

.about-section.last {
    margin-bottom: 0;
}

.section-title {
    display: block;
    font-size: 28rpx;
    font-weight: 700;
    color: #111827;
    margin-bottom: 14rpx;
}

.section-text {
    display: block;
    font-size: 24rpx;
    color: #6b7280;
    line-height: 1.7;
}

.feature-row {
    display: flex;
    gap: 14rpx;
    align-items: flex-start;
    padding: 16rpx;
    margin-bottom: 12rpx;
    border-radius: 16rpx;
    background: linear-gradient(180deg, #f7fbfe, #f2f8fc);
    border: 1rpx solid rgba(0, 168, 232, 0.06);
}

.feature-dot {
    width: 12rpx;
    height: 12rpx;
    border-radius: 50%;
    background: #00a8e8;
    margin-top: 10rpx;
    flex-shrink: 0;
}

.feature-title {
    display: block;
    font-size: 26rpx;
    font-weight: 600;
    color: #111827;
    margin-bottom: 4rpx;
}
</style>
