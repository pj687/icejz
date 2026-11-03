<template>
	<div class="org-auth-page">
		<section class="org-auth-hero">
			<div class="hero-copy">
				<span class="hero-kicker"><i class="hero-mark" aria-hidden="true"></i>系统管理</span>
				<h2>数据字典</h2>
				<p>统一维护枚举字典与动态 SQL 数据源，供表单与列表复用</p>
			</div>
			<div class="hero-meta">
				<span class="hero-chip"><em>{{ state.total || 0 }}</em>个类型</span>
				<span class="hero-chip">配置中心</span>
			</div>
		</section>

		<el-card class="org-auth-card org-auth-query layout-query" shadow="never">
			<el-form ref="queryRef" :inline="true" :model="state.queryForm" @keyup.enter="getDataList">
				<el-form-item prop="dictType">
					<el-input v-model="state.queryForm.dictType" clearable placeholder="字典类型"></el-input>
				</el-form-item>
				<el-form-item prop="dictName">
					<el-input v-model="state.queryForm.dictName" clearable placeholder="字典名称"></el-input>
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
					<el-button icon="Plus" type="primary" @click="addOrUpdateHandle()">新增字典</el-button>
					<el-button icon="Delete" plain type="danger" @click="deleteBatchHandle()">批量删除</el-button>
				</el-space>
			</div>

			<el-table
				:data="state.dataList"
				show-overflow-tooltip
				class="layout-table"
				row-key="id"
				lazy
				:load="load"
				:tree-props="{ children: 'children', hasChildren: 'hasChild' }"
				@selection-change="selectionChangeHandle"
				@sort-change="sortChangeHandle"
			>
				<el-table-column type="selection" header-align="center" align="center" width="50"></el-table-column>
				<el-table-column prop="dictType" label="字典类型" min-width="160">
					<template #default="scope">
						<span class="org-auth-code">{{ scope.row.dictType }}</span>
					</template>
				</el-table-column>
				<el-table-column prop="dictName" label="字典名称" min-width="140">
					<template #default="scope">
						<span class="org-auth-name">
							<span class="avatar dict">{{ (scope.row.dictName || '典').slice(0, 1) }}</span>
							{{ scope.row.dictName }}
						</span>
					</template>
				</el-table-column>
				<el-table-column prop="remark" label="备注" min-width="140" show-overflow-tooltip></el-table-column>
				<el-table-column prop="dictSource" label="数据来源" width="120" align="center">
					<template #default="scope">
						<span class="sys-type-pill" :class="scope.row.dictSource === 0 ? 'menu' : 'api'">
							{{ scope.row.dictSource === 0 ? '字典数据' : '动态 SQL' }}
						</span>
					</template>
				</el-table-column>
				<el-table-column prop="sort" label="排序" sortable="custom" width="100" align="center"></el-table-column>
				<el-table-column prop="createTime" label="创建时间" width="170"></el-table-column>
				<el-table-column label="操作" fixed="right" align="center" width="260">
					<template #default="scope">
						<div class="org-auth-actions">
							<el-button
								v-if="scope.row.dictSource === 0"
								class="act-btn act-success"
								@click="showDictDataHandle(scope.row)"
							>
								字典配置
							</el-button>
							<el-button
								v-if="scope.row.dictSource === 1"
								class="act-btn act-warn"
								@click="showDataSqlHandle(scope.row)"
							>
								动态数据
							</el-button>
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

			<el-drawer v-if="dataSqlVisible" v-model="dataSqlVisible" class="sys-admin-drawer" :title="dataSqlTitle" :size="800" :close-on-press-escape="false">
				<data-sql :dict-type-id="dictTypeId"></data-sql>
			</el-drawer>

			<el-drawer v-if="dictDataVisible" v-model="dictDataVisible" class="sys-admin-drawer" :title="dictDataTitle" :size="800" :close-on-press-escape="false">
				<dict-data :dict-type-id="dictTypeId"></dict-data>
			</el-drawer>
		</el-card>
	</div>
</template>

<script setup lang="ts" name="SysDictType">
import { useCrud } from '@/hooks'
import { reactive, ref } from 'vue'
import { Delete, Edit } from '@element-plus/icons-vue'
import AddOrUpdate from './type-add-or-update.vue'
import DataSql from './data-sql.vue'
import DictData from './data.vue'
import { IHooksOptions } from '@/hooks/interface'
import { useDictTypeListApi } from '@/api/sys/dict'

const state: IHooksOptions = reactive({
	dataListUrl: '/sys/dict/type/page',
	deleteUrl: '/sys/dict/type',
	queryForm: {
		dictName: '',
		dictType: ''
	}
})

const dictDataVisible = ref(false)
const dictDataTitle = ref()
const dictTypeId = ref()
const showDictDataHandle = (row: any) => {
	dictTypeId.value = row.id
	dictDataTitle.value = '字典配置 - ' + row.dictType
	dictDataVisible.value = true
}

const dataSqlVisible = ref(false)
const dataSqlTitle = ref()
const showDataSqlHandle = (row: any) => {
	dataSqlVisible.value = true
	dictTypeId.value = row.id
	dataSqlTitle.value = '动态数据 - ' + row.dictType
}

const nodeMap = new Map()
const load = (tree: any, treeNode: unknown, resolve: (data: any[]) => void) => {
	if (!nodeMap.has(tree.id)) {
		nodeMap.set(tree.id, { tree, treeNode, resolve })
	}

	useDictTypeListApi(tree.id).then((res: any) => {
		if (res.data.length > 0) {
			resolve(res.data)
		} else {
			resolve([])
		}
	})
}

const queryRef = ref()
const addOrUpdateRef = ref()
const addOrUpdateHandle = (id?: Number) => {
	addOrUpdateRef.value.init(id)
}

const { getDataList, sizeChangeHandle, selectionChangeHandle, sortChangeHandle, currentChangeHandle, deleteBatchHandle, reset } = useCrud(state)
</script>

<style lang="scss">
.sys-admin-drawer {
	.el-drawer__header {
		margin-bottom: 8px;
		padding: 18px 20px 10px;
		border-bottom: 1px solid #eef3f8;
	}

	.el-drawer__title {
		font-weight: 740;
		color: #122033;
	}

	.el-drawer__body {
		padding: 14px 20px 20px;
		background:
			radial-gradient(520px 180px at 100% 0%, rgba(0, 168, 232, 0.05), transparent 60%),
			#fff;
	}
}
</style>
