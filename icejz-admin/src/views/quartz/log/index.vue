<template>
	<div class="ops-log-panel">
		<el-form :inline="true" :model="state.queryForm" class="ops-log-query" @keyup.enter="getDataList()">
			<el-form-item>
				<el-input v-model="state.queryForm.jobId" clearable placeholder="任务ID"></el-input>
			</el-form-item>
			<el-form-item>
				<el-input v-model="state.queryForm.jobName" clearable placeholder="任务名称"></el-input>
			</el-form-item>
			<el-form-item>
				<ma-dict-select v-model="state.queryForm.jobGroup" dict-type="schedule_group" clearable placeholder="任务组名"></ma-dict-select>
			</el-form-item>
			<el-form-item>
				<el-button icon="Search" type="primary" @click="getDataList()">查询</el-button>
			</el-form-item>
		</el-form>

		<el-table
			v-loading="state.dataListLoading"
			show-overflow-tooltip
			:data="state.dataList"
			class="layout-table"
			@selection-change="selectionChangeHandle"
		>
			<el-table-column type="selection" header-align="center" align="center" width="50"></el-table-column>
			<el-table-column prop="jobId" label="任务ID" width="100" align="center"></el-table-column>
			<el-table-column prop="jobName" label="任务名称" min-width="140"></el-table-column>
			<ma-dict-column prop="jobGroup" label="任务组名" dict-type="schedule_group" width="120"></ma-dict-column>
			<el-table-column prop="beanName" label="执行方法" min-width="180">
				<template #default="scope">
					<span class="sys-route-code">{{ scope.row.beanName }}.{{ scope.row.method }}()</span>
				</template>
			</el-table-column>
			<el-table-column prop="status" label="状态" width="100" align="center">
				<template #default="scope">
					<span class="sys-type-pill" :class="scope.row.status === 0 ? 'api' : 'button'">
						{{ scope.row.status === 0 ? '失败' : '成功' }}
					</span>
				</template>
			</el-table-column>
			<el-table-column prop="times" label="时长" width="110" align="center">
				<template #default="scope">
					<span class="duration">{{ scope.row.times }}ms</span>
				</template>
			</el-table-column>
			<el-table-column prop="createTime" label="执行时间" width="170"></el-table-column>
			<el-table-column label="操作" fixed="right" align="center" width="90">
				<template #default="scope">
					<div class="org-auth-actions">
						<el-button class="act-btn act-primary" @click="detailHandle(scope.row)">详情</el-button>
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

		<detail ref="detailRef"></detail>
	</div>
</template>

<script setup lang="ts">
import { useCrud } from '@/hooks'
import { reactive, ref } from 'vue'
import Detail from './detail.vue'
import { IHooksOptions } from '@/hooks/interface'

const state: IHooksOptions = reactive({
	dataListUrl: '/schedule/log/page',
	queryForm: {
		jobName: '',
		jobGroup: '',
		jobId: ''
	}
})

const detailRef = ref()
const detailHandle = (row: any) => {
	detailRef.value.init(row)
}

const { getDataList, selectionChangeHandle, sizeChangeHandle, currentChangeHandle } = useCrud(state)

const init = (row?: any) => {
	if (row) {
		state.queryForm.jobId = row.id
		state.queryForm.jobName = row.jobName
		state.queryForm.jobGroup = row.jobGroup
	} else {
		state.queryForm.jobId = ''
		state.queryForm.jobName = ''
		state.queryForm.jobGroup = ''
	}
	getDataList()
}

defineExpose({
	init
})
</script>

<style scoped lang="scss">
.ops-log-panel {
	padding: 4px 4px 12px;
}

.ops-log-query {
	display: flex;
	flex-wrap: wrap;
	gap: 8px 4px;
	margin-bottom: 14px;
	padding: 12px 14px;
	border-radius: 14px;
	background: #f7fbfe;
	border: 1px solid #e7eef5;

	.el-form-item {
		margin-bottom: 0;
		margin-right: 10px;
	}
}

.duration {
	font-variant-numeric: tabular-nums;
	font-weight: 650;
	color: #475569;
}

:deep(.el-pagination) {
	margin-top: 16px;
	justify-content: flex-end;
}
</style>
