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
		<el-form-item prop="code" class="login-code">
			<el-input v-model="loginForm.code" :placeholder="$t('app.captcha')" size="large" maxlength="6">
				<template #prefix>
					<div class="input-icon">
						<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
							<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
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
import { ref, reactive, inject } from 'vue'
import { useUserStore } from '@/store/modules/user'
import { useSendCodeApi } from '@/api/auth'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { mobileRegExp } from '@/utils/validate'
import { ElMessage } from 'element-plus'
import constant from '@/utils/constant'
import cache from '@/utils/cache'

const userStore = useUserStore()
const loading = ref(false)
const ensureAgreement = inject<() => boolean>('ensureAgreement', () => true)
const setLoginLoading = inject<(val: boolean) => void>('setLoginLoading', () => undefined)

const sms = reactive({
	disabled: false,
	sending: false,
	total: 60,
	count: 0
})

const sendCode = async () => {
	if (!mobileRegExp.test(loginForm.mobile)) {
		ElMessage.error('请输入正确的手机号')
		return
	}

	if (!ensureAgreement()) {
		return
	}

	sms.sending = true
	try {
		const { data } = await useSendCodeApi(loginForm.mobile)
		timerHandler()
		// 模拟模式下后端会回传动态验证码，便于联调（非固定值）
		if (data) {
			loginForm.code = String(data)
			ElMessage.success('验证码已发送')
		} else {
			ElMessage.success('验证码已发送')
		}
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
		}
	}, 1000)
}

const router = useRouter()
const { t } = useI18n()
const loginFormRef = ref()

const loginForm = reactive({
	mobile: '13800138000',
	code: ''
})

const loginRules = ref({
	mobile: [{ required: true, message: t('required'), trigger: 'blur' }],
	code: [{ required: true, message: t('required'), trigger: 'blur' }]
})

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
			.mobileLoginAction(loginForm)
			.then(() => {
				router.push({ path: cache.getRedirect() || constant.loginPage })
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
