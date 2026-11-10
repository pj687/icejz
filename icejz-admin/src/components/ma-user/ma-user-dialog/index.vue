<template>
	<el-dialog
		:model-value="visible"
		:title="title"
		width="920px"
		align-center
		draggable
		append-to-body
		destroy-on-close
		class="ma-user-dialog"
		:close-on-click-modal="false"
		@close="handleClose"
	>
		<div class="user-pick-layout">
			<aside class="org-pane">
				<ma-data-tree-left
					url="/sys/org/list"
					title="机构列表"
					tree-data
					class="pick-org-tree"
					@click="onOrgClick"
				/>
			</aside>
			<section class="table-pane">
				<el-form :inline="true" :model="state.queryForm" class="pick-query" @submit.prevent>
					<el-form-item>
						<el-input v-model="state.queryForm.username" clearable placeholder="用户名" @keyup.enter="getDataList()" />
					</el-form-item>
					<el-form-item>
						<el-input v-model="state.queryForm.mobile" clearable placeholder="手机号" @keyup.enter="getDataList()" />
					</el-form-item>
					<el-form-item>
						<el-button icon="Search" type="primary" @click="getDataList()">查询</el-button>
					</el-form-item>
				</el-form>

				<el-table
					v-loading="state.dataListLoading"
					:data="state.dataList"
					border
					height="420"
					highlight-current-row
					show-overflow-tooltip
					row-key="id"
					@row-dblclick="handleRowDblClick"
					@selection-change="selectionChangeHandle"
					@current-change="onCurrentChange"
				>
					<el-table-column v-if="multiple" type="selection" header-align="center" align="center" width="48" />
					<el-table-column prop="realName" label="姓名" min-width="110" />
					<el-table-column prop="username" label="用户名" min-width="110" />
					<el-table-column prop="mobile" label="手机号" min-width="120" />
					<el-table-column prop="orgName" label="所属机构" min-width="140" />
				</el-table>

				<el-pagination
					:current-page="state.page"
					:page-sizes="state.pageSizes"
					:page-size="state.limit"
					:total="state.total"
					layout="total, sizes, prev, pager, next"
					@size-change="sizeChangeHandle"
					@current-change="currentChangeHandle"
				/>
			</section>
		</div>

		<template #footer>
			<el-button @click="handleClose">取消</el-button>
			<el-button type="primary" @click="submitHandle">确定</el-button>
		</template>
	</el-dialog>
</template>

<script setup lang="ts" name="MaUserDialog">
import { reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { IHooksOptions } from '@/hooks/interface'
import { useCrud } from '@/hooks'

const props = defineProps({
	multiple: {
		type: Boolean,
		required: false,
		default: false
	},
	url: {
		type: String,
		required: false,
		default: '/sys/user/page'
	},
	title: {
		type: String,
		required: false,
		default: '用户选择'
	}
})

const visible = defineModel<boolean>()

const state: IHooksOptions = reactive({
	dataListUrl: props.url,
	queryForm: {
		username: '',
		mobile: '',
		orgId: [] as any[]
	},
	isPage: true
})

const currentRow = ref<any>()
const onCurrentChange = (row: any) => {
	currentRow.value = row
}

const onOrgClick = (orgId: any[]) => {
	state.queryForm.orgId = orgId
	getDataList()
}

const emit = defineEmits(['select'])

const submitHandle = () => {
	if (props.multiple) {
		const dataList = state.dataListSelections ? state.dataListSelections : []
		if (!dataList.length) {
			ElMessage.warning('请选择用户')
			return
		}
		handleClose()
		emit('select', dataList)
		return
	}
	if (!currentRow.value) {
		ElMessage.warning('请选择用户')
		return
	}
	handleClose()
	emit('select', [currentRow.value])
}

const handleRowDblClick = (row: any) => {
	handleClose()
	emit('select', [row])
}

const handleClose = () => {
	visible.value = false
}

const { getDataList, selectionChangeHandle, sizeChangeHandle, currentChangeHandle } = useCrud(state)
</script>

<style scoped lang="scss">
.user-pick-layout {
	display: grid;
	grid-template-columns: 240px minmax(0, 1fr);
	gap: 12px;
	min-height: 500px;
}

.org-pane {
	min-width: 0;
}

.pick-org-tree {
	height: 100%;

	:deep(.el-card) {
		border-radius: 12px;
		border-color: #e8eef5;
	}

	:deep(.tree-body) {
		max-height: 440px;
		overflow: auto;
	}
}

.table-pane {
	min-width: 0;
	display: flex;
	flex-direction: column;
	gap: 10px;
}

.pick-query {
	margin: 0;

	:deep(.el-form-item) {
		margin-bottom: 0;
		margin-right: 10px;
	}
}
</style>

<style lang="scss">
.ma-user-dialog.el-dialog {
	border-radius: 16px;
	overflow: hidden;

	.el-dialog__header {
		margin: 0;
		padding: 16px 20px 8px;
	}

	.el-dialog__body {
		padding: 8px 16px 4px;
	}

	.el-dialog__footer {
		padding: 10px 20px 16px;
	}
}
</style>
