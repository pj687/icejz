<template>
    <view class="input-page">
        <view class="page-bg">
            <view class="bg-orb orb-gold"></view>
            <view class="bg-orb orb-blue"></view>
        </view>

        <view class="hero-card glass-card">
            <text class="hero-eyebrow">资料编辑</text>
            <text class="hero-title">{{ activeField.title }}</text>
            <text class="hero-desc">{{ activeField.desc }}</text>
        </view>

        <view class="editor-card glass-card">
            <view class="field-head">
                <view class="field-icon" :class="activeField.theme">
                    <uni-icons :type="activeField.icon" size="18" color="#ffffff" />
                </view>
                <view class="field-meta">
                    <text class="field-label">{{ activeField.label }}</text>
                    <text class="field-tip">{{ activeField.tip }}</text>
                </view>
            </view>

            <view class="input-shell">
                <input
                    v-model.trim="formValue"
                    :type="activeField.inputType"
                    :maxlength="activeField.maxlength"
                    :placeholder="activeField.placeholder"
                    :cursor-spacing="20"
                    class="field-input"
                    :focus="true"
                    confirm-type="done"
                    @confirm="onSubmit"
                />
            </view>

            <view class="preview-card">
                <view class="compare-row">
                    <view class="compare-item">
                        <text class="preview-label">原值</text>
                        <text class="preview-value">{{ originalValue || activeField.emptyText }}</text>
                    </view>
                    <view class="compare-arrow">
                        <uni-icons type="arrowright" size="16" color="#94a3b8" />
                    </view>
                    <view class="compare-item">
                        <text class="preview-label">新值</text>
                        <text class="preview-value">{{ formValue || activeField.emptyText }}</text>
                    </view>
                </view>
            </view>
        </view>

        <view class="action-bar">
            <button class="save-btn" :loading="saving" @click="onSubmit">保存修改</button>
        </view>
    </view>
</template>

<script>
import cache from '../../../../utils/cache.js';
import { useUserInfoApi, useUserInfoSubmitApi } from '../../../../api/user.js';

const FIELD_MAP = {
    realName: {
        key: 'realName',
        title: '修改姓名',
        label: '姓名',
        desc: '请填写真实姓名，方便服务人员与家属准确识别。',
        tip: '建议填写身份证或常用姓名',
        placeholder: '请输入姓名',
        emptyText: '暂未填写姓名',
        inputType: 'text',
        maxlength: 20,
        icon: 'person-filled',
        theme: 'dark'
    },
    mobile: {
        key: 'mobile',
        title: '修改手机号',
        label: '手机号',
        desc: '手机号将用于登录、通知提醒和服务联系，请确保可正常接收消息。',
        tip: '请输入本人常用手机号',
        placeholder: '请输入手机号',
        emptyText: '暂未填写手机号',
        inputType: 'number',
        maxlength: 11,
        icon: 'phone-filled',
        theme: 'blue'
    },
    email: {
        key: 'email',
        title: '修改邮箱',
        label: '邮箱',
        desc: '邮箱可用于接收重要通知、账号提醒和后续服务消息。',
        tip: '请输入常用邮箱地址',
        placeholder: '请输入邮箱',
        emptyText: '暂未填写邮箱',
        inputType: 'text',
        maxlength: 50,
        icon: 'email-filled',
        theme: 'violet'
    }
};

export default {
    name: 'UserInfoInput',
    data() {
        return {
            fieldKey: 'realName',
            formValue: '',
            originalValue: '',
            saving: false,
            user: {
                realName: '',
                mobile: '',
                email: '',
                gender: 2
            }
        };
    },
    computed: {
        activeField() {
            return FIELD_MAP[this.fieldKey] || FIELD_MAP.realName;
        }
    },
    onLoad(options) {
        const nextKey = options?.key;
        this.fieldKey = FIELD_MAP[nextKey] ? nextKey : 'realName';

        const userInfo = cache.getUserInfo() || {};
        this.user = {
            realName: userInfo.realName || '',
            mobile: userInfo.mobile || '',
            email: userInfo.email || '',
            gender: userInfo.gender ?? 2
        };
        this.formValue = this.user[this.fieldKey] || '';
        this.originalValue = this.formValue;
        uni.setNavigationBarTitle({ title: this.activeField.title });
    },
    methods: {
        validateValue() {
            const value = (this.formValue || '').trim();
            if (this.fieldKey === 'realName') {
                if (!value) {
                    uni.showToast({ title: '姓名不能为空', icon: 'none' });
                    return false;
                }
            }
            if (this.fieldKey === 'mobile') {
                if (!value) {
                    uni.showToast({ title: '手机号不能为空', icon: 'none' });
                    return false;
                }
                if (!/^1[3-9]\d{9}$/.test(value)) {
                    uni.showToast({ title: '手机号格式不正确', icon: 'none' });
                    return false;
                }
            }
            if (this.fieldKey === 'email') {
                if (!value) {
                    uni.showToast({ title: '邮箱不能为空', icon: 'none' });
                    return false;
                }
                if (!/^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/.test(value)) {
                    uni.showToast({ title: '邮箱格式不正确', icon: 'none' });
                    return false;
                }
            }
            return true;
        },
        async onSubmit() {
            if (this.saving) return;
            if (!this.validateValue()) return;

            const value = (this.formValue || '').trim();
            if (value === (this.originalValue || '').trim()) {
                uni.showToast({ title: '内容未发生变化', icon: 'none' });
                return;
            }

            this.saving = true;
            try {
                const payload = {
                    ...this.user,
                    [this.fieldKey]: value
                };
                await useUserInfoSubmitApi(payload);
                const userResponse = await useUserInfoApi();
                const latestUser = userResponse?.data || payload;
                this.user = {
                    ...this.user,
                    ...latestUser
                };
                this.formValue = latestUser[this.fieldKey] || value;
                this.originalValue = latestUser[this.fieldKey] || value;
                cache.setUserInfo({
                    ...cache.getUserInfo(),
                    ...latestUser
                });
                uni.showToast({ title: '保存成功', icon: 'success' });
                const pages = getCurrentPages();
                // 通知页面栈中所有相关页面刷新
                pages.forEach(page => {
                    const vm = page.$vm;
                    if (!vm) return;
                    if (typeof vm.loadUserInfo === 'function') vm.loadUserInfo();
                    if (typeof vm.loadMemberSummary === 'function') vm.loadMemberSummary();
                });
                setTimeout(() => {
                    uni.navigateBack();
                }, 600);
            } catch (error) {
                console.error('update user info error', error);
                uni.showToast({ title: error?.msg || '保存失败', icon: 'none' });
            } finally {
                this.saving = false;
            }
        }
    }
};
</script>

<style scoped>
.input-page {
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
    margin-top: 12rpx;
    color: #cbd5e1;
    font-size: 24rpx;
    line-height: 1.7;
}

.editor-card {
    margin-top: 22rpx;
    border-radius: 30rpx;
    padding: 28rpx 24rpx;
}

.field-head {
    display: flex;
    align-items: center;
    gap: 18rpx;
}

.field-icon {
    width: 72rpx;
    height: 72rpx;
    border-radius: 22rpx;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 12rpx 24rpx rgba(15, 23, 42, 0.1);
}

.field-icon.dark {
    background: linear-gradient(135deg, #0f172a 0%, #334155 100%);
}

.field-icon.blue {
    background: linear-gradient(135deg, #00a8e8 0%, #3ec6ff 100%);
}

.field-icon.violet {
    background: linear-gradient(135deg, #7c3aed 0%, #a78bfa 100%);
}

.field-meta {
    flex: 1;
    min-width: 0;
}

.field-label {
    display: block;
    color: #111827;
    font-size: 30rpx;
    font-weight: 700;
}

.field-tip {
    display: block;
    margin-top: 8rpx;
    color: #94a3b8;
    font-size: 22rpx;
    line-height: 1.6;
}

.input-shell {
    margin-top: 28rpx;
    padding: 0 24rpx;
    height: 108rpx;
    border-radius: 26rpx;
    background: linear-gradient(180deg, #ffffff 0%, #f8fafc 100%);
    border: 1rpx solid #e2e8f0;
    display: flex;
    align-items: center;
    box-shadow: inset 0 1rpx 0 rgba(255, 255, 255, 0.9);
}

.field-input {
    width: 100%;
    font-size: 30rpx;
    color: #0f172a;
}

.preview-card {
    margin-top: 22rpx;
    padding: 24rpx;
    border-radius: 24rpx;
    background: linear-gradient(180deg, #f8fbff 0%, #eef5ff 100%);
}

.compare-row {
    display: flex;
    align-items: center;
    gap: 16rpx;
}

.compare-item {
    flex: 1;
    min-width: 0;
}

.compare-arrow {
    width: 44rpx;
    height: 44rpx;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.78);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}

.preview-label {
    display: block;
    color: #64748b;
    font-size: 22rpx;
}

.preview-value {
    display: block;
    margin-top: 12rpx;
    color: #111827;
    font-size: 28rpx;
    font-weight: 600;
    line-height: 1.7;
    word-break: break-all;
}

.action-bar {
    position: relative;
    z-index: 1;
    margin-top: 28rpx;
}

.save-btn {
    width: 100%;
    height: 92rpx;
    line-height: 92rpx;
    border-radius: 22rpx;
    border: none;
    font-size: 30rpx;
    font-weight: 700;
    color: #ffffff;
    background: linear-gradient(135deg, #111827 0%, #374151 100%);
    box-shadow: 0 18rpx 36rpx rgba(15, 23, 42, 0.16);
}

.save-btn::after {
    border: none;
}
</style>
