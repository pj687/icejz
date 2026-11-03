<template>
	<el-dialog v-model="visible" class="org-auth-dialog" title="数据权限" :close-on-click-modal="false" :width="620" draggable>
		<el-form ref="dataFormRef" :model="dataForm" label-width="88px" @keyup.enter="submitHandle()">
			<section class="scope-block">
				<header class="block-head">
					<strong>范围设置</strong>
					<span>控制角色可访问的业务数据边界</span>
				</header>
				<el-form-item prop="name" label="角色">
					<el-input v-model="dataForm.name" disabled></el-input>
				</el-form-item>
				<el-form-item prop="dataScope" label="数据范围">
					<ma-dict-select v-model="dataForm.dataScope" dict-type="role_data_scope" placeholder="数据范围" style="width: 100%"></ma-dict-select>
				</el-form-item>
			</section>

			<section v-show="dataForm.dataScope == 4" class="scope-block org-block">
				<header class="block-head">
					<div>
						<strong>自定义机构</strong>
						<span>勾选后仅可访问所选机构数据</span>
					</div>
					<div class="tree-actions">
						<el-button link type="primary" @click="checkAllOrgs(true)">全选</el-button>
						<el-button link type="primary" @click="checkAllOrgs(false)">清空</el-button>
					</div>
				</header>
				<div class="org-tree-wrap">
					<el-tree
						ref="orgListTree"
						:data="orgList"
						:props="{ label: 'name', children: 'children' }"
						node-key="id"
						show-checkbox
					></el-tree>
				</div>
			</section>
		</el-form>
		<template #footer>
			<el-button @click="visible = false">取消</el-button>
			<el-button type="primary" @click="submitHandle()">确定</el-button>
		</template>
	</el-dialog>
</template>

<script setup lang="ts">
import { nextTick, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus/es'
import { useRoleApi, useRoleDataScopeSubmitApi } from '@/api/sys/role'
import { useOrgListApi } from '@/api/sys/orgs'

const visible = ref(false)
const orgList = ref([])
const orgListTree = ref()
const dataFormRef = ref()

const dataForm = reactive({
	id: '',
	name: '',
	orgIdList: [],
	dataScope: 0,
	remark: ''
})

const collectIds = (nodes: any[] = [], bag: any[] = []) => {
	nodes.forEach((node) => {
		bag.push(node.id)
		if (node.children?.length) collectIds(node.children, bag)
	})
	return bag
}

const checkAllOrgs = (checked: boolean) => {
	if (!orgListTree.value) return
	orgListTree.value.setCheckedKeys(checked ? collectIds(orgList.value) : [])
}

const init = (id?: number) => {
	visible.value = true
	dataForm.id = ''

	if (dataFormRef.value) {
		dataFormRef.value.resetFields()
	}
	nextTick(() => {
		if (orgListTree.value) {
			orgListTree.value.setCheckedKeys([])
		}
	})

	if (id) {
		getRole(id)
	}

	getOrgList()
}

const getOrgList = async () => {
	const res = await useOrgListApi()
	orgList.value = res.data
}

const getRole = (id: number) => {
	useRoleApi(id).then((res) => {
		Object.assign(dataForm, res.data)
		nextTick(() => {
			orgListTree.value?.setCheckedKeys(dataForm.orgIdList || [])
		})
	})
}

const submitHandle = () => {
	dataForm.orgIdList = orgListTree.value?.getCheckedKeys?.() || []

	useRoleDataScopeSubmitApi(dataForm).then(() => {
		ElMessage.success({
			message: '操作成功',
			duration: 500,
			onClose: () => {
				visible.value = false
			}
		})
	})
}

defineExpose({
	init
})
</script>

<style scoped lang="scss">
.scope-block {
	padding: 14px;
	border-radius: 14px;
	border: 1px solid #e8eef5;
	background: #fbfcfe;

	& + .scope-block {
		margin-top: 12px;
	}
}

.block-head {
	display: flex;
	align-items: flex-start;
	justify-content: space-between;
	gap: 10px;
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

.tree-actions {
	display: flex;
	gap: 2px;
}

.org-tree-wrap {
	max-height: 320px;
	overflow: auto;
	padding: 8px 6px;
	border-radius: 12px;
	background: var(--icejz-card-bg, #fff);
	border: 1px solid var(--icejz-card-border, #eef3f8);
}
</style>
