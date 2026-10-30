<template>
	<div class="third-panel">
		<div class="panel-hint">
			<span class="hint-dot"></span>
			绑定后可使用对应平台账号快捷登录 ICEJZ
		</div>

		<div class="third-grid">
			<div
				v-for="item in thirdList"
				:key="item.openType"
				class="third-card"
				:class="[item.openType, { bound: item.status === 1 }]"
			>
				<div class="card-glow" aria-hidden="true"></div>
				<svg class="card-pattern" viewBox="0 0 240 160" preserveAspectRatio="xMaxYMin meet" aria-hidden="true">
					<defs>
						<linearGradient :id="`g-${item.openType}`" x1="0%" y1="0%" x2="100%" y2="100%">
							<stop offset="0%" :stop-color="item.color" stop-opacity="0.22" />
							<stop offset="100%" :stop-color="item.color" stop-opacity="0" />
						</linearGradient>
					</defs>
					<circle cx="188" cy="28" r="56" :fill="`url(#g-${item.openType})`" />
					<circle cx="210" cy="78" r="34" :fill="item.color" fill-opacity="0.06" />
					<path
						:d="item.wave"
						fill="none"
						:stroke="item.color"
						stroke-opacity="0.14"
						stroke-width="1.5"
					/>
				</svg>

				<div class="third-top">
					<div class="third-mark" :title="item.label">
						<span class="mark-ring"></span>
						<span class="mark-core">
							<ma-icon :icon="item.icon" :size="28" class="app-icon" />
						</span>
					</div>
					<span :class="['status', item.status === 1 ? 'on' : 'off']">
						<span class="status-dot"></span>
						{{ item.status === 1 ? '已绑定' : '未绑定' }}
					</span>
				</div>

				<div class="third-body">
					<h4>{{ item.label }}</h4>
					<p>{{ item.status === 1 ? item.username : '尚未绑定该平台账号' }}</p>
				</div>

				<div class="third-foot">
					<button
						v-if="item.status === 0"
						type="button"
						class="action bind"
						@click="handleBind(item.openType)"
					>
						立即绑定
					</button>
					<button v-else type="button" class="action unbind" @click="handleUnBind(item.openType)">
						解除绑定
					</button>
				</div>
			</div>
		</div>
	</div>
</template>

<script setup lang="ts">
import { reactive } from 'vue'
import { useThirdBindApi, useThirdListApi, useThirdUnBindApi } from '@/api/sys/third'
import { ElMessage } from 'element-plus'
import constant from '@/utils/constant'

const thirdList = reactive([
	{
		openType: 'wechat_work',
		label: '企业微信',
		icon: 'icon-workweixin',
		username: '-',
		status: 0,
		color: '#2B7DE9',
		wave: 'M20 120 C60 95, 100 145, 140 118 S200 90, 230 110'
	},
	{
		openType: 'dingtalk',
		label: '钉钉',
		icon: 'icon-dingding',
		username: '-',
		status: 0,
		color: '#1684FC',
		wave: 'M10 108 C50 130, 90 85, 130 112 S190 140, 235 105'
	},
	{
		openType: 'feishu',
		label: '飞书',
		icon: 'icon-feishu',
		username: '-',
		status: 0,
		color: '#3370FF',
		wave: 'M15 115 C55 88, 95 135, 145 110 S205 85, 238 118'
	},
	{
		openType: 'wechat_open',
		label: '微信',
		icon: 'icon-weixin',
		username: '-',
		status: 0,
		color: '#07C160',
		wave: 'M18 122 C62 98, 105 140, 148 115 S205 92, 236 112'
	}
])

const getThirdList = async () => {
	const res = await useThirdListApi()

	thirdList.forEach(third => {
		third.status = 0
		third.username = '-'

		res.data.forEach((item: any) => {
			if (third.openType === item.openType) {
				third.status = 1
				third.username = item.username
			}
		})
	})
}

getThirdList()

const handleBind = (openType: string) => {
	const url = constant.thirdLoginUrl + openType
	window.open(url, '第三方登录', 'width=600, height=400, toolbar=no')

	window.onmessage = function (e) {
		if (!e.data?.openType) {
			return
		}

		useThirdBindApi(e.data).then(() => {
			ElMessage.success({
				message: '绑定成功',
				duration: 500,
				onClose: () => {
					getThirdList()
				}
			})
		})
	}
}

const handleUnBind = (openType: string) => {
	useThirdUnBindApi(openType).then(() => {
		ElMessage.success({
			message: '已解除绑定',
			duration: 500,
			onClose: () => {
				getThirdList()
			}
		})
	})
}
</script>

<style lang="scss" scoped>
.third-panel {
	max-width: none;
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
	margin-bottom: 18px;
	padding: 10px 12px;
	border-radius: 12px;
	font-size: 12.5px;
	color: #5f7386;
	background: rgba(0, 168, 232, 0.06);
	border: 1px solid rgba(0, 168, 232, 0.12);
}

.hint-dot {
	width: 7px;
	height: 7px;
	border-radius: 50%;
	background: #00a8e8;
	box-shadow: 0 0 0 4px rgba(0, 168, 232, 0.15);
}

.third-grid {
	display: grid;
	grid-template-columns: repeat(2, minmax(0, 1fr));
	gap: 14px;
}

.third-card {
	--brand: #00a8e8;
	position: relative;
	overflow: hidden;
	padding: 18px;
	border-radius: 18px;
	border: 1px solid rgba(15, 23, 36, 0.08);
	background: linear-gradient(160deg, #ffffff 0%, #f7fafc 100%);
	transition: transform 0.22s ease, box-shadow 0.22s ease, border-color 0.22s ease;

	&:hover {
		transform: translateY(-3px);
		box-shadow: 0 16px 36px rgba(15, 23, 36, 0.1);
		border-color: color-mix(in srgb, var(--brand) 28%, transparent);

		.mark-core {
			transform: scale(1.04) rotate(-2deg);
		}

		.card-glow {
			opacity: 1;
		}
	}

	&.wechat_work {
		--brand: #2b7de9;
	}
	&.dingtalk {
		--brand: #1684fc;
	}
	&.feishu {
		--brand: #3370ff;
	}
	&.wechat_open {
		--brand: #07c160;
	}

	&.bound {
		border-color: color-mix(in srgb, var(--brand) 22%, transparent);
		background:
			linear-gradient(160deg, #ffffff 0%, color-mix(in srgb, var(--brand) 6%, #f8fafc) 100%);
	}
}

.card-glow {
	position: absolute;
	inset: auto -20% -40% auto;
	width: 180px;
	height: 180px;
	border-radius: 50%;
	background: radial-gradient(circle, color-mix(in srgb, var(--brand) 22%, transparent), transparent 70%);
	opacity: 0.55;
	pointer-events: none;
	transition: opacity 0.22s ease;
}

.card-pattern {
	position: absolute;
	right: 0;
	top: 0;
	width: 58%;
	height: auto;
	pointer-events: none;
	opacity: 0.95;
}

.third-top {
	position: relative;
	z-index: 1;
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 16px;
}

.third-mark {
	position: relative;
	width: 52px;
	height: 52px;
	display: grid;
	place-items: center;
}

.mark-ring {
	display: none;
}

.mark-core {
	position: relative;
	z-index: 1;
	width: 52px;
	height: 52px;
	border-radius: 14px;
	display: grid;
	place-items: center;
	color: var(--brand);
	background: #fff;
	border: 1px solid rgba(15, 23, 36, 0.08);
	box-shadow: 0 6px 16px rgba(15, 23, 36, 0.06);
	transition: transform 0.22s ease;
}

.app-icon {
	display: block;
	line-height: 1;
	color: var(--brand) !important;

	:deep(svg),
	:deep(use) {
		fill: currentColor;
		color: inherit;
	}
}

.wechat_work .app-icon {
	color: #2b7de9 !important;
}

.dingtalk .app-icon {
	color: #1684fc !important;
}

.feishu .app-icon {
	color: #3370ff !important;
}

.wechat_open .app-icon {
	color: #07c160 !important;
}

.status {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	padding: 5px 10px;
	border-radius: 999px;
	font-size: 12px;
	font-weight: 650;
	backdrop-filter: blur(6px);

	&.on {
		color: #059669;
		background: rgba(16, 185, 129, 0.12);
		border: 1px solid rgba(16, 185, 129, 0.18);

		.status-dot {
			background: #10b981;
			box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.18);
		}
	}

	&.off {
		color: #7b8a99;
		background: rgba(148, 163, 184, 0.12);
		border: 1px solid rgba(148, 163, 184, 0.16);

		.status-dot {
			background: #94a3b8;
		}
	}
}

.status-dot {
	width: 6px;
	height: 6px;
	border-radius: 50%;
}

.third-body {
	position: relative;
	z-index: 1;

	h4 {
		margin: 0 0 6px;
		font-size: 16px;
		font-weight: 720;
		color: #0f1724;
	}

	p {
		margin: 0;
		min-height: 18px;
		font-size: 12.5px;
		color: #6b7c8d;
		word-break: break-all;
	}
}

.third-foot {
	position: relative;
	z-index: 1;
	margin-top: 18px;
}

.action {
	width: 100%;
	height: 38px;
	border-radius: 11px;
	border: none;
	font-size: 13px;
	font-weight: 650;
	cursor: pointer;
	transition: all 0.2s ease;

	&.bind {
		color: #fff;
		background: linear-gradient(135deg, var(--brand), color-mix(in srgb, var(--brand) 70%, #fff));
		box-shadow: 0 8px 18px color-mix(in srgb, var(--brand) 28%, transparent);

		&:hover {
			filter: brightness(1.04);
		}
	}

	&.unbind {
		color: #b42318;
		background: rgba(239, 68, 68, 0.08);
		border: 1px solid rgba(239, 68, 68, 0.1);

		&:hover {
			background: rgba(239, 68, 68, 0.14);
		}
	}
}

@media (max-width: 720px) {
	.third-grid {
		grid-template-columns: 1fr;
	}
}
</style>
