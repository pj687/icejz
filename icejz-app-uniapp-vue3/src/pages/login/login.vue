<template>
    <view class="login-container">
        <view class="bg-decoration">
            <view class="blur-orb orb-1"></view>
            <view class="blur-orb orb-2"></view>
        </view>

        <view class="header-section">
            <view class="logo-container">
                <image class="logo-image" src="/static/logo.png" mode="aspectFit" />
            </view>
            <view class="welcome-text">
                <text class="main-title">朝夕守护</text>
                <text class="sub-title">ICEJZ · 社区智慧养老服务</text>
            </view>
        </view>

        <view class="form-container">
            <view class="form-card glass-card">
                <view v-if="!showCompleteProfile" class="login-panel">
                    <view class="login-mode-switch">
                        <view class="mode-pill" :class="{ active: loginMode === 'mobile' }" @tap="loginMode = 'mobile'">手机号登录</view>
                        <view class="mode-pill" :class="{ active: loginMode === 'account' }" @tap="loginMode = 'account'">账号密码登录</view>
                    </view>

                    <view v-if="loginMode === 'mobile'">
                        <view class="panel-title">手机号登录</view>
                        <!-- <view class="panel-desc">首次登录会自动注册，验证码将输出在后端控制台并写入 Redis。</view> -->

                        <view class="input-group">
                            <view class="input-label">
                                <uni-icons type="phone" size="18" color="#9ca3af" />
                                <text class="label-text">手机号</text>
                            </view>
                            <view class="input-wrapper">
                                <input v-model="mobileForm.mobile" name="mobile" placeholder="请输入11位手机号" maxlength="11"
                                    class="form-input" :class="{ 'input-error': inputErrors.mobile }" @input="onPhoneInput" />
                            </view>
                            <view v-if="inputErrors.mobile" class="error-message">
                                <text>{{ inputErrors.mobile }}</text>
                            </view>
                            <view v-else class="hint-message">
                                <text>{{ phoneHint }}</text>
                            </view>
                        </view>

                        <view class="input-group">
                            <view class="input-label">
                                <uni-icons type="compose" size="18" color="#9ca3af" />
                                <text class="label-text">短信验证码</text>
                            </view>
                            <view class="captcha-container">
                                <view class="captcha-input-wrapper">
                                    <input v-model="mobileForm.code" name="code" placeholder="请输入短信验证码" maxlength="6"
                                        class="form-input captcha-input" :class="{ 'input-error': inputErrors.code }" />
                                </view>
                                <button type="default" class="sms-button" :disabled="sms.disabled || isLogging"
                                    @click.stop.prevent="sendCode">
                                    {{ sms.disabled ? `${sms.count}s后重发` : '发送验证码' }}
                                </button>
                            </view>
                            <view v-if="inputErrors.code" class="error-message">
                                <text>{{ inputErrors.code }}</text>
                            </view>
                            <view v-else class="hint-message">
                                <!-- <text>当前为模拟短信登录，请查看后端控制台验证码</text> -->
                            </view>
                        </view>

                        <view class="button-group">
                            <button type="default" @click="onMobileLogin" class="login-button"
                                :class="{ 'button-disabled': !canSubmit }" :disabled="!canSubmit">
                                <view v-if="isLogging" class="loading-spinner"></view>
                                <text>{{ isLogging ? '登录中，请稍候...' : '立即登录' }}</text>
                            </button>
                        </view>
                    </view>

                    <view v-else>
                        <view class="panel-title">账号密码登录</view>
                        <view class="input-group">
                            <view class="input-label">
                                <uni-icons type="person" size="18" color="#9ca3af" />
                                <text class="label-text">账号</text>
                            </view>
                            <view class="input-wrapper">
                                <input v-model="accountForm.username" placeholder="请输入账号" class="form-input" />
                            </view>
                        </view>
                        <view class="input-group">
                            <view class="input-label">
                                <uni-icons type="locked" size="18" color="#9ca3af" />
                                <text class="label-text">密码</text>
                            </view>
                            <view class="input-wrapper">
                                <input v-model="accountForm.password" password placeholder="请输入密码" class="form-input" />
                            </view>
                        </view>
                        <view class="button-group">
                            <button type="default" @click="onAccountLogin" class="login-button" :disabled="isLogging">
                                <view v-if="isLogging" class="loading-spinner"></view>
                                <text>{{ isLogging ? '登录中，请稍候...' : '账号登录' }}</text>
                            </button>
                        </view>
                    </view>
                </view>

                <view v-else class="complete-panel">
                    <view class="complete-header">
                        <text class="complete-title">完善信息</text>
                        <text class="complete-desc">请选择您的身份，并补充资料后进入系统。首次密码默认使用手机号，提交时会通过 SM2 加密传输。</text>
                    </view>

                    <view class="role-section">
                        <view class="input-label">
                            <uni-icons type="staff" size="18" color="#111827" />
                            <text class="label-text">选择身份</text>
                        </view>
                        <view class="role-grid">
                            <view v-for="item in roleOptions" :key="item.value" class="role-card"
                                :class="{ active: completeForm.roleId === item.value }" @tap="selectRole(item.value)">
                                <view class="role-illustration" :class="item.key">
                                    <text class="role-emoji">{{ item.emoji }}</text>
                                </view>
                                <text class="role-name">{{ item.label }}</text>
                                <text class="role-tip">{{ item.tip }}</text>
                            </view>
                        </view>
                        <view v-if="completeErrors.roleId" class="error-message">
                            <text>{{ completeErrors.roleId }}</text>
                        </view>
                    </view>

                    <view class="input-group">
                        <view class="input-label">
                            <uni-icons type="person" size="18" color="#111827" />
                            <text class="label-text">姓名</text>
                        </view>
                        <view class="input-wrapper">
                            <input v-model="completeForm.realName" placeholder="请输入真实姓名" class="form-input"
                                :class="{ 'input-error': completeErrors.realName }" />
                        </view>
                        <view v-if="completeErrors.realName" class="error-message">
                            <text>{{ completeErrors.realName }}</text>
                        </view>
                    </view>

                    <view class="input-group">
                        <view class="input-label">
                            <uni-icons type="phone" size="18" color="#111" />
                            <text class="label-text">手机号</text>
                        </view>
                        <view class="input-wrapper readonly-wrapper">
                            <input :value="completeForm.mobile" disabled class="form-input readonly-input" />
                        </view>
                        <view class="hint-message">
                            <text>首次登录默认密码为当前手机号</text>
                        </view>
                    </view>

                    <view class="input-group">
                        <view class="input-label">
                            <uni-icons type="female" size="18" color="#111827" />
                            <text class="label-text">性别</text>
                        </view>
                        <view class="role-grid gender-grid">
                            <view v-for="item in genderOptions" :key="item.value" class="role-card gender-card"
                                :class="{ active: completeForm.gender === item.value }" @tap="selectGender(item.value)">
                                <view class="role-illustration gender-illustration" :class="item.key">
                                    <text class="role-emoji">{{ item.emoji }}</text>
                                </view>
                                <text class="role-name">{{ item.label }}</text>
                                <text class="role-tip">{{ item.tip }}</text>
                            </view>
                        </view>
                    </view>

                    <view class="button-group complete-actions">
                        <button type="default" class="ghost-button" :disabled="isCompleting" @click="backToLogin">
                            返回登录
                        </button>
                        <button type="default" class="login-button" :disabled="isCompleting" @click="submitCompleteProfile">
                            <view v-if="isCompleting" class="loading-spinner"></view>
                            <text>{{ isCompleting ? '提交中，请稍候...' : '完成并进入系统' }}</text>
                        </button>
                    </view>
                </view>
            </view>
        </view>

        <view class="footer-section">
            <text class="footer-text">© 2026 朝夕守护 · 社区智慧养老服务管理系统</text>
        </view>
    </view>
</template>

<script>
import { sm2Encrypt } from '../../utils/sm2.js';
import cache from '../../utils/cache.js';
import { useSendCodeApi, useMobileLoginApi, useLoginApi, useCompleteProfileApi } from '../../api/auth.js';
import { useUserInfoApi } from '../../api/user.js';

export default {
    name: 'Login',
    computed: {
        canSubmit() {
            if (this.isLogging || this.showCompleteProfile || this.loginMode !== 'mobile') return false;
            return !!this.mobileForm.mobile && !!this.mobileForm.code;
        },
    },
    data() {
        return {
            isLogging: false,
            isCompleting: false,
            showCompleteProfile: false,
            pendingMobileLogin: null,
            loginMode: 'mobile',
            inputErrors: {
                mobile: '',
                code: ''
            },
            completeErrors: {
                realName: '',
                roleId: '',
                gender: ''
            },
            mobileForm: {
                mobile: '',
                code: ''
            },
            accountForm: {
                username: '',
                password: ''
            },
            completeForm: {
                userId: '',
                mobile: '',
                realName: '',
                roleId: null,
                gender: 2,
                orgId: null
            },
            roleOptions: [
                { key: 'elder', label: '老人', value: 303, emoji: '👴', tip: '本人使用，查看服务与档案' },
                { key: 'family', label: '家属', value: 302, emoji: '👨‍👩‍👧', tip: '协助家人，关注照护情况' }
            ],
            genderOptions: [
                { key: 'male', label: '男', value: 0, emoji: '👦', tip: '阳光稳重' },
                { key: 'female', label: '女', value: 1, emoji: '👩', tip: '温柔细致' },
                { key: 'unknown', label: '未知', value: 2, emoji: '🟰', tip: '保持默认' }
            ],
            phoneHint: '请输入11位手机号',
            sms: {
                disabled: false,
                total: 60,
                count: 0,
                timer: null
            }
        };
    },
    methods: {
        onPhoneInput(e) {
            const rawValue = (e?.detail?.value ?? this.mobileForm.mobile ?? '').replace(/\D/g, '').slice(0, 11);
            this.mobileForm.mobile = rawValue;
            this.inputErrors.mobile = '';
            if (!rawValue) return (this.phoneHint = '请输入11位手机号');
            if (rawValue.length < 11) return (this.phoneHint = `还需输入${11 - rawValue.length}位数字`);
            if (!/^1[3-9]\d{9}$/.test(rawValue)) return (this.phoneHint = '手机号格式不正确，请检查后重试');
            this.phoneHint = '手机号格式正确';
        },
        clearInputErrors() {
            this.inputErrors = { mobile: '', code: '' };
        },
        clearCompleteErrors() {
            this.completeErrors = { realName: '', roleId: '', gender: '' };
        },
        setInputError(field, message) {
            this.inputErrors[field] = message;
        },
        setCompleteError(field, message) {
            this.completeErrors[field] = message;
        },
        selectGender(gender) {
            this.completeForm.gender = gender;
            this.completeErrors.gender = '';
        },
        timerHandler() {
            if (this.sms.timer) clearInterval(this.sms.timer);
            this.sms.count = this.sms.total;
            this.sms.disabled = true;
            this.sms.timer = setInterval(() => {
                if (this.sms.count > 1) {
                    this.sms.count -= 1;
                } else {
                    this.sms.disabled = false;
                    clearInterval(this.sms.timer);
                    this.sms.timer = null;
                }
            }, 1000);
        },
        selectRole(roleId) {
            this.completeForm.roleId = roleId;
            this.completeErrors.roleId = '';
        },
        onGenderChange(e) {
            const index = Number(e.detail.value);
            this.completeForm.gender = this.genderOptions[index]?.value ?? 2;
        },
        backToLogin() {
            this.showCompleteProfile = false;
            this.pendingMobileLogin = null;
            this.clearCompleteErrors();
        },
        async sendCode() {
            if (this.sms.disabled || this.isLogging) return;
            if (!/^1[3-9]\d{9}$/.test(this.mobileForm.mobile)) {
                this.setInputError('mobile', '请输入正确的11位手机号');
                return;
            }
            try {
                await useSendCodeApi(this.mobileForm.mobile);
                uni.showToast({ title: '验证码已发送，请注意查收', icon: 'none' });
                this.timerHandler();
            } catch (error) {
                uni.showToast({ title: error?.msg || '发送失败，请稍后重试', icon: 'none' });
            }
        },
        async onMobileLogin() {
            if (this.isLogging) return;
            this.clearInputErrors();

            if (!/^1[3-9]\d{9}$/.test(this.mobileForm.mobile)) {
                this.setInputError('mobile', '请输入正确的11位手机号');
                return;
            }
            if (!this.mobileForm.code) {
                this.setInputError('code', '请输入短信验证码');
                return;
            }

            try {
                this.isLogging = true;
                const response = await useMobileLoginApi({
                    mobile: this.mobileForm.mobile,
                    code: this.mobileForm.code
                });
                await this.handleMobileLoginResult(response);
            } catch (error) {
                uni.showToast({ title: error?.msg || '登录失败，请检查网络连接', icon: 'none' });
            } finally {
                this.isLogging = false;
            }
        },
        async onAccountLogin() {
            if (this.isLogging) return;
            if (!this.accountForm.username || !this.accountForm.password) {
                uni.showToast({ title: '请输入账号和密码', icon: 'none' });
                return;
            }
            try {
                this.isLogging = true;
                const response = await useLoginApi({
                    username: this.accountForm.username,
                    password: await sm2Encrypt(this.accountForm.password)
                });
                await this.handleAccountLoginResult(response);
            } catch (error) {
                uni.showToast({ title: error?.msg || '账号登录失败', icon: 'none' });
            } finally {
                this.isLogging = false;
            }
        },
        async handleMobileLoginResult(response) {
            if (!(response && response.code === 0)) {
                throw response || new Error('登录失败');
            }

            const result = response.data || {};
            if (result.needCompleteProfile) {
                this.pendingMobileLogin = result;
                this.completeForm.userId = result.userId;
                this.completeForm.mobile = result.mobile || this.mobileForm.mobile;
                this.completeForm.realName = '';
                this.completeForm.roleId = Array.isArray(result.roleIdList) && result.roleIdList.length ? result.roleIdList[0] : null;
                this.completeForm.gender = 2;
                this.completeErrors.gender = '';
                this.completeForm.orgId = null;
                this.showCompleteProfile = true;
                this.clearCompleteErrors();
                uni.showToast({ title: result.firstLogin ? '首次登录，请完善信息' : '请完善信息后继续', icon: 'none' });
                return;
            }

            await this.handleLoginSuccess({ code: 0, data: result });
        },
        async handleAccountLoginResult(response) {
            if (!(response && response.code === 0)) {
                throw response || new Error('登录失败');
            }
            await this.handleLoginSuccess(response);
        },
        async submitCompleteProfile() {
            if (this.isCompleting) return;
            this.clearCompleteErrors();

            if (!this.completeForm.realName) {
                this.setCompleteError('realName', '请输入真实姓名');
                return;
            }
            if (!this.completeForm.roleId) {
                this.setCompleteError('roleId', '请选择身份角色');
                return;
            }

            try {
                this.isCompleting = true;
                const response = await useCompleteProfileApi({
                    userId: this.completeForm.userId,
                    roleId: this.completeForm.roleId,
                    realName: this.completeForm.realName,
                    gender: this.completeForm.gender,
                    mobile: this.completeForm.mobile,
                    orgId: this.completeForm.orgId,
                    password: await sm2Encrypt(this.completeForm.mobile)
                });
                await this.handleLoginSuccess(response);
            } catch (error) {
                uni.showToast({ title: error?.msg || '提交失败，请稍后重试', icon: 'none' });
            } finally {
                this.isCompleting = false;
            }
        },
        async handleLoginSuccess(response) {
            if (response && response.code === 0) {
                const tokenData = response.data || {};
                const accessToken = tokenData.access_token || tokenData.accessToken || tokenData.token || tokenData;
                if (!accessToken || typeof accessToken !== 'string') {
                    throw new Error('登录令牌为空');
                }
                cache.setToken(accessToken);
                const userResponse = await useUserInfoApi();
                if (userResponse && userResponse.code === 0) cache.setUserInfo(userResponse.data);
                this.showCompleteProfile = false;
                uni.showToast({ title: '登录成功', icon: 'success' });
                setTimeout(() => uni.switchTab({ url: '/pages/index/index' }), 1200);
                return;
            }
            throw response || new Error('登录失败');
        }
    },
    onUnload() {
        if (this.sms.timer) {
            clearInterval(this.sms.timer);
            this.sms.timer = null;
        }
    }
};
</script>

<style scoped>
.login-container {
    min-height: 100vh;
    background: radial-gradient(circle at 18% 12%, #1a2332 0%, #141820 40%, #0f1724 100%);
    color: #ffffff;
    display: flex;
    flex-direction: column;
    position: relative;
    overflow: hidden;
}

.bg-decoration {
    position: absolute;
    inset: 0;
    pointer-events: none;
}

.blur-orb {
    position: absolute;
    border-radius: 50%;
    filter: blur(60rpx);
    opacity: 0.3;
    background: #ffffff;
}

.orb-1 {
    width: 280rpx;
    height: 280rpx;
    top: 120rpx;
    left: -60rpx;
}

.orb-2 {
    width: 320rpx;
    height: 320rpx;
    right: -100rpx;
    bottom: 220rpx;
}

.header-section {
    padding: 110rpx 60rpx 60rpx;
    text-align: center;
    z-index: 1;
}

.logo-container {
    margin-bottom: 28rpx;
}

.logo-image {
    width: 210rpx;
    height: 210rpx;
}

.main-title {
    display: block;
    font-size: 48rpx;
    font-weight: 700;
    color: #ffffff;
    margin-bottom: 10rpx;
}

.sub-title {
    display: block;
    font-size: 26rpx;
    color: #d8d8d8;
}

.form-container {
    flex: 1;
    padding: 0 48rpx;
    z-index: 1;
    
}

.form-card {
    border-radius: 28rpx;
    padding: 40rpx 32rpx;
}

.glass-card {
    background: rgba(255, 255, 255, 0.1);
    border: 1rpx solid rgba(255, 255, 255, 0.18);
    backdrop-filter: blur(18rpx);
    -webkit-backdrop-filter: blur(18rpx);
    box-shadow: 0 18rpx 42rpx rgba(0, 0, 0, 0.34);
}

.login-panel {
    color: #e5e7eb;
}

.login-mode-switch {
    display: flex;
    gap: 14rpx;
    margin-bottom: 24rpx;
}

.mode-pill {
    flex: 1;
    text-align: center;
    padding: 16rpx 0;
    border-radius: 999rpx;
    background: rgba(255, 255, 255, 0.08);
    color: #cbd5e1;
    font-size: 24rpx;
    font-weight: 600;
}

.mode-pill.active {
    background: rgba(0, 168, 232, 0.35);
    color: #ffffff;
    box-shadow: 0 0 0 1rpx rgba(62, 198, 255, 0.45);
}

.login-panel .panel-title {
    display: block;
    font-size: 36rpx;
    font-weight: 700;
    margin-bottom: 20rpx;
    color: #f3f4f6;
}

.login-panel .input-label .label-text {
    color: #d1d5db;
}

.login-panel .form-input,
.login-panel .picker-input {
    border: 1rpx solid rgba(255, 255, 255, 0.12);
    background: rgba(255, 255, 255, 0.08);
    color: #f3f4f6;
}

.login-panel .form-input::placeholder {
    color: #9ca3af;
}

.login-panel .input-error {
    border-color: rgba(248, 113, 113, 0.75) !important;
    background: rgba(127, 29, 29, 0.12);
}

.login-panel .error-message text {
    color: #fca5a5;
}

.login-panel .hint-message text {
    color: #9ca3af;
}

.login-panel .sms-button {
    border: 1rpx solid rgba(255, 255, 255, 0.12);
    background: rgba(255, 255, 255, 0.1);
    color: #e5e7eb;
}

.login-panel .login-button {
    border: 1rpx solid rgba(255, 255, 255, 0.1) !important;
    background: rgba(255, 255, 255, 0.14) !important;
    color: #f9fafb !important;
    box-shadow: none;
}

.login-panel .login-button.button-disabled,
.login-panel .login-button[disabled] {
    opacity: 0.5;
}

.complete-panel {
    background: linear-gradient(180deg, #fffaf1 0%, #fff7eb 100%);
    color: #1b1f24;
    border-radius: 28rpx;
    padding: 36rpx 32rpx 32rpx;
    box-shadow: 0 24rpx 60rpx rgba(0, 0, 0, 0.16);
    border: 1rpx solid rgba(245, 203, 141, 0.38);
}

.complete-panel .panel-title,
.complete-panel .complete-title {
    display: block;
    font-size: 36rpx;
    font-weight: 700;
    margin-bottom: 12rpx;
    color: #111827;
}

.complete-panel .panel-desc,
.complete-panel .complete-desc {
    display: block;
    font-size: 24rpx;
    color: #6b7280;
    line-height: 1.7;
    margin-bottom: 34rpx;
}

.input-group,
.role-section {
    margin-bottom: 30rpx;
}

.input-label {
    display: flex;
    align-items: center;
    margin-bottom: 12rpx;
}

.label-text {
    margin-left: 10rpx;
    color: #111827;
    font-size: 28rpx;
}

.form-input,
.picker-input {
    width: 100%;
    height: 92rpx;
    border: 1rpx solid #e5e7eb;
    border-radius: 14rpx;
    padding: 0 22rpx;
    font-size: 30rpx;
    color: #111827;
    box-sizing: border-box;
    background: #f9fafb;
    display: flex;
    align-items: center;
}

.input-error {
    border-color: #ff6b6b !important;
    background: #fff5f5;
}

.readonly-input {
    opacity: 0.9;
    background: #f3f4f6;
    color: #6b7280;
}

.error-message text {
    color: #dc2626;
    font-size: 22rpx;
}

.hint-message text {
    color: #6b7280;
    font-size: 22rpx;
}

.captcha-container {
    display: flex;
    gap: 16rpx;
    align-items: center;
}

.captcha-input-wrapper {
    flex: 1;
}

.sms-button,
.ghost-button,
.login-button {
    height: 92rpx;
    border-radius: 14rpx;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 0 24rpx;
}

.sms-button {
    width: 220rpx;
    border: 1rpx solid #00a8e8;
    background: rgba(0, 168, 232, 0.12);
    color: #00a8e8;
    font-size: 24rpx;
}

.sms-button::after,
.ghost-button::after,
.login-button::after {
    border: none !important;
}

.sms-button[disabled],
.login-button[disabled],
.ghost-button[disabled] {
    opacity: 0.65;
}

.button-group {
    margin-top: 40rpx;
}

.complete-actions {
    display: flex;
    flex-direction: column;
    gap: 16rpx;
}

.ghost-button {
    width: 100%;
    background: #f3f4f6 !important;
    color: #111827 !important;
    border: 1rpx solid #e5e7eb !important;
}

.login-button {
    width: 100%;
    border: none !important;
    background: linear-gradient(135deg, #00a8e8 0%, #3ec6ff 100%) !important;
    color: #ffffff !important;
    font-size: 32rpx;
    font-weight: 700;
    box-shadow: 0 12rpx 28rpx rgba(0, 168, 232, 0.35);
}

.button-disabled {
    opacity: 0.55;
}

.role-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 18rpx;
}

.role-card {
    padding: 24rpx 20rpx;
    border-radius: 20rpx;
    background: rgba(255, 255, 255, 0.72);
    border: 2rpx solid #eadfca;
    text-align: center;
    transition: all 0.2s ease;
}

.role-card.active {
    background: #fff7e8;
    border-color: #e6a23c;
    transform: translateY(-2rpx);
    box-shadow: 0 12rpx 26rpx rgba(230, 162, 60, 0.16);
}

.gender-grid {
    grid-template-columns: repeat(3, minmax(0, 1fr));
}

.gender-card {
    padding-top: 28rpx;
    padding-bottom: 22rpx;
}

.gender-card .role-illustration {
    width: 104rpx;
    height: 104rpx;
    margin-bottom: 16rpx;
    border-radius: 28rpx;
}

.gender-illustration.male {
    background: linear-gradient(135deg, #e8f7fd 0%, #3ec6ff 100%);
}

.gender-illustration.female {
    background: linear-gradient(135deg, #fde2dc 0%, #f59e76 100%);
}

.gender-illustration.unknown {
    background: linear-gradient(135deg, #e5e7eb 0%, #94a3b8 100%);
}

.role-illustration {
    width: 120rpx;
    height: 120rpx;
    margin: 0 auto 18rpx;
    border-radius: 32rpx;
    display: flex;
    align-items: center;
    justify-content: center;
}

.role-illustration.elder {
    background: linear-gradient(135deg, #fff1c9 0%, #f8be7c 100%);
}

.role-illustration.family {
    background: linear-gradient(135deg, #ffdacc 0%, #ffb38f 100%);
}

.role-emoji {
    font-size: 58rpx;
}

.role-name {
    display: block;
    font-size: 30rpx;
    font-weight: 700;
    margin-bottom: 10rpx;
    color: #111827;
}

.role-tip {
    display: block;
    font-size: 22rpx;
    color: #6b7280;
    line-height: 1.6;
}

.loading-spinner {
    width: 28rpx;
    height: 28rpx;
    border: 4rpx solid rgba(0, 0, 0, 0.2);
    border-top-color: #111;
    border-radius: 50%;
    animation: spin 1s linear infinite;
    margin-right: 14rpx;
}

@keyframes spin {
    to {
        transform: rotate(360deg);
    }
}

.footer-section {
    padding: 28rpx 40rpx 44rpx;
    text-align: center;
    z-index: 1;
}

.footer-text {
    color: #d7d7d7;
    font-size: 22rpx;
}

</style>
