<template>
    <view class="bind-page">
        <view class="page-bg">
            <view class="bg-orb orb-pink"></view>
            <view class="bg-orb orb-cyan"></view>
        </view>

        <view class="bind-card glass-card">
            <text class="bind-eyebrow">绑定老人档案</text>
            <text class="bind-title">手机号 + 验证码绑定</text>
            <text class="bind-desc">输入老人用户手机号，发送验证码后完成验证绑定。当前为模拟发送，验证码会打印到后端控制台。</text>

            <view class="form-card">
                <text class="field-label">老人手机号</text>
                <view class="input-wrap">
                    <uni-icons type="phone-filled" size="18" color="#64748b" />
                    <input v-model="form.mobile" class="field-input" type="number" maxlength="11" placeholder="请输入老人账号手机号" />
                </view>

                <text class="field-label spaced">验证码</text>
                <view class="code-row">
                    <view class="input-wrap code-input-wrap">
                        <uni-icons type="email-filled" size="18" color="#64748b" />
                        <input v-model="form.verifyCode" class="field-input" type="number" maxlength="6" placeholder="请输入6位验证码" />
                    </view>
                    <button class="code-btn" :disabled="countdown > 0 || sendingCode" @tap="sendCode">
                        {{ countdown > 0 ? `${countdown}s后重发` : '发送验证码' }}
                    </button>
                </view>

                <text class="field-label spaced">关系说明</text>
                <view class="relation-grid">
                    <view
                        v-for="item in relationOptions"
                        :key="item"
                        class="relation-chip"
                        :class="{ active: form.relationType === item }"
                        @tap="form.relationType = item"
                    >
                        {{ item }}
                    </view>
                </view>

                <text class="field-label spaced">备注信息</text>
                <view class="textarea-wrap">
                    <textarea v-model="form.remark" maxlength="60" class="field-textarea" placeholder="可选，填写备注信息，便于后续识别" />
                </view>
            </view>

            <view v-if="preview.elderName" class="preview-card">
                <text class="preview-title">待绑定档案</text>
                <text class="preview-main">{{ preview.elderName }}</text>
                <text class="preview-sub">手机号：{{ preview.mobile }}</text>
            </view>

            <button class="submit-btn" :disabled="submitting" @tap="confirmBind">确认绑定</button>
        </view>
    </view>
</template>

<script>
import { useSendElderBindCodeApi, useConfirmElderBindApi } from '../../../api/user.js';

export default {
    name: 'BindElderArchive',
    data() {
        return {
            sendingCode: false,
            submitting: false,
            countdown: 0,
            timer: null,
            form: {
                mobile: '',
                verifyCode: '',
                relationType: '家属',
                remark: ''
            },
            preview: {
                elderName: '',
                mobile: ''
            },
            relationOptions: ['家属', '子女', '配偶', '监护人']
        };
    },
    onUnload() {
        this.clearTimer();
    },
    methods: {
        validateMobile() {
            if (!/^1\d{10}$/.test(this.form.mobile)) {
                uni.showToast({ title: '请输入正确的11位手机号', icon: 'none' });
                return false;
            }
            return true;
        },
        async sendCode() {
            if (this.sendingCode || this.countdown > 0) return;
            if (!this.validateMobile()) return;
            this.sendingCode = true;
            try {
                const response = await useSendElderBindCodeApi({ mobile: this.form.mobile });
                const data = response?.data || {};
                this.preview = {
                    elderName: data.elderName || '老人档案',
                    mobile: data.mobile || this.form.mobile
                };
                uni.showToast({ title: '验证码已发送', icon: 'success' });
                this.startCountdown();
            } catch (error) {
                console.error('send elder bind code error', error);
            } finally {
                this.sendingCode = false;
            }
        },
        startCountdown() {
            this.clearTimer();
            this.countdown = 60;
            this.timer = setInterval(() => {
                if (this.countdown <= 1) {
                    this.clearTimer();
                    return;
                }
                this.countdown -= 1;
            }, 1000);
        },
        clearTimer() {
            if (this.timer) {
                clearInterval(this.timer);
                this.timer = null;
            }
            this.countdown = 0;
        },
        async confirmBind() {
            if (this.submitting) return;
            if (!this.validateMobile()) return;
            if (!/^\d{6}$/.test(this.form.verifyCode)) {
                uni.showToast({ title: '请输入6位验证码', icon: 'none' });
                return;
            }
            this.submitting = true;
            try {
                const response = await useConfirmElderBindApi({
                    mobile: this.form.mobile,
                    verifyCode: this.form.verifyCode,
                    relationType: this.form.relationType,
                    remark: this.form.remark || '来自移动端老人档案绑定'
                });
                const data = response?.data || {};
                uni.showModal({
                    title: '绑定成功',
                    content: `${data.elderName || '老人档案'} 已成功绑定到当前账号`,
                    showCancel: false,
                    success: () => {
                        uni.redirectTo({ url: '/pages/usercenter/elder-archive/list' });
                    }
                });
            } catch (error) {
                console.error('confirm elder bind error', error);
            } finally {
                this.submitting = false;
            }
        }
    }
};
</script>

<style scoped>
.bind-page {
    min-height: 100vh;
    position: relative;
    overflow: hidden;
    padding: 28rpx 24rpx 48rpx;
    background: linear-gradient(180deg, #fff7fb 0%, #f3f7ff 100%);
}

.page-bg {
    position: absolute;
    inset: 0;
    pointer-events: none;
}

.bg-orb {
    position: absolute;
    border-radius: 50%;
    filter: blur(100rpx);
    opacity: 0.55;
}

.orb-pink {
    width: 320rpx;
    height: 320rpx;
    top: -60rpx;
    left: -60rpx;
    background: rgba(244, 114, 182, 0.24);
}

.orb-cyan {
    width: 360rpx;
    height: 360rpx;
    right: -120rpx;
    top: 280rpx;
    background: rgba(34, 211, 238, 0.2);
}

.glass-card {
    position: relative;
    z-index: 1;
    background: rgba(255, 255, 255, 0.9);
    border: 1rpx solid rgba(255, 255, 255, 0.78);
    box-shadow: 0 24rpx 60rpx rgba(15, 23, 42, 0.08);
    backdrop-filter: blur(20rpx);
    -webkit-backdrop-filter: blur(20rpx);
}

.bind-card {
    border-radius: 30rpx;
    padding: 32rpx 28rpx;
}

.bind-eyebrow {
    display: block;
    color: #7c3aed;
    font-size: 22rpx;
    letter-spacing: 4rpx;
}

.bind-title {
    display: block;
    margin-top: 12rpx;
    color: #111827;
    font-size: 40rpx;
    font-weight: 700;
}

.bind-desc {
    display: block;
    margin-top: 12rpx;
    color: #64748b;
    font-size: 24rpx;
    line-height: 1.8;
}

.form-card {
    margin-top: 26rpx;
    padding: 24rpx;
    border-radius: 24rpx;
    background: linear-gradient(180deg, #ffffff 0%, #f8fafc 100%);
    border: 1rpx solid #eef2f7;
}

.field-label {
    display: block;
    color: #0f172a;
    font-size: 26rpx;
    font-weight: 600;
}

.field-label.spaced {
    margin-top: 22rpx;
}

.input-wrap,
.textarea-wrap {
    margin-top: 12rpx;
    display: flex;
    align-items: center;
    gap: 12rpx;
    border-radius: 20rpx;
    background: #ffffff;
    border: 1rpx solid #e2e8f0;
    padding: 0 18rpx;
}

.input-wrap {
    height: 88rpx;
}

.field-input {
    flex: 1;
    height: 88rpx;
    font-size: 28rpx;
    color: #111827;
}

.code-row {
    margin-top: 12rpx;
    display: flex;
    gap: 14rpx;
}

.code-input-wrap {
    flex: 1;
    margin-top: 0;
}

.code-btn,
.submit-btn {
    border: none;
}

.code-btn::after,
.submit-btn::after {
    border: none;
}

.code-btn {
    width: 224rpx;
    height: 88rpx;
    line-height: 88rpx;
    border-radius: 20rpx;
    background: linear-gradient(135deg, #ede9fe 0%, #ddd6fe 100%);
    color: #6d28d9;
    font-size: 24rpx;
    font-weight: 700;
}

.code-btn[disabled] {
    color: #94a3b8;
    background: #e2e8f0;
}

.relation-grid {
    margin-top: 12rpx;
    display: flex;
    flex-wrap: wrap;
    gap: 12rpx;
}

.relation-chip {
    padding: 14rpx 22rpx;
    border-radius: 999rpx;
    background: #f1f5f9;
    color: #475569;
    font-size: 24rpx;
}

.relation-chip.active {
    background: linear-gradient(135deg, #111827 0%, #7c3aed 100%);
    color: #ffffff;
}

.textarea-wrap {
    align-items: flex-start;
    padding: 18rpx;
}

.field-textarea {
    width: 100%;
    min-height: 140rpx;
    font-size: 26rpx;
    color: #111827;
    line-height: 1.7;
}

.preview-card {
    margin-top: 22rpx;
    padding: 24rpx;
    border-radius: 24rpx;
    background: linear-gradient(180deg, #f5f3ff 0%, #ede9fe 100%);
}

.preview-title {
    display: block;
    color: #7c3aed;
    font-size: 22rpx;
}

.preview-main {
    display: block;
    margin-top: 10rpx;
    color: #111827;
    font-size: 32rpx;
    font-weight: 700;
}

.preview-sub {
    display: block;
    margin-top: 8rpx;
    color: #64748b;
    font-size: 22rpx;
}

.submit-btn {
    margin-top: 24rpx;
    width: 100%;
    height: 92rpx;
    line-height: 92rpx;
    border-radius: 22rpx;
    background: linear-gradient(135deg, #121a28 0%, #00a8e8 100%);
    color: #ffffff;
    font-size: 30rpx;
    font-weight: 700;
}

.submit-btn[disabled] {
    background: #cbd5e1;
}
</style>
