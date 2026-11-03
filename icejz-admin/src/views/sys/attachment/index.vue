<template>
	<div class="org-auth-page">
		<section class="org-auth-hero">
			<div class="hero-copy">
				<span class="hero-kicker"><i class="hero-mark" aria-hidden="true"></i>开发工具</span>
				<h2>附件管理</h2>
				<p>上传、下载与管理业务附件资源</p>
			</div>
			<div class="hero-meta">
				<span class="hero-chip"><em>{{ state.total || 0 }}</em>个文件</span>
				<span class="hero-chip">存储管理</span>
			</div>
		</section>

		<el-card class="org-auth-card org-auth-query layout-query" shadow="never">
			<el-form ref="queryRef" :inline="true" :model="state.queryForm" @keyup.enter="getDataList()">
				<el-form-item prop="name">
					<el-input v-model="state.queryForm.name" clearable placeholder="附件名称"></el-input>
				</el-form-item>
				<el-form-item prop="platform">
					<el-input v-model="state.queryForm.platform" clearable placeholder="存储平台"></el-input>
				</el-form-item>
				<el-form-item>
					<el-button icon="Search" type="primary" @click="getDataList()">查询</el-button>
					<el-button icon="RefreshRight" @click="reset(queryRef)">重置</el-button>
				</el-form-item>
			</el-form>
		</el-card>

		<el-card class="org-auth-card page-card" shadow="never" v-loading="state.dataListLoading">
			<div class="org-auth-toolbar">
				<el-space wrap>
					<el-upload
						:action="constant.uploadUrl"
						:headers="{ Authorization: cache.getToken() }"
						:before-upload="beforeUpload"
						:on-success="handleSuccess"
						:show-file-list="false"
					>
						<el-button v-auth="'sys:attachment:save'" icon="Plus" type="primary">上传附件</el-button>
					</el-upload>
					<el-button v-auth="'sys:attachment:delete'" icon="Delete" plain type="danger" @click="deleteBatchHandle()">批量删除</el-button>
				</el-space>
			</div>

			<el-table
				show-overflow-tooltip
				:data="state.dataList"
				class="layout-table"
				@selection-change="selectionChangeHandle"
			>
				<el-table-column type="selection" header-align="center" align="center" width="50"></el-table-column>
				<el-table-column prop="name" label="附件名称" min-width="180">
					<template #default="scope">
						<span class="org-auth-name">
							<span class="avatar">{{ fileMark(scope.row.name) }}</span>
							{{ scope.row.name || '—' }}
						</span>
					</template>
				</el-table-column>
				<el-table-column prop="url" label="附件地址" min-width="220" show-overflow-tooltip>
					<template #default="scope">
						<span class="sys-route-code">{{ scope.row.url || '—' }}</span>
					</template>
				</el-table-column>
				<el-table-column prop="size" label="附件大小" width="120" align="center">
					<template #default="scope">
						<span class="file-size">{{ convertSizeFormat(scope.row.size) }}</span>
					</template>
				</el-table-column>
				<el-table-column prop="platform" label="存储平台" width="120" align="center">
					<template #default="scope">
						<span class="sys-type-pill menu">{{ scope.row.platform || '—' }}</span>
					</template>
				</el-table-column>
				<el-table-column prop="createTime" label="创建时间" width="170"></el-table-column>
				<el-table-column label="操作" fixed="right" align="center" width="168">
					<template #default="scope">
						<div class="org-auth-actions">
							<el-button class="act-btn act-primary" @click="downloadHandle(scope.row.url, scope.row.name)">下载</el-button>
							<el-button
								v-auth="'sys:attachment:delete'"
								class="act-btn act-danger"
								@click="deleteBatchHandle(scope.row.id)"
							>删除</el-button>
						</div>
					</template>
				</el-table-column>
			</el-table>

			<el-pagination
				:current-page="state.page"
				:page-sizes="state.pageSizes"
				:page-size="state.limit"
				:total="state.total"
				layout="total, sizes, prev, pager, next, jumper"
				@size-change="sizeChangeHandle"
				@current-change="currentChangeHandle"
			>
			</el-pagination>
		</el-card>
	</div>
</template>

<script setup lang="ts" name="SysAttachmentIndex">
import { useCrud } from '@/hooks'
import { reactive, ref } from 'vue'
import constant from '@/utils/constant'
import cache from '@/utils/cache'
import { convertSizeFormat } from '@/utils/tool'
import { IHooksOptions } from '@/hooks/interface'
import { ElMessage } from 'element-plus'
import type { UploadProps } from 'element-plus'
import { useAttachmentSubmitApi } from '@/api/sys/attachment'

const state: IHooksOptions = reactive({
	dataListUrl: '/sys/attachment/page',
	deleteUrl: '/sys/attachment',
	queryForm: {
		name: '',
		platform: ''
	}
})

const queryRef = ref()
const dataForm = reactive({
	name: '',
	platform: '',
	size: '',
	url: ''
})

const fileMark = (name?: string) => {
	if (!name) return '?'
	const parts = name.split('.')
	if (parts.length > 1) {
		return parts[parts.length - 1].slice(0, 3).toUpperCase()
	}
	return name.slice(0, 1)
}

const handleSuccess: UploadProps['onSuccess'] = (res, file) => {
	if (res.code !== 0) {
		ElMessage.error('上传失败：' + res.msg)
		return false
	}

	Object.assign(dataForm, res.data)

	useAttachmentSubmitApi(dataForm).then(() => {
		ElMessage.success({
			message: '上传成功',
			duration: 500,
			onClose: () => {
				getDataList()
			}
		})
	})
}

const beforeUpload: UploadProps['beforeUpload'] = file => {
	if (file.size / 1024 / 1024 / 100 > 1) {
		ElMessage.error('文件大小不能超过100M')
		return false
	}
	return true
}

const { getDataList, selectionChangeHandle, sizeChangeHandle, currentChangeHandle, deleteBatchHandle, downloadHandle, reset } = useCrud(state)
</script>

<style scoped lang="scss">
.file-size {
	font-variant-numeric: tabular-nums;
	font-weight: 650;
	color: #475569;
}
</style>
