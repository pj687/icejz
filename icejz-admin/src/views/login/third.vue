<template>
	<div class="login-third">
		<div class="divider">
			<span class="divider-line"></span>
			<span class="divider-text">其他登录方式</span>
			<span class="divider-line"></span>
		</div>
		<div class="third-btns">
			<button class="third-btn wechat-work" title="企业微信" aria-label="企业微信登录" @click="thirdLogin('wechat_work')">
				<ma-icon icon="icon-workweixin" size="18" />
			</button>
			<button class="third-btn dingtalk" title="钉钉" aria-label="钉钉登录" @click="thirdLogin('dingtalk')">
				<ma-icon icon="icon-dingding" size="18" />
			</button>
			<button class="third-btn feishu" title="飞书" aria-label="飞书登录" @click="thirdLogin('feishu')">
				<ma-icon icon="icon-feishu" size="18" />
			</button>
			<button class="third-btn wechat" title="微信" aria-label="微信登录" @click="thirdLogin('wechat_open')">
				<ma-icon icon="icon-weixin" size="18" />
			</button>
		</div>
	</div>
</template>

<script setup lang="ts">
import { inject } from 'vue'
import constant from '@/utils/constant'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/store/modules/user'
import cache from '@/utils/cache'

const router = useRouter()
const userStore = useUserStore()
const ensureAgreement = inject<() => boolean>('ensureAgreement', () => true)

const thirdLogin = (openType: string) => {
	if (!ensureAgreement()) {
		return
	}

	const url = constant.thirdLoginUrl + openType
	window.open(url, '第三方登录', 'width=600, height=400, toolbar=no')

	window.onmessage = function (e) {
		if (!e.data?.openType) {
			return
		}

		userStore.thirdLoginAction(e.data).then(() => {
			const redirect = cache.getRedirect()
			cache.clearRedirect()
			router.push({ path: redirect || constant.loginPage })
		})
	}
}
</script>

<style lang="scss" scoped>
.login-third {
	margin-top: 2px;

	.divider {
		display: flex;
		align-items: center;
		margin-bottom: 14px;

		.divider-line {
			flex: 1;
			height: 1px;
			background: linear-gradient(90deg, transparent, #d7e6f0, transparent);
		}

		.divider-text {
			padding: 0 12px;
			font-size: 12px;
			color: #97a4b0;
			white-space: nowrap;
			letter-spacing: 0.2px;
		}
	}

	.third-btns {
		display: flex;
		justify-content: center;
		gap: 12px;
	}

	.third-btn {
		width: 44px;
		height: 44px;
		border-radius: 13px;
		border: 1px solid #e3edf5;
		background: linear-gradient(180deg, #ffffff, #f3f8fc);
		cursor: pointer;
		display: flex;
		align-items: center;
		justify-content: center;
		box-shadow:
			0 3px 8px rgba(15, 23, 36, 0.04),
			inset 0 1px 0 rgba(255, 255, 255, 0.9);
		transition: all 0.22s ease;
		color: #5b6777;

		&:hover {
			transform: translateY(-3px) scale(1.03);
			border-color: rgba(0, 168, 232, 0.38);
			background: linear-gradient(180deg, #f2faff, #e4f4fc);
			box-shadow:
				0 10px 20px rgba(0, 168, 232, 0.16),
				0 0 0 3px rgba(0, 168, 232, 0.06);
			color: #0090c8;
		}

		&:active {
			transform: translateY(0);
		}

		&.wechat-work:hover {
			border-color: #2979ff;
			background: #eef5ff;
			color: #2979ff;
		}

		&.dingtalk:hover {
			border-color: #007fff;
			background: #eef6ff;
			color: #007fff;
		}

		&.feishu:hover {
			border-color: #3370ff;
			background: #eef3ff;
			color: #3370ff;
		}

		&.wechat:hover {
			border-color: #07c160;
			background: #eefaf3;
			color: #07c160;
		}
	}
}
</style>
