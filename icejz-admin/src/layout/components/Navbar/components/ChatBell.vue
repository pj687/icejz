<template>
	<div v-if="canEnter" class="chat-bell" title="即时通讯" @click="goChat">
		<el-badge :value="unread" :hidden="!unread" :max="99">
			<ma-icon icon="icon-message" />
		</el-badge>
	</div>
</template>

<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/store/modules/user'
import { useChatUnreadCountApi } from '@/api/sys/chat'

const router = useRouter()
const userStore = useUserStore()
const unread = ref(0)
let timer = 0

const canEnter = computed(
	() => userStore.user?.superAdmin === 1 || !!userStore.authorityList?.includes('sys:chat:page')
)

const refresh = async () => {
	if (!canEnter.value) {
		unread.value = 0
		return
	}
	try {
		const res: any = await useChatUnreadCountApi()
		unread.value = Number(res.data || 0)
	} catch {
		unread.value = 0
	}
}

const goChat = () => {
	router.push('/sys/chat/index').catch(() => undefined)
}

watch(canEnter, v => {
	if (v) refresh()
})

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
.chat-bell {
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
