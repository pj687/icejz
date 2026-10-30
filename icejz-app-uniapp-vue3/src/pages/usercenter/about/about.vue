<template>
    <view class="about-container">
        <view class="about-card">
            <view class="about-logo">
                <image src="/static/logo.png" mode="aspectFit" class="logo-image" />
            </view>
            <text class="about-title">朝夕守护</text>
            <text class="about-subtitle">ICEJZ · 社区智慧养老服务管理系统</text>

            <view class="about-section">
                <text class="section-title">系统简介</text>
                <text class="section-text">
                    本系统聚焦社区智慧养老场景，面向长者、家属、服务人员与社区管理者，
                    提供统一的服务管理与信息协同能力。基于 ICEJZ 低代码平台构建。
                </text>
            </view>

            <view class="about-section">
                <text class="section-title">核心功能</text>
                <text class="section-text">1. 长者档案管理：基础信息、健康状态与服务记录统一管理。</text>
                <text class="section-text">2. 服务预约协同：支持上门照护、康复理疗、健康随访等服务流程。</text>
                <text class="section-text">3. 订单与提醒：服务进度可视化，关键节点消息提醒。</text>
                <text class="section-text">4. 账号与安全：支持多端登录、权限控制与数据安全管理。</text>
            </view>

            <view class="about-section">
                <text class="section-title">版本信息</text>
                <text class="section-text">当前版本：v1.0.0</text>
                <text class="section-text">技术底座：ICEJZ</text>
            </view>
        </view>
    </view>
</template>

<script>
export default {
    name: 'About'
};
</script>

<style scoped>
.about-container {
    min-height: 100vh;
    background: #f4f7fb;
    padding: 28rpx 24rpx;
}

.about-card {
    background: #ffffff;
    border-radius: 24rpx;
    padding: 40rpx 30rpx;
    box-shadow: 0 8rpx 32rpx rgba(20, 24, 32, 0.06);
}

.about-logo {
    display: flex;
    justify-content: center;
    margin-bottom: 20rpx;
}

.logo-image {
    width: 180rpx;
    height: 180rpx;
    border-radius: 28rpx;
}

.about-title {
    display: block;
    text-align: center;
    font-size: 40rpx;
    color: #1a2332;
    font-weight: 700;
}

.about-subtitle {
    display: block;
    text-align: center;
    margin-top: 10rpx;
    margin-bottom: 26rpx;
    color: #00a8e8;
    font-size: 24rpx;
}

.about-section {
    margin-top: 28rpx;
}

.section-title {
    display: block;
    font-size: 28rpx;
    font-weight: 600;
    color: #1a2332;
    margin-bottom: 12rpx;
}

.section-text {
    display: block;
    font-size: 24rpx;
    color: #6b7280;
    line-height: 1.7;
    margin-bottom: 8rpx;
}
</style>
