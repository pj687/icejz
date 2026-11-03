<template>
	<div class="config-pane">
		<div class="org-auth-toolbar">
			<el-space wrap>
				<el-button icon="Plus" type="primary" @click="addOrUpdateHandle()">新增配置</el-button>
				<el-button icon="Delete" plain type="danger" @click="deleteBatchHandle()">批量删除</el-button>
			</el-space>
		</div>

		<el-table v-loading="state.dataListLoading" :data="state.dataList" class="layout-table" @selection-change="selectionChangeHandle">
			<el-table-column type="selection" header-align="center" align="center" width="50"></el-table-column>
			<el-table-column prop="id" label="ID" width="90" align="center">
				<template #default="scope">
					<span class="org-auth-code">{{ scope.row.id }}</span>
				</template>
			</el-table-column>
			<ma-dict-column prop="platform" label="平台类型" dict-type="mail_platform" min-width="120"></ma-dict-column>
			<el-table-column prop="groupName" label="分组名称" min-width="140"></el-table-column>
			<ma-dict-column prop="status" label="状态" dict-type="enable_disable" width="100"></ma-dict-column>
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

		<add-or-update ref="addOrUpdateRef" @refreshDataList="getDataList"></add-or-update>
	</div>
</template>

<script setup lang="ts">
import { useCrud } from '@/hooks'
import { reactive, ref } from 'vue'
import { Delete, Edit } from '@element-plus/icons-vue'
import { IHooksOptions } from '@/hooks/interface'
import AddOrUpdate from './add-or-update.vue'

const state: IHooksOptions = reactive({
	dataListUrl: '/sys/mail/config/page',
	deleteUrl: '/sys/mail/config'
})

const addOrUpdateRef = ref()
const addOrUpdateHandle = (id?: number) => {
	addOrUpdateRef.value.init(id)
}

const { getDataList, selectionChangeHandle, sizeChangeHandle, currentChangeHandle, deleteBatchHandle } = useCrud(state)
</script>

<style scoped lang="scss">
.config-pane {
	padding-top: 4px;
}
</style>
