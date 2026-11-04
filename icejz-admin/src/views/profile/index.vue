<template>
	<div class="profile-page">
		<section class="profile-hero">
			<div class="hero-content">
				<div class="hero-avatar" :class="{ empty: !userStore.user.avatar, uploading: avatarUploading }">
					<button
						type="button"
						class="avatar-btn"
						:disabled="avatarUploading"
						:aria-label="userStore.user.avatar ? '查看头像' : '上传头像'"
						@click="onAvatarClick"
					>
						<img
							v-if="userStore.user.avatar"
							class="avatar-img"
							:src="userStore.user.avatar"
							alt="用户头像"
						/>
						<span v-else class="avatar-empty">
							<el-icon><Avatar /></el-icon>
							<em>上传头像</em>
						</span>
						<span class="avatar-veil" aria-hidden="true">
							<span class="veil-card">
								<template v-if="avatarUploading">
									<em>上传中…</em>
								</template>
								<template v-else-if="userStore.user.avatar">
									<el-icon><ZoomIn /></el-icon>
									<em>查看大图</em>
								</template>
								<template v-else>
									<el-icon><Camera /></el-icon>
									<em>上传头像</em>
								</template>
							</span>
						</span>
					</button>
					<button
						v-if="userStore.user.avatar"
						type="button"
						class="avatar-change"
						:disabled="avatarUploading"
						aria-label="更换头像"
						title="更换头像"
						@click.stop="pickAvatar"
					>
						<el-icon><Camera /></el-icon>
					</button>
					<span class="avatar-ring" aria-hidden="true"></span>
					<input
						ref="avatarInputRef"
						class="avatar-input"
						type="file"
						accept="image/jpeg,image/png,image/gif,image/webp"
						@change="onAvatarChange"
					/>
				</div>

				<el-image-viewer
					v-if="avatarPreviewVisible && userStore.user.avatar"
					teleported
					:z-index="5000"
					:url-list="[userStore.user.avatar]"
					@close="avatarPreviewVisible = false"
				/>

				<div class="hero-meta">
					<span class="hero-kicker">个人资料</span>
					<h1>{{ userStore.user.realName || userStore.user.username }}</h1>
					<p class="hero-sub">
						<span class="handle">@{{ userStore.user.username }}</span>
						<span class="dot" aria-hidden="true"></span>
						<span>{{ userStore.user.orgName || '未分配机构' }}</span>
					</p>
					<div class="hero-chips">
						<span class="chip primary">{{ postLabel }}</span>
						<span class="chip">入驻 {{ createDate }}</span>
					</div>
				</div>

				<div class="hero-contact" aria-label="联系方式">
					<div class="contact-item">
						<span class="contact-label">手机</span>
						<span class="contact-value">{{ userStore.user.mobile || '未填写' }}</span>
					</div>
					<span class="contact-rule" aria-hidden="true"></span>
					<div class="contact-item">
						<span class="contact-label">邮箱</span>
						<span class="contact-value">{{ userStore.user.email || '未填写' }}</span>
					</div>
				</div>
			</div>
		</section>

		<div class="profile-grid">
			<aside class="profile-side">
				<section class="side-panel overview-panel">
					<header class="side-head">
						<strong>账号概览</strong>
						<span>基础身份信息</span>
					</header>
					<div v-for="group in overviewGroups" :key="group.title" class="info-group">
						<h3>{{ group.title }}</h3>
						<div class="info-grid">
							<article
								v-for="item in group.items"
								:key="item.label"
								class="info-cell"
								:class="{ wide: item.wide }"
							>
								<span class="label">{{ item.label }}</span>
								<strong
									class="value"
									:class="{ nowrap: item.wide && !item.email, email: item.email }"
									:title="String(item.value || '')"
								>
									{{ item.value }}
								</strong>
							</article>
						</div>
					</div>
				</section>

				<section class="side-panel tip-panel">
					<span class="tip-badge">安全提示</span>
					<p>定期更新密码，勿共享账号。绑定第三方登录可提升登录便利性。</p>
				</section>
			</aside>

			<main class="profile-main">
				<section class="main-panel">
					<nav class="tab-rail" aria-label="个人中心功能">
						<button
							v-for="tab in tabs"
							:key="tab.name"
							type="button"
							class="tab-btn"
							:class="{ active: activeName === tab.name }"
							@click="activeName = tab.name"
						>
							<span class="tab-icon"><ma-icon :icon="tab.icon" /></span>
							<span class="tab-copy">
								<strong>{{ tab.label }}</strong>
								<em>{{ tab.desc }}</em>
							</span>
						</button>
					</nav>

					<div class="panel-stage">
						<header class="stage-head">
							<div>
								<h2>{{ currentTab?.label }}</h2>
								<p>{{ currentTab?.desc }}</p>
							</div>
						</header>

						<div
							class="stage-body"
							:class="{ wide: activeName === 'third' || activeName === 'signature' || activeName === 'devices' }"
						>
							<UserInfo v-if="activeName === 'info'" />
							<Password v-else-if="activeName === 'password'" />
							<Devices v-else-if="activeName === 'devices'" />
							<Signature v-else-if="activeName === 'signature'" />
							<ThirdLogin v-else-if="activeName === 'third'" />
						</div>
					</div>
				</section>
			</main>
		</div>
	</div>
</template>

<script setup lang="ts" name="ProfileIndex">
import { computed, ref } from 'vue'
import { Avatar, Camera, ZoomIn } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/modules/user'
import Password from '@/views/profile/password.vue'
import UserInfo from '@/views/profile/user-info.vue'
import Devices from '@/views/profile/devices.vue'
import Signature from '@/views/profile/signature.vue'
import ThirdLogin from '@/views/profile/third-login.vue'
import { useUserAvatarApi } from '@/api/sys/user'
import { uploadImg } from '@/api/sys/upload'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const activeName = ref('info')
const avatarInputRef = ref<HTMLInputElement | null>(null)
const avatarUploading = ref(false)
const avatarPreviewVisible = ref(false)

const pickAvatar = () => {
	if (avatarUploading.value) {
		return
	}
	avatarInputRef.value?.click()
}

const onAvatarClick = () => {
	if (avatarUploading.value) {
		return
	}
	if (userStore.user.avatar) {
		avatarPreviewVisible.value = true
		return
	}
	pickAvatar()
}

const onAvatarChange = async (event: Event) => {
	const input = event.target as HTMLInputElement
	const file = input.files?.[0]
	input.value = ''
	if (!file) {
		return
	}

	const allow = ['image/jpeg', 'image/png', 'image/gif', 'image/webp']
	if (!allow.includes(file.type)) {
		ElMessage.warning('请上传 JPG / PNG / GIF / WEBP 图片')
		return
	}
	if (file.size > 5 * 1024 * 1024) {
		ElMessage.warning('图片大小不能超过 5MB')
		return
	}

	const formData = new FormData()
	formData.append('file', file)
	avatarUploading.value = true
	try {
		const { data } = await uploadImg(formData)
		await useUserAvatarApi({ avatar: data.url })
		userStore.user.avatar = data.url
		ElMessage.success('头像更新成功')
	} catch {
		ElMessage.error('头像上传失败，请重试')
	} finally {
		avatarUploading.value = false
	}
}

const tabs = [
	{ name: 'info', label: '基本资料', desc: '姓名、手机与邮箱', icon: 'icon-user' },
	{ name: 'password', label: '修改密码', desc: '提升账号安全性', icon: 'icon-lock' },
	{ name: 'devices', label: '登录设备', desc: '多设备偏好与会话', icon: 'icon-mobile' },
	{ name: 'signature', label: '个人签名', desc: '审批与文书使用', icon: 'icon-edit' },
	{ name: 'third', label: '第三方登录', desc: '企微 / 钉钉等', icon: 'icon-link' }
]

const currentTab = computed(() => tabs.find((t) => t.name === activeName.value) || tabs[0])

const postLabel = computed(() => {
	const list = userStore.user.postNameList
	if (Array.isArray(list)) {
		return list.filter(Boolean).join(' / ') || '未分配岗位'
	}
	return list || '未分配岗位'
})

const createDate = computed(() => {
	const t = userStore.user.createTime
	return t ? String(t).slice(0, 10) : '—'
})

const createDateTime = computed(() => {
	const t = userStore.user.createTime
	if (!t) {
		return '—'
	}
	return String(t).replace('T', ' ').replace(/\.\d+$/, '').slice(0, 19)
})

const overviewGroups = computed(() => [
	{
		title: '账号',
		items: [
			{ label: '用户名', value: userStore.user.username || '—' },
			{ label: '姓名', value: userStore.user.realName || '—' },
			{ label: '手机号码', value: userStore.user.mobile || '—' },
			{ label: '用户邮箱', value: userStore.user.email || '—', wide: true, email: true }
		]
	},
	{
		title: '组织',
		items: [
			{ label: '所属机构', value: userStore.user.orgName || '—' },
			{ label: '所属岗位', value: postLabel.value },
			{ label: '创建日期', value: createDateTime.value, wide: true }
		]
	}
])

</script>

<style scoped lang="scss">
.profile-page {
	--ink: #122033;
	--muted: #64748b;
	--line: #e8eef5;
	--soft: #f7fbfe;
	--panel: #fff;
	--brand: #00a8e8;
	--brand-deep: #007eb8;
	display: flex;
	flex-direction: column;
	gap: 16px;
	min-height: 100%;
	padding: 2px 2px 20px;
	animation: rise 0.35s ease both;
}

@keyframes rise {
	from {
		opacity: 0;
		transform: translateY(8px);
	}
	to {
		opacity: 1;
		transform: none;
	}
}

.profile-hero {
	border-radius: 20px;
	border: 1px solid rgba(0, 168, 232, 0.14);
	background:
		radial-gradient(120% 160% at 0% 0%, rgba(0, 168, 232, 0.14), transparent 55%),
		linear-gradient(135deg, color-mix(in srgb, var(--brand) 8%, var(--panel)), var(--panel) 48%, var(--soft));
	box-shadow: 0 12px 28px rgba(15, 23, 36, 0.04);
	overflow: hidden;
}

.hero-content {
	display: grid;
	grid-template-columns: auto minmax(0, 1fr) auto;
	gap: 20px;
	align-items: center;
	padding: 22px 24px;
}

.hero-avatar {
	position: relative;
	width: 120px;
	height: 120px;
	flex-shrink: 0;
}

.avatar-btn {
	position: relative;
	z-index: 1;
	display: grid;
	place-items: center;
	width: 112px;
	height: 112px;
	margin: 4px;
	padding: 0;
	overflow: hidden;
	border: none;
	border-radius: 50%;
	background: var(--panel);
	box-shadow: 0 8px 18px rgba(15, 23, 36, 0.08);
	cursor: pointer;
	transition: box-shadow 0.22s ease, transform 0.22s ease;

	&:hover,
	&:focus-visible {
		transform: translateY(-1px);
		box-shadow: 0 12px 24px rgba(0, 168, 232, 0.18);
		outline: none;

		.avatar-veil {
			opacity: 1;
		}

		.veil-card {
			transform: translateY(0);
			opacity: 1;
		}

		.avatar-img {
			transform: scale(1.03);
		}
	}

	&:disabled {
		cursor: wait;
	}
}

.avatar-img {
	width: 100%;
	height: 100%;
	object-fit: cover;
	display: block;
	transition: transform 0.28s ease;
}

.avatar-empty {
	display: grid;
	justify-items: center;
	gap: 4px;
	color: var(--brand-deep);

	.el-icon {
		font-size: 28px;
		color: var(--brand);
	}

	em {
		font-style: normal;
		font-size: 12px;
		font-weight: 650;
	}
}

.avatar-veil {
	position: absolute;
	inset: 0;
	display: grid;
	place-items: center;
	background: linear-gradient(180deg, rgba(0, 126, 184, 0.08), rgba(8, 36, 52, 0.58));
	opacity: 0;
	transition: opacity 0.2s ease;
}

.veil-card {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	padding: 7px 12px;
	border-radius: 999px;
	color: #fff;
	background: rgba(255, 255, 255, 0.16);
	border: 1px solid rgba(255, 255, 255, 0.22);
	backdrop-filter: blur(6px);
	box-shadow: 0 8px 18px rgba(8, 28, 42, 0.18);
	opacity: 0;
	transform: translateY(6px);
	transition: opacity 0.2s ease, transform 0.2s ease;

	.el-icon {
		font-size: 14px;
	}

	em {
		font-style: normal;
		font-size: 12px;
		font-weight: 700;
		letter-spacing: 0.02em;
	}
}

.avatar-change {
	position: absolute;
	right: 2px;
	bottom: 2px;
	z-index: 2;
	display: grid;
	place-items: center;
	width: 34px;
	height: 34px;
	padding: 0;
	border: 2px solid #fff;
	border-radius: 50%;
	color: #fff;
	background: linear-gradient(145deg, #00a8e8, #007eb8);
	box-shadow: 0 8px 16px rgba(0, 126, 184, 0.28);
	cursor: pointer;
	transition: transform 0.2s ease, box-shadow 0.2s ease;

	.el-icon {
		font-size: 15px;
	}

	&:hover,
	&:focus-visible {
		transform: translateY(-1px) scale(1.04);
		box-shadow: 0 10px 18px rgba(0, 126, 184, 0.34);
		outline: none;
	}

	&:disabled {
		cursor: wait;
		opacity: 0.72;
	}
}

.avatar-ring {
	position: absolute;
	inset: 0;
	border-radius: 50%;
	border: 1px solid rgba(0, 168, 232, 0.2);
	box-shadow: 0 0 0 4px rgba(0, 168, 232, 0.07);
	pointer-events: none;
	transition: border-color 0.22s ease, box-shadow 0.22s ease;
}

.hero-avatar:hover .avatar-ring,
.hero-avatar:focus-within .avatar-ring,
.hero-avatar.uploading .avatar-ring {
	border-color: rgba(0, 168, 232, 0.42);
	box-shadow: 0 0 0 5px rgba(0, 168, 232, 0.12);
}

.hero-avatar.uploading {
	.avatar-veil,
	.veil-card {
		opacity: 1;
		transform: none;
	}
}

.avatar-input {
	display: none;
}

.hero-meta {
	min-width: 0;
}

.hero-kicker {
	display: inline-block;
	margin-bottom: 6px;
	padding: 3px 8px;
	border-radius: 6px;
	font-size: 11px;
	font-weight: 700;
	letter-spacing: 0.02em;
	color: var(--brand-deep);
	background: rgba(0, 168, 232, 0.1);
}

.hero-meta h1 {
	margin: 0;
	font-size: 24px;
	line-height: 1.25;
	font-weight: 750;
	color: var(--ink);
}

.hero-sub {
	display: flex;
	flex-wrap: wrap;
	align-items: center;
	gap: 8px;
	margin: 8px 0 12px;
	font-size: 13px;
	color: var(--muted);

	.handle {
		font-weight: 650;
		color: #475569;
	}

	.dot {
		width: 3px;
		height: 3px;
		border-radius: 50%;
		background: #94a3b8;
	}
}

.hero-chips {
	display: flex;
	flex-wrap: wrap;
	gap: 8px;
}

.chip {
	display: inline-flex;
	align-items: center;
	height: 26px;
	padding: 0 10px;
	border-radius: 8px;
	font-size: 12px;
	font-weight: 650;
	color: var(--muted);
	background: color-mix(in srgb, var(--panel) 90%, transparent);
	border: 1px solid var(--line);

	&.primary {
		color: var(--brand-deep);
		background: rgba(0, 168, 232, 0.1);
		border-color: rgba(0, 168, 232, 0.14);
	}
}

.hero-contact {
	display: grid;
	grid-template-columns: minmax(0, 1fr) auto minmax(0, 1fr);
	align-items: stretch;
	min-width: 240px;
	max-width: 320px;
	padding: 12px 14px;
	border-radius: 14px;
	background: color-mix(in srgb, var(--panel) 92%, transparent);
	border: 1px solid rgba(0, 168, 232, 0.12);
	box-shadow: 0 8px 18px rgba(15, 23, 36, 0.04);
}

.contact-item {
	display: grid;
	gap: 5px;
	min-width: 0;
	padding: 2px 4px;
}

.contact-label {
	font-size: 11px;
	font-weight: 650;
	letter-spacing: 0.02em;
	color: #7b8b9c;
}

.contact-value {
	font-size: 13px;
	font-weight: 720;
	line-height: 1.35;
	color: var(--ink);
	word-break: break-all;
}

.contact-rule {
	width: 1px;
	margin: 2px 8px;
	background: linear-gradient(180deg, transparent, var(--line) 18%, var(--line) 82%, transparent);
}

.profile-grid {
	display: grid;
	grid-template-columns: minmax(260px, 300px) minmax(0, 1fr);
	gap: 16px;
	align-items: start;
}

.side-panel,
.main-panel {
	border-radius: 18px;
	background: var(--panel);
	border: 1px solid var(--line);
	box-shadow: 0 10px 24px rgba(15, 23, 36, 0.04);
}

.side-panel {
	padding: 16px;
	margin-bottom: 12px;
}

.overview-panel {
	padding: 16px 14px 14px;
}

.side-head {
	margin-bottom: 14px;
	padding: 0 2px 12px;
	border-bottom: 1px solid var(--line);

	strong {
		display: block;
		font-size: 14px;
		color: var(--ink);
	}

	span {
		display: block;
		margin-top: 2px;
		font-size: 12px;
		color: var(--muted);
	}
}

.info-group {
	& + & {
		margin-top: 14px;
		padding-top: 12px;
		border-top: 1px dashed var(--line);
	}

	h3 {
		margin: 0 0 8px 2px;
		font-size: 11px;
		font-weight: 720;
		letter-spacing: 0.04em;
		color: #7b8b9c;
	}
}

.info-grid {
	display: grid;
	grid-template-columns: repeat(2, minmax(0, 1fr));
	gap: 8px;
}

.info-cell {
	display: grid;
	gap: 4px;
	min-width: 0;
	padding: 10px 11px;
	border-radius: 12px;
	background: var(--soft);
	border: 1px solid var(--line);

	&.wide {
		grid-column: 1 / -1;
	}
}

.label {
	font-size: 11px;
	font-weight: 650;
	color: #7b8b9c;
}

.value {
	font-size: 13px;
	font-weight: 700;
	line-height: 1.35;
	color: var(--ink);
	word-break: break-all;

	&.nowrap {
		white-space: nowrap;
		word-break: normal;
		overflow: hidden;
		text-overflow: ellipsis;
		font-variant-numeric: tabular-nums;
	}

	&.email {
		white-space: nowrap;
		word-break: normal;
		overflow-wrap: normal;
		overflow: visible;
	}
}

.tip-panel {
	background:
		radial-gradient(120% 140% at 0% 0%, rgba(0, 168, 232, 0.08), transparent 55%),
		#fff;
}

.tip-badge {
	display: inline-flex;
	margin-bottom: 8px;
	padding: 3px 8px;
	border-radius: 999px;
	font-size: 11px;
	font-weight: 700;
	color: var(--brand-deep);
	background: rgba(0, 168, 232, 0.1);
}

.tip-panel p {
	margin: 0;
	font-size: 12.5px;
	line-height: 1.65;
	color: var(--muted);
}

.main-panel {
	overflow: hidden;
}

.tab-rail {
	display: grid;
	grid-template-columns: repeat(5, minmax(0, 1fr));
	gap: 8px;
	padding: 12px;
	background: linear-gradient(180deg, var(--soft), color-mix(in srgb, var(--soft) 80%, var(--line)));
	border-bottom: 1px solid var(--line);
}

.tab-btn {
	display: flex;
	align-items: flex-start;
	gap: 10px;
	min-height: 64px;
	padding: 11px 12px;
	border: 1px solid transparent;
	border-radius: 14px;
	background: transparent;
	text-align: left;
	cursor: pointer;
	transition: background 0.18s ease, border-color 0.18s ease, box-shadow 0.18s ease;

	&:hover {
		background: color-mix(in srgb, var(--panel) 75%, transparent);
	}

	&.active {
		background: var(--panel);
		border-color: rgba(0, 168, 232, 0.18);
		box-shadow: 0 8px 18px rgba(15, 23, 36, 0.05);

		.tab-icon {
			color: #fff;
			background: linear-gradient(135deg, #00a8e8, #2bbef5);
		}

		.tab-copy strong {
			color: var(--brand-deep);
		}
	}
}

.tab-icon {
	width: 32px;
	height: 32px;
	border-radius: 10px;
	display: inline-grid;
	place-items: center;
	flex-shrink: 0;
	color: var(--brand-deep);
	background: rgba(0, 168, 232, 0.1);
}

.tab-copy {
	min-width: 0;
	display: flex;
	flex-direction: column;
	gap: 2px;

	strong {
		font-size: 13px;
		font-weight: 720;
		color: var(--ink);
	}

	em {
		font-style: normal;
		font-size: 11.5px;
		line-height: 1.4;
		color: var(--muted);
		display: -webkit-box;
		-webkit-line-clamp: 2;
		-webkit-box-orient: vertical;
		overflow: hidden;
	}
}

.panel-stage {
	padding: 20px 22px 26px;
}

.stage-head {
	margin-bottom: 16px;
	padding-bottom: 12px;
	border-bottom: 1px dashed #e8eef5;

	h2 {
		margin: 0 0 4px;
		font-size: 17px;
		font-weight: 740;
		color: var(--ink);
	}

	p {
		margin: 0;
		font-size: 13px;
		color: var(--muted);
	}
}

.stage-body {
	max-width: 640px;

	&.wide {
		max-width: 900px;
	}
}

@media (max-width: 1100px) {
	.tab-rail {
		grid-template-columns: repeat(2, minmax(0, 1fr));
	}

	.hero-content {
		grid-template-columns: auto minmax(0, 1fr);
	}

	.hero-contact {
		grid-column: 1 / -1;
		max-width: none;
	}
}

@media (max-width: 900px) {
	.profile-grid {
		grid-template-columns: 1fr;
	}

	.hero-content {
		grid-template-columns: 1fr;
		justify-items: start;
	}

	.hero-meta h1 {
		font-size: 22px;
	}

	.hero-contact {
		width: 100%;
	}
}

@media (max-width: 640px) {
	.tab-rail {
		grid-template-columns: 1fr;
	}

	.panel-stage {
		padding: 16px;
	}

	.stage-body {
		max-width: none;
	}

	.info-grid {
		grid-template-columns: 1fr;
	}

	.hero-contact {
		grid-template-columns: 1fr;
		gap: 10px;
	}

	.contact-rule {
		width: auto;
		height: 1px;
		margin: 0;
		background: linear-gradient(90deg, transparent, #d7e5ef 18%, #d7e5ef 82%, transparent);
	}
}
</style>
