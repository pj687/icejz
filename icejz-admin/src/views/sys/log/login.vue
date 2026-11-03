<template>
	<div class="org-auth-page">
		<section class="org-auth-hero">
			<div class="hero-copy">
				<span class="hero-kicker"><i class="hero-mark" aria-hidden="true"></i>运维中心</span>
				<h2>登录日志</h2>
				<p>追踪账号登录成功与失败记录，便于安全审计</p>
			</div>
			<div class="hero-meta">
				<span class="hero-chip"><em>{{ state.total || 0 }}</em>条记录</span>
				<span class="hero-chip">安全审计</span>
			</div>
		</section>

		<el-card class="org-auth-card org-auth-query layout-query" shadow="never">
			<el-form ref="queryRef" :inline="true" :model="state.queryForm" @keyup.enter="getDataList()">
				<el-form-item prop="username">
					<el-input v-model="state.queryForm.username" clearable placeholder="用户名"></el-input>
				</el-form-item>
				<el-form-item prop="address">
					<el-input v-model="state.queryForm.address" clearable placeholder="登录地点"></el-input>
				</el-form-item>
				<el-form-item prop="status">
					<ma-dict-select v-model="state.queryForm.status" dict-type="success_fail" placeholder="登录状态" clearable></ma-dict-select>
				</el-form-item>
				<el-form-item>
					<el-button icon="Search" type="primary" @click="getDataList()">查询</el-button>
					<el-button icon="RefreshRight" @click="reset(queryRef)">重置</el-button>
				</el-form-item>
			</el-form>
		</el-card>

		<el-card class="org-auth-card page-card" shadow="never" v-loading="state.dataListLoading">
			<div class="org-auth-toolbar">
				<el-space wrap>
					<el-button icon="Download" plain @click="downloadHandle('/sys/log/login/export')">导出</el-button>
				</el-space>
			</div>

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
				<el-table-column prop="ip" label="登录IP" min-width="130">
					<template #default="scope">
						<span class="sys-route-code">{{ scope.row.ip || '—' }}</span>
					</template>
				</el-table-column>
				<el-table-column prop="address" label="登录地点" min-width="140"></el-table-column>
				<el-table-column prop="userAgent" label="User Agent" min-width="200" show-overflow-tooltip></el-table-column>
				<ma-dict-column prop="status" label="登录状态" dict-type="success_fail" width="110"></ma-dict-column>
				<ma-dict-column prop="operation" label="操作信息" dict-type="login_operation" width="130"></ma-dict-column>
				<el-table-column prop="createTime" label="登录时间" width="170"></el-table-column>
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

<script setup lang="ts" name="SysLogLogin">
import { useCrud } from '@/hooks'
import { reactive, ref } from 'vue'
import { IHooksOptions } from '@/hooks/interface'

const state: IHooksOptions = reactive({
	dataListUrl: '/sys/log/login/page',
	queryForm: {
		username: '',
		address: '',
		status: ''
	}
})

const queryRef = ref()

const { getDataList, selectionChangeHandle, sizeChangeHandle, currentChangeHandle, downloadHandle, reset } = useCrud(state)
</script>
