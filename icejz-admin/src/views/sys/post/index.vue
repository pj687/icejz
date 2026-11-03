<template>
	<div class="org-auth-page">
		<section class="org-auth-hero">
			<div class="hero-copy">
				<span class="hero-kicker"><i class="hero-mark" aria-hidden="true"></i>组织权限</span>
				<h2>岗位管理</h2>
				<p>维护岗位编码、名称与启用状态，供用户归属引用</p>
			</div>
			<div class="hero-meta">
				<span class="hero-chip"><em>{{ state.total || 0 }}</em>个岗位</span>
				<span class="hero-chip">归属引用</span>
			</div>
		</section>

		<el-card class="org-auth-card org-auth-query layout-query" shadow="never">
			<el-form ref="queryRef" :inline="true" :model="state.queryForm" @keyup.enter="getDataList()">
				<el-form-item prop="postCode">
					<el-input v-model="state.queryForm.postCode" clearable placeholder="岗位编码"></el-input>
				</el-form-item>
				<el-form-item prop="postName">
					<el-input v-model="state.queryForm.postName" clearable placeholder="岗位名称"></el-input>
				</el-form-item>
				<el-form-item prop="status">
					<ma-dict-select v-model="state.queryForm.status" dict-type="post_status" clearable placeholder="状态"></ma-dict-select>
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
					<el-button v-auth="'sys:post:save'" icon="Plus" type="primary" @click="addOrUpdateHandle()">新增岗位</el-button>
					<el-button v-auth="'sys:post:delete'" icon="Delete" plain type="danger" @click="deleteBatchHandle()">批量删除</el-button>
				</el-space>
				<ma-view-mode v-model="viewMode" />
			</div>

			<template v-if="viewMode === 'table'">
				<el-table :data="state.dataList" class="layout-table" @selection-change="selectionChangeHandle">
					<el-table-column type="selection" header-align="center" align="center" width="50"></el-table-column>
					<el-table-column prop="postCode" label="岗位编码" min-width="140">
						<template #default="scope">
							<span class="org-auth-code">{{ scope.row.postCode || '—' }}</span>
						</template>
					</el-table-column>
					<el-table-column prop="postName" label="岗位名称" min-width="160">
						<template #default="scope">
							<span class="org-auth-name">
								<span class="avatar post">{{ (scope.row.postName || '岗').slice(0, 1) }}</span>
								{{ scope.row.postName }}
							</span>
						</template>
					</el-table-column>
					<el-table-column prop="sort" label="排序" width="100" align="center"></el-table-column>
					<ma-dict-column prop="status" label="状态" dict-type="post_status" width="110"></ma-dict-column>
				<el-table-column label="操作" fixed="right" align="center" width="168">
					<template #default="scope">
						<div class="org-auth-actions">
							<el-button v-auth="'sys:post:update'" class="act-btn act-primary" :icon="Edit" @click="addOrUpdateHandle(scope.row.id)">修改</el-button>
							<el-button v-auth="'sys:post:delete'" class="act-btn act-danger" :icon="Delete" @click="deleteBatchHandle(scope.row.id)">删除</el-button>
						</div>
					</template>
				</el-table-column>
				</el-table>
			</template>

			<div v-else class="org-auth-card-grid">
				<article v-for="row in state.dataList" :key="row.id" class="org-auth-entity-card">
					<div class="card-top">
						<div class="card-identity">
							<span class="card-avatar post">{{ (row.postName || '岗').slice(0, 1) }}</span>
							<div class="card-title">
								<strong>{{ row.postName }}</strong>
								<em>排序 {{ row.sort ?? 0 }}</em>
							</div>
						</div>
						<ma-dict-label dict-type="post_status" :dict-value="row.status" />
					</div>
					<div class="card-meta">
						<div class="meta-row"><span>岗位编码</span><b><span class="org-auth-code">{{ row.postCode || '—' }}</span></b></div>
					</div>
					<div class="card-foot">
						<span></span>
						<div class="org-auth-actions">
							<el-button v-auth="'sys:post:update'" class="act-btn act-primary" :icon="Edit" @click="addOrUpdateHandle(row.id)">修改</el-button>
							<el-button v-auth="'sys:post:delete'" class="act-btn act-danger" :icon="Delete" @click="deleteBatchHandle(row.id)">删除</el-button>
						</div>
					</div>
				</article>
				<div v-if="!state.dataList?.length" class="org-auth-empty-card">暂无岗位数据</div>
			</div>

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

<script setup lang="ts" name="SysPostIndex">
import { useCrud } from '@/hooks'
import { useViewMode } from '@/hooks/useViewMode'
import { reactive, ref } from 'vue'
import { Delete, Edit } from '@element-plus/icons-vue'
import AddOrUpdate from './add-or-update.vue'
import MaViewMode from '@/components/ma-view-mode/index.vue'
import { IHooksOptions } from '@/hooks/interface'

const { viewMode } = useViewMode('sys-post')

const state: IHooksOptions = reactive({
	dataListUrl: '/sys/post/page',
	deleteUrl: '/sys/post',
	queryForm: {
		postCode: '',
		postName: '',
		status: ''
	}
})

const queryRef = ref()
const addOrUpdateRef = ref()
const addOrUpdateHandle = (id?: number) => {
	addOrUpdateRef.value.init(id)
}

const { getDataList, selectionChangeHandle, sizeChangeHandle, currentChangeHandle, deleteBatchHandle, reset } = useCrud(state)
</script>

