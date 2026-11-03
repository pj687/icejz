<template>
	<div class="profile-panel">
		<div class="panel-hint">
			<span class="hint-dot"></span>
			建议使用 8 位以上，包含字母与数字的强密码，并定期更换
		</div>

		<div class="secure-banner">
			<div class="secure-art" aria-hidden="true">
				<svg viewBox="0 0 88 88" xmlns="http://www.w3.org/2000/svg">
					<defs>
						<linearGradient id="pwdShield" x1="0" y1="0" x2="1" y2="1">
							<stop offset="0%" stop-color="#E8F7FD" />
							<stop offset="100%" stop-color="#C8ECFA" />
						</linearGradient>
					</defs>
					<circle cx="44" cy="44" r="40" fill="url(#pwdShield)" />
					<path
						d="M44 18l22 8v16c0 14-9 24-22 28-13-4-22-14-22-28V26l22-8z"
						fill="#00A8E8"
						opacity=".9"
					/>
					<path
						d="M36 44l6 6 12-14"
						fill="none"
						stroke="#fff"
						stroke-width="3.2"
						stroke-linecap="round"
						stroke-linejoin="round"
					/>
				</svg>
			</div>
			<div class="secure-copy">
				<strong>账号安全保障</strong>
				<p>修改密码后，其他设备可能需要重新登录。请妥善保管新密码。</p>
			</div>
		</div>

		<el-form ref="dataFormRef" class="profile-form" :model="dataForm" :rules="dataRules" label-position="top">
			<el-form-item prop="password" :label="$t('profile.oldPassword')">
				<div class="field-shell">
					<span class="field-icon"><ma-icon icon="icon-lock" /></span>
					<el-input v-model="dataForm.password" type="password" show-password placeholder="请输入当前密码" />
				</div>
			</el-form-item>

			<el-form-item prop="newPassword" :label="$t('profile.newPassword')">
				<div class="field-shell">
					<span class="field-icon"><ma-icon icon="icon-password" /></span>
					<el-input
						v-model="dataForm.newPassword"
						type="password"
						show-password
						placeholder="请输入新密码"
					/>
				</div>
				<div class="strength">
					<div class="strength-bars">
						<span v-for="n in 4" :key="n" :class="['bar', { on: strengthLevel >= n, ['l' + strengthLevel]: strengthLevel >= n }]"></span>
					</div>
					<em>{{ strengthText }}</em>
				</div>
			</el-form-item>

			<el-form-item prop="confirmPassword" :label="$t('profile.confirmPassword')">
				<div class="field-shell">
					<span class="field-icon"><ma-icon icon="icon-check-square-fill" /></span>
					<el-input v-model="dataForm.confirmPassword" type="password" show-password placeholder="请再次输入新密码" />
				</div>
			</el-form-item>

			<ul class="tips">
				<li :class="{ ok: tipStates.length }">不少于 8 位字符</li>
				<li :class="{ ok: tipStates.letter }">包含字母</li>
				<li :class="{ ok: tipStates.number }">包含数字</li>
				<li :class="{ ok: tipStates.match }">两次输入一致</li>
			</ul>

			<div class="form-actions">
				<el-button type="primary" class="save-btn" @click="handleDataForm">确认修改</el-button>
			</div>
		</el-form>
	</div>
</template>

<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { validatePassword } from '@/utils/validate'
import { updatePasswordApi } from '@/api/sys/user'
import { ElMessage } from 'element-plus'

const { t } = useI18n()
const dataFormRef: any = ref(null)

const dataForm = reactive({
	password: '',
	newPassword: '',
	confirmPassword: ''
})

const tipStates = computed(() => {
	const pwd = dataForm.newPassword || ''
	return {
		length: pwd.length >= 8,
		letter: /[a-zA-Z]/.test(pwd),
		number: /\d/.test(pwd),
		match: !!pwd && pwd === dataForm.confirmPassword
	}
})

const strengthLevel = computed(() => {
	const pwd = dataForm.newPassword || ''
	if (!pwd) return 0
	let score = 0
	if (pwd.length >= 8) score++
	if (/[a-zA-Z]/.test(pwd)) score++
	if (/\d/.test(pwd)) score++
	if (/[^a-zA-Z0-9]/.test(pwd) || pwd.length >= 12) score++
	return score
})

const strengthText = computed(() => {
	const map = ['输入新密码', '较弱', '一般', '较强', '很强']
	return map[strengthLevel.value] || '输入新密码'
})

const dataRules = ref({
	password: [{ required: true, message: t('required'), trigger: 'blur' }],
	newPassword: [{ required: true, validator: validatePassword, trigger: 'blur' }],
	confirmPassword: [{ required: true, message: t('required'), trigger: 'blur' }]
})

const handleDataForm = () => {
	dataFormRef.value.validate((valid: boolean) => {
		if (!valid) {
			return false
		}
		if (dataForm.newPassword !== dataForm.confirmPassword) {
			ElMessage.warning('两次输入的新密码不一致')
			return false
		}

		updatePasswordApi(dataForm).then(() => {
			ElMessage.success('密码修改成功')
			dataForm.password = ''
			dataForm.newPassword = ''
			dataForm.confirmPassword = ''
			dataFormRef.value?.clearValidate?.()
		})
	})
}
</script>

<style scoped lang="scss">
.profile-panel {
	max-width: 480px;
	animation: panel-in 0.28s ease;
}

@keyframes panel-in {
	from {
		opacity: 0;
		transform: translateY(6px);
	}
	to {
		opacity: 1;
		transform: none;
	}
}

.panel-hint {
	display: flex;
	align-items: center;
	gap: 8px;
	margin-bottom: 16px;
	padding: 12px 14px;
	border-radius: 14px;
	font-size: 12.5px;
	color: #5f7386;
	background: linear-gradient(135deg, rgba(0, 168, 232, 0.08), rgba(62, 198, 255, 0.04));
	border: 1px solid rgba(0, 168, 232, 0.12);
}

.hint-dot {
	width: 7px;
	height: 7px;
	border-radius: 50%;
	background: #00a8e8;
	box-shadow: 0 0 0 4px rgba(0, 168, 232, 0.15);
}

.secure-banner {
	display: flex;
	align-items: center;
	gap: 12px;
	margin-bottom: 18px;
	padding: 12px 14px;
	border-radius: 16px;
	background: var(--soft, #f7fbfe);
	border: 1px solid var(--line, #e4eef6);
}

.secure-art {
	width: 56px;
	height: 56px;
	flex-shrink: 0;

	svg {
		width: 56px;
		height: 56px;
	}
}

.secure-copy {
	strong {
		display: block;
		margin-bottom: 4px;
		font-size: 14px;
		color: var(--ink, #122033);
	}
	p {
		margin: 0;
		font-size: 12px;
		line-height: 1.55;
		color: #6b7785;
	}
}

.profile-form {
	:deep(.el-form-item__label) {
		font-weight: 650;
		color: var(--ink, #334155);
		padding-bottom: 6px;
	}

	:deep(.el-form-item) {
		margin-bottom: 14px;
	}

	:deep(.el-input__wrapper) {
		padding-left: 0;
		box-shadow: none !important;
		background: transparent;
	}

	:deep(.el-input__inner) {
		height: 42px;
	}
}

.field-shell {
	display: flex;
	align-items: center;
	gap: 8px;
	width: 100%;
	padding: 0 12px 0 10px;
	border-radius: 14px;
	background: var(--soft, #f7fbfe);
	border: 1px solid var(--line, #e4eef6);
	transition: border-color 0.18s ease, box-shadow 0.18s ease, background 0.18s ease;

	&:focus-within {
		background: var(--panel, var(--icejz-card-bg, #fff));
		border-color: #00a8e8;
		box-shadow: 0 0 0 3px rgba(0, 168, 232, 0.12);
	}
}

.field-icon {
	width: 28px;
	height: 28px;
	border-radius: 9px;
	display: grid;
	place-items: center;
	color: #00a8e8;
	background: rgba(0, 168, 232, 0.1);
	flex-shrink: 0;
	font-size: 14px;
}

.strength {
	display: flex;
	align-items: center;
	gap: 10px;
	margin-top: 8px;
}

.strength-bars {
	display: grid;
	grid-template-columns: repeat(4, 1fr);
	gap: 6px;
	flex: 1;
}

.bar {
	height: 6px;
	border-radius: 999px;
	background: #e8eef5;
}

.bar.on.l1 {
	background: #f56c6c;
}
.bar.on.l2 {
	background: #eb6709;
}
.bar.on.l3 {
	background: #00a8e8;
}
.bar.on.l4 {
	background: #11c26d;
}

.strength em {
	font-style: normal;
	font-size: 12px;
	color: #7a8796;
	min-width: 48px;
	text-align: right;
}

.tips {
	list-style: none;
	margin: 0 0 8px;
	padding: 12px;
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 8px 12px;
	border-radius: 14px;
	background: var(--soft, #f8fbfd);
	border: 1px solid var(--line, #eaf1f7);

	li {
		position: relative;
		padding-left: 18px;
		font-size: 12px;
		color: #7a8796;

		&::before {
			content: '';
			position: absolute;
			left: 0;
			top: 4px;
			width: 10px;
			height: 10px;
			border-radius: 50%;
			background: #dbe4ee;
		}

		&.ok {
			color: #0f766e;
			&::before {
				background: #11c26d;
			}
		}
	}
}

.form-actions {
	margin-top: 8px;
}

.save-btn {
	min-width: 132px;
	height: 40px;
	border-radius: 12px;
	border: none;
	font-weight: 650;
	background: linear-gradient(135deg, #00a8e8, #2bbef5);
	box-shadow: 0 10px 22px rgba(0, 168, 232, 0.28);
}

@media (max-width: 520px) {
	.tips {
		grid-template-columns: 1fr;
	}
}
</style>
