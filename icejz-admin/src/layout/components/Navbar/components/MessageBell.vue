<template>
	<div class="message-bell" @click="goInbox">
		<el-badge :value="unread" :hidden="!unread" :max="99">
			<ma-icon icon="icon-message-fill" />
		</el-badge>
	</div>
</template>

<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useMessageUnreadCountApi } from '@/api/sys/message'

const router = useRouter()
const unread = ref(0)
let timer = 0

const refresh = async () => {
	try {
		const res: any = await useMessageUnreadCountApi()
		unread.value = Number(res.data || 0)
	} catch {
		unread.value = 0
	}
}

const goInbox = () => {
	router.push('/sys/message/inbox').catch(() => undefined)
}

onMounted(() => {
	refresh()
	timer = window.setInterval(refresh, 60000)
	window.addEventListener('focus', refresh)
})

onBeforeUnmount(() => {
	if (timer) window.clearInterval(timer)
	window.removeEventListener('focus', refresh)
})
</script>

<style scoped lang="scss">
.message-bell {
	display: inline-flex;
	align-items: center;
	justify-content: center;
	width: 36px;
	height: 36px;
	border-radius: 10px;
	cursor: pointer;
	color: var(--el-text-color-regular);
	transition: background 0.18s ease, color 0.18s ease;

	&:hover {
		background: rgba(0, 168, 232, 0.1);
		color: #007eb8;
	}
}
</style>
