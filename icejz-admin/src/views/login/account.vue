<template>
	<el-form ref="loginFormRef" :model="loginForm" :rules="loginRules" class="login-form" @keyup.enter="onLogin">
		<el-form-item prop="username">
			<el-input v-model="loginForm.username" :placeholder="$t('app.username')" size="large">
				<template #prefix>
					<div class="input-icon">
						<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
							<path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
							<circle cx="12" cy="7" r="4" />
						</svg>
					</div>
				</template>
			</el-input>
		</el-form-item>

		<el-form-item prop="password">
			<el-input v-model="loginForm.password" show-password :placeholder="$t('app.password')" size="large">
				<template #prefix>
					<div class="input-icon">
						<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
							<rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
							<path d="M7 11V7a5 5 0 0 1 10 0v4" />
						</svg>
					</div>
				</template>
			</el-input>
		</el-form-item>

		<el-form-item v-if="captchaVisible" prop="captcha" class="login-captcha">
			<LoginCaptcha
				ref="captchaRef"
				v-model="loginForm.captcha"
				v-model:captcha-key="loginForm.key"
				channel="pc"
			/>
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
import { ref, reactive, onMounted, inject, watch } from 'vue'
import { useCaptchaEnabledApi } from '@/api/auth'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import constant from '@/utils/constant'
import { sm2Encrypt } from '@/utils/smCrypto'
import cache from '@/utils/cache'
import { useUserStore } from '@/store/modules/user'
import LoginCaptcha from './LoginCaptcha.vue'

const userStore = useUserStore()
const router = useRouter()
const { t } = useI18n()
const loginFormRef = ref()
const captchaRef = ref<{ refresh: () => Promise<void>; ensureVerified?: () => Promise<boolean> }>()
const loading = ref(false)
const ensureAgreement = inject<() => boolean>('ensureAgreement', () => true)
const setLoginLoading = inject<(val: boolean) => void>('setLoginLoading', () => undefined)

const loginForm = reactive({
	username: constant.env.PROD ? '' : 'admin',
	password: constant.env.PROD ? '' : '123456',
	key: '',
	captcha: ''
})

const loginRules = ref({
	username: [{ required: true, message: t('required'), trigger: 'blur' }],
	password: [{ required: true, message: t('required'), trigger: 'blur' }],
	captcha: [{ required: true, message: '请先确认验证码', trigger: 'change' }]
})

const captchaVisible = ref(false)

/** 交互验证码通过后清掉表单项错误，避免「验证通过」仍挂着必填提示 */
watch(
	() => loginForm.captcha,
	val => {
		if (val) {
			loginFormRef.value?.clearValidate?.('captcha')
		}
	}
)

onMounted(() => {
	onCaptchaEnabled()
})

const onCaptchaEnabled = async () => {
	const { data } = await useCaptchaEnabledApi()
	captchaVisible.value = data
}

const onLogin = () => {
	loginFormRef.value.validate(async (valid: boolean) => {
		if (!valid) {
			return false
		}

		if (!ensureAgreement()) {
			return false
		}

		if (captchaVisible.value) {
			const ok = await captchaRef.value?.ensureVerified?.()
			if (ok === false) {
				return false
			}
		}

		loading.value = true
		setLoginLoading(true)

		const loginData = {
			username: loginForm.username,
			password: sm2Encrypt(loginForm.password),
			key: loginForm.key,
			captcha: loginForm.captcha
		}

		userStore
			.accountLoginAction(loginData)
			.then(() => {
				const redirect = cache.getRedirect()
				cache.clearRedirect()
				router.push({ path: redirect || constant.loginPage })
			})
			.catch(() => {
				if (captchaVisible.value) {
					captchaRef.value?.refresh()
				}
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
		animation: field-in 0.45s ease both;

		&:nth-child(1) {
			animation-delay: 0.04s;
		}
		&:nth-child(2) {
			animation-delay: 0.1s;
		}
		&:nth-child(3) {
			animation-delay: 0.16s;
		}
		&:nth-child(4) {
			animation-delay: 0.22s;
		}
	}

	:deep(.el-form-item__error) {
		padding-top: 2px;
	}

	:deep(.el-input__wrapper) {
		min-height: 50px;
		border-radius: 14px !important;
		box-shadow:
			0 0 0 1px #e1edf5 inset,
			0 1px 2px rgba(15, 23, 36, 0.02) !important;
		background: linear-gradient(180deg, #ffffff, #f4f9fc);
		padding-left: 13px;
		transition: box-shadow 0.2s ease, background 0.2s ease, transform 0.2s ease;

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
		transition: all 0.2s ease;

		svg {
			width: 15px;
			height: 15px;
		}
	}

	:deep(.el-input__wrapper.is-focus) .input-icon {
		color: #00a8e8;
		background: rgba(0, 168, 232, 0.12);
		box-shadow: 0 0 0 4px rgba(0, 168, 232, 0.08);
	}
}

.login-captcha {
	margin-bottom: 12px !important;

	:deep(.el-form-item__content) {
		display: block;
		width: 100%;
		/* 错误文案走文档流，避免绝对定位挤进验证码与登录按钮夹缝 */
		position: relative;
	}

	:deep(.el-form-item__error) {
		position: static;
		padding: 8px 4px 0;
		line-height: 1.35;
		font-size: 12px;
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

	/* 滑动/点选已有面板内状态提示，表单错误改为底部轻提示，不再贴边重叠 */
	&:has(.slider-wrap),
	&:has(.click-wrap),
	&:has(.word-wrap),
	&:has(.pow-wrap),
	&:has(.turnstile-wrap) {
		:deep(.el-form-item__error) {
			padding: 6px 2px 2px;
			text-align: center;
			background: transparent;
		}
	}
}

.login-button {
	margin-top: 10px;
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

		&:active {
			transform: translateY(0);
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

@keyframes field-in {
	from {
		opacity: 0;
		transform: translateY(10px);
	}
	to {
		opacity: 1;
		transform: translateY(0);
	}
}

</style>
