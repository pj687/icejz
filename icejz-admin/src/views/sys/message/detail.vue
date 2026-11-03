<template>
	<el-dialog v-model="visible" title="消息详情" width="620px" :close-on-click-modal="false" draggable>
		<div v-loading="loading" class="detail-wrap">
			<header class="detail-head">
				<h3>{{ detail.title }}</h3>
				<div class="meta">
					<ma-dict-label dict-type="message_type" :dict-value="detail.type" />
					<span>{{ detail.senderName || '系统' }}</span>
					<span>{{ detail.sendTime || detail.createTime }}</span>
				</div>
			</header>
			<p class="content">{{ detail.content }}</p>
			<footer class="foot">
				<span>接收：{{ detail.receiverType === 0 ? '全部用户' : '指定用户' }}</span>
				<span>阅读：{{ detail.readCount || 0 }}/{{ detail.receiverCount || 0 }}</span>
			</footer>
		</div>
	</el-dialog>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useMessageApi } from '@/api/sys/message'

const visible = ref(false)
const loading = ref(false)
const detail = reactive<any>({
	title: '',
	content: '',
	type: 0,
	senderName: '',
	sendTime: '',
	createTime: '',
	receiverType: 0,
	readCount: 0,
	receiverCount: 0
})

const init = (id: number) => {
	visible.value = true
	loading.value = true
	useMessageApi(id)
		.then((res: any) => {
			Object.assign(detail, res.data || {})
		})
		.finally(() => {
			loading.value = false
		})
}

defineExpose({ init })
</script>

<style scoped lang="scss">
.detail-wrap {
	min-height: 160px;
}

.detail-head {
	margin-bottom: 14px;

	h3 {
		margin: 0 0 8px;
		font-size: 18px;
		color: #122033;
	}
}

.meta {
	display: flex;
	flex-wrap: wrap;
	gap: 10px;
	font-size: 12px;
	color: #7a8796;
}

.content {
	margin: 0;
	padding: 14px;
	border-radius: 12px;
	background: #f5f9fc;
	color: #1f2a37;
	line-height: 1.7;
	white-space: pre-wrap;
	word-break: break-word;
}

.foot {
	display: flex;
	justify-content: space-between;
	gap: 12px;
	margin-top: 14px;
	font-size: 12px;
	color: #7a8796;
}
</style>
