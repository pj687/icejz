<template>
	<el-dialog v-model="visible" class="org-auth-dialog" :title="!dataForm.id ? '新增设备' : '修改设备'" :close-on-click-modal="false" width="640px" draggable>
		<el-form ref="dataFormRef" :model="dataForm" :rules="dataRules" label-width="100px" @keyup.enter="submitHandle()">
			<section class="form-block">
				<header class="block-head">
					<strong>设备标识</strong>
					<span>编码、名称与唯一标识码</span>
				</header>
				<el-row :gutter="12">
					<el-col :span="12">
						<el-form-item label="编码" prop="code">
							<el-input v-model="dataForm.code" placeholder="编码"></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="名称" prop="name">
							<el-input v-model="dataForm.name" placeholder="名称"></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="设备类型" prop="type">
							<ma-dict-select v-model="dataForm.type" dict-type="device_type" placeholder="设备类型" clearable style="width: 100%"></ma-dict-select>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="唯一标识码" prop="uid">
							<el-input v-model="dataForm.uid" placeholder="唯一标识码"></el-input>
						</el-form-item>
					</el-col>
				</el-row>
			</section>

			<section class="form-block" style="margin-top: 14px">
				<header class="block-head">
					<strong>接入配置</strong>
					<span>通信协议、密钥与启用状态</span>
				</header>
				<el-row :gutter="12">
					<el-col :span="12">
						<el-form-item label="通信协议" prop="protocolType">
							<el-select v-model="dataForm.protocolType" placeholder="通信协议" style="width: 100%">
								<el-option label="MQTT" value="MQTT"></el-option>
								<el-option label="TCP" value="TCP"></el-option>
								<el-option label="Modbus" value="Modbus" disabled></el-option>
								<el-option label="CoAP" value="CoAP" disabled></el-option>
								<el-option label="LwM2M" value="LwM2M" disabled></el-option>
							</el-select>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="设备密钥" prop="secret">
							<el-input v-model="dataForm.secret" placeholder="设备密钥"></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="24">
						<el-form-item label="状态" prop="status">
							<ma-dict-radio v-model="dataForm.status" dict-type="enable_disable"></ma-dict-radio>
						</el-form-item>
					</el-col>
				</el-row>
			</section>
		</el-form>

		<template #footer>
			<el-button @click="visible = false">取消</el-button>
			<el-button type="primary" @click="submitHandle()">确定</el-button>
		</template>
	</el-dialog>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue'
import { ElMessage } from 'element-plus/es'
import { useIotDeviceApi, useIotDeviceSubmitApi } from '@/api/iot/device'

const emit = defineEmits(['refreshDataList'])

const visible = ref(false)
const dataFormRef = ref()

const dataForm = reactive({
	id: '',
	code: '',
	name: '',
	type: '',
	uid: '',
	protocolType: '',
	secret: '',
	status: '1'
})

const init = (id?: number) => {
	visible.value = true
	dataForm.id = ''

	if (dataFormRef.value) {
		dataFormRef.value.resetFields()
	}

	if (id) {
		getIot_device(id)
	}
}

const getIot_device = (id: number) => {
	useIotDeviceApi(id).then(res => {
		Object.assign(dataForm, res.data)
	})
}

const dataRules = ref({
	code: [{ required: true, message: '编码不能为空', trigger: 'blur' }],
	name: [{ required: true, message: '名称不能为空', trigger: 'blur' }],
	type: [{ required: true, message: '设备类型不能为空', trigger: 'blur' }],
	uid: [{ required: true, message: '唯一标识码不能为空', trigger: 'blur' }],
	secret: [{ required: true, message: '设备密钥不能为空', trigger: 'blur' }],
	status: [{ required: true, message: '状态不能为空', trigger: 'blur' }],
	protocolType: [{ required: true, message: '通信协议不能为空', trigger: 'blur' }]
})

const submitHandle = () => {
	dataFormRef.value.validate((valid: boolean) => {
		if (!valid) {
			return false
		}

		useIotDeviceSubmitApi(dataForm).then(() => {
			ElMessage.success({
				message: '操作成功',
				duration: 500,
				onClose: () => {
					visible.value = false
					emit('refreshDataList')
				}
			})
		})
	})
}

defineExpose({
	init
})
</script>
