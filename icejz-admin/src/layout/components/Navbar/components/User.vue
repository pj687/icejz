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

	<el-dialog v-model="aboutVisible" title="关于 ICEJZ" width="420px" append-to-body>
		<div class="about-box">
			<img src="/logo.png" alt="ICEJZ" class="about-logo" />
			<strong>{{ aboutName }}</strong>
			<em>低代码开发平台</em>
			<ul>
				<li><span>前端版本</span><b>v{{ constant.version }}</b></li>
				<li><span>服务版本</span><b>v{{ serverVersion }}</b></li>
				<li v-if="serverApp"><span>服务标识</span><b>{{ serverApp }}</b></li>
			</ul>
		</div>
		<template #footer>
			<el-button type="primary" @click="aboutVisible = false">知道了</el-button>
		</template>
	</el-dialog>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useUserStore } from '@/store/modules/user'
import { ArrowDown } from '@element-plus/icons-vue'
import constant from '@/utils/constant'
import { useAppVersionApi } from '@/api/sys/app'

const userStore = useUserStore()
const aboutVisible = ref(false)
const aboutName = ref('ICEJZ')
const serverVersion = ref(constant.version)
const serverApp = ref('')

const openAbout = async () => {
	aboutVisible.value = true
	try {
		const { data } = await useAppVersionApi()
		aboutName.value = data?.name || 'ICEJZ'
		serverVersion.value = data?.version || constant.version
		serverApp.value = data?.application || ''
	} catch {
		serverVersion.value = constant.version
		serverApp.value = ''
	}
}

const logout = () => {
	userStore.logoutAction().then(() => {
		location.reload()
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

.about-box {
	display: flex;
	flex-direction: column;
	align-items: center;
	gap: 6px;
	padding: 8px 4px 4px;
	text-align: center;

	.about-logo {
		width: 56px;
		height: 56px;
		object-fit: contain;
		margin-bottom: 6px;
	}

	strong {
		font-size: 18px;
		color: #0f1724;
	}

	em {
		font-style: normal;
		font-size: 13px;
		color: #64748b;
		margin-bottom: 10px;
	}

	ul {
		width: 100%;
		margin: 0;
		padding: 0;
		list-style: none;
		border-top: 1px solid rgba(15, 23, 36, 0.06);

		li {
			display: flex;
			justify-content: space-between;
			align-items: center;
			padding: 10px 2px;
			border-bottom: 1px solid rgba(15, 23, 36, 0.06);
			font-size: 13px;

			span {
				color: #64748b;
			}
			b {
				font-weight: 700;
				color: #0f4f6e;
			}
		}
	}
}
</style>
