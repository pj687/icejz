<template>
	<el-card class="ma-left-tree org-auth-card" shadow="never">
		<template #header>
			<div class="card-header">
				<div class="title-wrap">
					<span class="title-mark" aria-hidden="true"></span>
					<span>{{ title }}</span>
				</div>
				<div class="header-actions">
					<button
						v-if="collapsible"
						type="button"
						class="menu-btn hide-btn"
						title="隐藏机构列表"
						@click="emits('hide')"
					>
						<ma-icon icon="icon-outdent" size="16px"></ma-icon>
						<span>隐藏</span>
					</button>
					<el-dropdown @command="handleCommand">
						<span class="menu-btn" title="更多操作">
							<ma-icon icon="icon-menu" size="18px"></ma-icon>
						</span>
						<template #dropdown>
							<el-dropdown-menu>
								<el-dropdown-item command="refresh">刷新数据</el-dropdown-item>
								<el-dropdown-item command="expand">展开全部</el-dropdown-item>
								<el-dropdown-item command="collapse">折叠全部</el-dropdown-item>
								<el-dropdown-item v-if="manage" command="manage">数据管理</el-dropdown-item>
							</el-dropdown-menu>
						</template>
					</el-dropdown>
				</div>
			</div>
		</template>
		<div class="tree-search">
			<el-input v-model="keyword" clearable placeholder="搜索机构" />
		</div>
		<div class="tree-body">
			<el-tree
				ref="treeRef"
				:key="treeKey"
				:data="dataList"
				:expand-on-click-node="false"
				:default-expand-all="isExpandAll"
				:filter-node-method="filterNode"
				:props="props"
				highlight-current
				node-key="id"
				:current-node-key="currentNodeKey"
				@node-click="handleNodeClick"
			/>
		</div>
	</el-card>
</template>

<script lang="ts" setup name="MaDataTreeLeft">
import { ElTree } from 'element-plus'
import { onMounted, PropType, ref, watch } from 'vue'
import emit, { MittEvent } from '@/utils/emits'
import { useDataApi } from '@/api/common'
import { generateUUID, treeDataTranslate } from '@/utils/tool'
const dataList = ref()
const keyword = ref()
const treeRef = ref()
const currentNodeKey = ref()

interface Prop {
	label: string
	children: string
}
const prop = defineProps({
	url: {
		type: String,
		default: ''
	},
	props: {
		type: Object as PropType<Prop>,
		required: false,
		default: () => ({
			label: 'name',
			children: 'children'
		})
	},
	manage: {
		type: Boolean,
		required: false,
		default: () => false
	},
	collapsible: {
		type: Boolean,
		required: false,
		default: false
	},
	title: {
		type: String,
		required: true
	},
	treeData: {
		type: Boolean,
		required: false,
		default: () => false
	}
})

// 是否展开全部
const isExpandAll = ref(false)
const treeKey = ref(generateUUID())
const handleCommand = (command: string) => {
	switch (command) {
		case 'refresh':
			getDataList()
			break
		case 'expand':
			treeKey.value = generateUUID()
			isExpandAll.value = true
			break
		case 'collapse':
			treeKey.value = generateUUID()
			isExpandAll.value = false
			break
		case 'manage':
			emits('manage')
			break
	}
}

onMounted(async () => {
	await getDataList()
})

watch(keyword, val => {
	treeRef.value.filter(val)
})

const getDataList = async () => {
	const data = await useDataApi(prop.url)
	if (prop.treeData) {
		dataList.value = data
	} else {
		dataList.value = treeDataTranslate(data)
	}
}

const filterNode = (name: string, data: any) => {
	if (!name) {
		return true
	}
	return data.name.includes(name)
}

emit.on(MittEvent.LeftTree, () => {
	getDataList()
})

const emits = defineEmits(['click', 'manage', 'hide'])
// 处理点击事件
const handleNodeClick = (row: any) => {
	if (currentNodeKey.value === row.id) {
		currentNodeKey.value = null
	} else {
		currentNodeKey.value = row.id
	}
	const idList = getAllChildNodeIds(currentNodeKey.value, dataList.value)
	emits('click', idList)
}

// 获取所有子节点 ID 的函数
function getAllChildNodeIds(nodeId: any, nodes: any) {
	if (!nodeId) {
		return []
	}
	const root = findNodeById(nodeId, nodes)
	if (!root) {
		console.warn(`Node with ID ${nodeId} not found.`)
		return []
	}
	const ids: any[] = getChildrenIdsRecursively(root)
	ids.push(root.id)
	return ids
}

// 查找指定 ID 的节点
function findNodeById(id: any, nodes: any): any {
	for (const node of nodes) {
		if (node.id === id) {
			return node
		}
		if (node.children && node.children.length > 0) {
			const result = findNodeById(id, node.children)
			if (result) {
				return result
			}
		}
	}
	return null
}

// 递归获取所有子节点 ID
function getChildrenIdsRecursively(node: any): any[] {
	const ids = []
	if (node.children && node.children.length > 0) {
		for (const child of node.children) {
			ids.push(child.id)
			ids.push(...getChildrenIdsRecursively(child))
		}
	}
	return ids
}
</script>

<style lang="scss" scoped>
.ma-left-tree {
	min-height: calc(100vh - 168px - var(--theme-header-height));
	overflow: hidden;
	white-space: nowrap;
	text-overflow: ellipsis;

	:deep(.el-tree-node__content) {
		height: 38px;
		border-radius: 11px;
		margin: 2px 10px;
		padding-right: 8px;
		transition: background 0.15s ease, color 0.15s ease;

		&:hover {
			background: rgba(0, 168, 232, 0.08);
		}
	}

	:deep(.el-tree-node__label) {
		font-size: 13px;
		color: #1f2a37;
	}

	:deep(.el-tree--highlight-current .el-tree-node.is-current > .el-tree-node__content) {
		background: rgba(0, 168, 232, 0.12);
		color: #007eb8;
		font-weight: 700;

		.el-tree-node__label {
			color: #007eb8;
		}
	}

	:deep(.el-card__header) {
		padding: 14px 14px 10px;
		border-bottom: 1px solid #eef3f8;
		background: linear-gradient(180deg, #f7fbfe, #fff);
	}

	:deep(.el-card__body) {
		padding: 0 0 10px;
	}

	.card-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		font-weight: 720;
		font-size: 14px;
		color: #122033;
	}

	.title-wrap {
		display: inline-flex;
		align-items: center;
		gap: 8px;
	}

	.title-mark {
		width: 8px;
		height: 8px;
		border-radius: 50%;
		background: #00a8e8;
		box-shadow: 0 0 0 4px rgba(0, 168, 232, 0.14);
	}

	.header-actions {
		display: inline-flex;
		align-items: center;
		gap: 4px;
	}

	.menu-btn {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		gap: 4px;
		width: 30px;
		height: 30px;
		border: 0;
		padding: 0;
		background: transparent;
		border-radius: 9px;
		cursor: pointer;
		color: #64748b;
		transition: background 0.15s ease, color 0.15s ease;

		&:hover {
			background: rgba(0, 168, 232, 0.1);
			color: #007eb8;
		}

		&.hide-btn {
			width: auto;
			padding: 0 8px;
			font-size: 12px;
			font-weight: 650;
		}
	}

	.tree-search {
		padding: 10px 12px 8px;

		:deep(.el-input__wrapper) {
			border-radius: 11px;
			box-shadow: 0 0 0 1px #e2e8f0 inset;
		}
	}

	.tree-body {
		max-height: calc(100vh - 250px - var(--theme-header-height));
		overflow: auto;
		padding-bottom: 8px;
	}
}
</style>
