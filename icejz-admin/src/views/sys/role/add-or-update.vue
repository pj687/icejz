<template>
	<el-dialog
		v-model="visible"
		class="org-auth-dialog role-dialog"
		:title="!dataForm.id ? '新增角色' : '修改角色'"
		:close-on-click-modal="false"
		width="720px"
		draggable
	>
		<el-form ref="dataFormRef" :model="dataForm" :rules="dataRules" label-width="88px" @keyup.enter="submitHandle()">
			<div class="dialog-grid">
				<section class="dialog-block">
					<header class="block-head">
						<strong>基本信息</strong>
						<span>角色标识与说明</span>
					</header>
					<el-form-item prop="name" label="名称">
						<el-input v-model="dataForm.name" placeholder="角色名称"></el-input>
					</el-form-item>
					<el-form-item prop="roleCode" label="编码">
						<el-input v-model="dataForm.roleCode" placeholder="如 ADMIN / OPS"></el-input>
					</el-form-item>
					<el-form-item prop="remark" label="备注">
						<el-input v-model="dataForm.remark" type="textarea" :rows="3" placeholder="可选备注"></el-input>
					</el-form-item>
				</section>

				<section class="dialog-block menu-block">
					<header class="block-head">
						<div>
							<strong>菜单权限</strong>
							<span>勾选后角色可访问对应菜单与按钮</span>
						</div>
						<div class="tree-actions">
							<el-button link type="primary" @click="expandMenus(true)">展开</el-button>
							<el-button link type="primary" @click="expandMenus(false)">收起</el-button>
							<el-button link type="primary" @click="checkAllMenus(true)">全选</el-button>
							<el-button link type="primary" @click="checkAllMenus(false)">清空</el-button>
						</div>
					</header>
					<div class="menu-tree-wrap">
						<el-tree
							ref="menuListTree"
							:data="menuList"
							:props="{ label: menuLabel, children: 'children' }"
							node-key="id"
							show-checkbox
							:default-expand-all="menuExpandAll"
						></el-tree>
					</div>
				</section>
			</div>
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
import { useRoleApi, useRoleMenuApi, useRoleSubmitApi } from '@/api/sys/role'

const emit = defineEmits(['refreshDataList'])

const visible = ref(false)
const menuList = ref([])
const menuListTree = ref()
const dataFormRef = ref()
const menuExpandAll = ref(false)

const dataForm = reactive({
	id: '',
	name: '',
	roleCode: '',
	menuIdList: [] as any[],
	orgIdList: [],
	remark: ''
})

const collectIds = (nodes: any[] = [], bag: any[] = []) => {
	nodes.forEach((node) => {
		bag.push(node.id)
		if (node.children?.length) collectIds(node.children, bag)
	})
	return bag
}

const expandMenus = (expand: boolean) => {
	menuExpandAll.value = expand
	const nodes = menuListTree.value?.store?.nodesMap || {}
	Object.values(nodes).forEach((node: any) => {
		node.expanded = expand
	})
}

const checkAllMenus = (checked: boolean) => {
	if (!menuListTree.value) return
	menuListTree.value.setCheckedKeys(checked ? collectIds(menuList.value) : [])
}

const init = async (id?: number) => {
	visible.value = true
	dataForm.id = ''
	menuExpandAll.value = false

	if (dataFormRef.value) {
		dataFormRef.value.resetFields()
	}
	await nextTick()
	if (menuListTree.value) {
		menuListTree.value.setCheckedKeys([])
	}

	await getMenuList()

	if (id) {
		getRole(id)
	}
}

const menuLabel = (data: any) => {
	const tag = data.clientType === 1 ? '[APP] ' : data.clientType === 2 ? '[小程序] ' : '[PC] '
	return `${tag}${data.name || ''}`
}

const getMenuList = async () => {
	const res = await useRoleMenuApi()
	menuList.value = res.data
}

const getRole = (id: number) => {
	useRoleApi(id).then((res) => {
		Object.assign(dataForm, res.data)
		nextTick(() => {
			dataForm.menuIdList.forEach((item) => menuListTree.value.setChecked(item, true))
		})
	})
}

const dataRules = ref({
	name: [{ required: true, message: '必填项不能为空', trigger: 'blur' }],
	roleCode: [{ required: true, message: '必填项不能为空', trigger: 'blur' }]
})

const submitHandle = () => {
	dataFormRef.value.validate((valid: boolean) => {
		if (!valid) {
			return false
		}
		dataForm.menuIdList = [...menuListTree.value.getHalfCheckedKeys(), ...menuListTree.value.getCheckedKeys()]

		useRoleSubmitApi(dataForm).then(() => {
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
.dialog-grid {
	display: grid;
	grid-template-columns: 1fr 1.15fr;
	gap: 14px;
}

.dialog-block {
	padding: 14px;
	border-radius: 14px;
	border: 1px solid #e8eef5;
	background: #fbfcfe;
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
	flex-wrap: wrap;
	justify-content: flex-end;
	gap: 2px;
}

.menu-tree-wrap {
	max-height: 360px;
	overflow: auto;
	padding: 8px 6px;
	border-radius: 12px;
	background: var(--icejz-card-bg, #fff);
	border: 1px solid var(--icejz-card-border, #eef3f8);
}

@media (max-width: 760px) {
	.dialog-grid {
		grid-template-columns: 1fr;
	}
}
</style>
