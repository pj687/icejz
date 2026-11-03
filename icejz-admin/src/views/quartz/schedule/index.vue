<template>
	<div class="org-auth-page">
		<section class="org-auth-hero">
			<div class="hero-copy">
				<span class="hero-kicker"><i class="hero-mark" aria-hidden="true"></i>运维中心</span>
				<h2>定时任务</h2>
				<p>管理调度任务、Cron 表达式与执行状态</p>
			</div>
			<div class="hero-meta">
				<span class="hero-chip"><em>{{ state.total || 0 }}</em>个任务</span>
				<span class="hero-chip">Quartz</span>
			</div>
		</section>

		<el-card class="org-auth-card org-auth-query layout-query" shadow="never">
			<el-form ref="queryRef" :inline="true" :model="state.queryForm" @keyup.enter="getDataList()">
				<el-form-item prop="jobName">
					<el-input v-model="state.queryForm.jobName" clearable placeholder="任务名称"></el-input>
				</el-form-item>
				<el-form-item prop="jobGroup">
					<ma-dict-select v-model="state.queryForm.jobGroup" dict-type="schedule_group" clearable placeholder="任务组名"></ma-dict-select>
				</el-form-item>
				<el-form-item prop="status">
					<ma-dict-select v-model="state.queryForm.status" dict-type="schedule_status" clearable placeholder="任务状态"></ma-dict-select>
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
					<el-button v-auth="'schedule:save'" icon="Plus" type="primary" @click="addOrUpdateHandle()">新增任务</el-button>
					<el-button v-auth="'schedule:log'" icon="Document" plain @click="logHandle()">任务日志</el-button>
					<el-button v-auth="'schedule:delete'" icon="Delete" plain type="danger" @click="deleteBatchHandle()">批量删除</el-button>
				</el-space>
			</div>

			<el-table
				show-overflow-tooltip
				:data="state.dataList"
				class="layout-table"
				@selection-change="selectionChangeHandle"
			>
				<el-table-column type="selection" header-align="center" align="center" width="50"></el-table-column>
				<el-table-column prop="id" label="ID" width="80" align="center"></el-table-column>
				<el-table-column prop="jobName" label="任务名称" min-width="140">
					<template #default="scope">
						<span class="org-auth-name">
							<span class="avatar">{{ (scope.row.jobName || '?').slice(0, 1) }}</span>
							{{ scope.row.jobName || '—' }}
						</span>
					</template>
				</el-table-column>
				<ma-dict-column prop="jobGroup" label="任务组名" dict-type="schedule_group" width="120"></ma-dict-column>
				<el-table-column prop="beanName" label="执行方法" min-width="180">
					<template #default="scope">
						<span class="sys-route-code">{{ scope.row.beanName }}.{{ scope.row.method }}()</span>
					</template>
				</el-table-column>
				<el-table-column prop="cronExpression" label="Cron 表达式" min-width="140">
					<template #default="scope">
						<span class="org-auth-code">{{ scope.row.cronExpression || '—' }}</span>
					</template>
				</el-table-column>
				<ma-dict-column prop="status" label="状态" dict-type="schedule_status" width="100"></ma-dict-column>
				<el-table-column label="操作" fixed="right" align="center" width="320">
					<template #default="scope">
						<div class="org-auth-actions">
							<el-button v-auth="'schedule:update'" class="act-btn act-primary" @click="addOrUpdateHandle(scope.row.id)">修改</el-button>
							<el-button
								v-if="scope.row.status === 0"
								v-auth="'schedule:update'"
								class="act-btn act-primary"
								@click="statusHandle(scope.row, 1)"
							>恢复</el-button>
							<el-button
								v-if="scope.row.status === 1"
								v-auth="'schedule:update'"
								class="act-btn act-primary"
								@click="statusHandle(scope.row, 0)"
							>暂停</el-button>
							<el-button v-auth="'schedule:run'" class="act-btn act-primary" @click="runHandle(scope.row)">执行</el-button>
							<el-button v-auth="'schedule:log'" class="act-btn act-primary" @click="logHandle(scope.row)">日志</el-button>
							<el-button v-auth="'schedule:delete'" class="act-btn act-danger" @click="deleteBatchHandle(scope.row.id)">删除</el-button>
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

			<add-or-update ref="addOrUpdateRef" @refresh-data-list="getDataList"></add-or-update>

			<el-drawer v-if="logVisible" v-model="logVisible" class="ops-drawer" title="任务日志" :size="1200" :close-on-press-escape="false">
				<log ref="logRef" />
			</el-drawer>
		</el-card>
	</div>
</template>

<script setup lang="ts" name="QuartzScheduleIndex">
import { useCrud } from '@/hooks'
import { reactive, ref, nextTick } from 'vue'
import AddOrUpdate from './add-or-update.vue'
import Log from '../log/index.vue'
import { IHooksOptions } from '@/hooks/interface'
import { useScheduleStatusApi, useScheduleRunApi } from '@/api/quartz/schedule'
import { ElMessage, ElMessageBox } from 'element-plus/es'

const state: IHooksOptions = reactive({
	dataListUrl: '/schedule/page',
	deleteUrl: '/schedule',
	queryForm: {
		jobName: '',
		jobGroup: '',
		status: ''
	}
})

const runHandle = (row: any) => {
	ElMessageBox.confirm('确定进行立即执行操作?', '提示', {
		confirmButtonText: '确定',
		cancelButtonText: '取消',
		type: 'warning'
	})
		.then(() => {
			useScheduleRunApi(row).then(() => {
				ElMessage.success({
					message: '操作成功',
					duration: 500
				})
			})
		})
		.catch(() => {})
}

const statusHandle = (row: any, status: any) => {
	const opt = status === 0 ? '暂停' : '恢复'
	ElMessageBox.confirm(`确定进行${opt}操作?`, '提示', {
		confirmButtonText: '确定',
		cancelButtonText: '取消',
		type: 'warning'
	})
		.then(() => {
			row.status = status
			useScheduleStatusApi(row).then(() => {
				ElMessage.success({
					message: '操作成功',
					duration: 500
				})
			})
		})
		.catch(() => {})
}

const logVisible = ref(false)
const logRef = ref<any>(null)
const logHandle = (row?: any) => {
	logVisible.value = true
	nextTick(() => {
		logRef.value?.init?.(row)
	})
}

const queryRef = ref()
const addOrUpdateRef = ref()
const addOrUpdateHandle = (id?: number) => {
	addOrUpdateRef.value.init(id)
}

const { getDataList, selectionChangeHandle, sizeChangeHandle, currentChangeHandle, deleteBatchHandle, reset } = useCrud(state)
</script>
