<template>
	<div class="iot-info-panel">
		<div class="iot-metric-row">
			<article class="iot-metric-card">
				<span class="label">电池电量</span>
				<strong>{{ dataForm.batteryPercent ?? '—' }}<small v-if="dataForm.batteryPercent !== '' && dataForm.batteryPercent !== null">%</small></strong>
			</article>
			<article class="iot-metric-card">
				<span class="label">设备温度</span>
				<strong>{{ dataForm.temperature ?? '—' }}</strong>
			</article>
			<article class="iot-metric-card">
				<span class="label">通信协议</span>
				<strong class="proto">{{ dataForm.protocolType || '—' }}</strong>
			</article>
			<article class="iot-metric-card">
				<span class="label">设备版本</span>
				<strong class="proto">{{ dataForm.appVersion || '—' }}</strong>
			</article>
		</div>

		<section class="form-block">
			<header class="block-head">
				<strong>设备标识</strong>
				<span>编码、名称与类型</span>
			</header>
			<el-form label-width="96px">
				<el-row :gutter="12">
					<el-col :span="12">
						<el-form-item label="编码">
							<el-input v-model="dataForm.code" disabled />
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="设备名称">
							<el-input v-model="dataForm.name" disabled />
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="唯一标识码">
							<el-input v-model="dataForm.uid" disabled />
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="设备类型">
							<ma-dict-select v-model="dataForm.type" dict-type="device_type" disabled style="width: 100%"></ma-dict-select>
						</el-form-item>
					</el-col>
				</el-row>
			</el-form>
		</section>

		<section class="form-block" style="margin-top: 14px">
			<header class="block-head">
				<strong>运行信息</strong>
				<span>状态、上下线与环境数据</span>
			</header>
			<el-form label-width="96px">
				<el-row :gutter="12">
					<el-col :span="12">
						<el-form-item label="设备状态">
							<ma-dict-select v-model="dataForm.status" dict-type="enable_disable" disabled style="width: 100%"></ma-dict-select>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="运行状态">
							<ma-dict-select
								v-model="dataForm.runningStatus"
								dict-type="device_running_status"
								disabled
								style="width: 100%"
							></ma-dict-select>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="上线时间">
							<el-input v-model="dataForm.upTime" disabled />
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="下线时间">
							<el-input v-model="dataForm.downTime" disabled />
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="通信协议">
							<el-input v-model="dataForm.protocolType" disabled />
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="设备版本">
							<el-input v-model="dataForm.appVersion" disabled />
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="电池电量">
							<el-input v-model="dataForm.batteryPercent" disabled />
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="设备温度">
							<el-input v-model="dataForm.temperature" disabled />
						</el-form-item>
					</el-col>
				</el-row>
			</el-form>
		</section>

		<section class="form-block" style="margin-top: 14px">
			<header class="block-head">
				<strong>创建信息</strong>
				<span>创建与最近更新时间</span>
			</header>
			<el-form label-width="96px">
				<el-row :gutter="12">
					<el-col :span="12">
						<el-form-item label="创建时间">
							<el-input v-model="dataForm.createTime" disabled />
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="更新时间">
							<el-input v-model="dataForm.updateTime" disabled />
						</el-form-item>
					</el-col>
				</el-row>
			</el-form>
		</section>
	</div>
</template>

<script setup lang="ts">
import { defineProps, onMounted, reactive, ref } from 'vue'
import { useIotDeviceApi } from '@/api/iot/device'

const visible = ref(false)
const dataFormRef = ref()

const dataForm = reactive({
	id: '',
	code: '',
	name: '',
	type: '',
	uid: '',
	secret: '',
	appVersion: '',
	batteryPercent: '' as any,
	temperature: '' as any,
	protocolType: '',
	status: '',
	runningStatus: '',
	upTime: '',
	downTime: '',
	createTime: '',
	updateTime: ''
})

const props = defineProps({
	deviceId: {
		type: Number,
		required: true
	}
})

const init = () => {
	visible.value = true
	if (dataFormRef.value) {
		dataFormRef.value.resetFields()
	}

	if (props.deviceId) {
		getIot_device(props.deviceId)
	}
}

const getIot_device = (id: number) => {
	useIotDeviceApi(id).then(res => {
		Object.assign(dataForm, res.data)
	})
}

onMounted(() => {
	init()
})
</script>

<style scoped lang="scss">
.iot-info-panel {
	display: flex;
	flex-direction: column;
	gap: 4px;
}

.iot-metric-row {
	display: grid;
	grid-template-columns: repeat(4, minmax(0, 1fr));
	gap: 12px;
	margin-bottom: 14px;
}

.iot-metric-card {
	padding: 14px 16px;
	border-radius: 14px;
	border: 1px solid #e7eef5;
	background: linear-gradient(160deg, #fff, #f7fbfe);

	.label {
		display: block;
		font-size: 12px;
		font-weight: 650;
		color: #7a8796;
	}

	strong {
		display: block;
		margin-top: 8px;
		font-size: 24px;
		line-height: 1.1;
		font-weight: 780;
		letter-spacing: -0.02em;
		color: #007eb8;
		font-variant-numeric: tabular-nums;

		small {
			margin-left: 2px;
			font-size: 13px;
			font-weight: 700;
			color: #64748b;
		}

		&.proto {
			font-size: 18px;
			color: #122033;
		}
	}
}

@media (max-width: 900px) {
	.iot-metric-row {
		grid-template-columns: repeat(2, minmax(0, 1fr));
	}
}
</style>
