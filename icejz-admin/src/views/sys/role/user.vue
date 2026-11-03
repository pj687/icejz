<template>
	<div class="role-user-panel">
		<div class="panel-toolbar">
			<el-form :inline="true" :model="state.queryForm" class="query-form" @keyup.enter="getDataList()">
				<el-form-item>
					<el-input v-model="state.queryForm.username" clearable placeholder="用户名"></el-input>
				</el-form-item>
				<el-form-item>
					<el-input v-model="state.queryForm.mobile" clearable placeholder="手机号"></el-input>
				</el-form-item>
				<el-form-item>
					<ma-dict-select v-model="state.queryForm.gender" dict-type="user_gender" clearable placeholder="性别"></ma-dict-select>
				</el-form-item>
				<el-form-item>
					<el-button icon="Search" type="primary" @click="getDataList()">查询</el-button>
				</el-form-item>
			</el-form>
			<el-space>
				<el-button icon="Plus" type="primary" @click="userSelectVisible = true">添加用户</el-button>
				<el-button icon="Delete" plain type="danger" @click="deleteBatchHandle()">批量删除</el-button>
			</el-space>
			<ma-user-dialog :key="userSelectVisible" v-model:visible="userSelectVisible" multiple @select="userHandle"></ma-user-dialog>
		</div>

		<el-table
			v-loading="state.dataListLoading"
			:data="state.dataList"
			class="layout-table"
			@selection-change="selectionChangeHandle"
			@sort-change="sortChangeHandle"
		>
			<el-table-column type="selection" header-align="center" align="center" width="50"></el-table-column>
			<el-table-column prop="realName" label="姓名" min-width="120">
				<template #default="scope">
					<span class="org-auth-name">
						<span class="avatar">{{ (scope.row.realName || scope.row.username || '?').slice(0, 1) }}</span>
						{{ scope.row.realName || '—' }}
					</span>
				</template>
			</el-table-column>
			<el-table-column prop="username" label="用户名" min-width="120"></el-table-column>
			<el-table-column prop="mobile" label="手机号" min-width="120"></el-table-column>
			<ma-dict-column prop="gender" label="性别" dict-type="user_gender" width="90"></ma-dict-column>
			<el-table-column label="操作" fixed="right" align="center" width="110">
				<template #default="scope">
					<div class="org-auth-actions">
						<el-button class="act-btn act-danger" :icon="Delete" @click="deleteBatchHandle(scope.row.id)">移除</el-button>
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
	</div>
</template>

<script setup lang="ts">
import { useCrud } from '@/hooks'
import { reactive, ref } from 'vue'
import { Delete } from '@element-plus/icons-vue'
import { IHooksOptions } from '@/hooks/interface'
import { useRoleUserSubmitApi } from '@/api/sys/role'
import { ElMessage } from 'element-plus/es'

const props = defineProps({
	roleId: {
		type: Number,
		required: true
	}
})

const userSelectVisible = ref(false)

const state: IHooksOptions = reactive({
	dataListUrl: '/sys/role/user/page',
	deleteUrl: '/sys/role/user/' + props.roleId,
	queryForm: {
		roleId: props.roleId,
		username: '',
		mobile: '',
		gender: ''
	}
})

const userHandle = (users: any[]) => {
	const userIdList = users.map((item: any) => item.id)
	useRoleUserSubmitApi(props.roleId, userIdList).then(() => {
		ElMessage.success('操作成功')
		getDataList()
	})
}

const { getDataList, selectionChangeHandle, sizeChangeHandle, currentChangeHandle, deleteBatchHandle, sortChangeHandle } = useCrud(state)
</script>

<style scoped lang="scss">
.role-user-panel {
	display: flex;
	flex-direction: column;
	gap: 12px;
}

.panel-toolbar {
	display: flex;
	flex-wrap: wrap;
	align-items: center;
	justify-content: space-between;
	gap: 10px;
	padding: 12px 14px;
	border-radius: 14px;
	background: #f5f9fc;
	border: 1px solid #e7eef5;
}

.query-form {
	:deep(.el-form-item) {
		margin-bottom: 0;
		margin-right: 10px;
	}

	:deep(.el-input__wrapper),
	:deep(.el-select__wrapper) {
		border-radius: 11px;
	}
}

:deep(.el-button) {
	border-radius: 11px;
}

:deep(.el-pagination) {
	margin-top: 8px;
	justify-content: flex-end;
}
</style>
