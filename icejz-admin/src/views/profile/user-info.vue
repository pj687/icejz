<template>
	<div class="profile-panel">
		<div class="panel-hint">
			<span class="hint-dot"></span>
			完善基本资料有助于同事识别与联系你
		</div>

		<el-form ref="dataFormRef" class="profile-form" :model="dataForm" :rules="dataRules" label-position="top">
			<div class="form-grid">
				<el-form-item prop="realName" label="姓名">
					<div class="field-shell">
						<span class="field-icon"><ma-icon icon="icon-user" /></span>
						<el-input v-model="dataForm.realName" placeholder="请输入真实姓名" maxlength="32" />
					</div>
				</el-form-item>

				<el-form-item prop="mobile" label="手机">
					<div class="field-shell">
						<span class="field-icon"><ma-icon icon="icon-phone" /></span>
						<el-input v-model="dataForm.mobile" placeholder="请输入手机号码" maxlength="20" />
					</div>
				</el-form-item>

				<el-form-item prop="email" label="邮箱" class="span-2">
					<div class="field-shell">
						<span class="field-icon"><ma-icon icon="icon-mail" /></span>
						<el-input v-model="dataForm.email" placeholder="请输入邮箱地址" maxlength="64" />
					</div>
				</el-form-item>

				<el-form-item prop="gender" label="性别" class="span-2 gender-item">
					<div class="gender-grid" role="radiogroup" aria-label="性别">
						<button
							v-for="item in genderOptions"
							:key="item.value"
							type="button"
							class="gender-card"
							:class="[item.tone, { active: String(dataForm.gender) === item.value }]"
							role="radio"
							:aria-checked="String(dataForm.gender) === item.value"
							@click="dataForm.gender = Number(item.value)"
						>
							<span class="gender-art" aria-hidden="true">
								<img :src="item.art" :alt="item.label" width="96" height="96" draggable="false" />
							</span>
							<span class="gender-text">
								<strong>{{ item.label }}</strong>
								<em>{{ item.desc }}</em>
							</span>
							<span class="gender-check" aria-hidden="true">
								<svg viewBox="0 0 24 24" fill="none">
									<path
										d="M5 12.5l4.2 4.2L19 7"
										stroke="currentColor"
										stroke-width="2.4"
										stroke-linecap="round"
										stroke-linejoin="round"
									/>
								</svg>
							</span>
						</button>
					</div>
				</el-form-item>
			</div>

			<div class="form-actions">
				<el-button type="primary" class="save-btn" @click="handleDataForm">保存资料</el-button>
			</div>
		</el-form>
	</div>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { validatePassword } from '@/utils/validate'
import { useUserInfoSubmitApi } from '@/api/sys/user'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/store/modules/user'

const userStore = useUserStore()
const { t } = useI18n()
const dataFormRef: any = ref(null)

const dataForm = reactive({
	realName: userStore.user.realName,
	mobile: userStore.user.mobile,
	email: userStore.user.email,
	gender: userStore.user.gender
})

const genderOptions = [
	{
		value: '0',
		label: '男士',
		desc: 'Male',
		tone: 'male',
		art: '/profile/gender-male.jpg'
	},
	{
		value: '2',
		label: '暂不透露',
		desc: 'Prefer not to say',
		tone: 'unknown',
		art: '/profile/gender-unknown.jpg'
	},
	{
		value: '1',
		label: '女士',
		desc: 'Female',
		tone: 'female',
		art: '/profile/gender-female.jpg'
	}
]

const dataRules = ref({
	realName: [{ required: true, message: t('required'), trigger: 'blur' }],
	mobile: [{ required: true, validator: validatePassword, trigger: 'blur' }]
})

const handleDataForm = () => {
	dataFormRef.value.validate((valid: boolean) => {
		if (!valid) {
			return false
		}

		useUserInfoSubmitApi(dataForm).then(() => {
			userStore.user.realName = dataForm.realName
			userStore.user.mobile = dataForm.mobile
			userStore.user.email = dataForm.email
			userStore.user.gender = dataForm.gender
			ElMessage.success('资料已更新')
		})
	})
}
</script>

<style scoped lang="scss">
.profile-panel {
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
	margin-bottom: 20px;
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

.form-grid {
	display: grid;
	grid-template-columns: repeat(2, minmax(0, 1fr));
	gap: 8px 16px;
}

.span-2 {
	grid-column: 1 / -1;
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

.gender-item {
	:deep(.el-form-item__content) {
		display: block;
	}
}

.gender-grid {
	display: grid;
	grid-template-columns: repeat(3, minmax(0, 1fr));
	gap: 12px;
	width: 100%;
}

.gender-card {
	position: relative;
	display: flex;
	flex-direction: column;
	align-items: center;
	gap: 10px;
	padding: 16px 12px 14px;
	border-radius: 18px;
	border: 1px solid var(--line, #e6eef5);
	background: linear-gradient(180deg, var(--panel, #fff) 0%, var(--soft, #f7fbfe) 100%);
	cursor: pointer;
	text-align: center;
	transition: transform 0.18s ease, border-color 0.18s ease, box-shadow 0.18s ease, background 0.18s ease;
}

.gender-card:hover {
	transform: translateY(-1px);
	box-shadow: 0 8px 18px rgba(15, 23, 36, 0.05);
}

.gender-art {
	width: 96px;
	height: 96px;
	border-radius: 50%;
	overflow: hidden;
	display: grid;
	place-items: center;
	box-shadow: 0 10px 18px rgba(15, 23, 36, 0.08);

	img {
		width: 96px;
		height: 96px;
		object-fit: cover;
		display: block;
		user-select: none;
		pointer-events: none;
	}
}

.gender-text {
	display: flex;
	flex-direction: column;
	gap: 2px;

	strong {
		font-size: 15px;
		color: #122033;
		font-weight: 720;
	}
	em {
		font-style: normal;
		font-size: 12px;
		color: #7a8796;
	}
}

.gender-check {
	position: absolute;
	top: 10px;
	right: 10px;
	width: 22px;
	height: 22px;
	border-radius: 50%;
	display: grid;
	place-items: center;
	color: transparent;
	background: rgba(15, 23, 36, 0.06);
	transition: 0.18s ease;

	svg {
		width: 12px;
		height: 12px;
	}
}

.gender-card.active {
	border-color: transparent;
	box-shadow: 0 14px 28px rgba(0, 168, 232, 0.14);

	.gender-check {
		color: #fff;
	}
}

.gender-card.male.active {
	background: linear-gradient(180deg, rgba(0, 168, 232, 0.12), #fff);
	box-shadow: 0 14px 28px rgba(0, 168, 232, 0.16);
	outline: 2px solid rgba(0, 168, 232, 0.45);

	.gender-check {
		background: #00a8e8;
	}
}

.gender-card.female.active {
	background: linear-gradient(180deg, rgba(226, 138, 173, 0.14), #fff);
	box-shadow: 0 14px 28px rgba(226, 138, 173, 0.16);
	outline: 2px solid rgba(226, 138, 173, 0.45);

	.gender-check {
		background: #e28aad;
	}
}

.gender-card.unknown.active {
	background: linear-gradient(180deg, rgba(138, 160, 180, 0.16), #fff);
	box-shadow: 0 14px 28px rgba(96, 119, 137, 0.12);
	outline: 2px solid rgba(138, 160, 180, 0.55);

	.gender-check {
		background: #8aa0b4;
	}
}

.form-actions {
	margin-top: 10px;
	padding-top: 4px;
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

@media (max-width: 720px) {
	.form-grid,
	.gender-grid {
		grid-template-columns: 1fr;
	}
}
</style>
