<template>
	<el-drawer v-model="visible" class="ops-drawer tool-drawer" title="邮件日志详情" :size="1000">
		<section class="form-block">
			<header class="block-head">
				<strong>发送概览</strong>
				<span>平台、收发件人与状态</span>
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
							<ma-dict-select v-model="dataForm.platform" dict-type="mail_platform" disabled style="width: 100%"></ma-dict-select>
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
						<el-form-item label="发件人">
							<el-input v-model="dataForm.mailFrom" disabled></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="发送时间">
							<el-input v-model="dataForm.createTime" disabled></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="24">
						<el-form-item label="接收人">
							<el-input v-model="dataForm.mailTos" disabled></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="24">
						<el-form-item label="主题">
							<el-input v-model="dataForm.subject" disabled></el-input>
						</el-form-item>
					</el-col>
				</el-row>
			</el-form>
		</section>

		<section class="form-block" style="margin-top: 14px">
			<header class="block-head">
				<strong>邮件正文</strong>
				<span>内容预览与错误信息</span>
			</header>
			<el-form label-width="96px">
				<el-form-item label="内容">
					<div class="mail-content" v-html="dataForm.content"></div>
				</el-form-item>
				<el-form-item v-if="dataForm.status === 0" label="错误信息">
					<el-input v-model="dataForm.error" :rows="10" type="textarea" disabled />
				</el-form-item>
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
	mailFrom: '',
	status: 0,
	mailTos: '',
	subject: '',
	content: '',
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

<style scoped lang="scss">
.mail-content {
	width: 100%;
	min-height: 120px;
	padding: 12px 14px;
	border-radius: 12px;
	border: 1px solid var(--icejz-card-border, #e8eef5);
	background: var(--icejz-card-bg, #fff);
	color: #334155;
	line-height: 1.6;
	overflow: auto;
}
</style>
