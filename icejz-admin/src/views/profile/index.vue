<template>
	<div class="profile-page">
		<section class="profile-hero">
			<div class="hero-bg" aria-hidden="true"></div>
			<div class="hero-content">
				<div class="hero-avatar">
					<ma-upload-image
						v-model:image-url="userStore.user.avatar"
						:drag="false"
						width="96px"
						height="96px"
						border-radius="50%"
						@success="handleSuccess"
					>
						<template #empty>
							<el-icon><Avatar /></el-icon>
							<span>上传头像</span>
						</template>
					</ma-upload-image>
					<span class="avatar-ring"></span>
				</div>
				<div class="hero-meta">
					<div class="hero-eyebrow">ICEJZ · 个人中心</div>
					<h1 class="hero-name">{{ userStore.user.realName || userStore.user.username }}</h1>
					<p class="hero-sub">
						<span>@{{ userStore.user.username }}</span>
						<span class="dot">·</span>
						<span>{{ userStore.user.orgName || '未分配机构' }}</span>
					</p>
					<div class="hero-tags">
						<span class="tag">
							<ma-icon icon="icon-tag" />
							{{ postLabel }}
						</span>
						<span class="tag soft">
							<ma-icon icon="icon-calendar-check" />
							入驻 {{ createDate }}
						</span>
					</div>
				</div>
			</div>
		</section>

		<div class="profile-grid">
			<aside class="profile-side">
				<div class="side-card">
					<div class="side-title">
						<span>账号概览</span>
					</div>
					<ul class="info-list">
						<li v-for="item in infoItems" :key="item.label">
							<div class="info-icon">
								<ma-icon :icon="item.icon" />
							</div>
							<div class="info-body">
								<span class="label">{{ item.label }}</span>
								<span class="value">{{ item.value }}</span>
							</div>
						</li>
					</ul>
				</div>

				<div class="side-card tip-card">
					<div class="tip-badge">安全提示</div>
					<p>定期更新密码，勿将账号共享给他人。绑定第三方登录可提升登录便利性与安全性。</p>
				</div>
			</aside>

			<main class="profile-main">
				<div class="main-card">
					<div class="main-tabs">
						<button
							v-for="tab in tabs"
							:key="tab.name"
							type="button"
							:class="['tab-item', { active: activeName === tab.name }]"
							@click="activeName = tab.name"
						>
							<span class="tab-icon">
								<ma-icon :icon="tab.icon" />
							</span>
							<span class="tab-text">
								<span class="tab-label">{{ tab.label }}</span>
								<span class="tab-desc">{{ tab.desc }}</span>
							</span>
						</button>
					</div>

					<div class="main-panel">
						<div class="panel-head">
							<h2>{{ currentTab?.label }}</h2>
							<p>{{ currentTab?.desc }}</p>
						</div>

						<div class="panel-body" :class="{ wide: activeName === 'third' || activeName === 'signature' }">
							<UserInfo v-if="activeName === 'info'" />
							<Password v-else-if="activeName === 'password'" />
							<Signature v-else-if="activeName === 'signature'" />
							<ThirdLogin v-else-if="activeName === 'third'" />
						</div>
					</div>
				</div>
			</main>
		</div>
	</div>
</template>

<script setup lang="ts" name="ProfileIndex">
import { computed, ref } from 'vue'
import { useUserStore } from '@/store/modules/user'
import Password from '@/views/profile/password.vue'
import UserInfo from '@/views/profile/user-info.vue'
import Signature from '@/views/profile/signature.vue'
import ThirdLogin from '@/views/profile/third-login.vue'
import { useUserAvatarApi } from '@/api/sys/user'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const activeName = ref('info')

const tabs = [
	{ name: 'info', label: '基本资料', desc: '维护姓名、手机与邮箱等信息', icon: 'icon-user' },
	{ name: 'password', label: '修改密码', desc: '定期更换密码保障账号安全', icon: 'icon-lock' },
	{ name: 'signature', label: '个人签名', desc: '手写签名用于审批与文书场景', icon: 'icon-edit' },
	{ name: 'third', label: '第三方登录', desc: '绑定企业微信、钉钉等平台', icon: 'icon-link' }
]

const currentTab = computed(() => tabs.find(t => t.name === activeName.value) || tabs[0])

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

const infoItems = computed(() => [
	{ icon: 'icon-user', label: '用户名', value: userStore.user.username || '—' },
	{ icon: 'icon-idcard', label: '姓名', value: userStore.user.realName || '—' },
	{ icon: 'icon-phone', label: '手机号码', value: userStore.user.mobile || '—' },
	{ icon: 'icon-mail', label: '用户邮箱', value: userStore.user.email || '—' },
	{ icon: 'icon-apartment', label: '所属机构', value: userStore.user.orgName || '—' },
	{ icon: 'icon-tag', label: '所属岗位', value: postLabel.value },
	{ icon: 'icon-calendar-check', label: '创建日期', value: userStore.user.createTime || '—' }
])

const handleSuccess = (data: any) => {
	useUserAvatarApi({ avatar: data.url }).then(() => {
		ElMessage.success('头像更新成功')
	})
}
</script>

<style scoped lang="scss">
.profile-page {
	--profile-brand: #00a8e8;
	--profile-brand-deep: #0090c8;
	--profile-ink: #0f1724;
	--profile-muted: #6b7c8d;
	--profile-line: rgba(15, 23, 36, 0.08);
	--profile-soft: #f4f8fb;
	min-height: 100%;
	padding: 4px 2px 20px;
}

.profile-hero {
	position: relative;
	overflow: hidden;
	border-radius: 22px;
	margin-bottom: 18px;
	background:
		radial-gradient(120% 140% at 0% 0%, rgba(0, 168, 232, 0.22), transparent 42%),
		radial-gradient(90% 120% at 100% 10%, rgba(62, 198, 255, 0.16), transparent 40%),
		linear-gradient(135deg, #0b1a28 0%, #123247 48%, #0e2435 100%);
	box-shadow: 0 18px 40px rgba(11, 26, 40, 0.18);
}

.hero-bg {
	position: absolute;
	inset: 0;
	background-image:
		linear-gradient(rgba(255, 255, 255, 0.04) 1px, transparent 1px),
		linear-gradient(90deg, rgba(255, 255, 255, 0.04) 1px, transparent 1px);
	background-size: 28px 28px;
	mask-image: linear-gradient(180deg, #000 30%, transparent 100%);
	opacity: 0.55;
	pointer-events: none;
}

.hero-content {
	position: relative;
	z-index: 1;
	display: flex;
	align-items: center;
	gap: 28px;
	padding: 28px 32px;
}

.hero-avatar {
	position: relative;
	flex-shrink: 0;
	width: 108px;
	height: 108px;
	display: flex;
	align-items: center;
	justify-content: center;

	:deep(.upload-box) {
		width: 96px;
		height: 96px;
	}

	:deep(.upload-image) {
		border-radius: 50%;
		object-fit: cover;
	}

	:deep(.upload-empty) {
		color: rgba(255, 255, 255, 0.75);

		.el-icon {
			color: rgba(255, 255, 255, 0.85);
		}
	}

	:deep(.el-upload) {
		border-color: rgba(255, 255, 255, 0.28) !important;
		background: rgba(255, 255, 255, 0.08);
	}
}

.avatar-ring {
	position: absolute;
	inset: 0;
	border-radius: 50%;
	border: 2px solid rgba(255, 255, 255, 0.35);
	box-shadow: 0 0 0 6px rgba(0, 168, 232, 0.18);
	pointer-events: none;
}

.hero-meta {
	min-width: 0;
	color: #fff;
}

.hero-eyebrow {
	display: inline-flex;
	align-items: center;
	padding: 4px 10px;
	border-radius: 999px;
	font-size: 12px;
	font-weight: 650;
	letter-spacing: 0.3px;
	color: #bfefff;
	background: rgba(255, 255, 255, 0.08);
	border: 1px solid rgba(255, 255, 255, 0.12);
}

.hero-name {
	margin: 12px 0 8px;
	font-size: 28px;
	font-weight: 750;
	line-height: 1.2;
	letter-spacing: 0.2px;
}

.hero-sub {
	display: flex;
	align-items: center;
	flex-wrap: wrap;
	gap: 8px;
	margin: 0 0 14px;
	font-size: 14px;
	color: rgba(255, 255, 255, 0.72);

	.dot {
		opacity: 0.45;
	}
}

.hero-tags {
	display: flex;
	flex-wrap: wrap;
	gap: 8px;
}

.tag {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	padding: 7px 12px;
	border-radius: 999px;
	font-size: 12.5px;
	background: rgba(0, 168, 232, 0.22);
	border: 1px solid rgba(191, 239, 255, 0.22);
	color: #eaf9ff;

	&.soft {
		background: rgba(255, 255, 255, 0.08);
		border-color: rgba(255, 255, 255, 0.12);
		color: rgba(255, 255, 255, 0.82);
	}
}

.profile-grid {
	display: grid;
	grid-template-columns: minmax(280px, 340px) minmax(0, 1fr);
	gap: 18px;
	align-items: start;
}

.side-card,
.main-card {
	border-radius: 18px;
	background: #fff;
	border: 1px solid var(--profile-line);
	box-shadow: 0 10px 28px rgba(15, 23, 36, 0.04);
}

.side-card {
	padding: 18px 18px 8px;
	margin-bottom: 14px;
}

.side-title {
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 8px;
	padding: 0 4px 10px;
	font-size: 15px;
	font-weight: 700;
	color: var(--profile-ink);
	border-bottom: 1px solid var(--profile-line);
}

.info-list {
	list-style: none;
	margin: 0;
	padding: 4px 0 8px;
}

.info-list li {
	display: flex;
	align-items: center;
	gap: 12px;
	padding: 12px 6px;
	border-bottom: 1px dashed rgba(15, 23, 36, 0.06);

	&:last-child {
		border-bottom: none;
	}
}

.info-icon {
	width: 34px;
	height: 34px;
	border-radius: 10px;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	flex-shrink: 0;
	color: var(--profile-brand-deep);
	background: rgba(0, 168, 232, 0.1);
}

.info-body {
	min-width: 0;
	flex: 1;
	display: flex;
	flex-direction: column;
	gap: 2px;
}

.label {
	font-size: 12px;
	color: var(--profile-muted);
}

.value {
	font-size: 13.5px;
	font-weight: 600;
	color: var(--profile-ink);
	word-break: break-all;
}

.tip-card {
	padding: 16px 18px 18px;
	background:
		radial-gradient(120% 100% at 0% 0%, rgba(0, 168, 232, 0.1), transparent 50%),
		linear-gradient(180deg, #f8fcff, #f3f8fb);
}

.tip-badge {
	display: inline-flex;
	margin-bottom: 8px;
	padding: 3px 8px;
	border-radius: 999px;
	font-size: 11px;
	font-weight: 700;
	color: var(--profile-brand-deep);
	background: rgba(0, 168, 232, 0.12);
}

.tip-card p {
	margin: 0;
	font-size: 13px;
	line-height: 1.7;
	color: var(--profile-muted);
}

.main-card {
	overflow: hidden;
}

.main-tabs {
	display: grid;
	grid-template-columns: repeat(4, minmax(0, 1fr));
	gap: 8px;
	padding: 14px;
	background: linear-gradient(180deg, #f7fafc, #f2f7fa);
	border-bottom: 1px solid var(--profile-line);
}

.tab-item {
	display: flex;
	align-items: flex-start;
	gap: 10px;
	padding: 12px 12px 11px;
	border: 1px solid transparent;
	border-radius: 14px;
	background: transparent;
	text-align: left;
	cursor: pointer;
	transition: all 0.2s ease;

	&:hover {
		background: rgba(255, 255, 255, 0.8);
	}

	&.active {
		background: #fff;
		border-color: rgba(0, 168, 232, 0.18);
		box-shadow: 0 8px 20px rgba(15, 23, 36, 0.06);

		.tab-icon {
			color: #fff;
			background: linear-gradient(135deg, #00a8e8, #3ec6ff);
			box-shadow: 0 8px 16px rgba(0, 168, 232, 0.28);
		}

		.tab-label {
			color: var(--profile-brand-deep);
		}
	}
}

.tab-icon {
	width: 34px;
	height: 34px;
	border-radius: 10px;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	flex-shrink: 0;
	color: var(--profile-brand-deep);
	background: rgba(0, 168, 232, 0.1);
	transition: all 0.2s ease;
}

.tab-text {
	min-width: 0;
	display: flex;
	flex-direction: column;
	gap: 2px;
}

.tab-label {
	font-size: 13.5px;
	font-weight: 700;
	color: var(--profile-ink);
}

.tab-desc {
	font-size: 11.5px;
	line-height: 1.4;
	color: var(--profile-muted);
	display: -webkit-box;
	-webkit-line-clamp: 2;
	-webkit-box-orient: vertical;
	overflow: hidden;
}

.main-panel {
	padding: 22px 24px 28px;
}

.panel-head {
	margin-bottom: 18px;
	padding-bottom: 14px;
	border-bottom: 1px dashed rgba(15, 23, 36, 0.08);

	h2 {
		margin: 0 0 6px;
		font-size: 18px;
		font-weight: 740;
		color: var(--profile-ink);
	}

	p {
		margin: 0;
		font-size: 13px;
		color: var(--profile-muted);
	}
}

.panel-body {
	max-width: 640px;

	&.wide {
		max-width: 860px;
	}
}

@media (max-width: 1100px) {
	.main-tabs {
		grid-template-columns: repeat(2, minmax(0, 1fr));
	}
}

@media (max-width: 900px) {
	.profile-grid {
		grid-template-columns: 1fr;
	}

	.hero-content {
		flex-direction: column;
		align-items: flex-start;
		padding: 24px 20px;
	}

	.hero-name {
		font-size: 24px;
	}
}

@media (max-width: 640px) {
	.main-tabs {
		grid-template-columns: 1fr;
	}

	.main-panel {
		padding: 18px 16px 22px;
	}

	.panel-body {
		max-width: none;
	}
}
</style>
