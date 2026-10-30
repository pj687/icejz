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
			<div class="captcha-row">
				<el-input
					v-model="loginForm.captcha"
					class="captcha-input"
					:placeholder="$t('app.captcha')"
					size="large"
					maxlength="8"
				>
					<template #prefix>
						<div class="input-icon">
							<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
								<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
							</svg>
						</div>
					</template>
				</el-input>
				<button type="button" class="captcha-box" title="点击刷新验证码" @click="onCaptcha">
					<img v-if="captchaBase64" :src="captchaBase64" alt="验证码" />
					<span v-else class="captcha-loading">加载中</span>
					<span class="captcha-refresh">刷新</span>
				</button>
			</div>
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
import { ref, reactive, onMounted, inject } from 'vue'
import { useCaptchaApi, useCaptchaEnabledApi } from '@/api/auth'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import constant from '@/utils/constant'
import { sm2Encrypt } from '@/utils/smCrypto'
import cache from '@/utils/cache'
import { useUserStore } from '@/store/modules/user'

const userStore = useUserStore()
const router = useRouter()
const { t } = useI18n()
const loginFormRef = ref()
const captchaBase64 = ref()
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
	captcha: [{ required: true, message: t('required'), trigger: 'blur' }]
})

const captchaVisible = ref(false)

onMounted(() => {
	onCaptchaEnabled()
})

const onCaptchaEnabled = async () => {
	const { data } = await useCaptchaEnabledApi()
	captchaVisible.value = data

	if (data) {
		await onCaptcha()
	}
}

const onCaptcha = async () => {
	const { data } = await useCaptchaApi()
	if (data.enabled) {
		captchaVisible.value = true
	}
	loginForm.key = data.key
	captchaBase64.value = data.image
}

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

		const loginData = {
			username: loginForm.username,
			password: sm2Encrypt(loginForm.password),
			key: loginForm.key,
			captcha: loginForm.captcha
		}

		userStore
			.accountLoginAction(loginData)
			.then(() => {
				router.push({ path: cache.getRedirect() || constant.loginPage })
			})
			.catch(() => {
				if (captchaVisible.value) {
					onCaptcha()
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
	:deep(.el-form-item__content) {
		display: block;
		width: 100%;
	}
}

.captcha-row {
	display: grid;
	grid-template-columns: minmax(0, 1fr) 200px;
	gap: 12px;
	width: 100%;
	align-items: stretch;
}

.captcha-input {
	width: 100%;
	min-width: 0;
}

.captcha-box {
	position: relative;
	width: 200px;
	min-height: 50px;
	height: 50px;
	padding: 0;
	border: 1px solid #d4e6f2;
	border-radius: 13px;
	overflow: hidden;
	cursor: pointer;
	background:
		linear-gradient(135deg, rgba(0, 168, 232, 0.06), transparent),
		#eef5fa;
	box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.7);
	flex-shrink: 0;
	transition: border-color 0.2s ease, box-shadow 0.2s ease;

	img {
		width: 100%;
		height: 100%;
		object-fit: cover;
		display: block;
	}

	.captcha-loading {
		display: flex;
		align-items: center;
		justify-content: center;
		height: 100%;
		font-size: 12px;
		color: #8b93a7;
	}

	.captcha-refresh {
		position: absolute;
		right: 8px;
		bottom: 6px;
		padding: 3px 9px;
		border-radius: 999px;
		font-size: 11px;
		color: #fff;
		background: rgba(0, 144, 200, 0.78);
		opacity: 0;
		transform: translateY(4px);
		transition: all 0.2s ease;
	}

	&:hover {
		border-color: rgba(0, 168, 232, 0.45);
		box-shadow: 0 8px 18px rgba(0, 168, 232, 0.12);

		.captcha-refresh {
			opacity: 1;
			transform: translateY(0);
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

@media (max-width: 480px) {
	.captcha-row {
		grid-template-columns: minmax(0, 1fr) 150px;
	}

	.captcha-box {
		width: 150px;
	}
}
</style>
