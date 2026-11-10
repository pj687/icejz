<template>
	<el-dialog
		v-model="visible"
		class="org-auth-dialog"
		:title="!dataForm.id ? '新增用户' : '修改用户'"
		:close-on-click-modal="false"
		width="760px"
		draggable
	>
		<el-form ref="dataFormRef" :model="dataForm" :rules="dataRules" label-width="88px" @keyup.enter="submitHandle()">
			<section class="form-block">
				<header class="block-head">
					<strong>账号信息</strong>
					<span>登录身份与基础资料</span>
				</header>
				<el-row :gutter="16">
					<el-col :span="12">
						<el-form-item prop="username" label="用户名">
							<el-input v-model="dataForm.username" placeholder="用户名"></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item prop="realName" label="姓名">
							<el-input v-model="dataForm.realName" placeholder="姓名"></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item prop="mobile" label="手机号">
							<el-input v-model="dataForm.mobile" placeholder="手机号"></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item prop="email" label="邮箱">
							<el-input v-model="dataForm.email" placeholder="邮箱"></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item prop="password" label="密码">
							<el-input v-model="dataForm.password" type="password" show-password placeholder="密码"></el-input>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item prop="gender" label="性别">
							<ma-dict-radio v-model="dataForm.gender" dict-type="user_gender"></ma-dict-radio>
						</el-form-item>
					</el-col>
				</el-row>
			</section>

			<section class="form-block">
				<header class="block-head">
					<strong>组织归属</strong>
					<span>机构、角色与岗位配置</span>
				</header>
				<el-row :gutter="16">
					<el-col :span="12">
						<el-form-item prop="orgId" label="所属机构">
							<ma-org-select v-model="dataForm.orgId" placeholder="请选择"></ma-org-select>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item prop="leaderId" label="直属主管">
							<ma-user-input v-model="dataForm.leaderId" placeholder="请选择"></ma-user-input>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item prop="roleIdList" label="所属角色">
							<el-select v-model="dataForm.roleIdList" multiple filterable placeholder="所属角色" style="width: 100%">
								<el-option v-for="role in roleList" :key="role.id" :label="role.name" :value="role.id"></el-option>
							</el-select>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item prop="postIdList" label="所属岗位">
							<el-select v-model="dataForm.postIdList" multiple filterable placeholder="所属岗位" style="width: 100%">
								<el-option v-for="post in postList" :key="post.id" :label="post.postName" :value="post.id"></el-option>
							</el-select>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item prop="status" label="状态">
							<ma-dict-radio v-model="dataForm.status" dict-type="user_status"></ma-dict-radio>
						</el-form-item>
					</el-col>
				</el-row>
			</section>

			<section class="form-block">
				<header class="block-head">
					<strong>登录设备</strong>
					<span>{{ systemOn ? '系统已开启多设备；可覆盖为关/开，留空跟随系统' : '系统已关闭多设备：全员强制单设备，此处不可开启' }}</span>
				</header>
				<el-row :gutter="16">
					<el-col :span="12">
						<el-form-item label="多设备登录">
							<el-select v-model="dataForm.multiDeviceLogin" clearable placeholder="跟随系统" style="width: 100%">
								<el-option :value="1" label="允许多设备" :disabled="!systemOn" />
								<el-option :value="0" label="仅单设备（互踢）" />
							</el-select>
						</el-form-item>
					</el-col>
					<el-col :span="12">
						<el-form-item label="设备上限">
							<div class="device-max-row">
								<el-input-number
									v-model="dataForm.multiDeviceMax"
									:min="1"
									:max="systemMax"
									:disabled="!systemOn || dataForm.multiDeviceLogin !== 1"
									controls-position="right"
									placeholder="跟随系统"
									style="width: 100%"
								/>
								<span class="device-max-cap">≤{{ systemMax }}</span>
							</div>
						</el-form-item>
					</el-col>
				</el-row>
				<p class="field-tip">
					{{
						systemOn
							? `选「允许多设备」时可单独设上限（不得超过系统上限 ${systemMax}）；选「仅单设备」则个人强制互踢。清空后跟随系统。`
							: '系统总开关关闭时，即使用户曾设为多设备也不会生效，也无法重新开启。'
					}}
				</p>
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
import { useUserApi, useUserSubmitApi } from '@/api/sys/user'
import { usePostListApi } from '@/api/sys/post'
import { useRoleListApi } from '@/api/sys/role'
import { useLoginSecurityConfigApi } from '@/api/sys/login-security'
import MaUserInput from '@/components/ma-user/ma-user-input/index.vue'

const emit = defineEmits(['refreshDataList'])

const visible = ref(false)
const postList = ref<any[]>([])
const roleList = ref<any[]>([])
const dataFormRef = ref()
const systemMax = ref(5)
const systemOn = ref(false)

const dataForm = reactive({
	id: '',
	username: '',
	realName: '',
	orgId: '',
	leaderId: '',
	password: '',
	gender: 0,
	email: '',
	mobile: '',
	roleIdList: [] as any[],
	postIdList: [] as any[],
	status: 1,
	multiDeviceLogin: null as number | null,
	multiDeviceMax: null as number | null
})

const loadSystemMax = async () => {
	try {
		const { data } = await useLoginSecurityConfigApi()
		systemOn.value = !!data?.multiDeviceLogin
		systemMax.value = Math.max(1, data?.multiDeviceMax ?? 5)
		if (!systemOn.value && dataForm.multiDeviceLogin === 1) {
			dataForm.multiDeviceLogin = null
			dataForm.multiDeviceMax = null
		}
	} catch {
		systemOn.value = false
		systemMax.value = 5
	}
}

const init = (id?: number) => {
	visible.value = true
	dataForm.id = ''
	dataForm.multiDeviceLogin = null
	dataForm.multiDeviceMax = null

	if (dataFormRef.value) {
		dataFormRef.value.resetFields()
	}

	loadSystemMax()
	if (id) {
		getUser(id)
	}

	getPostList()
	getRoleList()
}

const getPostList = async () => {
	let res = await usePostListApi()
	postList.value = res.data
}

const getRoleList = async () => {
	let res = await useRoleListApi()
	roleList.value = res.data
}

const getUser = (id: number) => {
	useUserApi(id).then((res) => {
		Object.assign(dataForm, res.data)
		if (dataForm.multiDeviceLogin === undefined) {
			dataForm.multiDeviceLogin = null
		}
		if (dataForm.multiDeviceLogin !== 1) {
			dataForm.multiDeviceMax = dataForm.multiDeviceLogin === 0 ? null : dataForm.multiDeviceMax
		} else if (dataForm.multiDeviceMax != null) {
			dataForm.multiDeviceMax = Math.max(1, Math.min(dataForm.multiDeviceMax, systemMax.value))
		}
	})
}

const submitPayload = () => {
	const payload: any = { ...dataForm }
	if (!systemOn.value && payload.multiDeviceLogin === 1) {
		ElMessage.warning('系统已关闭多设备登录，不可为用户开启')
		return null
	}
	if (payload.multiDeviceLogin !== 1) {
		payload.multiDeviceMax = null
	} else if (payload.multiDeviceMax != null) {
		payload.multiDeviceMax = Math.max(1, Math.min(payload.multiDeviceMax, systemMax.value))
	}
	return payload
}

const dataRules = ref({
	username: [{ required: true, message: '必填项不能为空', trigger: 'blur' }],
	realName: [{ required: true, message: '必填项不能为空', trigger: 'blur' }],
	mobile: [{ required: true, message: '必填项不能为空', trigger: 'blur' }],
	orgId: [{ required: true, message: '必填项不能为空', trigger: 'blur' }]
})

const submitHandle = () => {
	dataFormRef.value.validate((valid: boolean) => {
		if (!valid) {
			return false
		}

		const payload = submitPayload()
		if (!payload) {
			return false
		}

		useUserSubmitApi(payload).then(() => {
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

	& + .form-block {
		margin-top: 12px;
	}
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

.field-tip {
	margin: -4px 0 0;
	font-size: 12px;
	line-height: 1.5;
	color: #94a3b8;
}

.device-max-row {
	display: flex;
	align-items: center;
	gap: 8px;
	width: 100%;
}

.device-max-cap {
	flex-shrink: 0;
	font-size: 12px;
	color: #64748b;
	white-space: nowrap;
}
</style>
