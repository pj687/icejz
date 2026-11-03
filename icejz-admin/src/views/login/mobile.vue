<template>
	<el-form ref="loginFormRef" :model="loginForm" :rules="loginRules" class="login-form" @keyup.enter="onLogin">
		<el-form-item prop="mobile">
			<el-input v-model="loginForm.mobile" :placeholder="$t('app.mobile')" size="large">
				<template #prefix>
					<div class="input-icon">
						<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
							<rect x="5" y="2" width="14" height="20" rx="2" ry="2" />
							<line x1="12" y1="18" x2="12.01" y2="18" />
						</svg>
					</div>
				</template>
			</el-input>
		</el-form-item>

		<el-form-item v-if="showCaptcha" prop="captcha" class="login-captcha">
			<LoginCaptcha
				ref="captchaRef"
				v-model="loginForm.captcha"
				v-model:captcha-key="loginForm.key"
				channel="sms"
			/>
		</el-form-item>

		<el-form-item prop="code" class="login-code">
			<el-input v-model="loginForm.code" placeholder="短信验证码" size="large" maxlength="6">
				<template #prefix>
					<div class="input-icon">
						<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
							<path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z" />
						</svg>
					</div>
				</template>
			</el-input>
			<el-button v-if="!sms.disabled" class="code-btn" :loading="sms.sending" @click="sendCode">发送验证码</el-button>
			<el-button v-else class="code-btn" disabled>
				<span class="countdown">{{ sms.count }}</span> 秒后重发
			</el-button>
		</el-form-item>
		<el-form-item class="login-button">
			<el-button type="primary" class="submit-btn" :loading="loading" @click="onLogin()">
				<span class="btn-sheen" aria-hidden="true"></span>
				<span v-if="!loading" class="btn-text">{{ $t('app.signIn') }}</span>
				<span v-else class="btn-text">登录中...</span>
			</el-button>
		</el-form-item>
	</el-form>
</template>

<script setup lang="ts">
import { ref, reactive, inject, computed, nextTick, watch } from 'vue'
import { useUserStore } from '@/store/modules/user'
import { useSendCodeApi } from '@/api/auth'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { mobileRegExp } from '@/utils/validate'
import { ElMessage } from 'element-plus'
import constant from '@/utils/constant'
import cache from '@/utils/cache'
import LoginCaptcha from './LoginCaptcha.vue'

const userStore = useUserStore()
const loading = ref(false)
const captchaRef = ref<{ refresh: () => Promise<void>; ensureVerified?: () => Promise<boolean> }>()
const ensureAgreement = inject<() => boolean>('ensureAgreement', () => true)
const setLoginLoading = inject<(val: boolean) => void>('setLoginLoading', () => undefined)

const sms = reactive({
	disabled: false,
	sending: false,
	sent: false,
	total: 60,
	count: 0
})

/** 发短信前 / 倒计时结束后需重发时，才展示并校验图形验证码 */
const showCaptcha = computed(() => !sms.sent || !sms.disabled)

const sendCode = async () => {
	if (!mobileRegExp.test(loginForm.mobile)) {
		ElMessage.error('请输入正确的手机号')
		return
	}

	if (!loginForm.key) {
		ElMessage.error('图形验证码已失效，请刷新后重试')
		await captchaRef.value?.refresh()
		return
	}

	const captchaOk = await captchaRef.value?.ensureVerified?.()
	if (captchaOk === false || loginForm.captcha === '' || loginForm.captcha == null) {
		ElMessage.error('请先完成图形验证码校验')
		return
	}

	if (!ensureAgreement()) {
		return
	}

	sms.sending = true
	try {
		const { data } = await useSendCodeApi({
			mobile: loginForm.mobile,
			key: loginForm.key,
			captcha: loginForm.captcha
		})
		timerHandler()
		sms.sent = true
		loginForm.captcha = ''
		loginForm.key = ''
		await nextTick()
		loginFormRef.value?.clearValidate?.('captcha')
		// 模拟模式下后端会回传动态验证码，便于联调（非固定值）
		if (data) {
			loginForm.code = String(data)
		}
		ElMessage.success('验证码已发送')
	} catch {
		await captchaRef.value?.refresh()
	} finally {
		sms.sending = false
	}
}

const timerHandler = () => {
	sms.count = sms.total
	sms.disabled = true

	const timer = setInterval(() => {
		if (sms.count > 1 && sms.count <= sms.total) {
			sms.count--
		} else {
			sms.disabled = false
			clearInterval(timer)
			nextTick(() => captchaRef.value?.refresh())
		}
	}, 1000)
}

const router = useRouter()
const { t } = useI18n()
const loginFormRef = ref()

const loginForm = reactive({
	mobile: constant.env.PROD ? '' : '13800138000',
	code: '',
	key: '',
	captcha: ''
})

const loginRules = computed(() => ({
	mobile: [{ required: true, message: t('required'), trigger: 'blur' }],
	captcha: showCaptcha.value ? [{ required: true, message: t('required'), trigger: 'change' }] : [],
	code: [{ required: true, message: t('required'), trigger: 'blur' }]
}))

watch(
	() => loginForm.mobile,
	() => {
		if (sms.sent) {
			sms.sent = false
			loginForm.code = ''
		}
	}
)

const onLogin = () => {
	loginFormRef.value.validate((valid: boolean) => {
		if (!valid) {
			return false
		}

		if (!ensureAgreement()) {
			return false
		}

		loading.value = true
		setLoginLoading(true)

		userStore
			.mobileLoginAction({
				mobile: loginForm.mobile,
				code: loginForm.code
			})
			.then(() => {
				const redirect = cache.getRedirect()
				cache.clearRedirect()
				router.push({ path: redirect || constant.loginPage })
			})
			.finally(() => {
				loading.value = false
				setLoginLoading(false)
			})
	})
}
</script>

<style lang="scss" scoped>
.login-form {
	:deep(.el-form-item) {
		margin-bottom: 16px;
	}

	:deep(.el-input__wrapper) {
		min-height: 50px;
		border-radius: 14px !important;
		box-shadow:
			0 0 0 1px #e1edf5 inset,
			0 1px 2px rgba(15, 23, 36, 0.02) !important;
		background: linear-gradient(180deg, #ffffff, #f4f9fc);
		padding-left: 13px;
		transition: box-shadow 0.2s ease, background 0.2s ease;

		&:hover {
			box-shadow:
				0 0 0 1px #c5e2f2 inset,
				0 4px 12px rgba(0, 168, 232, 0.06) !important;
		}

		&.is-focus {
			background: #fff;
			box-shadow:
				0 0 0 2px rgba(0, 168, 232, 0.22) inset,
				0 10px 22px rgba(0, 168, 232, 0.12) !important;
		}
	}

	:deep(.el-input__inner::placeholder) {
		color: #9aa8b5;
	}

	.input-icon {
		width: 22px;
		height: 22px;
		border-radius: 8px;
		display: flex;
		align-items: center;
		justify-content: center;
		color: #8b93a7;
		background: rgba(0, 168, 232, 0.06);

		svg {
			width: 15px;
			height: 15px;
		}
	}

	:deep(.el-input__wrapper.is-focus) .input-icon {
		color: #00a8e8;
		background: rgba(0, 168, 232, 0.12);
	}
}

.login-captcha {
	margin-bottom: 12px !important;

	:deep(.el-form-item__content) {
		display: block;
		width: 100%;
		position: relative;
	}

	:deep(.el-form-item__error) {
		position: static;
		padding: 8px 4px 0;
		line-height: 1.35;
		font-size: 12px;
		text-align: center;
	}

	&.is-error {
		margin-bottom: 6px !important;
	}

	&:has(.slider-wrap) {
		margin-bottom: 8px !important;
	}

	&:has(.click-wrap),
	&:has(.word-wrap) {
		margin-bottom: 10px !important;
	}
}

.login-code {
	:deep(.el-form-item__content) {
		display: flex;
		gap: 12px;
	}

	:deep(.el-input) {
		flex: 1;
	}

	.code-btn {
		height: 50px;
		min-width: 118px;
		padding: 0 12px;
		border-radius: 13px;
		font-size: 13px;
		font-weight: 600;
		background: rgba(0, 168, 232, 0.09);
		border: 1px solid rgba(0, 168, 232, 0.22);
		color: #0090c8;
		flex-shrink: 0;
		transition: all 0.2s ease;

		&:hover {
			background: rgba(0, 168, 232, 0.15);
			border-color: rgba(0, 168, 232, 0.35);
		}

		.countdown {
			display: inline-flex;
			align-items: center;
			justify-content: center;
			min-width: 22px;
			font-weight: 700;
		}

		&:disabled {
			background: #eef2f6;
			border-color: #e5eef5;
			color: #9ca3af;
			cursor: not-allowed;
		}
	}
}

.login-button {
	margin-top: 6px;
	margin-bottom: 0 !important;

	:deep(.submit-btn.el-button--primary) {
		position: relative;
		overflow: hidden;
		width: 100%;
		height: 52px;
		font-size: 15px;
		font-weight: 700;
		letter-spacing: 4px;
		border-radius: 14px;
		border: none;
		background: linear-gradient(135deg, #0096d6 0%, #00a8e8 40%, #3ec6ff 100%);
		box-shadow:
			0 14px 28px rgba(0, 168, 232, 0.34),
			0 0 0 1px rgba(255, 255, 255, 0.12) inset,
			inset 0 1px 0 rgba(255, 255, 255, 0.4);
		transition: transform 0.2s ease, filter 0.2s ease, box-shadow 0.2s ease;

		&:hover {
			filter: brightness(1.05);
			transform: translateY(-2px);
			box-shadow:
				0 18px 36px rgba(0, 168, 232, 0.42),
				0 0 24px rgba(62, 198, 255, 0.2);

			.btn-sheen {
				transform: translateX(120%);
			}
		}
	}

	.btn-sheen {
		position: absolute;
		inset: 0 auto 0 -40%;
		width: 40%;
		background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.45), transparent);
		transform: translateX(-10%);
		transition: transform 0.65s ease;
		pointer-events: none;
	}

	.btn-text {
		position: relative;
		z-index: 1;
	}
}

</style>
