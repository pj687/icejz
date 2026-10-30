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
							<span class="gender-art" aria-hidden="true" v-html="item.art"></span>
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
		art: `<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg">
			<defs>
				<linearGradient id="icejzMaleBg" x1="0" y1="0" x2="1" y2="1">
					<stop offset="0%" stop-color="#E8F7FD"/>
					<stop offset="100%" stop-color="#C8ECFA"/>
				</linearGradient>
				<linearGradient id="icejzMaleShirt" x1="0" y1="0" x2="0" y2="1">
					<stop offset="0%" stop-color="#5EC8F0"/>
					<stop offset="100%" stop-color="#00A8E8"/>
				</linearGradient>
			</defs>
			<circle cx="60" cy="60" r="54" fill="url(#icejzMaleBg)"/>
			<path d="M28 48c2-18 14-30 32-30s30 12 32 30c-6-8-18-12-32-12S34 40 28 48Z" fill="#3A4A5C"/>
			<path d="M26 52c4-10 14-16 34-16s30 6 34 16v6c0 20-14 34-34 34S26 78 26 58v-6Z" fill="#FFE0C8"/>
			<path d="M38 44c6-8 16-12 22-12 8 0 16 2 22 8-8-2-16-2-24 0-8 2-14 4-20 4Z" fill="#2E3B4A"/>
			<circle cx="46" cy="62" r="4.2" fill="#2B3645"/>
			<circle cx="74" cy="62" r="4.2" fill="#2B3645"/>
			<circle cx="47.3" cy="60.8" r="1.3" fill="#fff"/>
			<circle cx="75.3" cy="60.8" r="1.3" fill="#fff"/>
			<path d="M42 54c2.5-2 5-3 8-2.2" stroke="#2B3645" stroke-width="2" stroke-linecap="round" fill="none"/>
			<path d="M70 51.8c2.8-.6 5.4.2 8 2.4" stroke="#2B3645" stroke-width="2" stroke-linecap="round" fill="none"/>
			<path d="M54 72c2.2 2.4 6.2 2.4 8.4 0" stroke="#E0897A" stroke-width="2.2" stroke-linecap="round" fill="none"/>
			<path d="M34 96c6-14 16-20 26-20s20 6 26 20v10H34V96Z" fill="url(#icejzMaleShirt)"/>
			<path d="M52 76c2 5 6 8 8 8s6-3 8-8c-4 2-8 2-16 0Z" fill="#FFE0C8"/>
			<circle cx="44" cy="70" r="3.2" fill="#FFB4A3" opacity=".75"/>
			<circle cx="76" cy="70" r="3.2" fill="#FFB4A3" opacity=".75"/>
		</svg>`
	},
	{
		value: '1',
		label: '女士',
		desc: 'Female',
		tone: 'female',
		art: `<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg">
			<defs>
				<linearGradient id="icejzFemaleBg" x1="0" y1="0" x2="1" y2="1">
					<stop offset="0%" stop-color="#FFEAF2"/>
					<stop offset="100%" stop-color="#FFD3E4"/>
				</linearGradient>
			</defs>
			<circle cx="60" cy="60" r="54" fill="url(#icejzFemaleBg)"/>
			<path d="M22 56c2-24 16-38 38-38s36 14 38 38c-4-14-16-22-38-22S26 42 22 56Z" fill="#6B4A3A"/>
			<path d="M20 58c6-16 18-24 40-24s34 8 40 24v2c-2 24-18 40-40 40S22 84 20 60v-2Z" fill="#6B4A3A"/>
			<path d="M32 56c3-8 11-12 28-12s25 4 28 12v4c0 18-12 30-28 30S32 78 32 60v-4Z" fill="#FFE1CB"/>
			<path d="M28 52c8 2 16 0 22-2 8-2 16-2 24 0 4 1 10 2 16 2 0 0-4-14-18-20-8-4-18-4-26-1-10 4-18 14-18 21Z" fill="#5A3C30"/>
			<circle cx="48" cy="64" r="4.2" fill="#3A2A24"/>
			<circle cx="72" cy="64" r="4.2" fill="#3A2A24"/>
			<circle cx="49.3" cy="62.8" r="1.3" fill="#fff"/>
			<circle cx="73.3" cy="62.8" r="1.3" fill="#fff"/>
			<path d="M44 56c2.2-1.8 4.8-2.4 7.4-1.6" stroke="#3A2A24" stroke-width="1.8" stroke-linecap="round" fill="none"/>
			<path d="M68.6 54.4c2.4-.6 5-.2 7.4 1.6" stroke="#3A2A24" stroke-width="1.8" stroke-linecap="round" fill="none"/>
			<path d="M56 74c2 2.6 6 2.6 8 0" stroke="#E0897A" stroke-width="2.2" stroke-linecap="round" fill="none"/>
			<circle cx="46" cy="72" r="3.5" fill="#FF9CB8" opacity=".8"/>
			<circle cx="74" cy="72" r="3.5" fill="#FF9CB8" opacity=".8"/>
			<path d="M34 98c5-14 14-20 26-20s21 6 26 20v10H34V98Z" fill="#E887AD"/>
			<path d="M50 78c2 5 6 8 10 8s8-3 10-8c-5 2-10 2-20 0Z" fill="#FFE1CB"/>
			<path d="M42 42c-3-5-2-10 1-12 2 4 4 8 5 11-2 1-4 1-6 1Z" fill="#F4B4C8"/>
			<path d="M78 42c3-5 2-10-1-12-2 4-4 8-5 11 2 1 4 1 6 1Z" fill="#F4B4C8"/>
		</svg>`
	},
	{
		value: '2',
		label: '暂不透露',
		desc: 'Prefer not to say',
		tone: 'unknown',
		art: `<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg">
			<defs>
				<linearGradient id="icejzUnknownBg" x1="0" y1="0" x2="1" y2="1">
					<stop offset="0%" stop-color="#F0F5F9"/>
					<stop offset="100%" stop-color="#DDE7F0"/>
				</linearGradient>
				<linearGradient id="icejzUnknownBody" x1="0" y1="0" x2="0" y2="1">
					<stop offset="0%" stop-color="#B7C7D6"/>
					<stop offset="100%" stop-color="#8FA4B8"/>
				</linearGradient>
			</defs>
			<circle cx="60" cy="60" r="54" fill="url(#icejzUnknownBg)"/>
			<path d="M28 50c4-16 14-26 32-26s28 10 32 26c-6-8-16-12-32-12S34 42 28 50Z" fill="#A9B8C7"/>
			<path d="M30 54c3-10 12-16 30-16s27 6 30 16v4c0 18-12 32-30 32S30 76 30 58v-4Z" fill="#F2F6F9"/>
			<circle cx="47" cy="62" r="5" fill="#6E8498"/>
			<circle cx="73" cy="62" r="5" fill="#6E8498"/>
			<circle cx="48.4" cy="60.6" r="1.5" fill="#fff"/>
			<circle cx="74.4" cy="60.6" r="1.5" fill="#fff"/>
			<path d="M42 54c2.5-2 5.5-2.6 8.2-1.4" stroke="#6E8498" stroke-width="2" stroke-linecap="round" fill="none"/>
			<path d="M69.8 52.6c2.6-.8 5.4-.2 8.2 1.6" stroke="#6E8498" stroke-width="2" stroke-linecap="round" fill="none"/>
			<path d="M55 73h10" stroke="#91A4B6" stroke-width="2.4" stroke-linecap="round"/>
			<path d="M34 98c5-14 14-20 26-20s21 6 26 20v10H34V98Z" fill="url(#icejzUnknownBody)"/>
			<path d="M52 78c2 4 5 7 8 7s6-3 8-7c-4 2-8 2-16 0Z" fill="#F2F6F9"/>
			<circle cx="86" cy="36" r="12" fill="#fff" stroke="#A7B8C8" stroke-width="2"/>
			<text x="86" y="41" text-anchor="middle" font-size="14" font-weight="700" fill="#7B8FA3">?</text>
		</svg>`
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
		color: #334155;
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
	background: #f7fbfe;
	border: 1px solid #e4eef6;
	transition: border-color 0.18s ease, box-shadow 0.18s ease, background 0.18s ease;

	&:focus-within {
		background: #fff;
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
	border: 1px solid #e6eef5;
	background: linear-gradient(180deg, #ffffff 0%, #f7fbfe 100%);
	cursor: pointer;
	text-align: center;
	transition: transform 0.18s ease, border-color 0.18s ease, box-shadow 0.18s ease, background 0.18s ease;
}

.gender-card:hover {
	transform: translateY(-2px);
	box-shadow: 0 12px 24px rgba(15, 23, 36, 0.06);
}

.gender-art {
	width: 88px;
	height: 88px;
	display: grid;
	place-items: center;
	filter: drop-shadow(0 8px 14px rgba(15, 23, 36, 0.08));

	:deep(svg) {
		width: 88px;
		height: 88px;
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
