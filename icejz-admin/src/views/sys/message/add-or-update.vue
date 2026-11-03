<template>
	<el-dialog
		v-model="visible"
		class="org-auth-dialog"
		title="发送消息"
		:close-on-click-modal="false"
		width="640px"
		draggable
	>
		<el-form ref="dataFormRef" :model="dataForm" :rules="dataRules" label-width="96px">
			<section class="form-block">
				<header class="block-head">
					<strong>消息内容</strong>
					<span>标题、正文与类型</span>
				</header>
				<el-form-item label="标题" prop="title">
					<el-input v-model="dataForm.title" maxlength="100" show-word-limit placeholder="请输入消息标题"></el-input>
				</el-form-item>
				<el-form-item label="类型" prop="type">
					<ma-dict-radio v-model="dataForm.type" dict-type="message_type"></ma-dict-radio>
				</el-form-item>
				<el-form-item label="内容" prop="content">
					<el-input
						v-model="dataForm.content"
						type="textarea"
						:rows="6"
						maxlength="2000"
						show-word-limit
						placeholder="请输入消息正文"
					></el-input>
				</el-form-item>
			</section>

			<section class="form-block" style="margin-top: 14px">
				<header class="block-head">
					<strong>接收范围</strong>
					<span>可群发全部用户，或指定部分账号</span>
				</header>
				<el-form-item label="范围" prop="receiverType">
					<el-radio-group v-model="dataForm.receiverType">
						<el-radio :value="0">全部用户</el-radio>
						<el-radio :value="1">指定用户</el-radio>
					</el-radio-group>
				</el-form-item>
				<el-form-item v-if="dataForm.receiverType === 1" label="接收人" prop="receiverIdList">
					<el-select
						v-model="dataForm.receiverIdList"
						multiple
						filterable
						remote
						reserve-keyword
						collapse-tags
						collapse-tags-tooltip
						:remote-method="searchUsers"
						:loading="userLoading"
						placeholder="搜索姓名或账号"
						style="width: 100%"
					>
						<el-option v-for="item in userOptions" :key="item.id" :label="formatUser(item)" :value="item.id" />
					</el-select>
				</el-form-item>
			</section>
		</el-form>
		<template #footer>
			<el-button @click="visible = false">取消</el-button>
			<el-button type="primary" :loading="submitting" @click="submitHandle()">立即发送</el-button>
		</template>
	</el-dialog>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue'
import { ElMessage } from 'element-plus/es'
import service from '@/utils/request'
import { useMessageSubmitApi } from '@/api/sys/message'

const emit = defineEmits(['refreshDataList'])

const visible = ref(false)
const submitting = ref(false)
const userLoading = ref(false)
const dataFormRef = ref()
const userOptions = ref<any[]>([])

const dataForm = reactive({
	title: '',
	content: '',
	type: 0,
	receiverType: 0,
	receiverIdList: [] as number[]
})

const dataRules = ref({
	title: [{ required: true, message: '必填项不能为空', trigger: 'blur' }],
	content: [{ required: true, message: '必填项不能为空', trigger: 'blur' }],
	type: [{ required: true, message: '必填项不能为空', trigger: 'change' }],
	receiverType: [{ required: true, message: '必填项不能为空', trigger: 'change' }],
	receiverIdList: [
		{
			validator: (_: any, value: number[], callback: (e?: Error) => void) => {
				if (dataForm.receiverType === 1 && (!value || !value.length)) {
					callback(new Error('请选择接收人'))
					return
				}
				callback()
			},
			trigger: 'change'
		}
	]
})

const formatUser = (item: any) => `${item.realName || item.username}（${item.username}）`

const searchUsers = (keyword: string) => {
	userLoading.value = true
	service
		.get('/sys/user/page', {
			params: {
				page: 1,
				limit: 20,
				username: keyword || undefined
			}
		})
		.then((res: any) => {
			userOptions.value = res.data?.list || []
		})
		.finally(() => {
			userLoading.value = false
		})
}

const init = () => {
	visible.value = true
	dataForm.title = ''
	dataForm.content = ''
	dataForm.type = 0
	dataForm.receiverType = 0
	dataForm.receiverIdList = []
	userOptions.value = []
	if (dataFormRef.value) {
		dataFormRef.value.resetFields()
	}
	searchUsers('')
}

const submitHandle = () => {
	dataFormRef.value.validate((valid: boolean) => {
		if (!valid) return
		submitting.value = true
		useMessageSubmitApi({
			title: dataForm.title,
			content: dataForm.content,
			type: dataForm.type,
			receiverType: dataForm.receiverType,
			receiverIdList: dataForm.receiverType === 1 ? dataForm.receiverIdList : []
		})
			.then(() => {
				ElMessage.success({
					message: '发送成功',
					duration: 500,
					onClose: () => {
						visible.value = false
						emit('refreshDataList')
					}
				})
			})
			.finally(() => {
				submitting.value = false
			})
	})
}

defineExpose({ init })
</script>

<style scoped lang="scss">
.form-block {
	padding: 14px;
	border-radius: 14px;
	border: 1px solid #e8eef5;
	background: #fbfcfe;
}

.block-head {
	margin-bottom: 12px;

	strong {
		display: block;
		font-size: 14px;
		color: #122033;
	}

	span {
		display: block;
		margin-top: 2px;
		font-size: 12px;
		color: #7a8796;
	}
}
</style>
