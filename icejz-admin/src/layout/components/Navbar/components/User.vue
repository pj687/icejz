<template>
	<el-dropdown class="avatar-container" trigger="hover">
		<div class="avatar-wrapper">
			<el-avatar shape="circle" :size="30" :src="userStore.user.avatar || constant.defaultAvatar"></el-avatar>
			<span>{{ userStore.user.realName }}</span>
			<el-icon class="el-icon--right"><ArrowDown /></el-icon>
		</div>
		<template #dropdown>
			<el-dropdown-menu class="user-dropdown">
				<router-link to="/profile">
					<el-dropdown-item> {{ $t('app.profile') }} </el-dropdown-item>
				</router-link>
				<el-dropdown-item @click="openAbout">关于 ICEJZ</el-dropdown-item>
				<el-dropdown-item divided @click="logout"> {{ $t('app.signOut') }} </el-dropdown-item>
			</el-dropdown-menu>
		</template>
	</el-dropdown>

	<el-dialog
		v-model="aboutVisible"
		class="about-icejz-dialog"
		width="560px"
		append-to-body
		align-center
		:show-close="true"
	>
		<template #header>
			<div class="about-header">
				<span class="about-header-mark" aria-hidden="true"></span>
				<span>关于 ICEJZ</span>
			</div>
		</template>

		<div class="about-box" v-loading="loading">
			<div class="about-hero">
				<div class="hero-logo-wrap">
					<img src="/logo.png" alt="ICEJZ" class="about-logo" />
					<span class="logo-ring" aria-hidden="true"></span>
				</div>
				<div class="hero-copy">
					<strong class="about-name">{{ aboutName }}</strong>
					<em class="about-subtitle">低代码开发平台 · ICECORE 引擎</em>
					<p class="about-desc">{{ aboutDesc }}</p>
				</div>
			</div>

			<ul class="about-features">
				<li
					v-for="item in features"
					:key="item.title"
					:class="['feat-card', 'feat-card--' + item.tone]"
				>
					<span class="feat-icon" :class="'tone-' + item.tone">
						<!-- 安全可靠：盾牌 -->
						<svg v-if="item.tone === 'secure'" class="feat-svg" viewBox="0 0 24 24" aria-hidden="true">
							<path
								d="M12 2.5c.4 0 .8.1 1.1.3l6.2 3.2c.7.4 1.2 1.2 1.2 2.1v4.6c0 4.6-3.1 8.8-7.5 10.1-.4.1-.8.1-1.2 0C7.4 21.5 4.3 17.3 4.3 12.7V8.1c0-.9.5-1.7 1.2-2.1l6.2-3.2c.4-.2.8-.3 1.3-.3z"
								fill="currentColor"
								opacity="0.22"
							/>
							<path
								d="M12 3.2c.3 0 .5.1.8.2l6 3.1c.5.3.8.8.8 1.4v4.8c0 4-2.7 7.6-6.5 8.7-.2.1-.5.1-.7 0C8.6 20.3 5.9 16.7 5.9 12.7V7.9c0-.6.3-1.1.8-1.4l6-3.1c.2-.1.5-.2.8-.2z"
								fill="none"
								stroke="currentColor"
								stroke-width="1.4"
								stroke-linejoin="round"
							/>
							<path
								d="M9.2 12.1l1.9 1.9 3.8-4"
								fill="none"
								stroke="currentColor"
								stroke-width="1.8"
								stroke-linecap="round"
								stroke-linejoin="round"
							/>
						</svg>
						<!-- 快速开发：闪电 -->
						<svg v-else-if="item.tone === 'speed'" class="feat-svg" viewBox="0 0 24 24" aria-hidden="true">
							<path d="M13.2 3.2L6.4 13.1h4.2l-1.1 7.7 8.1-11.2h-4.5l2.1-6.4z" fill="currentColor" opacity="0.22" />
							<path
								d="M13.2 3.2L6.4 13.1h4.2l-1.1 7.7 8.1-11.2h-4.5l2.1-6.4z"
								fill="none"
								stroke="currentColor"
								stroke-width="1.5"
								stroke-linejoin="round"
								stroke-linecap="round"
							/>
						</svg>
						<!-- 灵活扩展：模块拼图 -->
						<svg v-else-if="item.tone === 'scale'" class="feat-svg" viewBox="0 0 24 24" aria-hidden="true">
							<rect x="3.5" y="3.5" width="7.2" height="7.2" rx="1.6" fill="currentColor" opacity="0.22" />
							<rect x="13.3" y="3.5" width="7.2" height="7.2" rx="1.6" fill="currentColor" opacity="0.22" />
							<rect x="3.5" y="13.3" width="7.2" height="7.2" rx="1.6" fill="currentColor" opacity="0.22" />
							<path
								d="M4.2 4.2h5.8v5.8H4.2V4.2zm10 0h5.8v5.8H14.2V4.2zm-10 10h5.8v5.8H4.2V14.2z"
								fill="none"
								stroke="currentColor"
								stroke-width="1.4"
								stroke-linejoin="round"
							/>
							<path
								d="M14.2 14.2h2.4V16h1.8v2.4H16v1.8h-1.8V18.4H12.4v-1.8h1.8v-2.4z"
								fill="currentColor"
							/>
						</svg>
						<!-- 支持信创：国产化徽章 -->
						<svg v-else class="feat-svg" viewBox="0 0 24 24" aria-hidden="true">
							<circle cx="12" cy="12" r="8.2" fill="currentColor" opacity="0.2" />
							<circle
								cx="12"
								cy="12"
								r="8.2"
								fill="none"
								stroke="currentColor"
								stroke-width="1.4"
							/>
							<path
								d="M12 6.8l1.4 2.9 3.2.4-2.3 2.2.6 3.2L12 14.1l-2.9 1.4.6-3.2-2.3-2.2 3.2-.4L12 6.8z"
								fill="currentColor"
							/>
						</svg>
					</span>
					<div>
						<strong>{{ item.title }}</strong>
						<p>{{ item.desc }}</p>
					</div>
				</li>
			</ul>

			<div class="about-meta">
				<div class="meta-row">
					<span>前端版本</span>
					<b>v{{ constant.version }}</b>
				</div>
				<div class="meta-row">
					<span>服务版本</span>
					<b>v{{ serverVersion }}</b>
				</div>
				<div class="meta-row" v-if="serverApp">
					<span>服务标识</span>
					<b>{{ serverApp }}</b>
				</div>
				<div class="meta-row">
					<span>当前用户</span>
					<b>{{ userStore.user.realName || userStore.user.username || '—' }}</b>
				</div>
				<div class="meta-row">
					<span>官方站点</span>
					<a class="meta-link" href="https://icejz.net" target="_blank" rel="noopener noreferrer">icejz.net</a>
				</div>
			</div>

			<p class="about-foot">© {{ year }} ICEJZ · Author ice_jz · 面向企业交付的低代码底座</p>
		</div>

		<template #footer>
			<div class="about-footer">
				<el-button @click="openSite">访问官网</el-button>
				<el-button type="primary" @click="aboutVisible = false">知道了</el-button>
			</div>
		</template>
	</el-dialog>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useUserStore } from '@/store/modules/user'
import { ArrowDown } from '@element-plus/icons-vue'
import constant from '@/utils/constant'
import { useAppVersionApi } from '@/api/sys/app'

const { t } = useI18n()
const userStore = useUserStore()
const aboutVisible = ref(false)
const loading = ref(false)
const aboutName = ref('ICEJZ')
const serverVersion = ref(constant.version)
const serverApp = ref('')
const year = new Date().getFullYear()

const aboutDesc = t('app.description')

const features = [
	{ tone: 'secure', title: '安全可靠', desc: '统一认证、细粒度权限与操作审计' },
	{ tone: 'speed', title: '快速开发', desc: '代码生成与模块化能力加速交付' },
	{ tone: 'scale', title: '灵活扩展', desc: '业务模块可插拔，适配多端场景' },
	{ tone: 'local', title: '支持信创', desc: '面向国产化环境持续适配' }
]

const openAbout = async () => {
	aboutVisible.value = true
	loading.value = true
	try {
		const { data } = await useAppVersionApi()
		aboutName.value = data?.name || 'ICEJZ'
		serverVersion.value = data?.version || constant.version
		serverApp.value = data?.application || ''
	} catch {
		serverVersion.value = constant.version
		serverApp.value = ''
	} finally {
		loading.value = false
	}
}

const openSite = () => {
	window.open('https://icejz.net', '_blank', 'noopener,noreferrer')
}

const logout = () => {
	userStore.logoutAction().then(() => {
		// 直接回登录页，避免带着上一账号页面 redirect 导致换号 404
		location.href = '/login'
	})
}
</script>

<style lang="scss" scoped>
.avatar-container {
	display: flex;
	align-items: center;
	justify-content: flex-end;
	height: var(--theme-header-height);
	.avatar-wrapper {
		display: flex;
		align-items: center;
		white-space: nowrap;
		cursor: pointer;
		padding: 0 8px;
		color: var(--theme-header-text-color);
		span {
			margin-left: 6px;
		}
	}
}

.about-header {
	display: flex;
	align-items: center;
	gap: 8px;
	font-weight: 700;
	color: var(--icejz-ink, #0f1724);
}

.about-header-mark {
	width: 8px;
	height: 8px;
	border-radius: 50%;
	background: linear-gradient(135deg, #00a8e8, #3ec6ff);
	box-shadow: 0 0 0 4px rgba(0, 168, 232, 0.16);
}

.about-box {
	display: flex;
	flex-direction: column;
	gap: 16px;
	padding: 2px 2px 0;
}

.about-hero {
	display: flex;
	gap: 16px;
	align-items: flex-start;
	padding: 14px;
	border-radius: 16px;
	background:
		radial-gradient(120% 140% at 0% 0%, rgba(0, 168, 232, 0.16), transparent 55%),
		linear-gradient(135deg, color-mix(in srgb, #00a8e8 10%, var(--icejz-card-bg, #f3faff)), var(--icejz-surface-2, #eef8fc));
	border: 1px solid rgba(0, 168, 232, 0.14);
}

.hero-logo-wrap {
	position: relative;
	width: 64px;
	height: 64px;
	flex-shrink: 0;
}

.about-logo {
	width: 64px;
	height: 64px;
	object-fit: contain;
	position: relative;
	z-index: 1;
	filter: drop-shadow(0 8px 14px rgba(5, 70, 102, 0.16));
}

.logo-ring {
	position: absolute;
	inset: -4px;
	border-radius: 18px;
	border: 1px solid rgba(0, 168, 232, 0.22);
	background: color-mix(in srgb, var(--icejz-card-bg, #fff) 45%, transparent);
}

.hero-copy {
	min-width: 0;
	flex: 1;
}

.about-name {
	display: block;
	font-size: 20px;
	line-height: 1.2;
	color: var(--icejz-ink, #0f1724);
	letter-spacing: 0.5px;
}

.about-subtitle {
	display: block;
	margin-top: 4px;
	font-style: normal;
	font-size: 12.5px;
	color: #0f6f99;
	font-weight: 600;
}

.about-desc {
	margin: 8px 0 0;
	font-size: 13px;
	line-height: 1.65;
	color: var(--icejz-muted, #475569);
}

.about-features {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 8px;
	margin: 0;
	padding: 0;
	list-style: none;

	.feat-card {
		display: flex;
		gap: 8px;
		align-items: flex-start;
		min-height: 64px;
		padding: 10px;
		border-radius: 10px;
		background: var(--icejz-surface-2, #fbfcfe);
		border: 1px solid var(--icejz-card-border, #e8eef5);
		transition: border-color 0.2s ease, box-shadow 0.2s ease, transform 0.2s ease;

		&:hover {
			transform: translateY(-1px);
		}

		&.feat-card--secure {
			background:
				radial-gradient(120% 160% at 0% 50%, rgba(14, 165, 233, 0.12), transparent 55%),
				var(--icejz-surface-2, #f5fbff);
			border-color: rgba(14, 165, 233, 0.22);
		}

		&.feat-card--speed {
			background:
				radial-gradient(120% 160% at 0% 50%, rgba(20, 184, 166, 0.12), transparent 55%),
				var(--icejz-surface-2, #f8fffd);
			border-color: rgba(13, 148, 136, 0.2);
		}

		&.feat-card--scale {
			background:
				radial-gradient(120% 160% at 0% 50%, rgba(99, 102, 241, 0.12), transparent 55%),
				var(--icejz-surface-2, #f9f8ff);
			border-color: rgba(79, 70, 229, 0.2);
		}

		&.feat-card--local {
			background:
				radial-gradient(120% 160% at 0% 50%, rgba(245, 158, 11, 0.14), transparent 55%),
				var(--icejz-surface-2, #fffbf5);
			border-color: rgba(217, 119, 6, 0.22);
		}
	}

	strong {
		display: block;
		font-size: 12.5px;
		line-height: 1.3;
		color: var(--icejz-ink, #0f1724);
	}

	p {
		margin: 2px 0 0;
		font-size: 11.5px;
		line-height: 1.4;
		color: var(--icejz-muted, #64748b);
	}
}

.feat-icon {
	width: 28px;
	height: 28px;
	margin-top: 1px;
	border-radius: 8px;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	flex-shrink: 0;
	color: #fff;
	position: relative;
	box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.35);

	&::after {
		content: '';
		position: absolute;
		inset: -2px;
		border-radius: 10px;
		pointer-events: none;
	}

	&.tone-secure {
		background:
			radial-gradient(circle at 30% 25%, rgba(255, 255, 255, 0.42), transparent 45%),
			linear-gradient(145deg, #38bdf8 0%, #0284c7 55%, #0369a1 100%);
		box-shadow:
			0 4px 10px rgba(2, 132, 199, 0.22),
			inset 0 1px 0 rgba(255, 255, 255, 0.35);

		&::after {
			border: 1px solid rgba(14, 165, 233, 0.28);
		}
	}

	&.tone-speed {
		background:
			radial-gradient(circle at 30% 25%, rgba(255, 255, 255, 0.4), transparent 45%),
			linear-gradient(145deg, #2dd4bf 0%, #0d9488 55%, #0f766e 100%);
		box-shadow:
			0 4px 10px rgba(13, 148, 136, 0.2),
			inset 0 1px 0 rgba(255, 255, 255, 0.35);

		&::after {
			border: 1px solid rgba(20, 184, 166, 0.28);
		}
	}

	&.tone-scale {
		background:
			radial-gradient(circle at 30% 25%, rgba(255, 255, 255, 0.4), transparent 45%),
			linear-gradient(145deg, #818cf8 0%, #4f46e5 55%, #4338ca 100%);
		box-shadow:
			0 4px 10px rgba(79, 70, 229, 0.2),
			inset 0 1px 0 rgba(255, 255, 255, 0.35);

		&::after {
			border: 1px solid rgba(99, 102, 241, 0.28);
		}
	}

	&.tone-local {
		background:
			radial-gradient(circle at 30% 25%, rgba(255, 255, 255, 0.42), transparent 45%),
			linear-gradient(145deg, #fbbf24 0%, #d97706 55%, #b45309 100%);
		box-shadow:
			0 4px 10px rgba(217, 119, 6, 0.2),
			inset 0 1px 0 rgba(255, 255, 255, 0.35);

		&::after {
			border: 1px solid rgba(245, 158, 11, 0.3);
		}
	}
}

.feat-svg {
	width: 16px;
	height: 16px;
	display: block;
}

.about-meta {
	border-radius: 12px;
	border: 1px solid var(--icejz-card-border, #e8eef5);
	overflow: hidden;
	background: var(--icejz-card-bg, #fff);
}

.meta-row {
	display: flex;
	justify-content: space-between;
	align-items: center;
	gap: 12px;
	padding: 11px 14px;
	font-size: 13px;
	border-bottom: 1px solid var(--icejz-card-border, #eef2f6);

	&:last-child {
		border-bottom: none;
	}

	span {
		color: var(--icejz-muted, #64748b);
		flex-shrink: 0;
	}

	b {
		font-weight: 700;
		color: var(--icejz-ink, #0f4f6e);
		text-align: right;
		word-break: break-all;
	}
}

.meta-link {
	color: #0090c8;
	font-weight: 700;
	text-decoration: none;

	&:hover {
		text-decoration: underline;
	}
}

.about-foot {
	margin: 0;
	text-align: center;
	font-size: 12px;
	color: #94a3b8;
}

.about-footer {
	display: flex;
	justify-content: flex-end;
	gap: 10px;
}

@media (max-width: 560px) {
	.about-hero {
		flex-direction: column;
		align-items: center;
		text-align: center;
	}

	.about-features {
		grid-template-columns: 1fr;
	}
}
</style>

<style lang="scss">
.about-icejz-dialog {
	border-radius: 18px !important;
	overflow: hidden;

	.el-dialog__header {
		margin-right: 0;
		padding: 16px 20px 8px;
	}

	.el-dialog__body {
		padding: 8px 20px 6px;
	}

	.el-dialog__footer {
		padding: 10px 20px 18px;
	}
}
</style>
