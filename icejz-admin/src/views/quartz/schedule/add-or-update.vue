<template>
	<el-dialog v-model="visible" class="org-auth-dialog" :title="!dataForm.id ? '新增任务' : '修改任务'" :close-on-click-modal="false" width="720px" draggable>
		<el-form ref="dataFormRef" :model="dataForm" :rules="dataRules" label-width="100px" @keyup.enter="submitHandle()">
			<section class="form-block">
				<header class="block-head">
					<strong>基本信息</strong>
					<span>任务名称与分组</span>
				</header>
				<el-row :gutter="12">
					<el-col :span="12">
						<el-form-item label="任务名称" prop="jobName">
							<el-input v-model="dataForm.jobName" placeholder="任务名称"></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="任务组名" prop="jobGroup">
							<ma-dict-select v-model="dataForm.jobGroup" dict-type="schedule_group" placeholder="任务组名" style="width: 100%"></ma-dict-select>
						</el-form-item>
					</el-col>
				</el-row>
			</section>

			<section class="form-block" style="margin-top: 14px">
				<header class="block-head">
					<strong>执行配置</strong>
					<span>Bean、方法与 Cron 表达式</span>
				</header>
				<el-row :gutter="12">
					<el-col :span="12">
						<el-form-item label="Bean 名称" prop="beanName">
							<el-input v-model="dataForm.beanName" placeholder="spring bean 名称"></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="方法名称" prop="method">
							<el-input v-model="dataForm.method" placeholder="方法名称"></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="方法参数" prop="params">
							<el-input v-model="dataForm.params" placeholder="方法参数"></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="Cron 表达式" prop="cronExpression">
							<el-input v-model="dataForm.cronExpression" placeholder="cron 表达式"></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="是否并发" prop="concurrent">
							<el-radio-group v-model="dataForm.concurrent">
								<el-radio-button :value="1">允许</el-radio-button>
								<el-radio-button :value="0">禁止</el-radio-button>
							</el-radio-group>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="备注" prop="remark">
							<el-input v-model="dataForm.remark" placeholder="备注"></el-input>
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
import { useScheduleApi, useScheduleSubmitApi } from '@/api/quartz/schedule'

const emit = defineEmits(['refreshDataList'])

const visible = ref(false)
const dataFormRef = ref()
const dataForm = reactive({
	id: '',
	jobName: '',
	jobGroup: '',
	beanName: '',
	method: '',
	params: '',
	cronExpression: '',
	status: 0,
	concurrent: 1,
	remark: ''
})

const init = (id?: number) => {
	visible.value = true
	dataForm.id = ''

	if (dataFormRef.value) {
		dataFormRef.value.resetFields()
	}

	if (id) {
		getScheduleJob(id)
	}
}

const getScheduleJob = (id: number) => {
	useScheduleApi(id).then(res => {
		Object.assign(dataForm, res.data)
	})
}

const dataRules = ref({
	jobName: [{ required: true, message: '必填项不能为空', trigger: 'blur' }],
	jobGroup: [{ required: true, message: '必填项不能为空', trigger: 'blur' }],
	beanName: [{ required: true, message: '必填项不能为空', trigger: 'blur' }],
	method: [{ required: true, message: '必填项不能为空', trigger: 'blur' }],
	cronExpression: [{ required: true, message: '必填项不能为空', trigger: 'blur' }]
})

const submitHandle = () => {
	dataFormRef.value.validate((valid: boolean) => {
		if (!valid) {
			return false
		}

		useScheduleSubmitApi(dataForm).then(() => {
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
