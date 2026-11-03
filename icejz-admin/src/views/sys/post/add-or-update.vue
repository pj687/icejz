<template>
	<el-dialog
		v-model="visible"
		class="org-auth-dialog"
		:title="!dataForm.id ? '新增岗位' : '修改岗位'"
		:close-on-click-modal="false"
		width="520px"
		draggable
	>
		<el-form ref="dataFormRef" :model="dataForm" :rules="dataRules" label-width="88px" @keyup.enter="submitHandle()">
			<section class="form-block">
				<header class="block-head">
					<strong>岗位信息</strong>
					<span>编码、名称与启用状态</span>
				</header>
				<el-form-item label="岗位编码" prop="postCode">
					<el-input v-model="dataForm.postCode" placeholder="如 DEV / HR"></el-input>
				</el-form-item>
				<el-form-item label="岗位名称" prop="postName">
					<el-input v-model="dataForm.postName" placeholder="岗位名称"></el-input>
				</el-form-item>
				<el-form-item label="排序" prop="sort">
					<el-input-number v-model="dataForm.sort" :min="0" controls-position="right"></el-input-number>
				</el-form-item>
				<el-form-item label="状态" prop="status">
					<ma-dict-radio v-model="dataForm.status" dict-type="post_status"></ma-dict-radio>
				</el-form-item>
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
import { usePostApi, usePostSubmitApi } from '@/api/sys/post'

const emit = defineEmits(['refreshDataList'])

const visible = ref(false)
const dataFormRef = ref()

const dataForm = reactive({
	id: '',
	postCode: '',
	postName: '',
	sort: 0,
	status: 1
})

const init = (id?: number) => {
	visible.value = true
	dataForm.id = ''

	if (dataFormRef.value) {
		dataFormRef.value.resetFields()
	}

	if (id) {
		getPost(id)
	}
}

const getPost = (id: number) => {
	usePostApi(id).then((res) => {
		Object.assign(dataForm, res.data)
	})
}

const dataRules = ref({
	postCode: [{ required: true, message: '必填项不能为空', trigger: 'blur' }],
	postName: [{ required: true, message: '必填项不能为空', trigger: 'blur' }]
})

const submitHandle = () => {
	dataFormRef.value.validate((valid: boolean) => {
		if (!valid) {
			return false
		}

		usePostSubmitApi(dataForm).then(() => {
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
