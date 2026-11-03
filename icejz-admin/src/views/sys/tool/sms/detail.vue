<template>
	<el-drawer v-model="visible" class="ops-drawer tool-drawer" title="短信日志详情" :size="1000">
		<section class="form-block">
			<header class="block-head">
				<strong>发送概览</strong>
				<span>平台、手机号与发送状态</span>
			</header>
			<el-form label-width="96px">
				<el-row :gutter="12">
					<el-col :span="12">
						<el-form-item label="日志ID">
							<el-input v-model="dataForm.id" disabled></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="平台ID">
							<el-input v-model="dataForm.platformId" disabled></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="平台类型">
							<ma-dict-select v-model="dataForm.platform" dict-type="sms_platform" disabled style="width: 100%"></ma-dict-select>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="手机号">
							<el-input v-model="dataForm.mobile" disabled></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="状态">
							<span class="sys-type-pill" :class="dataForm.status === 0 ? 'api' : 'button'">
								{{ dataForm.status === 0 ? '失败' : '成功' }}
							</span>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="发送时间">
							<el-input v-model="dataForm.createTime" disabled></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="24">
						<el-form-item label="参数">
							<el-input v-model="dataForm.params" disabled></el-input>
						</el-form-item>
					</el-col>
					<el-col v-if="dataForm.status === 0" :span="24">
						<el-form-item label="错误信息">
							<el-input v-model="dataForm.error" :rows="12" type="textarea" disabled />
						</el-form-item>
					</el-col>
				</el-row>
			</el-form>
		</section>

		<template #footer>
			<el-button type="primary" @click="visible = false">关闭</el-button>
		</template>
	</el-drawer>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue'

const visible = ref(false)
const dataForm = reactive({
	id: '',
	platformId: '',
	platform: '',
	mobile: '',
	status: 0,
	params: '',
	error: '',
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
