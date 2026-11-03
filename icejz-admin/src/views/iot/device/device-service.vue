<template>
	<div class="iot-sub-panel">
		<div class="iot-sub-query">
			<el-form ref="queryRef" :inline="true" :model="state.queryForm" @keyup.enter="getDataList()">
				<el-form-item prop="deviceCommand">
					<ma-dict-select
						v-model="state.queryForm.deviceCommandEnum"
						dict-type="device_command"
						placeholder="服务类型"
						clearable
					></ma-dict-select>
				</el-form-item>
				<el-form-item>
					<el-button icon="Search" type="primary" @click="getDataList()">查询</el-button>
				</el-form-item>
			</el-form>
		</div>

		<el-table
			v-loading="state.dataListLoading"
			show-overflow-tooltip
			:data="state.dataList"
			class="layout-table"
			@selection-change="selectionChangeHandle"
		>
			<el-table-column type="selection" header-align="center" align="center" width="50"></el-table-column>
			<el-table-column prop="serviceUid" label="服务ID" min-width="140">
				<template #default="scope">
					<span class="sys-route-code">{{ scope.row.serviceUid || '—' }}</span>
				</template>
			</el-table-column>
			<ma-dict-column prop="deviceCommandEnum" label="服务类型" dict-type="device_command" width="120"></ma-dict-column>
			<el-table-column prop="servicePayload" label="下发内容" min-width="200" show-overflow-tooltip></el-table-column>
			<el-table-column prop="serviceTime" label="下发时间" width="170"></el-table-column>
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
import { defineProps, onMounted, reactive, ref } from 'vue'
import { IHooksOptions } from '@/hooks/interface'

const state: IHooksOptions = reactive({
	dataListUrl: '/iot/device_service_log/page',
	deleteUrl: '/iot/device_service_log',
	queryForm: {
		deviceId: ''
	}
})

const queryRef = ref()
const props = defineProps({
	deviceId: {
		type: Number,
		required: true
	}
})

onMounted(() => {
	state.queryForm.deviceId = props.deviceId
})

const { getDataList, selectionChangeHandle, sizeChangeHandle, currentChangeHandle } = useCrud(state)
</script>

<style scoped lang="scss">
.iot-sub-panel {
	padding-bottom: 8px;
}

.iot-sub-query {
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

:deep(.el-pagination) {
	margin-top: 16px;
	justify-content: flex-end;
}
</style>
