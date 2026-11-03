<template>
	<div class="org-auth-page">
		<section class="org-auth-hero">
			<div class="hero-copy">
				<span class="hero-kicker"><i class="hero-mark" aria-hidden="true"></i>运维中心</span>
				<h2>操作日志</h2>
				<p>记录模块操作请求、耗时与结果，便于排障追溯</p>
			</div>
			<div class="hero-meta">
				<span class="hero-chip"><em>{{ state.total || 0 }}</em>条记录</span>
				<span class="hero-chip">行为审计</span>
			</div>
		</section>

		<el-card class="org-auth-card org-auth-query layout-query" shadow="never">
			<el-form ref="queryRef" :inline="true" :model="state.queryForm" @keyup.enter="getDataList()">
				<el-form-item prop="realName">
					<el-input v-model="state.queryForm.realName" clearable placeholder="用户"></el-input>
				</el-form-item>
				<el-form-item prop="module">
					<el-input v-model="state.queryForm.module" clearable placeholder="模块名"></el-input>
				</el-form-item>
				<el-form-item prop="reqUri">
					<el-input v-model="state.queryForm.reqUri" clearable placeholder="请求URI"></el-input>
				</el-form-item>
				<el-form-item prop="status">
					<ma-dict-select v-model="state.queryForm.status" placeholder="操作状态" dict-type="success_fail" clearable></ma-dict-select>
				</el-form-item>
				<el-form-item>
					<el-button icon="Search" type="primary" @click="getDataList()">查询</el-button>
					<el-button icon="RefreshRight" @click="reset(queryRef)">重置</el-button>
				</el-form-item>
			</el-form>
		</el-card>

		<el-card class="org-auth-card page-card" shadow="never" v-loading="state.dataListLoading">
			<el-table
				show-overflow-tooltip
				:data="state.dataList"
				class="layout-table"
				@selection-change="selectionChangeHandle"
			>
				<el-table-column type="selection" header-align="center" align="center" width="50"></el-table-column>
				<el-table-column prop="realName" label="用户" min-width="110">
					<template #default="scope">
						<span class="org-auth-name">
							<span class="avatar">{{ (scope.row.realName || '?').slice(0, 1) }}</span>
							{{ scope.row.realName || '—' }}
						</span>
					</template>
				</el-table-column>
				<el-table-column prop="module" label="模块名" min-width="120"></el-table-column>
				<el-table-column prop="reqUri" label="请求URI" min-width="180">
					<template #default="scope">
						<span class="sys-route-code">{{ scope.row.reqUri || '—' }}</span>
					</template>
				</el-table-column>
				<el-table-column prop="reqMethod" label="方法" width="90" align="center">
					<template #default="scope">
						<span class="sys-type-pill menu">{{ scope.row.reqMethod || '—' }}</span>
					</template>
				</el-table-column>
				<el-table-column prop="address" label="地点" min-width="120"></el-table-column>
				<ma-dict-column prop="operateType" label="操作类型" dict-type="log_operate_type" width="110"></ma-dict-column>
				<el-table-column prop="duration" label="耗时" width="100" align="center">
					<template #default="scope">
						<span class="duration">{{ scope.row.duration }}ms</span>
					</template>
				</el-table-column>
				<ma-dict-column prop="status" label="状态" dict-type="success_fail" width="100"></ma-dict-column>
				<el-table-column prop="createTime" label="创建时间" width="170"></el-table-column>
				<el-table-column label="操作" fixed="right" align="center" width="100">
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

			<operate-detail ref="detailRef"></operate-detail>
		</el-card>
	</div>
</template>

<script setup lang="ts" name="SysLogOperate">
import { useCrud } from '@/hooks'
import { reactive, ref } from 'vue'
import { IHooksOptions } from '@/hooks/interface'
import OperateDetail from './operate-detail.vue'

const state: IHooksOptions = reactive({
	dataListUrl: '/sys/log/operate/page',
	queryForm: {
		realName: '',
		module: '',
		reqUri: '',
		status: ''
	}
})

const queryRef = ref()
const detailRef = ref()
const detailHandle = (row: any) => {
	detailRef.value.init(row)
}

const { getDataList, selectionChangeHandle, sizeChangeHandle, currentChangeHandle, reset } = useCrud(state)
</script>

<style scoped lang="scss">
.duration {
	font-variant-numeric: tabular-nums;
	font-weight: 650;
	color: #475569;
}
</style>
