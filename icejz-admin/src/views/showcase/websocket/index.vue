<template>
	<ShowcaseShell title="WebSocket 联调" desc="连接实时通道、指定接收人并发送消息，右侧即时查看回执">
		<template #actions>
			<el-tag :type="openState ? 'success' : 'danger'" effect="light" round>
				{{ openState ? '已连接' : '已断开' }}
			</el-tag>
			<el-button :type="openState ? 'danger' : 'primary'" @click="handleConnect">
				{{ openState ? '断开连接' : '立即连接' }}
			</el-button>
		</template>

		<div class="ws-layout">
			<div class="panel">
				<strong class="panel-title">发送面板</strong>
				<el-form ref="dataFormRef" :model="dataForm" :rules="dataRules" label-position="top" class="ws-form">
					<el-form-item label="服务地址">
						<el-input v-model="webSocketUrl" disabled />
					</el-form-item>
					<el-form-item prop="userId" label="发送给谁">
						<ma-user-input v-model="dataForm.userId"></ma-user-input>
					</el-form-item>
					<el-form-item prop="content" label="发送内容">
						<el-input v-model="dataForm.content" :rows="4" type="textarea" placeholder="输入要推送的消息…" />
					</el-form-item>
				</el-form>
				<div class="form-foot">
					<el-button type="primary" :disabled="!openState" @click="submitHandle()">发送消息</el-button>
				</div>
			</div>

			<div class="panel messages">
				<strong class="panel-title">消息列表 · {{ messageList.length }}</strong>
				<el-scrollbar class="msg-scroll">
					<div v-if="!messageList.length" class="empty">连接后发送一条消息试试</div>
					<chat-item
						v-for="(message, idx) in messageList"
						:key="idx"
						:avatar="message.avatar"
						:name="message.name"
						:content="message.content"
						:datetime="message.sendTime"
						role="user"
						variant="text"
					></chat-item>
				</el-scrollbar>
			</div>
		</div>
	</ShowcaseShell>
</template>

<script lang="ts" setup>
import { ChatItem } from '@tdesign-vue-next/chat'
import { computed, reactive, ref, watch } from 'vue'
import constant from '@/utils/constant'
import cache from '@/utils/cache'
import MaUserInput from '@/components/ma-user/ma-user-input/index.vue'
import { ElNotification } from 'element-plus'
import service from '@/utils/request'
import { useWebSocket } from '@vueuse/core'
import { useUserStore } from '@/store/modules/user'
import ShowcaseShell from '../ShowcaseShell.vue'

const webSocketUrl = ref(constant.apiUrl.replace('http://', 'ws://').replace('https://', 'wss://') + '/ws?access_token=' + cache.getToken())
const { data, status, open, close } = useWebSocket(webSocketUrl, {
	autoReconnect: true,
	onConnected() {
		console.log('websocket connected')
	},
	onError() {
		ElNotification({
			type: 'error',
			title: '连接中断',
			message: 'WebSocket连接，已断开！'
		})
	}
})
watch(
	() => data.value,
	val => {
		const result = JSON.parse(val)
		messageList.value.push({
			name: result.data.name,
			avatar: result.data.avatar,
			content: result.data.content,
			sendTime: result.data.sendTime
		})
	}
)

const openState = computed(() => status.value === 'OPEN')
const handleConnect = () => {
	if (openState.value) close()
	else open()
}

const messageList = ref<any[]>([])
const dataFormRef = ref()
const dataForm = reactive({
	content: '',
	userId: ''
})

const dataRules = ref({
	content: [{ required: true, message: '必填项不能为空', trigger: 'blur' }],
	userId: [{ required: true, message: '必填项不能为空', trigger: 'blur' }]
})

const submitHandle = () => {
	dataFormRef.value.validate((valid: boolean) => {
		if (!valid) return false
		service.postForm('/ws/message/send', dataForm).then(() => {
			const userStore = useUserStore()
			messageList.value.push({
				name: userStore.user.realName,
				avatar: userStore.user.avatar,
				content: dataForm.content,
				sendTime: getCurrentDate()
			})
			dataForm.content = ''
		})
	})
}

const getCurrentDate = () => {
	return new Date().toLocaleString('zh-CN', {
		year: 'numeric',
		month: '2-digit',
		day: '2-digit',
		hour: '2-digit',
		minute: '2-digit',
		second: '2-digit'
	})
}
</script>

<style scoped lang="scss">
.ws-layout {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 16px;
	min-height: 620px;
}

.panel {
	display: flex;
	flex-direction: column;
	padding: 18px;
	border-radius: 20px;
	border: 1px solid rgba(0, 168, 232, 0.12);
	background: rgba(255, 255, 255, 0.92);
	box-shadow: 0 10px 24px rgba(15, 40, 64, 0.04);
}

.panel-title {
	margin-bottom: 14px;
	font-size: 14px;
	font-weight: 750;
	color: #0f1724;
}

.ws-form {
	flex: 1;
}

.form-foot {
	display: flex;
	justify-content: flex-end;
	padding-top: 8px;
}

.messages {
	min-height: 0;
}

.msg-scroll {
	flex: 1;
	height: 540px;
	padding-right: 4px;
}

.empty {
	padding: 48px 12px;
	text-align: center;
	color: #94a3b8;
	font-size: 13px;
}

@media (max-width: 960px) {
	.ws-layout {
		grid-template-columns: 1fr;
	}
}
</style>

<style lang="scss">
@use '@tdesign-vue-next/chat/dist/tdesign-vue-chat.min.css';
</style>
