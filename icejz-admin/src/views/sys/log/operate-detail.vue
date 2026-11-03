<template>
	<el-dialog v-model="visible" class="org-auth-dialog" title="日志详情" :close-on-click-modal="false" width="720px" draggable>
		<section class="form-block">
			<header class="block-head">
				<strong>请求概览</strong>
				<span>操作人、模块与接口信息</span>
			</header>
			<el-form label-width="96px">
				<el-row :gutter="12">
					<el-col :span="12">
						<el-form-item label="日志ID">
							<el-input v-model="dataForm.id" disabled></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="操作人">
							<el-input v-model="dataForm.realName" disabled></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="模块名">
							<el-input v-model="dataForm.module" disabled></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="操作名">
							<el-input v-model="dataForm.name" disabled></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="请求URI">
							<el-input v-model="dataForm.reqUri" disabled></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="请求方法">
							<el-input v-model="dataForm.reqMethod" disabled></el-input>
						</el-form-item>
					</el-col>
				</el-row>
			</el-form>
		</section>

		<section class="form-block" style="margin-top: 14px">
			<header class="block-head">
				<strong>执行结果</strong>
				<span>网络位置、耗时与状态</span>
			</header>
			<el-form label-width="96px">
				<el-row :gutter="12">
					<el-col :span="12">
						<el-form-item label="操作IP">
							<el-input v-model="dataForm.ip" disabled></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="登录地点">
							<el-input v-model="dataForm.address" disabled></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="操作类型">
							<ma-dict-select v-model="dataForm.operateType" dict-type="log_operate_type" disabled style="width: 100%"></ma-dict-select>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="执行时长">
							<el-input v-model="dataForm.duration" disabled>
								<template #append>ms</template>
							</el-input>
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
						<el-form-item label="创建时间">
							<el-input v-model="dataForm.createTime" disabled></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="24">
						<el-form-item label="User Agent">
							<el-input v-model="dataForm.userAgent" disabled></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="24">
						<el-form-item label="请求参数">
							<el-input v-model="dataForm.reqParams" :rows="8" type="textarea" disabled />
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
	id: '',
	realName: '',
	module: '',
	name: '',
	reqUri: '',
	reqMethod: '',
	ip: '',
	address: '',
	operateType: '',
	duration: '',
	status: 0,
	userAgent: '',
	reqParams: '',
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
