<template>
    <view class="login-page">
        <view class="bg-layer" aria-hidden="true">
            <view class="bg-base"></view>
            <view class="blob b1"></view>
            <view class="blob b2"></view>
            <view class="blob b3"></view>
            <view class="bg-mesh"></view>
            <view class="bg-vignette"></view>
        </view>

        <view class="lang-bar" :style="{ paddingTop: statusBarPx + 'px' }">
            <view class="lang-btn" @tap="toggleLocale">
                <text class="lang-code">{{ localeShort }}</text>
                <text class="lang-sep">/</text>
                <text class="lang-next">{{ nextLocaleShort }}</text>
            </view>
        </view>

        <view class="brand-block">
            <view class="logo-wrap">
                <image class="brand-logo" src="/static/logo.png" mode="aspectFill" />
                <view class="logo-pulse"></view>
                <view class="logo-shine"></view>
            </view>
            <view class="hero-title">
                <text class="hero-ice">ICE</text><text class="hero-jz">JZ</text>
            </view>
            <text class="slogan">{{ $t('brand.slogan') }}</text>
            <view class="brand-eyebrow">
                <view class="eyebrow-dot"></view>
                <text class="eyebrow-text">{{ $t('brand.tagline') }}</text>
            </view>
        </view>

        <view class="card">
            <view class="card-glow g-a"></view>
            <view class="card-glow g-b"></view>
            <view class="card-sheen"></view>

            <view class="card-head">
                <view class="card-kicker">
                    <view class="kicker-dot"></view>
                    <text class="kicker-text">{{ $t('login.welcomeKicker') }}</text>
                </view>
                <text class="card-sub">{{ $t('brand.loginHint') }}</text>
            </view>

            <view v-if="!showCompleteProfile">
                <view class="tabs">
                    <view class="tab" :class="{ active: loginMode === 'account' }" @tap="loginMode = 'account'">{{ $t('login.accountLogin') }}</view>
                    <view class="tab" :class="{ active: loginMode === 'mobile' }" @tap="loginMode = 'mobile'">{{ $t('login.mobileLogin') }}</view>
                    <view class="tab-indicator" :class="{ mobile: loginMode === 'mobile' }"></view>
                </view>

                <view v-if="loginMode === 'account'" class="form-body">
                    <view class="field">
                        <text class="field-label">{{ $t('login.account') }}</text>
                        <view class="field-shell">
                            <view class="field-ico">
                                <image class="field-ico-img" src="/static/icons/user.svg" mode="aspectFit" />
                            </view>
                            <input v-model="accountForm.username" class="field-input" :placeholder="$t('login.accountPh')" />
                        </view>
                    </view>
                    <view class="field">
                        <text class="field-label">{{ $t('login.password') }}</text>
                        <view class="field-shell">
                            <view class="field-ico">
                                <image class="field-ico-img" src="/static/icons/lock.svg" mode="aspectFit" />
                            </view>
                            <input v-model="accountForm.password" password class="field-input" :placeholder="$t('login.passwordPh')" />
                        </view>
                    </view>
                    <view class="field" v-if="captchaEnabled">
                        <text class="field-label">{{ $t('login.security') }}</text>
                        <view class="security-shell">
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
                    </view>
                    <view class="submit-btn" :class="{ disabled: isLogging }" @tap="onAccountLogin">
                        <view v-if="isLogging" class="spinner"></view>
                        {{ isLogging ? $t('login.logging') : $t('login.login') }}
                    </view>
                </view>

                <view v-else class="form-body">
                    <view class="field">
                        <text class="field-label">{{ $t('login.mobile') }}</text>
                        <view class="field-shell" :class="{ error: !!inputErrors.mobile }">
                            <view class="field-ico">
                                <image class="field-ico-img" src="/static/icons/phone.svg" mode="aspectFit" />
                            </view>
                            <input v-model="mobileForm.mobile" class="field-input" maxlength="11" :placeholder="$t('login.mobilePh')" @input="onPhoneInput" />
                        </view>
                        <text class="field-tip" :class="{ err: !!inputErrors.mobile }">{{ inputErrors.mobile || phoneHint }}</text>
                    </view>

                    <view class="field">
                        <text class="field-label">{{ $t('login.security') }}</text>
                        <view class="security-shell">
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
                        </view>
                        <text v-if="inputErrors.captcha" class="field-tip err">{{ inputErrors.captcha }}</text>
                        <text v-else class="field-tip">{{ $t('login.captchaBeforeSms') }}</text>
                    </view>

                    <view class="field">
                        <text class="field-label">{{ $t('login.sms') }}</text>
                        <view class="captcha-row">
                            <view class="field-shell flex" :class="{ error: !!inputErrors.code }">
                                <view class="field-ico">
                                    <image class="field-ico-img" src="/static/icons/msg.svg" mode="aspectFit" />
                                </view>
                                <input v-model="mobileForm.code" class="field-input" maxlength="6" :placeholder="$t('login.smsPh')" />
                            </view>
                            <view class="code-btn" :class="{ disabled: sms.disabled || isLogging }" @tap.stop="sendCode">
                                <text class="code-btn-text">{{ sms.disabled ? sms.count + 's' : $t('login.sendCode') }}</text>
                            </view>
                        </view>
                        <text v-if="inputErrors.code" class="field-tip err">{{ inputErrors.code }}</text>
                    </view>

                    <view class="submit-btn" :class="{ disabled: !canSubmit }" @tap="onMobileLogin">
                        <view v-if="isLogging" class="spinner"></view>
                        {{ isLogging ? $t('login.logging') : $t('login.login') }}
                    </view>
                </view>
            </view>

            <view v-else class="complete-body">
                <view class="card-kicker">
                    <view class="kicker-dot"></view>
                    <text class="kicker-text">{{ $t('login.welcomeKicker') }}</text>
                </view>
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
                    <view class="field-shell" :class="{ error: !!completeErrors.realName }">
                        <view class="field-ico">
                            <image class="field-ico-img" src="/static/icons/name.svg" mode="aspectFit" />
                        </view>
                        <input v-model="completeForm.realName" class="field-input" placeholder="请输入真实姓名" />
                    </view>
                    <text v-if="completeErrors.realName" class="field-tip err">{{ completeErrors.realName }}</text>
                </view>

                <view class="field">
                    <text class="field-label">手机号</text>
                    <view class="field-shell readonly">
                        <view class="field-ico">
                            <image class="field-ico-img" src="/static/icons/phone.svg" mode="aspectFit" />
                        </view>
                        <input :value="completeForm.mobile" disabled class="field-input" />
                    </view>
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
                <view class="secure-chip">{{ $t('login.secureEncrypt') }}</view>
                <view class="secure-chip">{{ $t('login.secureAuth') }}</view>
                <view class="secure-chip">{{ $t('login.secureAudit') }}</view>
            </view>
        </view>

        <text class="footnote">{{ brand.footer }} · {{ $t('login.footnote') }}</text>
        <ice-toast-host />
    </view>
</template>

<script>
import { sm2Encrypt } from '../../utils/sm2.js';
import cache from '../../utils/cache.js';
import brand from '../../config/brand.js';
import { setAppLocale } from '@/locale/index.js';
import { useSendCodeApi, useMobileLoginApi, useLoginApi, useCompleteProfileApi, useCaptchaApi, useCaptchaEnabledApi } from '../../api/auth.js';
import { useUserInfoApi } from '../../api/user.js';
import { goAfterAuth } from '@/utils/guide.js';
import LoginAgreement from './LoginAgreement.vue';
import LoginCaptchaPopup from './LoginCaptchaPopup.vue';
import IceToastHost from '@/components/feedback/IceToastHost.vue';

const CAPTCHA_TYPE_MODE = {
    pattern: 'click',
    block_puzzle: 'slider',
    click_word: 'word',
    curve: 'curve',
    rotate: 'rotate',
    angle: 'angle',
    pow: 'pow',
    turnstile: 'turnstile',
    spec: 'input',
    number: 'input',
    chinese: 'input',
    arithmetic: 'input'
};

export default {
    name: 'Login',
    components: { LoginAgreement, LoginCaptchaPopup, IceToastHost },
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
        localeCode() {
            return this.$i18n.locale === 'en-US' ? 'en-US' : 'zh-CN';
        },
        localeShort() {
            return this.localeCode === 'en-US' ? 'EN' : '中';
        },
        nextLocaleShort() {
            return this.localeCode === 'en-US' ? '中' : 'EN';
        }
    },
    watch: {
        loginMode() {
            if (!this.showCompleteProfile) {
                this.loadCaptcha();
            }
        }
    },
    created() {
        try {
            this.statusBarPx = uni.getSystemInfoSync().statusBarHeight || 20;
        } catch (e) {
            this.statusBarPx = 20;
        }
    },
    data() {
        return {
            brand,
            statusBarPx: 20,
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
                { key: 'dev', label: '研发', value: 2, emoji: '⚙', tip: '开发工具与物联网能力' },
                { key: 'ops', label: '运维', value: 3, emoji: '🛰', tip: '日志、监控与定时任务' },
                { key: 'pm', label: '产品', value: 4, emoji: '◎', tip: '日常协作与业务查阅' }
            ],
            genderOptions: [
                { key: 'male', label: '男', value: 0, emoji: '♂', tip: '男性' },
                { key: 'female', label: '女', value: 1, emoji: '♀', tip: '女性' },
                { key: 'unknown', label: '未知', value: 2, emoji: '·', tip: '保持默认' }
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
        toggleLocale() {
            const next = this.localeCode === 'zh-CN' ? 'en-US' : 'zh-CN';
            setAppLocale(next);
            uni.showToast({ title: this.$t('lang.switched'), icon: 'none' });
        },
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
                setTimeout(() => goAfterAuth({ replace: true }), 1200);
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
    --cyan-2: #2bb8ef;
    --ink: #0f1b2d;
    --mute: #8492a6;
    min-height: 100vh;
    position: relative;
    padding: 0 28rpx calc(36rpx + env(safe-area-inset-bottom));
    box-sizing: border-box;
    background: #f3f6fa;
    overflow-x: hidden;
    color: var(--ink);
}

.lang-bar {
    position: relative;
    z-index: 3;
    display: flex;
    justify-content: flex-start;
    padding-left: 0;
    padding-bottom: 4rpx;
}

.lang-btn {
    display: inline-flex;
    align-items: center;
    gap: 6rpx;
    height: 64rpx;
    padding: 0 22rpx;
    border-radius: 999rpx;
    background: rgba(255, 255, 255, 0.92);
    border: 1rpx solid rgba(255, 255, 255, 0.98);
    box-shadow: 0 10rpx 22rpx rgba(15, 35, 55, 0.06);
}

.lang-code {
    font-size: 24rpx;
    font-weight: 750;
    color: #00a8e8;
}

.lang-sep {
    font-size: 20rpx;
    color: #c5ced6;
}

.lang-next {
    font-size: 22rpx;
    font-weight: 650;
    color: #8492a6;
}

/* ===== Background ===== */
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
        radial-gradient(ellipse 80% 55% at 50% -5%, rgba(0, 168, 232, 0.16), transparent 60%),
        radial-gradient(ellipse 55% 40% at 100% 20%, rgba(56, 189, 248, 0.12), transparent 55%),
        radial-gradient(ellipse 50% 35% at 0% 70%, rgba(0, 168, 232, 0.1), transparent 55%),
        linear-gradient(180deg, #eef6fb 0%, #f3f6fa 42%, #f7f9fc 100%);
}

.blob {
    position: absolute;
    border-radius: 50%;
    filter: blur(2px);
    pointer-events: none;
}
.blob.b1 {
    width: 480rpx;
    height: 480rpx;
    top: -160rpx;
    right: -120rpx;
    background: radial-gradient(circle, rgba(0, 168, 232, 0.22), transparent 68%);
    animation: float-a 7s ease-in-out infinite;
}
.blob.b2 {
    width: 380rpx;
    height: 380rpx;
    bottom: 6%;
    left: -140rpx;
    background: radial-gradient(circle, rgba(56, 189, 248, 0.18), transparent 70%);
    animation: float-b 8s ease-in-out infinite;
}
.blob.b3 {
    width: 240rpx;
    height: 240rpx;
    top: 38%;
    right: 8%;
    background: radial-gradient(circle, rgba(255, 255, 255, 0.7), transparent 70%);
    animation: float-a 9s ease-in-out infinite reverse;
}

.bg-mesh {
    position: absolute;
    inset: 0;
    opacity: 0.28;
    background-image:
        linear-gradient(rgba(0, 168, 232, 0.08) 1rpx, transparent 1rpx),
        linear-gradient(90deg, rgba(0, 168, 232, 0.08) 1rpx, transparent 1rpx);
    background-size: 56rpx 56rpx;
    mask-image: radial-gradient(ellipse at 50% 18%, #000 0%, transparent 70%);
}

.bg-vignette {
    position: absolute;
    inset: 0;
    background: radial-gradient(ellipse at 50% 30%, transparent 40%, rgba(243, 246, 250, 0.55) 100%);
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
    padding: 28rpx 0 20rpx;
    text-align: center;
}

@media (max-height: 760px) {
    .brand-block { padding: 12rpx 0 8rpx; }
    .logo-wrap {
        width: 88rpx;
        height: 88rpx;
        margin-bottom: 12rpx;
        border-radius: 28rpx;
    }
    .brand-logo {
        border-radius: 28rpx;
    }
    .logo-pulse { border-radius: 34rpx; }
    .hero-ice, .hero-jz { font-size: 52rpx; }
    .slogan { margin-top: 8rpx; font-size: 22rpx; }
    .brand-eyebrow { margin-top: 10rpx; }
}

.brand-eyebrow {
    display: inline-flex;
    align-items: center;
    gap: 10rpx;
    margin-top: 18rpx;
    padding: 10rpx 20rpx;
    border-radius: 999rpx;
    background: rgba(255, 255, 255, 0.88);
    border: 1rpx solid rgba(255, 255, 255, 0.98);
    box-shadow: 0 10rpx 24rpx rgba(15, 35, 55, 0.05);
    animation: fade-up 0.65s ease 0.16s both;
}
.eyebrow-dot {
    width: 10rpx;
    height: 10rpx;
    border-radius: 50%;
    background: var(--cyan);
    box-shadow: 0 0 0 6rpx rgba(0, 168, 232, 0.14);
    animation: pulse-dot 2.2s ease-in-out infinite;
}
.eyebrow-text {
    font-size: 20rpx;
    font-weight: 650;
    letter-spacing: 0.04em;
    color: var(--mute);
}

.logo-wrap {
    position: relative;
    width: 112rpx;
    height: 112rpx;
    margin-bottom: 20rpx;
    border-radius: 36rpx;
    overflow: hidden;
    background: #041018;
    box-shadow: 0 14rpx 28rpx rgba(15, 35, 55, 0.14);
    animation: logo-float 4.5s ease-in-out infinite;
}
.brand-logo {
    width: 100%;
    height: 100%;
    border-radius: 36rpx;
    display: block;
}
.logo-pulse {
    position: absolute;
    inset: -8rpx;
    border-radius: 42rpx;
    border: 2rpx solid rgba(0, 168, 232, 0.24);
    animation: ring-glow 3.2s ease-in-out infinite;
    pointer-events: none;
}
.logo-shine {
    position: absolute;
    inset: 0;
    border-radius: 36rpx;
    overflow: hidden;
    pointer-events: none;
}
.logo-shine::before {
    content: '';
    position: absolute;
    top: -40%;
    left: -60%;
    width: 48%;
    height: 180%;
    background: linear-gradient(120deg, transparent, rgba(255, 255, 255, 0.55), transparent);
    transform: rotate(18deg);
    animation: logo-shine 4.8s ease-in-out infinite;
}

.hero-title {
    line-height: 1;
    animation: fade-up 0.7s ease 0.05s both;
}
.hero-ice {
    color: var(--ink);
    font-size: 64rpx;
    font-weight: 800;
    letter-spacing: 2rpx;
}
.hero-jz {
    color: var(--cyan);
    font-size: 64rpx;
    font-weight: 800;
    letter-spacing: 2rpx;
}
.slogan {
    display: block;
    margin-top: 14rpx;
    color: var(--mute);
    font-size: 24rpx;
    letter-spacing: 0.5rpx;
    animation: fade-up 0.7s ease 0.1s both;
}

/* ===== Card ===== */
.card {
    position: relative;
    margin-top: 12rpx;
    padding: 40rpx 30rpx 28rpx;
    border-radius: 36rpx;
    background: rgba(255, 255, 255, 0.9);
    border: 1rpx solid rgba(255, 255, 255, 0.98);
    box-shadow:
        0 24rpx 56rpx rgba(15, 35, 55, 0.08),
        0 2rpx 0 rgba(255, 255, 255, 0.95) inset;
    overflow: hidden;
    animation: fade-up 0.75s ease 0.12s both;
    backdrop-filter: blur(18px);
}
.card-glow {
    position: absolute;
    border-radius: 50%;
    pointer-events: none;
    filter: blur(36rpx);
}
.card-glow.g-a {
    width: 300rpx;
    height: 300rpx;
    right: -100rpx;
    top: -140rpx;
    background: rgba(0, 168, 232, 0.16);
}
.card-glow.g-b {
    width: 220rpx;
    height: 220rpx;
    left: -80rpx;
    bottom: -90rpx;
    background: rgba(56, 189, 248, 0.12);
}
.card-sheen {
    position: absolute;
    inset: 0;
    pointer-events: none;
    background: linear-gradient(160deg, rgba(255, 255, 255, 0.55) 0%, transparent 38%, transparent 100%);
}

.card-head {
    position: relative;
    z-index: 1;
    margin-bottom: 24rpx;
}
.card-kicker {
    display: inline-flex;
    align-items: center;
    gap: 10rpx;
    margin-bottom: 12rpx;
    padding: 8rpx 16rpx;
    border-radius: 999rpx;
    background: rgba(0, 168, 232, 0.08);
}
.kicker-dot {
    width: 10rpx;
    height: 10rpx;
    border-radius: 50%;
    background: #10b981;
    box-shadow: 0 0 0 5rpx rgba(16, 185, 129, 0.14);
    animation: pulse-dot 2s ease-in-out infinite;
}
.kicker-text {
    font-size: 20rpx;
    font-weight: 700;
    color: #0284c7;
    letter-spacing: 0.04em;
}
.card-sub {
    display: block;
    color: var(--mute);
    font-size: 24rpx;
    line-height: 1.45;
}

.tabs {
    position: relative;
    z-index: 1;
    display: flex;
    margin-bottom: 30rpx;
    padding: 8rpx;
    border-radius: 999rpx;
    background: rgba(243, 246, 250, 0.92);
    border: 1rpx solid rgba(255, 255, 255, 0.9);
}
.tab {
    flex: 1;
    text-align: center;
    padding: 18rpx 0;
    color: var(--mute);
    font-size: 26rpx;
    font-weight: 650;
    border-radius: 999rpx;
    position: relative;
    z-index: 1;
    transition: color 0.2s ease;
}
.tab.active { color: #fff; }
.tab-indicator {
    position: absolute;
    left: 8rpx;
    top: 8rpx;
    bottom: 8rpx;
    width: calc(50% - 8rpx);
    border-radius: 999rpx;
    background: linear-gradient(145deg, #00a8e8, #2bb8ef);
    box-shadow: 0 12rpx 24rpx rgba(0, 168, 232, 0.28);
    transition: transform 0.24s cubic-bezier(0.22, 1, 0.36, 1);
    z-index: 0;
    pointer-events: none;
}
.tab-indicator.mobile { transform: translateX(100%); }

.form-body,
.complete-body {
    position: relative;
    z-index: 1;
}

.field { margin-bottom: 22rpx; }
.field-label {
    display: block;
    margin-bottom: 12rpx;
    margin-left: 8rpx;
    color: #5b6b7c;
    font-size: 23rpx;
    font-weight: 650;
    letter-spacing: 0.02em;
}
.field-shell {
    display: flex;
    align-items: center;
    gap: 8rpx;
    min-height: 96rpx;
    padding: 0 12rpx 0 16rpx;
    border-radius: 28rpx;
    border: 1rpx solid rgba(232, 238, 245, 0.95);
    background: rgba(247, 250, 252, 0.96);
    box-sizing: border-box;
    transition: border-color 0.18s ease, box-shadow 0.18s ease, background 0.18s ease;
}
.field-shell.flex { flex: 1; min-width: 0; }
.field-shell.error {
    border-color: rgba(225, 29, 72, 0.4);
    background: #fff5f7;
}
.field-shell.readonly {
    background: #eef2f6;
}
.field-shell:focus-within {
    border-color: rgba(0, 168, 232, 0.42);
    background: #fff;
    box-shadow: 0 0 0 8rpx rgba(0, 168, 232, 0.08);
}
.field-ico {
    width: 56rpx;
    height: 56rpx;
    border-radius: 18rpx;
    background: rgba(0, 168, 232, 0.1);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}
.field-ico-img {
    width: 30rpx;
    height: 30rpx;
}
.field-input {
    flex: 1;
    min-width: 0;
    height: 96rpx;
    padding: 0 12rpx 0 4rpx;
    border: none;
    background: transparent;
    color: var(--ink);
    font-size: 28rpx;
    box-sizing: border-box;
}
.field-tip {
    display: block;
    margin-top: 10rpx;
    padding-left: 12rpx;
    color: var(--mute);
    font-size: 20rpx;
}
.field-tip.err { color: #e11d48; }

.security-shell {
    padding: 18rpx 18rpx 14rpx;
    border-radius: 28rpx;
    background: rgba(247, 250, 252, 0.96);
    border: 1rpx solid rgba(232, 238, 245, 0.95);
}

.captcha-row {
    display: flex;
    gap: 14rpx;
    align-items: stretch;
}
.captcha-row .field-input,
.captcha-row :deep(uni-input),
.captcha-row :deep(.uni-input-wrapper),
.captcha-row :deep(.uni-input-input) {
    height: 96rpx !important;
    min-height: 96rpx !important;
    box-sizing: border-box;
}

.code-btn {
    min-width: 196rpx;
    height: 96rpx;
    padding: 0 22rpx;
    border-radius: 28rpx;
    border: none;
    background: rgba(0, 168, 232, 0.1);
    box-sizing: border-box;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}
.code-btn-text {
    color: #0284c7;
    font-size: 24rpx;
    font-weight: 700;
    line-height: 1.2;
}
.code-btn.disabled { opacity: 0.5; pointer-events: none; }

.submit-btn {
    position: relative;
    overflow: hidden;
    margin: 8rpx auto 0;
    width: 78%;
    min-height: 84rpx;
    padding: 20rpx 24rpx;
    border-radius: 999rpx;
    background: linear-gradient(145deg, #00a8e8 0%, #1ab3ec 55%, #2bb8ef 100%);
    box-sizing: border-box;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow:
        0 12rpx 26rpx rgba(0, 168, 232, 0.22),
        inset 0 1rpx 0 rgba(255, 255, 255, 0.35);
    color: #fff;
    font-size: 28rpx;
    font-weight: 720;
    letter-spacing: 1rpx;
    line-height: 1.3;
}
.submit-btn::after {
    content: '';
    position: absolute;
    inset: 0;
    background: linear-gradient(110deg, transparent 35%, rgba(255, 255, 255, 0.28) 50%, transparent 65%);
    transform: translateX(-120%);
    animation: btn-glint 3.6s ease-in-out infinite;
}
.submit-btn.disabled { opacity: 0.5; pointer-events: none; }
@keyframes btn-glint {
    0%, 55% { transform: translateX(-120%); }
    75%, 100% { transform: translateX(120%); }
}

.ghost-btn {
    min-height: 88rpx;
    padding: 20rpx 24rpx;
    border-radius: 999rpx;
    border: 1rpx solid rgba(232, 238, 245, 0.95);
    background: #f7fafc;
    box-sizing: border-box;
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--ink);
    font-size: 26rpx;
    font-weight: 600;
    line-height: 1.2;
}
.ghost-btn.block { width: 100%; margin-bottom: 16rpx; }
.ghost-btn.disabled { opacity: 0.5; pointer-events: none; }

.spinner {
    width: 28rpx;
    height: 28rpx;
    margin-right: 12rpx;
    border-radius: 50%;
    border: 4rpx solid rgba(255, 255, 255, 0.35);
    border-top-color: #fff;
    animation: spin 1s linear infinite;
}

.complete-title {
    display: block;
    color: var(--ink);
    font-size: 36rpx;
    font-weight: 800;
}
.complete-desc {
    display: block;
    margin: 10rpx 0 24rpx;
    color: var(--mute);
    font-size: 24rpx;
    line-height: 1.6;
}
.role-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14rpx; }
.gender-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12rpx; }
.role-card {
    padding: 24rpx 16rpx;
    border-radius: 24rpx;
    background: #f7fafc;
    border: 2rpx solid transparent;
    text-align: center;
}
.role-card.active {
    background: rgba(0, 168, 232, 0.08);
    border-color: rgba(0, 168, 232, 0.42);
    box-shadow: 0 10rpx 22rpx rgba(0, 168, 232, 0.1);
}
.role-card.compact { padding: 20rpx 8rpx; }
.role-name {
    display: block;
    color: var(--ink);
    font-size: 28rpx;
    font-weight: 700;
}
.role-tip {
    display: block;
    margin-top: 8rpx;
    color: var(--mute);
    font-size: 20rpx;
    line-height: 1.4;
}

.card-secure {
    position: relative;
    z-index: 1;
    margin-top: 28rpx;
    padding-top: 22rpx;
    border-top: 1rpx solid rgba(238, 242, 247, 0.95);
    display: flex;
    justify-content: center;
    flex-wrap: wrap;
    gap: 10rpx;
}
.secure-chip {
    padding: 8rpx 16rpx;
    border-radius: 999rpx;
    background: #f3f6fa;
    color: #8492a6;
    font-size: 20rpx;
    font-weight: 600;
}

.footnote {
    display: block;
    margin-top: 28rpx;
    text-align: center;
    color: var(--mute);
    font-size: 22rpx;
    line-height: 1.5;
}

@keyframes spin { to { transform: rotate(360deg); } }
@keyframes float-a {
    0%, 100% { transform: translate(0, 0); }
    50% { transform: translate(18rpx, 14rpx); }
}
@keyframes float-b {
    0%, 100% { transform: translate(0, 0); }
    50% { transform: translate(-16rpx, 12rpx); }
}
@keyframes logo-float {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-8rpx); }
}
@keyframes logo-shine {
    0%, 55% { transform: translateX(-120%) rotate(18deg); opacity: 0; }
    65% { opacity: 0.9; }
    80%, 100% { transform: translateX(280%) rotate(18deg); opacity: 0; }
}
@keyframes ring-glow {
    0%, 100% { opacity: 0.35; transform: scale(1); }
    50% { opacity: 0.85; transform: scale(1.05); }
}
@keyframes pulse-dot {
    0%, 100% { transform: scale(1); opacity: 1; }
    50% { transform: scale(1.15); opacity: 0.7; }
}
@keyframes fade-up {
    from { opacity: 0; transform: translateY(18rpx); }
    to { opacity: 1; transform: none; }
}
</style>
