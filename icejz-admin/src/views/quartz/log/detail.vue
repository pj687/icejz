<template>
	<el-dialog v-model="visible" class="org-auth-dialog" title="任务日志详情" :close-on-click-modal="false" width="720px" draggable>
		<section class="form-block">
			<header class="block-head">
				<strong>任务信息</strong>
				<span>任务标识与执行目标</span>
			</header>
			<el-form label-width="96px">
				<el-row :gutter="12">
					<el-col :span="12">
						<el-form-item label="任务ID">
							<el-input v-model="dataForm.jobId" disabled></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="任务名称">
							<el-input v-model="dataForm.jobName" disabled></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="任务组名">
							<ma-dict-select v-model="dataForm.jobGroup" dict-type="schedule_group" disabled style="width: 100%"></ma-dict-select>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="Bean 名称">
							<el-input v-model="dataForm.beanName" disabled></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="方法名称">
							<el-input v-model="dataForm.method" disabled></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="方法参数">
							<el-input v-model="dataForm.params" disabled></el-input>
						</el-form-item>
					</el-col>
				</el-row>
			</el-form>
		</section>

		<section class="form-block" style="margin-top: 14px">
			<header class="block-head">
				<strong>执行结果</strong>
				<span>时长、状态与错误信息</span>
			</header>
			<el-form label-width="96px">
				<el-row :gutter="12">
					<el-col :span="12">
						<el-form-item label="执行时间">
							<el-input v-model="dataForm.createTime" disabled></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="6">
						<el-form-item label="执行时长">
							<span class="sys-type-pill menu">{{ dataForm.times }}ms</span>
						</el-form-item>
					</el-col>
					<el-col :span="6">
						<el-form-item label="任务状态">
							<span class="sys-type-pill" :class="dataForm.status === 0 ? 'api' : 'button'">
								{{ dataForm.status === 0 ? '失败' : '成功' }}
							</span>
						</el-form-item>
					</el-col>
					<el-col v-if="dataForm.status === 0" :span="24">
						<el-form-item label="错误信息">
							<el-input v-model="dataForm.error" :rows="10" type="textarea" disabled />
						</el-form-item>
					</el-col>
				</el-row>
			</el-form>
		</section>

		<template #footer>
			<el-button type="primary" @click="visible = false">关闭</el-button>
		</template>
	</el-dialog>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue'

const visible = ref(false)
const dataForm = reactive({
	jobId: '',
	jobName: '',
	jobGroup: '',
	beanName: '',
	method: '',
	params: '',
	error: '',
	times: 0,
	status: 0,
	createTime: ''
})

const init = (data?: any) => {
	visible.value = true
	Object.assign(dataForm, data)
}

defineExpose({
	init
})
</script>
