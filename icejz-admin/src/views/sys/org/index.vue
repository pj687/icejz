<template>
	<div class="org-auth-page">
		<section class="org-auth-hero">
			<div class="hero-copy">
				<span class="hero-kicker"><i class="hero-mark" aria-hidden="true"></i>组织权限</span>
				<h2>机构管理</h2>
				<p>维护组织树结构、上级关系与负责人信息</p>
			</div>
			<div class="hero-meta">
				<span class="hero-chip"><em>{{ nodeCount }}</em>个节点</span>
				<span class="hero-chip">树形结构</span>
			</div>
		</section>

		<el-card class="org-auth-card page-card" shadow="never" v-loading="state.dataListLoading">
			<div class="org-auth-toolbar">
				<el-space wrap>
					<el-button v-auth="'sys:org:save'" type="primary" icon="Plus" @click="addOrUpdateHandle(false, null)">新增机构</el-button>
					<el-button v-if="viewMode === 'table'" plain @click="toggleExpandAll()">
						<template v-if="!isExpandAll">
							全部展开&nbsp;<el-icon><ArrowDown /></el-icon>
						</template>
						<template v-else>
							全部收起&nbsp;<el-icon><ArrowUp /></el-icon>
						</template>
					</el-button>
				</el-space>
				<div class="toolbar-right">
					<span class="org-count">共 {{ nodeCount }} 个节点</span>
					<ma-view-mode v-model="viewMode" />
				</div>
			</div>

			<template v-if="viewMode === 'table'">
				<el-table
					v-if="refreshTable"
					:default-expand-all="isExpandAll"
					:data="state.dataList"
					row-key="id"
					class="layout-table org-table"
				>
					<el-table-column prop="name" label="机构名称" min-width="220">
						<template #default="scope">
							<span class="org-auth-name">
								<span class="avatar org">{{ (scope.row.name || '机').slice(0, 1) }}</span>
								{{ scope.row.name }}
							</span>
						</template>
					</el-table-column>
					<el-table-column prop="parentName" label="上级机构" min-width="160" align="center">
						<template #default="scope">
							<span class="parent-name">{{ scope.row.parentName || '—' }}</span>
						</template>
					</el-table-column>
					<el-table-column prop="sort" label="排序" width="100" align="center"></el-table-column>
					<el-table-column label="操作" fixed="right" align="center" width="268">
						<template #default="scope">
							<div class="org-auth-actions">
								<el-button v-auth="'sys:org:save'" class="act-btn act-success" :icon="Plus" @click="addOrUpdateHandle(false, scope.row)">下级</el-button>
								<el-button v-auth="'sys:org:update'" class="act-btn act-primary" :icon="Edit" @click="addOrUpdateHandle(true, scope.row)">修改</el-button>
								<el-button v-auth="'sys:org:delete'" class="act-btn act-danger" :icon="Delete" @click="deleteHandle(scope.row.id)">删除</el-button>
							</div>
						</template>
					</el-table-column>
				</el-table>
			</template>

			<div v-else class="org-auth-card-grid">
				<article v-for="row in flatOrgList" :key="row.id" class="org-auth-entity-card">
					<div class="card-top">
						<div class="card-identity">
							<span class="card-avatar org">{{ (row.name || '机').slice(0, 1) }}</span>
							<div class="card-title">
								<strong>{{ row.name }}</strong>
								<em>层级 {{ row.depth + 1 }}</em>
							</div>
						</div>
						<span class="child-chip" v-if="row.childCount">{{ row.childCount }} 下级</span>
					</div>
					<div class="card-meta">
						<div class="meta-row"><span>上级机构</span><b>{{ row.parentName || '—' }}</b></div>
						<div class="meta-row"><span>排序</span><b>{{ row.sort ?? 0 }}</b></div>
					</div>
					<div class="card-foot">
						<span></span>
						<div class="org-auth-actions">
							<el-button v-auth="'sys:org:save'" class="act-btn act-success" :icon="Plus" @click="addOrUpdateHandle(false, row)">下级</el-button>
							<el-button v-auth="'sys:org:update'" class="act-btn act-primary" :icon="Edit" @click="addOrUpdateHandle(true, row)">修改</el-button>
							<el-button v-auth="'sys:org:delete'" class="act-btn act-danger" :icon="Delete" @click="deleteHandle(row.id)">删除</el-button>
						</div>
					</div>
				</article>
				<div v-if="!flatOrgList.length" class="org-auth-empty-card">暂无机构数据</div>
			</div>

			<add-or-update ref="addOrUpdateRef" @refresh-data-list="getDataList"></add-or-update>
		</el-card>
	</div>
</template>

<script setup lang="ts">
import { useCrud } from '@/hooks'
import { useViewMode } from '@/hooks/useViewMode'
import { computed, nextTick, reactive, ref } from 'vue'
import AddOrUpdate from './add-or-update.vue'
import MaViewMode from '@/components/ma-view-mode/index.vue'
import { IHooksOptions } from '@/hooks/interface'
import { ArrowDown, ArrowUp, Delete, Edit, Plus } from '@element-plus/icons-vue'

const { viewMode } = useViewMode('sys-org')

const state: IHooksOptions = reactive({
	dataListUrl: '/sys/org/list',
	deleteUrl: '/sys/org',
	isPage: false
})

const addOrUpdateRef = ref()
const addOrUpdateHandle = (isUpdate: Boolean, row: any) => {
	addOrUpdateRef.value.init(isUpdate, row)
}

const { getDataList, deleteHandle } = useCrud(state)

const isExpandAll = ref(false)
const refreshTable = ref(true)

const countNodes = (list: any[] = []): number =>
	list.reduce((sum, item) => sum + 1 + countNodes(item.children || []), 0)

const flattenOrgs = (list: any[] = [], depth = 0, bag: any[] = []) => {
	list.forEach((item) => {
		const children = item.children || []
		bag.push({
			...item,
			depth,
			childCount: children.length
		})
		if (children.length) flattenOrgs(children, depth + 1, bag)
	})
	return bag
}

const nodeCount = computed(() => countNodes(state.dataList || []))
const flatOrgList = computed(() => flattenOrgs(state.dataList || []))

const toggleExpandAll = () => {
	refreshTable.value = false
	isExpandAll.value = !isExpandAll.value
	nextTick(() => {
		refreshTable.value = true
	})
}
</script>

<style scoped lang="scss">
.toolbar-right {
	display: inline-flex;
	align-items: center;
	gap: 12px;
}

.org-count {
	font-size: 12px;
	font-weight: 650;
	color: #64748b;
	padding: 4px 10px;
	border-radius: 999px;
	background: #f5f9fc;
}

.parent-name {
	color: #64748b;
}

.child-chip {
	padding: 3px 8px;
	border-radius: 999px;
	font-size: 11px;
	font-weight: 650;
	color: #2563eb;
	background: rgba(37, 99, 235, 0.1);
	white-space: nowrap;
}

.org-table {
	:deep(.el-table__expand-icon) {
		color: #007eb8;
	}
}
</style>
