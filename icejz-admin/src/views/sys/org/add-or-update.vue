<template>
	<el-dialog
		v-model="visible"
		class="org-auth-dialog"
		:title="!dataForm.id ? '新增机构' : '修改机构'"
		:close-on-click-modal="false"
		width="560px"
		draggable
	>
		<el-form ref="dataFormRef" :model="dataForm" :rules="dataRules" label-width="88px" @keyup.enter="submitHandle()">
			<section class="form-block">
				<header class="block-head">
					<strong>机构信息</strong>
					<span>名称、上级关系与负责人</span>
				</header>
				<el-form-item prop="name" label="名称">
					<el-input v-model="dataForm.name" placeholder="机构名称"></el-input>
				</el-form-item>
				<el-form-item prop="pid" label="上级机构">
					<ma-org-select v-model="dataForm.pid" placeholder="请选择"></ma-org-select>
				</el-form-item>
				<el-form-item prop="leaderId" label="负责人">
					<ma-user-input v-model="dataForm.leaderId" placeholder="机构负责人"></ma-user-input>
				</el-form-item>
				<el-form-item prop="sort" label="排序">
					<el-input-number v-model="dataForm.sort" controls-position="right" :min="0" aria-label="排序"></el-input-number>
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
import { useOrgSubmitApi } from '@/api/sys/orgs'
import MaUserInput from '@/components/ma-user/ma-user-input/index.vue'
import MaOrgSelect from '@/components/ma-org/ma-org-select/index.vue'

const emit = defineEmits(['refreshDataList'])

const visible = ref(false)
const dataFormRef = ref()

const dataForm = reactive({
	id: '',
	name: '',
	pid: '',
	parentName: '',
	leaderId: '',
	sort: 0
})

const init = (isUpdate: boolean, row: any) => {
	visible.value = true

	if (dataFormRef.value) {
		dataFormRef.value.resetFields()
	}

	if (row) {
		getOrg(isUpdate, row)
	} else {
		dataForm.id = ''
		dataForm.pid = ''
		dataForm.parentName = ''
		dataForm.name = ''
		dataForm.sort = 0
		dataForm.leaderId = ''
	}
}

const getOrg = (isUpdate: boolean, row: any) => {
	Object.assign(dataForm, row)
	if (!isUpdate) {
		dataForm.pid = dataForm.id
		dataForm.parentName = dataForm.name
		dataForm.id = ''
		dataForm.name = ''
		dataForm.sort = 0
	}
}

const dataRules = ref({
	name: [{ required: true, message: '必填项不能为空', trigger: 'blur' }],
	parentName: [{ required: true, message: '必填项不能为空', trigger: 'blur' }]
})

const submitHandle = () => {
	dataFormRef.value.validate((valid: boolean) => {
		if (!valid) {
			return false
		}

		useOrgSubmitApi(dataForm).then(() => {
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
