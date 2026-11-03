<template>
	<div class="org-auth-page">
		<section class="org-auth-hero">
			<div class="hero-copy">
				<span class="hero-kicker"><i class="hero-mark" aria-hidden="true"></i>运维中心</span>
				<h2>在线用户</h2>
				<p>查看当前在线会话与设备信息，必要时可强制下线</p>
			</div>
			<div class="hero-meta">
				<span class="hero-chip"><em>{{ state.total || 0 }}</em>人在线</span>
				<span class="hero-chip">会话管理</span>
			</div>
		</section>

		<el-card class="org-auth-card page-card" shadow="never" v-loading="state.dataListLoading">
			<el-table
				show-overflow-tooltip
				:data="state.dataList"
				class="layout-table"
				@selection-change="selectionChangeHandle"
			>
				<el-table-column type="selection" header-align="center" align="center" width="50"></el-table-column>
				<el-table-column prop="username" label="用户名" min-width="120">
					<template #default="scope">
						<span class="org-auth-name">
							<span class="avatar">{{ (scope.row.username || '?').slice(0, 1) }}</span>
							{{ scope.row.username || '—' }}
						</span>
					</template>
				</el-table-column>
				<el-table-column prop="realName" label="姓名" min-width="100"></el-table-column>
				<el-table-column prop="loginIp" label="登录 IP" min-width="120">
					<template #default="scope">
						<span class="sys-route-code">{{ scope.row.loginIp || '—' }}</span>
					</template>
				</el-table-column>
				<el-table-column prop="clientType" label="客户端" width="90">
					<template #default="scope">
						{{ clientLabel(scope.row.clientType) }}
					</template>
				</el-table-column>
				<el-table-column prop="userAgent" label="设备 / 浏览器" min-width="200" show-overflow-tooltip>
					<template #default="scope">
						{{ shortUa(scope.row.userAgent) }}
					</template>
				</el-table-column>
				<el-table-column prop="loginTime" label="登录时间" min-width="160">
					<template #default="scope">
						{{ formatTime(scope.row.loginTime) }}
					</template>
				</el-table-column>
				<el-table-column prop="accessToken" label="会话编号" min-width="160" show-overflow-tooltip>
					<template #default="scope">
						<span class="sys-route-code">{{ scope.row.accessToken || '—' }}</span>
					</template>
				</el-table-column>
				<el-table-column label="操作" fixed="right" align="center" width="110">
					<template #default="scope">
						<div class="org-auth-actions">
							<el-button class="act-btn act-danger" @click="logoutHandle(scope.row.accessToken)">踢出</el-button>
						</div>
					</template>
				</el-table-column>
			</el-table>

			<el-pagination
				:current-page="state.page"
				:page-sizes="state.pageSizes"
				:page-size="state.limit"
				:total="state.total"
				layout="total, sizes, prev, pager, next, jumper"
				@size-change="sizeChangeHandle"
				@current-change="currentChangeHandle"
			>
			</el-pagination>
		</el-card>
	</div>
</template>

<script setup lang="ts">
import { useCrud } from '@/hooks'
import { reactive } from 'vue'
import { IHooksOptions } from '@/hooks/interface'
import { useMonitorUserLogoutApi } from '@/api/monitor/user'
import { ElMessage, ElMessageBox } from 'element-plus'

const state: IHooksOptions = reactive({
	dataListUrl: 'monitor/user/page'
})

const clientLabel = (type?: string) => {
	const map: Record<string, string> = { pc: 'PC', app: 'App', mp: '小程序' }
	return map[type || ''] || type || '—'
}

const shortUa = (ua?: string) => {
	if (!ua) {
		return '—'
	}
	if (ua.length <= 64) {
		return ua
	}
	return ua.slice(0, 64) + '…'
}

const formatTime = (t?: string) => {
	if (!t) {
		return '—'
	}
	return String(t).replace('T', ' ').replace(/\.\d+$/, '').slice(0, 19)
}

const logoutHandle = (accessToken: string) => {
	ElMessageBox.confirm('确定踢出该用户? 被踢设备的刷新令牌也将失效。', '提示', {
		confirmButtonText: '确定',
		cancelButtonText: '取消',
		type: 'warning'
	})
		.then(() => {
			useMonitorUserLogoutApi(accessToken).then(() => {
				ElMessage.success({
					message: '操作成功',
					duration: 500
				})
				getDataList()
			})
		})
		.catch(() => {})
}

const { getDataList, selectionChangeHandle, sizeChangeHandle, currentChangeHandle } = useCrud(state)
</script>
