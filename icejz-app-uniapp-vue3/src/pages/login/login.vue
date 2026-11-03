<template>
    <view class="login-page">
        <view class="bg-layer" aria-hidden="true">
            <view class="bg-base"></view>
            <view class="bg-stars"></view>
            <view class="bg-mesh"></view>
            <view class="bg-aurora a1"></view>
            <view class="bg-aurora a2"></view>
            <view class="bg-aurora a3"></view>
            <view class="bg-glow g1"></view>
            <view class="bg-glow g2"></view>
            <view class="bg-glow g3"></view>
            <view class="orbit-ring r1"></view>
            <view class="orbit-ring r2"></view>
            <view class="orbit-ring r3"></view>
            <view class="float-dot d1"></view>
            <view class="float-dot d2"></view>
            <view class="float-dot d3"></view>
            <view class="float-dot d4"></view>
            <view class="float-dot d5"></view>
            <view class="bg-scan"></view>
            <view class="bg-vignette"></view>
        </view>

        <view class="brand-block">
            <view class="brand-eyebrow">
                <view class="eyebrow-dot"></view>
                <text class="eyebrow-text">ICECORE · 低代码引擎</text>
            </view>
            <view class="logo-wrap">
                <image class="brand-logo" src="/static/logo.png" mode="aspectFit" />
                <view class="logo-pulse"></view>
            </view>
            <view class="hero-title">
                <text class="hero-ice">ICE</text><text class="hero-jz">JZ</text>
            </view>
            <text class="slogan">{{ brand.slogan }}</text>
            <view class="brand-chips">
                <text class="chip">安全可靠</text>
                <text class="chip">快速开发</text>
                <text class="chip">灵活扩展</text>
            </view>
        </view>

        <view class="card">
            <view class="card-accent"></view>
            <view class="card-glow"></view>
            <view class="card-corner c-tl"></view>
            <view class="card-corner c-tr"></view>
            <view class="card-corner c-bl"></view>
            <view class="card-corner c-br"></view>

            <view class="card-head">
                <view class="card-logo-wrap">
                    <image class="card-logo" src="/static/logo.png" mode="aspectFit" />
                    <view class="card-logo-pulse"></view>
                </view>
                <view class="card-head-text">
                    <view class="card-title-row">
                        <text class="card-title">欢迎登录</text>
                        <view class="card-badge">
                            <view class="badge-dot"></view>
                            <text>Secure</text>
                        </view>
                    </view>
                    <text class="card-sub">{{ brand.loginHint }}</text>
                </view>
            </view>

            <view v-if="!showCompleteProfile">
                <view class="tabs">
                    <view class="tab" :class="{ active: loginMode === 'account' }" @tap="loginMode = 'account'">账号登录</view>
                    <view class="tab" :class="{ active: loginMode === 'mobile' }" @tap="loginMode = 'mobile'">手机登录</view>
                    <view class="tab-indicator" :class="{ mobile: loginMode === 'mobile' }"></view>
                </view>

                <view v-if="loginMode === 'account'" class="form-body">
                    <view class="field">
                        <text class="field-label">账号</text>
                        <input v-model="accountForm.username" class="field-input" placeholder="请输入账号" />
                    </view>
                    <view class="field">
                        <text class="field-label">密码</text>
                        <input v-model="accountForm.password" password class="field-input" placeholder="请输入密码" />
                    </view>
                    <view class="field" v-if="captchaEnabled">
                        <text class="field-label">安全验证</text>
                        <LoginCaptchaPopup
                            ref="accountCaptchaRef"
                            v-model="accountForm.captcha"
                            :captcha-key="accountForm.key"
                            :mode="captchaMode"
                            :tip="captchaTip"
                            :image="captchaBase64"
                            :jigsaw-image="jigsawImage"
                            :jigsaw-y="jigsawY"
                            :words="captchaWords"
                            :pow-running="powRunning"
                            :site-key="captchaSiteKey"
                            @refresh="loadCaptcha"
                        />
                    </view>
                    <view class="submit-btn" :class="{ disabled: isLogging }" @tap="onAccountLogin">
                        <view v-if="isLogging" class="spinner"></view>
                        {{ isLogging ? '登录中...' : '登录' }}
                    </view>
                </view>

                <view v-else class="form-body">
                    <view class="field">
                        <text class="field-label">手机号</text>
                        <input v-model="mobileForm.mobile" class="field-input" :class="{ error: inputErrors.mobile }" maxlength="11" placeholder="请输入11位手机号" @input="onPhoneInput" />
                        <text class="field-tip" :class="{ err: !!inputErrors.mobile }">{{ inputErrors.mobile || phoneHint }}</text>
                    </view>

                    <view class="field">
                        <text class="field-label">安全验证</text>
                        <LoginCaptchaPopup
                            ref="mobileCaptchaRef"
                            v-model="mobileForm.captcha"
                            :captcha-key="mobileForm.key"
                            :mode="captchaMode"
                            :tip="captchaTip"
                            :image="captchaBase64"
                            :jigsaw-image="jigsawImage"
                            :jigsaw-y="jigsawY"
                            :words="captchaWords"
                            :pow-running="powRunning"
                            :site-key="captchaSiteKey"
                            @refresh="loadCaptcha"
                        />
                        <text v-if="inputErrors.captcha" class="field-tip err">{{ inputErrors.captcha }}</text>
                        <text v-else class="field-tip">通过弹窗完成验证后才能发送短信</text>
                    </view>

                    <view class="field">
                        <text class="field-label">短信验证码</text>
                        <view class="captcha-row">
                            <input v-model="mobileForm.code" class="field-input flex" :class="{ error: inputErrors.code }" maxlength="6" placeholder="请输入短信验证码" />
                            <view class="code-btn" :class="{ disabled: sms.disabled || isLogging }" @tap.stop="sendCode">
                                <text class="code-btn-text">{{ sms.disabled ? sms.count + 's' : '发送验证码' }}</text>
                            </view>
                        </view>
                        <text v-if="inputErrors.code" class="field-tip err">{{ inputErrors.code }}</text>
                    </view>

                    <view class="submit-btn" :class="{ disabled: !canSubmit }" @tap="onMobileLogin">
                        <view v-if="isLogging" class="spinner"></view>
                        {{ isLogging ? '登录中...' : '登录' }}
                    </view>
                </view>
            </view>

            <view v-else class="complete-body">
                <text class="complete-title">完善信息</text>
                <text class="complete-desc">选择身份并补充资料后进入系统。首次默认密码为当前手机号。</text>

                <view class="field">
                    <text class="field-label">选择身份</text>
                    <view class="role-grid">
                        <view v-for="item in roleOptions" :key="item.value" class="role-card" :class="{ active: completeForm.roleId === item.value }" @tap="selectRole(item.value)">
                            <text class="role-name">{{ item.label }}</text>
                            <text class="role-tip">{{ item.tip }}</text>
                        </view>
                    </view>
                    <text v-if="completeErrors.roleId" class="field-tip err">{{ completeErrors.roleId }}</text>
                </view>

                <view class="field">
                    <text class="field-label">姓名</text>
                    <input v-model="completeForm.realName" class="field-input" :class="{ error: completeErrors.realName }" placeholder="请输入真实姓名" />
                    <text v-if="completeErrors.realName" class="field-tip err">{{ completeErrors.realName }}</text>
                </view>

                <view class="field">
                    <text class="field-label">手机号</text>
                    <input :value="completeForm.mobile" disabled class="field-input readonly" />
                </view>

                <view class="field">
                    <text class="field-label">性别</text>
                    <view class="gender-grid">
                        <view v-for="item in genderOptions" :key="item.value" class="role-card compact" :class="{ active: completeForm.gender === item.value }" @tap="selectGender(item.value)">
                            <text class="role-name">{{ item.label }}</text>
                        </view>
                    </view>
                </view>

                <view class="ghost-btn block" :class="{ disabled: isCompleting }" @tap="backToLogin">
                    <text>返回登录</text>
                </view>
                <view class="submit-btn" :class="{ disabled: isCompleting }" @tap="submitCompleteProfile">
                    <view v-if="isCompleting" class="spinner"></view>
                    {{ isCompleting ? '提交中...' : '完成并进入系统' }}
                </view>
            </view>

            <LoginAgreement v-if="!showCompleteProfile" ref="agreementRef" v-model="agreed" />

            <view class="card-secure">
                <text>加密传输</text>
                <text class="sep">·</text>
                <text>权限隔离</text>
                <text class="sep">·</text>
                <text>操作可审计</text>
            </view>
        </view>

        <text class="footnote">{{ brand.footer }} · 请先阅读并同意相关协议后再登录</text>
    </view>
</template>

<script>
import { sm2Encrypt } from '../../utils/sm2.js';
import cache from '../../utils/cache.js';
import brand from '../../config/brand.js';
import { useSendCodeApi, useMobileLoginApi, useLoginApi, useCompleteProfileApi, useCaptchaApi, useCaptchaEnabledApi } from '../../api/auth.js';
import { useUserInfoApi } from '../../api/user.js';
import LoginAgreement from './LoginAgreement.vue';
import LoginCaptchaPopup from './LoginCaptchaPopup.vue';

const CAPTCHA_TYPE_MODE = {
    pattern: 'click',
    block_puzzle: 'slider',
    click_word: 'word',
    pow: 'pow',
    turnstile: 'turnstile',
    spec: 'input',
    number: 'input',
    chinese: 'input',
    arithmetic: 'input'
};

export default {
    name: 'Login',
    components: { LoginAgreement, LoginCaptchaPopup },
    async onShow() {
        try {
            const enabledRes = await useCaptchaEnabledApi();
            this.captchaEnabled = !!enabledRes?.data;
        } catch (e) {
            this.captchaEnabled = true;
        }
        if (!this.showCompleteProfile) {
            this.loadCaptcha();
        }
    },
    computed: {
        canSubmit() {
            if (this.isLogging || this.showCompleteProfile || this.loginMode !== 'mobile') return false;
            return !!this.mobileForm.mobile && !!this.mobileForm.code;
        },
    },
    watch: {
        loginMode() {
            if (!this.showCompleteProfile) {
                this.loadCaptcha();
            }
        }
    },
    data() {
        return {
            brand,
            agreed: false,
            isLogging: false,
            isCompleting: false,
            showCompleteProfile: false,
            pendingMobileLogin: null,
            loginMode: 'account',
            captchaEnabled: true,
            inputErrors: {
                mobile: '',
                captcha: '',
                code: ''
            },
            completeErrors: {
                realName: '',
                roleId: '',
                gender: ''
            },
            captchaBase64: '',
            captchaTip: '',
            captchaMode: 'input',
            captchaSiteKey: '',
            jigsawImage: '',
            jigsawY: 0,
            sliderX: 0,
            captchaWords: [],
            wordClicks: [],
            powRunning: false,
            powChallenge: '',
            powDifficulty: 3,
            powToken: 0,
            mobileForm: {
                mobile: '',
                code: '',
                key: '',
                captcha: ''
            },
            accountForm: {
                username: 'admin',
                password: '123456',
                key: '',
                captcha: ''
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
            this.inputErrors = { mobile: '', captcha: '', code: '' };
        },
        async loadCaptcha() {
            try {
                this.powToken += 1;
                this.powRunning = false;
                const channel = this.loginMode === 'mobile' ? 'sms' : 'app';
                const { data } = await useCaptchaApi(channel);
                this.mobileForm.key = data?.key || '';
                this.accountForm.key = data?.key || '';
                this.captchaBase64 = data?.image || '';
                this.captchaTip = data?.tip || '';
                // 优先用 mode；缺省时按 type 映射，避免点选图仍走输入框
                this.captchaMode = data?.mode || CAPTCHA_TYPE_MODE[data?.type] || 'input';
                this.captchaSiteKey = data?.siteKey || '';
                this.jigsawImage = data?.jigsawImage || '';
                this.jigsawY = data?.jigsawY || 0;
                this.captchaWords = data?.words || [];
                this.wordClicks = [];
                this.sliderX = 0;
                this.mobileForm.captcha = '';
                this.accountForm.captcha = '';
                this.inputErrors.captcha = '';
                this.$refs.accountCaptchaRef?.reset?.();
                this.$refs.mobileCaptchaRef?.reset?.();
                this.powChallenge = data?.challenge || '';
                this.powDifficulty = data?.difficulty || 3;
                if (this.captchaMode === 'pow' && this.powChallenge) {
                    this.runPow(this.powChallenge, this.powDifficulty, this.powToken);
                }
            } catch (error) {
                uni.showToast({ title: error?.msg || '图形验证码加载失败', icon: 'none' });
            }
        },
        openCaptchaPopup(which = 'account') {
            const ref = which === 'mobile' ? this.$refs.mobileCaptchaRef : this.$refs.accountCaptchaRef;
            ref?.open?.();
        },
        ensureCaptcha(which = 'account') {
            if (!this.captchaEnabled) return true;
            const value = which === 'mobile' ? this.mobileForm.captcha : this.accountForm.captcha;
            if (value !== '' && value != null) return true;
            this.openCaptchaPopup(which);
            uni.showToast({ title: '请先完成安全验证', icon: 'none' });
            return false;
        },
        setCaptchaValue(val) {
            const v = val == null ? '' : String(val);
            this.accountForm.captcha = v;
            this.mobileForm.captcha = v;
            this.inputErrors.captcha = '';
        },
        async runPow(challenge, difficulty, token) {
            this.powRunning = true;
            const prefix = '0'.repeat(Math.max(2, Math.min(Number(difficulty) || 3, 5)));
            let nonce = 0;
            try {
                const digest = async (text) => {
                    if (typeof crypto !== 'undefined' && crypto.subtle) {
                        const buf = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(text));
                        return [...new Uint8Array(buf)].map((b) => b.toString(16).padStart(2, '0')).join('');
                    }
                    let h = 0;
                    for (let i = 0; i < text.length; i++) h = (h * 31 + text.charCodeAt(i)) >>> 0;
                    return h.toString(16).padStart(8, '0');
                };
                while (token === this.powToken) {
                    const hash = await digest(challenge + nonce);
                    if (String(hash).startsWith(prefix)) {
                        if (!crypto?.subtle) {
                            uni.showToast({ title: '当前端不支持 PoW，请改用其它验证码', icon: 'none' });
                            break;
                        }
                        this.setCaptchaValue(String(nonce));
                        break;
                    }
                    nonce++;
                    if (nonce % 100 === 0) await new Promise((r) => setTimeout(r, 0));
                    if (nonce > 200000) break;
                }
            } finally {
                if (token === this.powToken) {
                    this.powRunning = false;
                }
            }
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
            if (!this.ensureCaptcha('mobile')) {
                this.setInputError('captcha', '请先在弹窗中完成图形验证');
                return;
            }
            if (!this.mobileForm.key) {
                this.setInputError('captcha', '图形验证码已失效，请点击刷新');
                await this.loadCaptcha();
                return;
            }
            try {
                await useSendCodeApi({
                    mobile: this.mobileForm.mobile,
                    key: this.mobileForm.key,
                    captcha: this.mobileForm.captcha
                });
                uni.showToast({ title: '验证码已发送，请注意查收', icon: 'none' });
                this.timerHandler();
                await this.loadCaptcha();
            } catch (error) {
                await this.loadCaptcha();
                uni.showToast({ title: error?.msg || '发送失败，请稍后重试', icon: 'none' });
            }
        },
        ensureAgreement() {
            return this.$refs.agreementRef?.ensureAgreed?.() ?? false;
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
            if (!this.ensureAgreement()) return;

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
            if (!this.ensureCaptcha('account')) return;
            if (!this.ensureAgreement()) return;
            try {
                this.isLogging = true;
                const payload = {
                    username: this.accountForm.username,
                    password: sm2Encrypt(this.accountForm.password)
                };
                if (this.captchaEnabled) {
                    payload.key = this.accountForm.key;
                    payload.captcha = this.accountForm.captcha;
                }
                const response = await useLoginApi(payload);
                await this.handleAccountLoginResult(response);
            } catch (error) {
                await this.loadCaptcha();
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
                    password: sm2Encrypt(this.completeForm.mobile)
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
.login-page {
    --cyan: #00a8e8;
    --cyan-2: #3ec6ff;
    min-height: 100vh;
    position: relative;
    padding: 0 28rpx calc(40rpx + env(safe-area-inset-bottom));
    box-sizing: border-box;
    background: #030912;
    overflow-x: hidden;
    color: #fff;
}

/* ===== Background (PC-like, mobile-light) ===== */
.bg-layer {
    position: absolute;
    inset: 0;
    pointer-events: none;
    overflow: hidden;
}

.bg-base {
    position: absolute;
    inset: 0;
    background:
        radial-gradient(ellipse 80% 55% at 12% 12%, rgba(0, 168, 232, 0.42), transparent 55%),
        radial-gradient(ellipse 70% 50% at 92% 78%, rgba(62, 198, 255, 0.26), transparent 52%),
        radial-gradient(ellipse 50% 40% at 50% 42%, rgba(14, 60, 92, 0.45), transparent 60%),
        linear-gradient(160deg, #030912 0%, #0a1524 36%, #0e2438 66%, #081c2c 100%);
}

.bg-stars {
    position: absolute;
    inset: 0;
    opacity: 0.55;
    background-image:
        radial-gradient(2rpx 2rpx at 12% 18%, rgba(255, 255, 255, 0.75), transparent),
        radial-gradient(2rpx 2rpx at 28% 62%, rgba(183, 233, 255, 0.7), transparent),
        radial-gradient(3rpx 3rpx at 46% 22%, rgba(255, 255, 255, 0.55), transparent),
        radial-gradient(2rpx 2rpx at 64% 48%, rgba(154, 230, 255, 0.65), transparent),
        radial-gradient(2rpx 2rpx at 78% 16%, rgba(255, 255, 255, 0.5), transparent),
        radial-gradient(2rpx 2rpx at 88% 72%, rgba(122, 217, 255, 0.6), transparent),
        radial-gradient(3rpx 3rpx at 18% 84%, rgba(255, 255, 255, 0.4), transparent),
        radial-gradient(2rpx 2rpx at 52% 78%, rgba(183, 233, 255, 0.55), transparent),
        radial-gradient(2rpx 2rpx at 35% 40%, rgba(255, 255, 255, 0.45), transparent),
        radial-gradient(2rpx 2rpx at 70% 30%, rgba(154, 230, 255, 0.5), transparent);
    animation: stars-twinkle 6s ease-in-out infinite;
}

.bg-mesh {
    position: absolute;
    inset: 0;
    opacity: 0.16;
    background-image:
        linear-gradient(rgba(0, 168, 232, 0.14) 1rpx, transparent 1rpx),
        linear-gradient(90deg, rgba(0, 168, 232, 0.14) 1rpx, transparent 1rpx);
    background-size: 56rpx 56rpx;
    mask-image: radial-gradient(ellipse at 50% 28%, #000 8%, transparent 72%);
}

.bg-aurora {
    position: absolute;
    border-radius: 42%;
    filter: blur(70rpx);
    opacity: 0.36;
    mix-blend-mode: screen;
}
.a1 {
    width: 520rpx;
    height: 520rpx;
    left: -140rpx;
    top: -160rpx;
    background: conic-gradient(from 90deg, rgba(0, 168, 232, 0.65), transparent, rgba(62, 198, 255, 0.45), transparent);
    animation: aurora 14s ease-in-out infinite;
}
.a2 {
    width: 480rpx;
    height: 480rpx;
    right: -160rpx;
    bottom: -120rpx;
    background: conic-gradient(from 220deg, rgba(62, 198, 255, 0.5), transparent, rgba(0, 168, 232, 0.38), transparent);
    animation: aurora 18s ease-in-out infinite reverse;
}
.a3 {
    width: 360rpx;
    height: 360rpx;
    left: 28%;
    top: 34%;
    opacity: 0.2;
    background: conic-gradient(from 40deg, rgba(120, 220, 255, 0.35), transparent 40%, rgba(0, 168, 232, 0.28), transparent 75%);
    animation: aurora 20s ease-in-out infinite;
}

.bg-glow {
    position: absolute;
    border-radius: 50%;
    filter: blur(80rpx);
}
.g1 {
    width: 420rpx;
    height: 420rpx;
    left: -120rpx;
    top: -80rpx;
    background: rgba(0, 168, 232, 0.42);
    animation: float-a 11s ease-in-out infinite;
}
.g2 {
    width: 360rpx;
    height: 360rpx;
    right: -100rpx;
    top: 260rpx;
    background: rgba(62, 198, 255, 0.26);
    animation: float-b 13s ease-in-out infinite;
}
.g3 {
    width: 240rpx;
    height: 240rpx;
    left: 40%;
    top: 16%;
    background: rgba(0, 168, 232, 0.14);
    animation: float-a 15s ease-in-out infinite reverse;
}

.orbit-ring {
    position: absolute;
    left: 50%;
    top: 18%;
    border-radius: 50%;
    border: 1rpx solid rgba(0, 168, 232, 0.18);
    transform: translate(-50%, -50%);
}
.r1 {
    width: 280rpx;
    height: 280rpx;
    animation: orbit-spin 22s linear infinite;
    box-shadow: 0 0 24rpx rgba(0, 168, 232, 0.08) inset;
}
.r2 {
    width: 420rpx;
    height: 420rpx;
    border-color: rgba(62, 198, 255, 0.12);
    animation: orbit-spin 34s linear infinite reverse;
}
.r3 {
    width: 560rpx;
    height: 560rpx;
    border-style: dashed;
    border-color: rgba(0, 168, 232, 0.1);
    animation: orbit-spin 48s linear infinite;
}

.float-dot {
    position: absolute;
    width: 8rpx;
    height: 8rpx;
    border-radius: 50%;
    background: rgba(183, 233, 255, 0.85);
    box-shadow: 0 0 12rpx rgba(0, 168, 232, 0.8);
    animation: float-dot 7s ease-in-out infinite;
}
.d1 { left: 14%; top: 22%; animation-delay: 0s; }
.d2 { left: 78%; top: 18%; width: 6rpx; height: 6rpx; animation-delay: 1.2s; }
.d3 { left: 22%; top: 48%; animation-delay: 2s; }
.d4 { left: 86%; top: 42%; width: 10rpx; height: 10rpx; animation-delay: 0.6s; }
.d5 { left: 48%; top: 12%; animation-delay: 1.8s; }

.bg-scan {
    position: absolute;
    inset: 0;
    background: linear-gradient(
        180deg,
        transparent 0%,
        rgba(0, 168, 232, 0.04) 46%,
        rgba(62, 198, 255, 0.12) 50%,
        rgba(0, 168, 232, 0.04) 54%,
        transparent 100%
    );
    background-size: 100% 240%;
    animation: scan 8s linear infinite;
    opacity: 0.35;
    z-index: 1;
}

.bg-vignette {
    position: absolute;
    inset: 0;
    z-index: 1;
    background:
        radial-gradient(ellipse at center, transparent 36%, rgba(4, 10, 18, 0.58) 100%),
        linear-gradient(180deg, rgba(4, 10, 18, 0.08), transparent 20%, transparent 70%, rgba(4, 10, 18, 0.35));
}

.brand-block,
.card,
.footnote {
    position: relative;
    z-index: 2;
    width: 100%;
    max-width: 860rpx;
    margin-left: auto;
    margin-right: auto;
    box-sizing: border-box;
}

/* ===== Brand ===== */
.brand-block {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 72rpx 0 32rpx;
    text-align: center;
}

.brand-eyebrow {
    display: inline-flex;
    align-items: center;
    gap: 10rpx;
    margin-bottom: 22rpx;
    padding: 8rpx 18rpx;
    border-radius: 999rpx;
    background: rgba(255, 255, 255, 0.06);
    border: 1rpx solid rgba(0, 168, 232, 0.22);
    animation: fade-up 0.6s ease both;
}
.eyebrow-dot {
    width: 10rpx;
    height: 10rpx;
    border-radius: 50%;
    background: var(--cyan);
    box-shadow: 0 0 0 6rpx rgba(0, 168, 232, 0.18);
    animation: pulse-dot 2.2s ease-in-out infinite;
}
.eyebrow-text {
    font-size: 20rpx;
    font-weight: 700;
    letter-spacing: 0.08em;
    color: rgba(183, 233, 255, 0.92);
}

.logo-wrap {
    position: relative;
    width: 108rpx;
    height: 108rpx;
    margin-bottom: 22rpx;
    animation: logo-float 4.5s ease-in-out infinite;
}
.brand-logo {
    width: 108rpx;
    height: 108rpx;
    border-radius: 28rpx;
    background: rgba(255, 255, 255, 0.08);
    border: 1rpx solid rgba(255, 255, 255, 0.12);
    box-shadow: 0 16rpx 40rpx rgba(0, 0, 0, 0.28);
}
.logo-pulse {
    position: absolute;
    inset: -10rpx;
    border-radius: 34rpx;
    border: 2rpx solid rgba(0, 168, 232, 0.35);
    animation: ring-glow 3.2s ease-in-out infinite;
    pointer-events: none;
}

.hero-title {
    line-height: 1;
    animation: fade-up 0.7s ease 0.05s both;
}
.hero-ice {
    color: #fff;
    font-size: 72rpx;
    font-weight: 780;
    letter-spacing: 2rpx;
    text-shadow: 0 8rpx 30rpx rgba(0, 0, 0, 0.35);
}
.hero-jz {
    color: var(--cyan);
    font-size: 72rpx;
    font-weight: 780;
    letter-spacing: 2rpx;
    text-shadow: 0 0 28rpx rgba(0, 168, 232, 0.45);
}
.slogan {
    display: block;
    margin-top: 16rpx;
    color: rgba(255, 255, 255, 0.72);
    font-size: 24rpx;
    letter-spacing: 1rpx;
    animation: fade-up 0.7s ease 0.12s both;
}
.brand-chips {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    gap: 10rpx;
    margin-top: 22rpx;
    animation: fade-up 0.7s ease 0.18s both;
}
.chip {
    padding: 8rpx 16rpx;
    border-radius: 999rpx;
    font-size: 20rpx;
    font-weight: 650;
    color: rgba(183, 233, 255, 0.92);
    background: rgba(0, 168, 232, 0.12);
    border: 1rpx solid rgba(0, 168, 232, 0.22);
}

/* ===== Card ===== */
.card {
    position: relative;
    margin-top: 8rpx;
    padding: 36rpx 28rpx 24rpx;
    border-radius: 28rpx;
    background:
        linear-gradient(180deg, rgba(255, 255, 255, 0.98), rgba(247, 251, 253, 0.96));
    border: 1rpx solid rgba(255, 255, 255, 0.55);
    box-shadow:
        0 28rpx 64rpx rgba(0, 0, 0, 0.32),
        0 0 0 1rpx rgba(0, 168, 232, 0.08) inset;
    overflow: hidden;
    animation: fade-up 0.75s ease 0.14s both;
}
.card-accent {
    position: absolute;
    left: 0;
    right: 0;
    top: 0;
    height: 6rpx;
    background: linear-gradient(90deg, #0096d6, #00a8e8, #3ec6ff, #00a8e8);
    background-size: 200% 100%;
    animation: accent-flow 4s linear infinite;
}
.card-glow {
    position: absolute;
    width: 280rpx;
    height: 280rpx;
    right: -80rpx;
    top: -120rpx;
    border-radius: 50%;
    background: rgba(0, 168, 232, 0.14);
    filter: blur(40rpx);
    pointer-events: none;
}
.card-corner {
    position: absolute;
    width: 22rpx;
    height: 22rpx;
    border-color: rgba(0, 168, 232, 0.35);
    border-style: solid;
    pointer-events: none;
}
.c-tl { left: 14rpx; top: 14rpx; border-width: 2rpx 0 0 2rpx; }
.c-tr { right: 14rpx; top: 14rpx; border-width: 2rpx 2rpx 0 0; }
.c-bl { left: 14rpx; bottom: 14rpx; border-width: 0 0 2rpx 2rpx; }
.c-br { right: 14rpx; bottom: 14rpx; border-width: 0 2rpx 2rpx 0; }

.card-head {
    display: flex;
    align-items: center;
    gap: 18rpx;
    margin-bottom: 28rpx;
}
.card-logo-wrap {
    position: relative;
    width: 72rpx;
    height: 72rpx;
    flex-shrink: 0;
}
.card-logo {
    width: 72rpx;
    height: 72rpx;
    border-radius: 18rpx;
    background: linear-gradient(180deg, #f0f9ff, #e0f2fe);
    border: 1rpx solid rgba(0, 168, 232, 0.18);
}
.card-logo-pulse {
    position: absolute;
    inset: -6rpx;
    border-radius: 22rpx;
    border: 2rpx solid rgba(0, 168, 232, 0.28);
    animation: ring-glow 3.2s ease-in-out infinite;
}
.card-head-text {
    min-width: 0;
    flex: 1;
}
.card-title-row {
    display: flex;
    align-items: center;
    gap: 12rpx;
}
.card-title {
    color: #0f1724;
    font-size: 34rpx;
    font-weight: 760;
}
.card-badge {
    display: inline-flex;
    align-items: center;
    gap: 8rpx;
    height: 36rpx;
    padding: 0 14rpx;
    border-radius: 999rpx;
    background: rgba(0, 168, 232, 0.1);
    border: 1rpx solid rgba(0, 168, 232, 0.18);
    color: #0284c7;
    font-size: 18rpx;
    font-weight: 740;
    letter-spacing: 0.04em;
}
.badge-dot {
    width: 10rpx;
    height: 10rpx;
    border-radius: 50%;
    background: #10b981;
    box-shadow: 0 0 0 4rpx rgba(16, 185, 129, 0.18);
    animation: pulse-dot 2s ease-in-out infinite;
}
.card-sub {
    display: block;
    margin-top: 8rpx;
    color: #64748b;
    font-size: 22rpx;
}

.tabs {
    position: relative;
    display: flex;
    gap: 0;
    margin-bottom: 28rpx;
    border-bottom: 1rpx solid #eef2f7;
}
.tab {
    flex: 1;
    text-align: center;
    padding: 0 0 20rpx;
    color: #94a3b8;
    font-size: 28rpx;
    font-weight: 600;
}
.tab.active { color: #0f1724; }
.tab-indicator {
    position: absolute;
    left: 0;
    bottom: 0;
    width: 50%;
    height: 4rpx;
    border-radius: 999rpx;
    background: linear-gradient(90deg, #00a8e8, #3ec6ff);
    box-shadow: 0 0 12rpx rgba(0, 168, 232, 0.45);
    transition: transform 0.22s ease-out;
}
.tab-indicator.mobile { transform: translateX(100%); }

.field { margin-bottom: 24rpx; }
.field-label { display: block; margin-bottom: 10rpx; color: #475569; font-size: 24rpx; font-weight: 600; }
.field-input {
    width: 100%;
    height: 88rpx;
    padding: 0 22rpx;
    border-radius: 16rpx;
    border: 1rpx solid #e5e7eb;
    background: linear-gradient(180deg, #ffffff, #f4f9fc);
    color: #111827;
    font-size: 28rpx;
    box-sizing: border-box;
}
.field-input.error { border-color: #f56c6c; background: #fff5f5; }
.field-input.readonly { color: #94a3b8; background: #f1f5f9; }
.field-input.flex { flex: 1; }
.field-tip { display: block; margin-top: 8rpx; color: #94a3b8; font-size: 20rpx; }
.field-tip.err { color: #f56c6c; }

.captcha-row {
    display: flex;
    gap: 14rpx;
    align-items: stretch;
}
.captcha-row .field-input,
.captcha-row :deep(uni-input),
.captcha-row :deep(.uni-input-wrapper),
.captcha-row :deep(.uni-input-input) {
    height: 88rpx !important;
    min-height: 88rpx !important;
    box-sizing: border-box;
}

.code-btn {
    min-width: 200rpx;
    height: 88rpx;
    padding: 0 20rpx;
    border-radius: 16rpx;
    border: 1rpx solid #00a8e8;
    background: rgba(0,168,232,0.1);
    box-sizing: border-box;
    display: flex;
    align-items: center;
    justify-content: center;
}
.code-btn-text {
    color: #00a8e8;
    font-size: 24rpx;
    font-weight: 600;
    line-height: 1.2;
}
.code-btn.disabled { opacity: 0.55; pointer-events: none; }

.submit-btn {
    position: relative;
    overflow: hidden;
    margin-top: 8rpx;
    min-height: 96rpx;
    padding: 26rpx 24rpx;
    border-radius: 16rpx;
    background: linear-gradient(135deg, #0096d6 0%, #00a8e8 40%, #3ec6ff 100%);
    box-sizing: border-box;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow:
        0 14rpx 30rpx rgba(0,168,232,0.34),
        inset 0 1rpx 0 rgba(255,255,255,0.35);
    color: #fff;
    font-size: 30rpx;
    font-weight: 740;
    letter-spacing: 4rpx;
    line-height: 1.4;
}
.submit-btn.disabled { opacity: 0.55; pointer-events: none; }

.ghost-btn {
    min-height: 88rpx;
    padding: 20rpx 24rpx;
    border-radius: 16rpx;
    border: 1rpx solid #e5e7eb;
    background: #f8fafc;
    box-sizing: border-box;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #111827;
    font-size: 26rpx;
    line-height: 1.2;
}
.ghost-btn.block { width: 100%; margin-bottom: 16rpx; }
.ghost-btn.disabled { opacity: 0.55; pointer-events: none; }

.spinner {
    width: 28rpx;
    height: 28rpx;
    margin-right: 12rpx;
    border-radius: 50%;
    border: 4rpx solid rgba(255,255,255,0.35);
    border-top-color: #fff;
    animation: spin 1s linear infinite;
}

.complete-title { display: block; color: #111827; font-size: 34rpx; font-weight: 700; }
.complete-desc { display: block; margin: 10rpx 0 24rpx; color: #64748b; font-size: 24rpx; line-height: 1.6; }
.role-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14rpx; }
.gender-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12rpx; }
.role-card {
    padding: 22rpx 16rpx;
    border-radius: 16rpx;
    background: #f4f8fb;
    border: 2rpx solid transparent;
    text-align: center;
}
.role-card.active { background: #e8f7fd; border-color: #00a8e8; }
.role-card.compact { padding: 20rpx 8rpx; }
.role-name { display: block; color: #111827; font-size: 28rpx; font-weight: 700; }
.role-tip { display: block; margin-top: 8rpx; color: #64748b; font-size: 20rpx; line-height: 1.4; }

.card-secure {
    margin-top: 28rpx;
    padding-top: 22rpx;
    border-top: 1rpx solid #eef2f7;
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 12rpx;
    color: #94a3b8;
    font-size: 20rpx;
}
.sep { color: #cbd5e1; }

.footnote {
    display: block;
    margin-top: 28rpx;
    text-align: center;
    color: rgba(255,255,255,0.45);
    font-size: 22rpx;
}

@keyframes spin { to { transform: rotate(360deg); } }
@keyframes stars-twinkle {
    0%, 100% { opacity: 0.42; }
    50% { opacity: 0.7; }
}
@keyframes aurora {
    0%, 100% { transform: translate(0, 0) rotate(0deg) scale(1); }
    33% { transform: translate(4%, 3%) rotate(8deg) scale(1.05); }
    66% { transform: translate(-3%, 5%) rotate(-6deg) scale(0.96); }
}
@keyframes float-a {
    0%, 100% { transform: translate(0, 0); }
    50% { transform: translate(24rpx, 18rpx); }
}
@keyframes float-b {
    0%, 100% { transform: translate(0, 0); }
    50% { transform: translate(-20rpx, 16rpx); }
}
@keyframes float-dot {
    0%, 100% { transform: translateY(0); opacity: 0.55; }
    50% { transform: translateY(-16rpx); opacity: 1; }
}
@keyframes orbit-spin {
    to { transform: translate(-50%, -50%) rotate(360deg); }
}
@keyframes scan {
    0% { background-position: 0% 0%; }
    100% { background-position: 0% 100%; }
}
@keyframes logo-float {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-10rpx); }
}
@keyframes ring-glow {
    0%, 100% { opacity: 0.35; transform: scale(1); }
    50% { opacity: 0.85; transform: scale(1.06); }
}
@keyframes pulse-dot {
    0%, 100% { transform: scale(1); opacity: 1; }
    50% { transform: scale(1.15); opacity: 0.7; }
}
@keyframes accent-flow {
    0% { background-position: 0% 50%; }
    100% { background-position: 200% 50%; }
}
@keyframes fade-up {
    from { opacity: 0; transform: translateY(18rpx); }
    to { opacity: 1; transform: none; }
}
</style>
