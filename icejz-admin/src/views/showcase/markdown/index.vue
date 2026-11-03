<template>
	<ShowcaseShell title="Markdown 编辑" desc="支持即时预览的 Markdown 写作区，适合文档与说明稿">
		<div class="md-panel">
			<ma-markdown v-model="editorValue" height="560px"></ma-markdown>
		</div>
	</ShowcaseShell>
</template>

<script lang="ts" setup>
import { ref } from 'vue'
import ShowcaseShell from '../ShowcaseShell.vue'

const editorValue = ref(`# ICEJZ Markdown

写一点平台说明，例如：

- 工作台日历记事
- 小冰助手对话
- 菜单与权限配置

\`\`\`ts
const hello = 'ICEJZ'
\`\`\`
`)
</script>

<style scoped lang="scss">
.md-panel {
	padding: 12px;
	border-radius: 20px;
	border: 1px solid rgba(0, 168, 232, 0.12);
	background: color-mix(in srgb, var(--sc-panel, #fff) 92%, transparent);
	box-shadow: 0 10px 24px rgba(15, 40, 64, 0.04);
	overflow: hidden;
}
</style>
