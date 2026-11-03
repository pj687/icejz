<template>
	<div class="org-auth-page">
		<section class="org-auth-hero">
			<div class="hero-copy">
				<span class="hero-kicker"><i class="hero-mark" aria-hidden="true"></i>物联网平台</span>
				<h2>设备列表</h2>
				<p>管理接入设备、运行状态与通信协议</p>
			</div>
			<div class="hero-meta">
				<span class="hero-chip"><em>{{ state.total || 0 }}</em>台设备</span>
				<span class="hero-chip">设备管理</span>
			</div>
		</section>

		<el-card class="org-auth-card org-auth-query layout-query" shadow="never">
			<el-form ref="queryRef" :inline="true" :model="state.queryForm" @keyup.enter="getDataList()">
				<el-form-item prop="type">
					<ma-dict-select v-model="state.queryForm.type" dict-type="device_type" placeholder="设备类型" clearable></ma-dict-select>
				</el-form-item>
				<el-form-item prop="status">
					<ma-dict-select v-model="state.queryForm.status" dict-type="enable_disable" placeholder="设备状态" clearable></ma-dict-select>
				</el-form-item>
				<el-form-item prop="runningStatus">
					<ma-dict-select
						v-model="state.queryForm.runningStatus"
						dict-type="device_running_status"
						placeholder="运行状态"
						clearable
					></ma-dict-select>
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
					<el-button v-auth="'iot:device:save'" icon="Plus" type="primary" @click="addOrUpdateHandle()">新增设备</el-button>
					<el-button v-auth="'iot:device:delete'" icon="Delete" plain type="danger" @click="deleteBatchHandle()">批量删除</el-button>
				</el-space>
			</div>

			<el-table
				show-overflow-tooltip
				:data="state.dataList"
				class="layout-table"
				@selection-change="selectionChangeHandle"
			>
				<el-table-column type="selection" header-align="center" align="center" width="50"></el-table-column>
				<el-table-column prop="name" label="设备名称" min-width="150">
					<template #default="scope">
						<span class="org-auth-name">
							<span class="avatar">{{ (scope.row.name || scope.row.code || '?').slice(0, 1) }}</span>
							<span>
								<strong>{{ scope.row.name || '—' }}</strong>
								<em class="device-code">{{ scope.row.code || '—' }}</em>
							</span>
						</span>
					</template>
				</el-table-column>
				<ma-dict-column prop="type" label="设备类型" dict-type="device_type" width="110"></ma-dict-column>
				<ma-dict-column prop="status" label="状态" dict-type="enable_disable" width="90"></ma-dict-column>
				<ma-dict-column prop="runningStatus" label="运行状态" dict-type="device_running_status" width="110"></ma-dict-column>
				<el-table-column prop="uid" label="唯一标识码" min-width="140">
					<template #default="scope">
						<span class="sys-route-code">{{ scope.row.uid || '—' }}</span>
					</template>
				</el-table-column>
				<el-table-column prop="protocolType" label="协议" width="100" align="center">
					<template #default="scope">
						<span class="sys-type-pill menu">{{ scope.row.protocolType || '—' }}</span>
					</template>
				</el-table-column>
				<el-table-column prop="batteryPercent" label="电量" width="140">
					<template #default="scope">
						<div class="battery-cell">
							<el-progress
								:percentage="formatBatteryPercentage(scope.row.batteryPercent)"
								:stroke-width="8"
								:color="getBatteryColor(scope.row.batteryPercent)"
								:format="batteryFormat"
							/>
						</div>
					</template>
				</el-table-column>
				<el-table-column prop="temperature" label="温度" width="90" align="center">
					<template #default="scope">
						<span class="temp-value">{{ scope.row.temperature ?? '—' }}</span>
					</template>
				</el-table-column>
				<el-table-column prop="appVersion" label="版本" width="100" align="center"></el-table-column>
				<el-table-column prop="upTime" label="最近在线" width="170"></el-table-column>
				<el-table-column label="操作" fixed="right" align="center" width="168">
					<template #default="scope">
						<div class="org-auth-actions">
							<el-button v-auth="'iot:device:info'" class="act-btn act-primary" @click="showDeviceDetailsHandle(scope.row)">详情</el-button>
							<el-button
								v-auth="'iot:device:delete'"
								class="act-btn act-danger"
								@click="deleteBatchHandle(scope.row.id)"
							>删除</el-button>
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

			<el-drawer
				v-if="deviceDetailsVisible"
				v-model="deviceDetailsVisible"
				class="ops-drawer tool-drawer"
				:title="deviceDetailsTitle"
				:size="1000"
				:close-on-press-escape="false"
			>
				<device-details :device-id="deviceId" :protocol-type="protocolType"></device-details>
			</el-drawer>
		</el-card>
	</div>
</template>

<script setup lang="ts" name="IotDeviceIndex">
import { useCrud } from '@/hooks'
import { reactive, ref } from 'vue'
import { IHooksOptions } from '@/hooks/interface'
import DeviceDetails from './device-details.vue'
import AddOrUpdate from './add-or-update.vue'

const state: IHooksOptions = reactive({
	dataListUrl: '/iot/device/page',
	deleteUrl: '/iot/device',
	queryForm: {}
})

const queryRef = ref()
const addOrUpdateRef = ref()

const deviceDetailsVisible = ref(false)
const deviceDetailsTitle = ref()
const deviceId = ref()
const protocolType = ref()
const showDeviceDetailsHandle = (row: any) => {
	deviceId.value = row.id
	protocolType.value = row.protocolType
	deviceDetailsTitle.value = '设备 - ' + row.code + '-' + row.name
	deviceDetailsVisible.value = true
}

const addOrUpdateHandle = (id?: number) => {
	addOrUpdateRef.value.init(id)
}

const { getDataList, selectionChangeHandle, sizeChangeHandle, currentChangeHandle, deleteBatchHandle, reset } = useCrud(state)

const batteryFormat = (percentage: number) => {
	return percentage === 100 ? '满' : `${percentage}%`
}

const formatBatteryPercentage = (percentage: number | undefined) => {
	return percentage !== undefined ? percentage : 0
}

const getBatteryColor = (percentage: any) => {
	if (percentage >= 80) return '#2fbfa4'
	if (percentage >= 60) return '#00a8e8'
	if (percentage >= 30) return '#f0a202'
	return '#ef4444'
}
</script>

<style scoped lang="scss">
.device-code {
	display: block;
	margin-top: 2px;
	font-style: normal;
	font-size: 12px;
	font-weight: 600;
	color: #7a8796;
	font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
}

.battery-cell {
	padding-right: 6px;

	:deep(.el-progress__text) {
		font-size: 12px !important;
		min-width: 34px;
	}
}

.temp-value {
	font-variant-numeric: tabular-nums;
	font-weight: 650;
	color: #475569;
}

.org-auth-name strong {
	display: block;
	font-weight: 700;
	color: #122033;
}
</style>
