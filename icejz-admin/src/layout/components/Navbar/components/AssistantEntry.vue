<template>
	<button
		type="button"
		class="assistant-entry"
		:class="{ closed: assistantStore.mascotClosed, active: assistantStore.open }"
		:title="entryTitle"
		@click="onClick"
	>
		<span class="entry-dot" aria-hidden="true"></span>
		<span class="entry-label">{{ assistantStore.robotName || '小冰' }}</span>
	</button>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useAssistantStore } from '@/store/modules/assistant'

const assistantStore = useAssistantStore()

const entryTitle = computed(() => {
	if (assistantStore.mascotClosed) {
		return `打开${assistantStore.robotName || '小冰'}`
	}
	if (assistantStore.open) {
		return `收起${assistantStore.robotName || '小冰'}对话`
	}
	return `呼叫${assistantStore.robotName || '小冰'}`
})

const onClick = () => {
	if (assistantStore.mascotClosed) {
		assistantStore.showMascot()
		return
	}
	assistantStore.togglePanel()
}
</script>

<style scoped lang="scss">
.assistant-entry {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	height: 32px;
	padding: 0 10px 0 8px;
	margin: 0 2px;
	border: 1px solid transparent;
	border-radius: 999px;
	background: transparent;
	color: var(--el-text-color-regular);
	cursor: pointer;
	font-size: 12px;
	font-weight: 700;
	line-height: 1;
	transition: background 0.18s ease, color 0.18s ease, border-color 0.18s ease, box-shadow 0.18s ease;

	&:hover {
		background: rgba(0, 168, 232, 0.1);
		color: #007eb8;
	}

	&.closed {
		border-color: rgba(0, 168, 232, 0.22);
		background: rgba(0, 168, 232, 0.1);
		color: #007eb8;
		box-shadow: 0 0 0 3px rgba(0, 168, 232, 0.06);
	}

	&.active {
		border-color: rgba(0, 168, 232, 0.28);
		background: linear-gradient(135deg, rgba(0, 168, 232, 0.16), rgba(0, 168, 232, 0.08));
		color: #007eb8;
	}
}

.entry-dot {
	width: 8px;
	height: 8px;
	border-radius: 50%;
	background: #00a8e8;
	box-shadow: 0 0 0 3px rgba(0, 168, 232, 0.16);
}

.closed .entry-dot {
	background: #94a3b8;
	box-shadow: 0 0 0 3px rgba(148, 163, 184, 0.18);
	animation: pulse-dot 1.4s ease infinite;
}

@keyframes pulse-dot {
	0%,
	100% {
		transform: scale(1);
		opacity: 1;
	}
	50% {
		transform: scale(1.15);
		opacity: 0.75;
	}
}

.entry-label {
	max-width: 48px;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}
</style>
