<template>
	<div class="iot-debug-panel">
		<div class="debug-tip">
			<span class="sys-type-pill menu">MQTT</span>
			<p>调试前请确认已开启 MQTT 监听功能</p>
		</div>

		<section class="form-block">
			<header class="block-head">
				<strong>服务下发</strong>
				<span>向设备发送调试指令</span>
			</header>
			<el-form v-loading="loading" :model="serviceDebugDataForm" label-width="96px">
				<el-row :gutter="12">
					<el-col :span="12">
						<el-form-item label="接入协议">
							<el-input v-model="propertyDataForm.accessProtocol" disabled />
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="指令">
							<ma-dict-select v-model="serviceDebugDataForm.command" dict-type="device_command" style="width: 100%"></ma-dict-select>
						</el-form-item>
					</el-col>
					<el-col :span="24">
						<el-form-item label="设备响应">
							<el-radio-group v-model="serviceDebugDataForm.waitResponse">
								<el-radio value="0">不等待</el-radio>
								<el-radio value="1">等待</el-radio>
							</el-radio-group>
						</el-form-item>
					</el-col>
					<el-col :span="24">
						<el-form-item label="指令内容">
							<el-input v-model="serviceDebugDataForm.payload" placeholder="请输入指令内容" clearable />
						</el-form-item>
					</el-col>
					<el-col :span="24">
						<el-form-item>
							<el-button v-auth="'iot:device:send'" type="primary" @click="serviceDebugHandle(serviceDebugDataForm)">下发</el-button>
						</el-form-item>
					</el-col>
				</el-row>
			</el-form>
		</section>

		<section class="form-block" style="margin-top: 14px">
			<header class="block-head">
				<strong>属性上报</strong>
				<span>模拟设备上报最新属性值</span>
			</header>
			<el-form :model="propertyDataForm" label-width="96px">
				<el-row :gutter="12">
					<el-col :span="12">
						<el-form-item label="接入协议">
							<el-input v-model="propertyDataForm.accessProtocol" disabled />
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="属性">
							<ma-dict-select v-model="propertyDataForm.propertyType" dict-type="device_property" style="width: 100%"></ma-dict-select>
						</el-form-item>
					</el-col>
					<el-col :span="24">
						<el-form-item label="属性值">
							<template v-if="propertyDataForm.propertyType === 'RUNNING_STATUS'">
								<ma-dict-select v-model="propertyDataForm.payload" dict-type="device_running_status" style="width: 100%"></ma-dict-select>
							</template>
							<template v-else-if="propertyDataForm.propertyType === 'BATTERY_PERCENT'">
								<el-input-number v-model="propertyDataForm.payload" :min="0" :max="100" />
							</template>
							<template v-else-if="propertyDataForm.propertyType === 'TEMPERATURE'">
								<el-input-number v-model="propertyDataForm.payload" :min="0" :max="100" />
							</template>
							<template v-else>
								<el-input v-model="propertyDataForm.payload" placeholder="请输入最新的属性值" clearable />
							</template>
						</el-form-item>
					</el-col>
					<el-col :span="24">
						<el-form-item>
							<el-button v-auth="'iot:device:report'" type="primary" @click="deviceReportAttributeDataHandle(propertyDataForm)">上报</el-button>
						</el-form-item>
					</el-col>
				</el-row>
			</el-form>
		</section>
	</div>
</template>

<script setup lang="ts">
import { defineProps, reactive, ref } from 'vue'
import {
	useIotDeviceAsyncSendCommandApi,
	useIotDeviceSimulateDeviceReportAttributeDataApi,
	useIotDeviceSyncSendCommandDebugApi
} from '@/api/iot/device'
import { ElMessage } from 'element-plus'

const props = defineProps({
	deviceId: {
		type: Number,
		required: true
	},
	protocolType: {
		type: String,
		required: true
	}
})

const serviceDebugDataForm = reactive({
	deviceId: props.deviceId,
	accessProtocol: props.protocolType,
	command: 'LOCK',
	payload: '',
	waitResponse: '0'
})

const propertyDataForm = reactive({
	deviceId: props.deviceId,
	accessProtocol: props.protocolType,
	propertyType: 'RUNNING_STATUS',
	command: 'LOCK',
	payload: '0' as any
})

const loading = ref(false)

const serviceDebugHandle = (serviceDebugDataForm: any) => {
	if (serviceDebugDataForm.waitResponse == '1') {
		loading.value = true
		useIotDeviceSyncSendCommandDebugApi(serviceDebugDataForm)
			.then(res => {
				ElMessage.success({
					message: res.data
				})
			})
			.finally(() => {
				loading.value = false
			})
	} else {
		useIotDeviceAsyncSendCommandApi(serviceDebugDataForm).then(() => {
			ElMessage.success({
				message: '服务指令下发成功！'
			})
		})
	}
}

const deviceReportAttributeDataHandle = (propertyDataForm: any) => {
	useIotDeviceSimulateDeviceReportAttributeDataApi(propertyDataForm).then(() => {
		ElMessage.success({
			message: '属性上报成功！'
		})
	})
}
</script>

<style scoped lang="scss">
.iot-debug-panel {
	padding-bottom: 8px;
}

.debug-tip {
	display: flex;
	align-items: center;
	gap: 10px;
	margin-bottom: 14px;
	padding: 12px 14px;
	border-radius: 14px;
	border: 1px solid rgba(0, 168, 232, 0.16);
	background: rgba(0, 168, 232, 0.06);

	p {
		margin: 0;
		font-size: 13px;
		color: #475569;
		font-weight: 600;
	}
}
</style>
