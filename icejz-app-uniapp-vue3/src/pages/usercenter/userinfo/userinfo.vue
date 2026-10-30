<template>
    <view class="userinfo-page">
        <view class="page-bg">
            <view class="bg-orb orb-gold"></view>
            <view class="bg-orb orb-blue"></view>
        </view>

        <view class="hero-card glass-card">
            <view class="hero-header">
                <view>
                    <text class="hero-eyebrow">个人资料</text>
                    <text class="hero-title">完善你的守护档案</text>
                    <text class="hero-desc">点击头像上传照片，使用更直观的方式管理个人信息。</text>
                </view>
            </view>

            <view class="hero-profile">
                <view class="avatar-wrap" @tap="uploadAvatar">
                    <image :src="displayAvatar" class="profile-avatar" mode="aspectFill" />
                    <view class="avatar-badge">
                        <uni-icons type="camera-filled" size="16" color="#ffffff" />
                    </view>
                    <view class="avatar-mask">
                        <text class="avatar-mask-text">点击上传头像</text>
                    </view>
                </view>

                <view class="profile-meta">
                    <text class="profile-name">{{ user.realName || '未设置姓名' }}</text>
                    <text class="profile-sub">{{ user.mobile || '请先完善手机号，方便接收服务通知' }}</text>
                    <view class="profile-tags">
                        <text class="profile-tag">{{ genderLabel }}</text>
                        <text class="profile-tag soft">资料实时同步</text>
                    </view>
                </view>
            </view>
        </view>

        <view class="section-card glass-card">
            <view class="section-head">
                <view>
                    <text class="section-title">基础信息</text>
                    <text class="section-subtitle">点击卡片即可编辑对应内容</text>
                </view>
            </view>

            <view class="info-list">
                <view class="info-item" @tap="navigateToInput('realName')">
                    <view class="info-left">
                        <view class="info-icon dark">
                            <uni-icons type="person-filled" size="18" color="#ffffff" />
                        </view>
                        <view>
                            <text class="info-label">姓名</text>
                            <text class="info-tip">展示你的真实姓名</text>
                        </view>
                    </view>
                    <view class="info-right">
                        <text class="info-value">{{ user.realName || '请填写' }}</text>
                        <uni-icons type="arrowright" size="16" color="#9ca3af" />
                    </view>
                </view>

                <view class="info-item" @tap="navigateToInput('mobile')">
                    <view class="info-left">
                        <view class="info-icon blue">
                            <uni-icons type="phone-filled" size="18" color="#ffffff" />
                        </view>
                        <view>
                            <text class="info-label">手机号</text>
                            <text class="info-tip">用于登录、通知与联系</text>
                        </view>
                    </view>
                    <view class="info-right">
                        <text class="info-value">{{ user.mobile || '请填写' }}</text>
                        <uni-icons type="arrowright" size="16" color="#9ca3af" />
                    </view>
                </view>

                <view class="info-item" @tap="navigateToInput('email')">
                    <view class="info-left">
                        <view class="info-icon violet">
                            <uni-icons type="email-filled" size="18" color="#ffffff" />
                        </view>
                        <view>
                            <text class="info-label">邮箱</text>
                            <text class="info-tip">接收重要通知与消息</text>
                        </view>
                    </view>
                    <view class="info-right">
                        <text class="info-value">{{ user.email || '请填写' }}</text>
                        <uni-icons type="arrowright" size="16" color="#9ca3af" />
                    </view>
                </view>
            </view>
        </view>

        <view class="section-card glass-card">
            <view class="section-head">
                <view>
                    <text class="section-title">性别选择</text>
                    <text class="section-subtitle">插画卡片式选择，更直观也更现代</text>
                </view>
            </view>

            <view class="gender-grid">
                <view
                    v-for="item in genderList"
                    :key="item.value"
                    class="gender-card"
                    :class="[item.theme, { active: Number(user.gender) === item.value }]"
                    @tap="selectGender(item)"
                >
                    <view class="gender-illustration">
                        <view class="avatar-circle"></view>
                        <view class="avatar-head"></view>
                        <view class="avatar-body"></view>
                        <view v-if="item.value === 0" class="avatar-jacket"></view>
                        <view v-if="item.value === 1" class="avatar-hair"></view>
                        <view v-if="item.value === 1" class="avatar-skirt"></view>
                        <view v-if="item.value === 2" class="avatar-neutral-ring"></view>
                    </view>
                    <view class="gender-content">
                        <text class="gender-name">{{ item.label }}</text>
                        <text class="gender-desc">{{ item.desc }}</text>
                    </view>
                    <view class="gender-check">
                        <uni-icons
                            :type="Number(user.gender) === item.value ? 'checkbox-filled' : 'circle'"
                            size="20"
                            :color="Number(user.gender) === item.value ? '#111827' : '#cbd5e1'"
                        />
                    </view>
                </view>
            </view>
        </view>
    </view>
</template>

<script>
import cache from '../../../utils/cache.js';
import * as request from '../../../utils/request.js';
import { useUserInfoApi, useUserInfoSubmitApi, useUserAvatarApi } from '../../../api/user.js';

export default {
    name: 'UserInfo',
    data() {
        return {
            uploadingAvatar: false,
            savingGender: false,
            user: {
                id: '',
                avatar: '',
                realName: '',
                mobile: '',
                email: '',
                gender: 2
            },
            genderList: [
                { label: '男', value: 0, desc: '适用于男性用户档案', theme: 'theme-male' },
                { label: '女', value: 1, desc: '适用于女性用户档案', theme: 'theme-female' },
                { label: '未知', value: 2, desc: '暂不设置或稍后完善', theme: 'theme-neutral' }
            ]
        };
    },
    computed: {
        displayAvatar() {
            return this.user.avatar || '/static/logo.png';
        },
        genderLabel() {
            const current = this.genderList.find(item => item.value === Number(this.user.gender));
            return current ? current.label : '未知';
        }
    },
    async onShow() {
        try {
            const response = await useUserInfoApi();
            const userInfo = response?.data || {};
            this.user = {
                id: userInfo.id || '',
                avatar: userInfo.avatar || '',
                realName: userInfo.realName || '',
                mobile: userInfo.mobile || '',
                email: userInfo.email || '',
                gender: userInfo.gender === undefined || userInfo.gender === null || userInfo.gender === '' ? 2 : Number(userInfo.gender)
            };
            cache.setUserInfo(this.user);
        } catch (error) {
            console.error('load user info error', error);
            uni.showToast({ title: '获取用户信息失败', icon: 'none' });
        }
    },
    methods: {
        async uploadAvatar() {
            if (this.uploadingAvatar) return;
            this.uploadingAvatar = true;
            let loadingShown = false;
            try {
                const tempFilePath = await new Promise((resolve, reject) => {
                    uni.chooseImage({
                        count: 1,
                        sizeType: ['compressed'],
                        sourceType: ['album', 'camera'],
                        success: (res) => resolve((res.tempFilePaths && res.tempFilePaths[0]) || ''),
                        fail: (err) => reject(err)
                    });
                });

                if (!tempFilePath) {
                    throw new Error('未获取到图片');
                }

                uni.showLoading({ title: '上传中...' });
                loadingShown = true;
                const { data } = await request.upload('/sys/file/upload', tempFilePath);
                await useUserAvatarApi({ avatar: data.url });
                this.user.avatar = data.url;
                cache.setUserInfo(this.user);
                uni.showToast({ title: '头像已更新', icon: 'success' });
                // 通知 usercenter 页面刷新
                const pages = getCurrentPages();
                pages.forEach(page => {
                    const vm = page.$vm;
                    if (vm && typeof vm.loadUserInfo === 'function') vm.loadUserInfo();
                });
            } catch (error) {
                if (error && error.errMsg && error.errMsg.includes('cancel')) return;
                console.error('upload avatar error', error);
                uni.showToast({ title: '上传头像失败', icon: 'none' });
            } finally {
                if (loadingShown) {
                    uni.hideLoading();
                }
                this.uploadingAvatar = false;
            }
        },
        navigateToInput(key) {
            uni.navigateTo({ url: `input/input?key=${key}` });
        },
        async selectGender(item) {
            const nextGender = Number(item.value);
            if (this.savingGender || Number(this.user.gender) === nextGender) return;
            this.savingGender = true;
            const prevGender = this.user.gender;
            this.user.gender = nextGender;
            try {
                await useUserInfoSubmitApi(this.user);
                cache.setUserInfo(this.user);
                uni.showToast({ title: `已切换为${item.label}`, icon: 'success' });
                // 通知 usercenter 页面刷新档案数据
                const pages = getCurrentPages();
                pages.forEach(page => {
                    const vm = page.$vm;
                    if (vm && typeof vm.loadMemberSummary === 'function') vm.loadMemberSummary();
                });
            } catch (error) {
                this.user.gender = prevGender;
                console.error('update gender error', error);
                uni.showToast({ title: '更新性别失败', icon: 'none' });
            } finally {
                this.savingGender = false;
            }
        }
    }
};
</script>

<style scoped>
.userinfo-page {
    min-height: 100vh;
    position: relative;
    overflow: hidden;
    padding: 28rpx 24rpx 48rpx;
    background:
        radial-gradient(circle at top left, rgba(250, 204, 21, 0.18) 0%, rgba(250, 204, 21, 0) 28%),
        radial-gradient(circle at top right, rgba(96, 165, 250, 0.16) 0%, rgba(96, 165, 250, 0) 30%),
        linear-gradient(180deg, #f7f8fc 0%, #eef2f7 100%);
}

.page-bg {
    position: absolute;
    inset: 0;
    pointer-events: none;
}

.bg-orb {
    position: absolute;
    border-radius: 50%;
    filter: blur(90rpx);
    opacity: 0.55;
}

.orb-gold {
    width: 320rpx;
    height: 320rpx;
    top: -40rpx;
    left: -60rpx;
    background: rgba(251, 191, 36, 0.28);
}

.orb-blue {
    width: 360rpx;
    height: 360rpx;
    top: 220rpx;
    right: -120rpx;
    background: rgba(96, 165, 250, 0.26);
}

.glass-card {
    position: relative;
    z-index: 1;
    background: rgba(255, 255, 255, 0.88);
    border: 1rpx solid rgba(255, 255, 255, 0.72);
    box-shadow: 0 24rpx 60rpx rgba(15, 23, 42, 0.08);
    backdrop-filter: blur(20rpx);
    -webkit-backdrop-filter: blur(20rpx);
}

.hero-card {
    border-radius: 32rpx;
    padding: 30rpx;
    background: linear-gradient(145deg, rgba(17, 24, 39, 0.96) 0%, rgba(51, 65, 85, 0.92) 100%);
    box-shadow: 0 30rpx 70rpx rgba(15, 23, 42, 0.22);
}

.hero-eyebrow {
    display: block;
    color: rgba(255, 255, 255, 0.72);
    font-size: 22rpx;
    letter-spacing: 4rpx;
}

.hero-title {
    display: block;
    margin-top: 12rpx;
    color: #ffffff;
    font-size: 42rpx;
    font-weight: 700;
}

.hero-desc {
    display: block;
    margin-top: 10rpx;
    color: #cbd5e1;
    font-size: 24rpx;
    line-height: 1.7;
}

.hero-profile {
    margin-top: 28rpx;
    display: flex;
    align-items: center;
    gap: 22rpx;
}

.avatar-wrap {
    position: relative;
    width: 156rpx;
    height: 156rpx;
    flex-shrink: 0;
}

.profile-avatar {
    width: 156rpx;
    height: 156rpx;
    border-radius: 42rpx;
    border: 4rpx solid rgba(255, 255, 255, 0.72);
    box-shadow: 0 18rpx 36rpx rgba(15, 23, 42, 0.24);
    background: rgba(255, 255, 255, 0.12);
}

.avatar-badge {
    position: absolute;
    right: -6rpx;
    bottom: -6rpx;
    width: 52rpx;
    height: 52rpx;
    border-radius: 50%;
    background: linear-gradient(135deg, #3b82f6 0%, #8b5cf6 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    border: 4rpx solid rgba(17, 24, 39, 0.92);
}

.avatar-mask {
    position: absolute;
    inset: 0;
    border-radius: 42rpx;
    background: linear-gradient(180deg, rgba(15, 23, 42, 0) 36%, rgba(15, 23, 42, 0.58) 100%);
    display: flex;
    align-items: flex-end;
    justify-content: center;
    padding-bottom: 18rpx;
}

.avatar-mask-text {
    color: #ffffff;
    font-size: 20rpx;
}

.profile-meta {
    flex: 1;
    min-width: 0;
}

.profile-name {
    display: block;
    color: #ffffff;
    font-size: 38rpx;
    font-weight: 700;
}

.profile-sub {
    display: block;
    margin-top: 10rpx;
    color: #cbd5e1;
    font-size: 24rpx;
    line-height: 1.7;
}

.profile-tags {
    display: flex;
    gap: 12rpx;
    flex-wrap: wrap;
    margin-top: 18rpx;
}

.profile-tag {
    padding: 10rpx 18rpx;
    border-radius: 999rpx;
    background: rgba(255, 255, 255, 0.14);
    color: #ffffff;
    font-size: 20rpx;
}

.profile-tag.soft {
    background: rgba(255, 255, 255, 0.08);
    color: #dbe4f0;
}

.section-card {
    margin-top: 22rpx;
    border-radius: 30rpx;
    padding: 28rpx 24rpx;
}

.section-head {
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.section-title {
    display: block;
    color: #0f172a;
    font-size: 32rpx;
    font-weight: 700;
}

.section-subtitle {
    display: block;
    margin-top: 8rpx;
    color: #94a3b8;
    font-size: 22rpx;
}

.info-list {
    margin-top: 22rpx;
    display: flex;
    flex-direction: column;
    gap: 16rpx;
}

.info-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 16rpx;
    padding: 22rpx 20rpx;
    border-radius: 24rpx;
    background: linear-gradient(180deg, #ffffff 0%, #f8fafc 100%);
    border: 1rpx solid #edf2f7;
}

.info-left,
.info-right {
    display: flex;
    align-items: center;
}

.info-left {
    gap: 16rpx;
    flex: 1;
    min-width: 0;
}

.info-right {
    gap: 12rpx;
    max-width: 52%;
}

.info-icon {
    width: 68rpx;
    height: 68rpx;
    border-radius: 20rpx;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 12rpx 24rpx rgba(15, 23, 42, 0.1);
}

.info-icon.dark {
    background: linear-gradient(135deg, #0f172a 0%, #334155 100%);
}

.info-icon.blue {
    background: linear-gradient(135deg, #00a8e8 0%, #3ec6ff 100%);
}

.info-icon.violet {
    background: linear-gradient(135deg, #7c3aed 0%, #a78bfa 100%);
}

.info-label {
    display: block;
    color: #111827;
    font-size: 28rpx;
    font-weight: 600;
}

.info-tip {
    display: block;
    margin-top: 6rpx;
    color: #94a3b8;
    font-size: 22rpx;
}

.info-value {
    color: #475569;
    font-size: 24rpx;
    text-align: right;
    word-break: break-all;
}

.gender-grid {
    margin-top: 22rpx;
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 16rpx;
}

.gender-card {
    position: relative;
    overflow: hidden;
    border-radius: 28rpx;
    padding: 24rpx 18rpx 20rpx;
    min-height: 320rpx;
    border: 2rpx solid transparent;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    transition: all 0.2s ease;
}

.gender-card.active {
    border-color: rgba(15, 23, 42, 0.12);
    box-shadow: 0 18rpx 38rpx rgba(15, 23, 42, 0.14);
    transform: translateY(-4rpx);
}

.theme-male {
    background: linear-gradient(180deg, #edf6ff 0%, #e8f7fd 100%);
}

.theme-female {
    background: linear-gradient(180deg, #fff1f7 0%, #ffe4ee 100%);
}

.theme-neutral {
    background: linear-gradient(180deg, #f8fafc 0%, #eef2f7 100%);
}

.gender-illustration {
    position: relative;
    height: 170rpx;
}

.avatar-circle {
    position: absolute;
    left: 50%;
    top: 8rpx;
    width: 126rpx;
    height: 126rpx;
    margin-left: -63rpx;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.46);
}

.avatar-head {
    position: absolute;
    left: 50%;
    top: 28rpx;
    width: 56rpx;
    height: 56rpx;
    margin-left: -28rpx;
    border-radius: 50%;
    background: #f6c7a7;
    z-index: 2;
}

.avatar-body {
    position: absolute;
    left: 50%;
    top: 82rpx;
    width: 88rpx;
    height: 72rpx;
    margin-left: -44rpx;
    border-radius: 34rpx 34rpx 24rpx 24rpx;
    background: #ffffff;
    z-index: 1;
}

.avatar-jacket {
    position: absolute;
    left: 50%;
    top: 94rpx;
    width: 94rpx;
    height: 58rpx;
    margin-left: -47rpx;
    border-radius: 28rpx;
    background: linear-gradient(180deg, #00a8e8 0%, #3ec6ff 100%);
    z-index: 3;
}

.avatar-hair {
    position: absolute;
    left: 50%;
    top: 22rpx;
    width: 70rpx;
    height: 70rpx;
    margin-left: -35rpx;
    border-radius: 36rpx 36rpx 28rpx 28rpx;
    background: #8b5e3c;
    z-index: 1;
}

.avatar-skirt {
    position: absolute;
    left: 50%;
    top: 92rpx;
    width: 90rpx;
    height: 66rpx;
    margin-left: -45rpx;
    border-radius: 30rpx 30rpx 22rpx 22rpx;
    background: linear-gradient(180deg, #ec4899 0%, #f9a8d4 100%);
    z-index: 3;
}

.avatar-neutral-ring {
    position: absolute;
    left: 50%;
    top: 20rpx;
    width: 74rpx;
    height: 74rpx;
    margin-left: -37rpx;
    border-radius: 50%;
    border: 8rpx solid #94a3b8;
    border-bottom-color: transparent;
    z-index: 1;
}

.gender-content {
    margin-top: 8rpx;
}

.gender-name {
    display: block;
    color: #111827;
    font-size: 28rpx;
    font-weight: 700;
}

.gender-desc {
    display: block;
    margin-top: 8rpx;
    color: #64748b;
    font-size: 21rpx;
    line-height: 1.6;
}

.gender-check {
    margin-top: 18rpx;
    display: flex;
    justify-content: flex-end;
}
</style>
