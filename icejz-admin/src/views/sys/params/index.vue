<template>
	<div class="org-auth-page">
		<section class="org-auth-hero">
			<div class="hero-copy">
				<span class="hero-kicker"><i class="hero-mark" aria-hidden="true"></i>系统管理</span>
				<h2>参数管理</h2>
				<p>配置全局键值参数，控制系统行为与业务开关</p>
			</div>
			<div class="hero-meta">
				<span class="hero-chip"><em>{{ state.total || 0 }}</em>条参数</span>
				<span class="hero-chip">键值配置</span>
			</div>
		</section>

		<el-card class="org-auth-card org-auth-query layout-query" shadow="never">
			<el-form ref="queryRef" :inline="true" :model="state.queryForm" @keyup.enter="getDataList()">
				<el-form-item prop="paramKey">
					<el-input v-model="state.queryForm.paramKey" clearable placeholder="参数键"></el-input>
				</el-form-item>
				<el-form-item prop="paramValue">
					<el-input v-model="state.queryForm.paramValue" clearable placeholder="参数值"></el-input>
				</el-form-item>
				<el-form-item prop="paramType">
					<ma-dict-select v-model="state.queryForm.paramType" dict-type="params_type" placeholder="系统参数" clearable></ma-dict-select>
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
					<el-button icon="Plus" type="primary" @click="addOrUpdateHandle()">新增参数</el-button>
					<el-button icon="Delete" plain type="danger" @click="deleteBatchHandle()">批量删除</el-button>
				</el-space>
			</div>

			<el-table
				show-overflow-tooltip
				:data="state.dataList"
				class="layout-table"
				@selection-change="selectionChangeHandle"
			>
				<el-table-column type="selection" header-align="center" align="center" width="50"></el-table-column>
				<el-table-column prop="paramName" label="参数名称" min-width="140"></el-table-column>
				<el-table-column prop="paramKey" label="参数键" min-width="160">
					<template #default="scope">
						<span class="org-auth-code">{{ scope.row.paramKey }}</span>
					</template>
				</el-table-column>
				<el-table-column prop="paramValue" label="参数值" min-width="160" show-overflow-tooltip></el-table-column>
				<ma-dict-column prop="paramType" label="系统参数" dict-type="params_type" width="120"></ma-dict-column>
				<el-table-column prop="remark" label="备注" min-width="140" show-overflow-tooltip></el-table-column>
				<el-table-column prop="createTime" label="创建时间" width="170"></el-table-column>
				<el-table-column label="操作" fixed="right" align="center" width="168">
					<template #default="scope">
						<div class="org-auth-actions">
							<el-button class="act-btn act-primary" :icon="Edit" @click="addOrUpdateHandle(scope.row.id)">修改</el-button>
							<el-button class="act-btn act-danger" :icon="Delete" @click="deleteBatchHandle(scope.row.id)">删除</el-button>
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
		</el-card>
	</div>
</template>

<script setup lang="ts" name="SysParamsIndex">
import { useCrud } from '@/hooks'
import { reactive, ref } from 'vue'
import { Delete, Edit } from '@element-plus/icons-vue'
import AddOrUpdate from './add-or-update.vue'
import { IHooksOptions } from '@/hooks/interface'

const state: IHooksOptions = reactive({
	dataListUrl: '/sys/params/page',
	deleteUrl: '/sys/params',
	queryForm: {
		paramType: '',
		paramKey: '',
		paramValue: ''
	}
})

const queryRef = ref()
const addOrUpdateRef = ref()
const addOrUpdateHandle = (id?: number) => {
	addOrUpdateRef.value.init(id)
}

const { getDataList, selectionChangeHandle, sizeChangeHandle, currentChangeHandle, deleteBatchHandle, reset } = useCrud(state)
</script>
