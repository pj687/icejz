<template>
	<div class="navbar-settings">
		<ma-icon icon="icon-ellipsis-v" @click="visible = true"></ma-icon>
		<el-dialog
			v-model="visible"
			class="layout-settings-dialog"
			width="720px"
			align-center
			:destroy-on-close="false"
			append-to-body
			draggable
		>
			<template #header>
				<div class="dialog-header">
					<span class="dialog-mark" aria-hidden="true"></span>
					<div>
						<strong>{{ $t('settings.title') }}</strong>
						<p>{{ $t('settings.subtitle') }}</p>
					</div>
				</div>
			</template>

			<div class="settings-container">
				<div class="settings-layout">
					<section class="settings-section">
						<header class="section-head">
							<strong>{{ $t('settings.themeStyle') }}</strong>
							<span>{{ $t('settings.themeStyleTip') }}</span>
						</header>

						<div class="preview-grid">
							<button
								type="button"
								class="settings-box-item item-left-dark"
								:class="{ active: theme.sidebarStyle === 'dark' }"
								:title="$t('settings.sidebarDark')"
								@click="handleSidebarTheme('dark')"
							>
								<span class="preview-label">{{ $t('settings.sidebarDark') }}</span>
							</button>
							<button
								type="button"
								class="settings-box-item item-left-light"
								:class="{ active: theme.sidebarStyle === 'light' }"
								:title="$t('settings.sidebarLight')"
								@click="handleSidebarTheme('light')"
							>
								<span class="preview-label">{{ $t('settings.sidebarLight') }}</span>
							</button>
							<button
								type="button"
								class="settings-box-item item-top-light"
								:class="{ active: theme.headerStyle === 'light' }"
								:title="$t('settings.navbarLight')"
								@click="handleHeaderTheme('light')"
							>
								<span class="preview-label">{{ $t('settings.navbarLight') }}</span>
							</button>
							<button
								type="button"
								class="settings-box-item item-top-theme"
								:class="{ active: theme.headerStyle === 'theme' }"
								:title="$t('settings.navbarTheme')"
								@click="handleHeaderTheme('theme')"
							>
								<span class="preview-label">{{ $t('settings.navbarTheme') }}</span>
							</button>
						</div>

						<div class="color-block">
							<div class="color-head">
								<span>{{ $t('settings.primaryColor') }}</span>
								<em>{{ theme.primaryColor }}</em>
							</div>
							<div class="color-list">
								<button
									v-for="color in colors"
									:key="color"
									type="button"
									class="theme-color"
									:class="{ active: theme.primaryColor === color }"
									:style="{ backgroundColor: color }"
									:aria-label="color"
									@click="handleThemeColor(color)"
								></button>
								<label class="theme-color theme-color-custom" :title="$t('settings.customColor')">
									<input type="color" :value="theme.primaryColor" @input="onCustomColor" />
									<span>+</span>
								</label>
							</div>
						</div>
					</section>

					<section class="settings-section">
						<header class="section-head">
							<strong>{{ $t('settings.layout') }}</strong>
							<span>{{ $t('settings.layoutTip') }}</span>
						</header>
						<div class="preview-grid layout-grid">
							<button
								type="button"
								class="settings-box-item item-vertical"
								:class="{ active: theme.layout === 'vertical' }"
								@click="handleLayoutTheme('vertical')"
							>
								<span class="preview-label">{{ $t('settings.vertical') }}</span>
							</button>
							<button
								type="button"
								class="settings-box-item item-columns"
								:class="{ active: theme.layout === 'columns' }"
								@click="handleLayoutTheme('columns')"
							>
								<span class="columns-tips-box"></span>
								<span class="columns-sub-menu"></span>
								<span class="preview-label">{{ $t('settings.columns') }}</span>
							</button>
							<button
								type="button"
								class="settings-box-item item-transverse"
								:class="{ active: theme.layout === 'transverse' }"
								@click="handleLayoutTheme('transverse')"
							>
								<span class="preview-label">{{ $t('settings.transverse') }}</span>
							</button>
						</div>
					</section>

					<section class="settings-section settings-section-wide">
						<header class="section-head">
							<strong>{{ $t('settings.interface') }}</strong>
							<span>{{ $t('settings.interfaceTip') }}</span>
						</header>
						<div class="switch-panel">
							<SwitchItem v-model="isDark" :title="$t('settings.dark')" />
							<SwitchItem v-model="theme.uniqueOpened" :title="$t('settings.uniqueOpened')" @change="handleOtherTheme" />
							<SwitchItem v-model="theme.isLogo" :title="$t('settings.logo')" @change="handleOtherTheme" />
							<SwitchItem v-model="theme.isBreadcrumb" :title="$t('settings.breadcrumb')" @change="handleOtherTheme" />
							<SwitchItem v-model="theme.isTabsView" :title="$t('settings.tabs')" @change="handleOtherTheme" />
							<SwitchItem
								v-model="theme.isTabsCache"
								:title="$t('settings.tabsCache')"
								:disabled="!theme.isTabsView"
								@change="handleOtherTheme"
							/>
							<SelectItem
								v-model="theme.tabsStyle"
								:title="$t('settings.tabsStyle')"
								:options="tabsStyle"
								:disabled="!theme.isTabsView"
								@change="handleOtherTheme"
							/>
							<SelectItem
								v-model="componentSize"
								:title="$t('settings.componentSize')"
								:options="sizeOptions"
								@change="handleComponentSize"
							/>
						</div>
					</section>
				</div>
			</div>

			<template #footer>
				<div class="dialog-footer">
					<p class="persist-tip">{{ $t('settings.tips') }}</p>
					<div class="config-btn">
						<el-button :icon="RefreshRight" @click="handleResetConfig">
							{{ $t('settings.reset') }}
						</el-button>
						<el-button :icon="CopyDocument" @click="handleCopyConfig">
							{{ $t('settings.copyConfig') }}
						</el-button>
						<el-button type="primary" :icon="Upload" :loading="applying" @click="handleApplyConfig">
							{{ $t('settings.applyConfig') }}
						</el-button>
					</div>
				</div>
			</template>
		</el-dialog>
	</div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { CopyDocument, RefreshRight, Upload } from '@element-plus/icons-vue'
import { useClipboard, useDark } from '@vueuse/core'
import SwitchItem from './components/SwitchItem.vue'
import SelectItem from './components/SelectItem.vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { handleThemeStyle } from '@/utils/theme'
import cache from '@/utils/cache'
import emits from '@/utils/emits'
import { useAppStore } from '@/store/modules/app'
import { themeConfig } from '@/store/theme/config'

const appStore = useAppStore()
const { t } = useI18n()
const { copy } = useClipboard()

const visible = ref(false)
const applying = ref(false)
emits.on('openThemeSettings', () => (visible.value = true))

const colors = [
	'#00a8e8',
	'#0BB2D4',
	'#3E8EF7',
	'#11C26D',
	'#17B3A3',
	'#1a2332',
	'#667AFA',
	'#757575',
	'#EB6709',
	'#F74584',
	'#FCB900',
	'#FF4C52'
]

const tabsStyle = computed(() => [
	{ label: t('settings.style1'), value: 'style-1' },
	{ label: t('settings.style2'), value: 'style-2' }
])

const sizeOptions = computed(() => [
	{ label: t('app.large'), value: 'large' },
	{ label: t('app.default'), value: 'default' },
	{ label: t('app.small'), value: 'small' }
])

const theme = computed(() => appStore.theme)
const componentSize = computed({
	get: () => appStore.componentSize,
	set: (val: string) => appStore.setComponentSize(val)
})

const persistTheme = () => {
	cache.setTheme(theme.value)
}

const handleLayoutTheme = (layout: string) => {
	theme.value.layout = layout
	persistTheme()
}

const handleSidebarTheme = (style: string) => {
	theme.value.sidebarStyle = style
	persistTheme()
}

const handleHeaderTheme = (style: string) => {
	theme.value.headerStyle = style
	persistTheme()
}

const isDark = useDark()

const handleOtherTheme = () => {
	persistTheme()
}

const handleThemeColor = (color: string) => {
	theme.value.primaryColor = color
	persistTheme()
	handleThemeStyle(theme.value)
}

const onCustomColor = (event: Event) => {
	const value = (event.target as HTMLInputElement).value
	handleThemeColor(value)
}

const handleComponentSize = () => {
	// SelectItem 已通过 v-model 写入 componentSize
}

const themeJson = () => JSON.stringify(theme.value, null, 2)

const handleCopyConfig = async () => {
	await copy(themeJson())
	ElMessage.success(t('settings.copySuc'))
}

const handleApplyConfig = async () => {
	try {
		await ElMessageBox.confirm(t('settings.applyConfirm'), t('settings.title'), {
			type: 'warning',
			confirmButtonText: t('settings.applyConfig'),
			cancelButtonText: t('cancel')
		})
	} catch {
		return
	}

	applying.value = true
	try {
		const response = await fetch('/__icejz/theme-apply', {
			method: 'POST',
			headers: { 'Content-Type': 'application/json' },
			body: themeJson()
		})
		const result = await response.json().catch(() => ({}))
		if (!response.ok || !result?.ok) {
			throw new Error(result?.message || t('settings.applyFail'))
		}
		ElMessage.success(t('settings.applySuc'))
	} catch (error) {
		ElMessage.error(error instanceof Error ? error.message : t('settings.applyFail'))
	} finally {
		applying.value = false
	}
}

const handleResetConfig = async () => {
	try {
		await ElMessageBox.confirm(t('settings.resetConfirm'), t('settings.title'), {
			type: 'warning',
			confirmButtonText: t('settings.reset'),
			cancelButtonText: t('cancel')
		})
		Object.assign(theme.value, { ...themeConfig })
		persistTheme()
		handleThemeStyle(theme.value)
		appStore.setComponentSize('default')
		isDark.value = false
		ElMessage.success(t('settings.resetSuc'))
	} catch {
		// cancelled
	}
}
</script>

<style lang="scss" scoped>
.dialog-header {
	display: flex;
	align-items: flex-start;
	gap: 10px;

	strong {
		display: block;
		font-size: 16px;
		color: var(--el-text-color-primary);
		line-height: 1.3;
	}

	p {
		margin: 4px 0 0;
		font-size: 12px;
		color: var(--el-text-color-secondary);
		line-height: 1.4;
	}
}

.dialog-mark {
	width: 8px;
	height: 8px;
	margin-top: 6px;
	border-radius: 50%;
	flex-shrink: 0;
	background: linear-gradient(135deg, #00a8e8, #3ec6ff);
	box-shadow: 0 0 0 4px rgba(0, 168, 232, 0.16);
}

.settings-container {
	color: var(--el-text-color-primary);
}

.settings-layout {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 12px;
}

.settings-section {
	padding: 14px;
	border-radius: 14px;
	background: var(--el-fill-color-blank);
	border: 1px solid var(--el-border-color-lighter);
}

.settings-section-wide {
	grid-column: 1 / -1;
}

.section-head {
	margin-bottom: 12px;

	strong {
		display: block;
		font-size: 13px;
		font-weight: 700;
	}

	span {
		display: block;
		margin-top: 2px;
		font-size: 12px;
		color: var(--el-text-color-secondary);
	}
}

.preview-grid {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 12px;
}

.layout-grid {
	grid-template-columns: repeat(3, 1fr);
	gap: 10px;
}

.settings-box-item {
	position: relative;
	width: 100%;
	height: 54px;
	padding: 0;
	border: 1px solid var(--el-border-color-lighter);
	border-radius: 10px;
	background-color: var(--el-fill-color-light);
	box-shadow: none;
	cursor: pointer;
	overflow: hidden;
	transition: border-color 0.2s ease, box-shadow 0.2s ease, transform 0.2s ease;

	&:hover {
		transform: translateY(-1px);
		border-color: color-mix(in srgb, var(--el-color-primary) 45%, transparent);
	}

	&.active {
		border-color: var(--el-color-primary);
		box-shadow: 0 0 0 3px color-mix(in srgb, var(--el-color-primary) 18%, transparent);

		.preview-label {
			color: var(--el-color-primary);
			font-weight: 700;
		}
	}
}

.preview-label {
	position: absolute;
	left: 0;
	right: 0;
	bottom: 4px;
	z-index: 2;
	font-size: 11px;
	line-height: 1;
	color: var(--el-text-color-secondary);
	text-align: center;
	pointer-events: none;
}

.item-left-light::before,
.item-left-dark::before,
.item-vertical::before {
	position: absolute;
	top: 0;
	left: 0;
	width: 30%;
	height: calc(100% - 16px);
	content: '';
	border-top-left-radius: 9px;
}

.item-left-light::before,
.item-left-dark::before {
	height: calc(100% - 16px);
}

.item-left-light::before {
	background-color: #fff;
	border: 1px solid #e5e7eb;
	border-left: none;
	border-bottom: none;
}

.item-left-dark::before,
.item-vertical::before {
	background-color: #111827;
}

.item-top-light::before,
.item-top-theme::before,
.item-transverse::before {
	position: absolute;
	top: 0;
	left: 0;
	width: 100%;
	height: 28%;
	content: '';
	border-top-left-radius: 9px;
	border-top-right-radius: 9px;
}

.item-top-light::before {
	background-color: #fff;
	border-bottom: 1px solid #e5e7eb;
}

.item-top-theme::before {
	background-color: var(--el-color-primary);
}

.item-transverse::before {
	background-color: #1f2937;
}

.item-columns {
	.columns-tips-box,
	.columns-sub-menu {
		position: absolute;
		top: 0;
		left: 18%;
		display: block;
	}

	&::before {
		position: absolute;
		top: 0;
		left: 0;
		width: 18%;
		height: calc(100% - 16px);
		background-color: #111827;
		content: '';
		border-top-left-radius: 9px;
	}

	.columns-tips-box {
		width: 82%;
		height: 22%;
		background-color: #374151;
		border-top-right-radius: 9px;
	}

	.columns-sub-menu {
		width: 16%;
		height: calc(78% - 16px);
		top: 22%;
		background-color: #9ca3af;
	}
}

.color-block {
	margin-top: 14px;
	padding-top: 12px;
	border-top: 1px dashed var(--el-border-color-lighter);
}

.color-head {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 10px;
	font-size: 12px;
	color: var(--el-text-color-regular);

	em {
		font-style: normal;
		font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
		color: var(--el-color-primary);
		font-weight: 600;
	}
}

.color-list {
	display: flex;
	flex-wrap: wrap;
	gap: 8px;
}

.theme-color {
	width: 22px;
	height: 22px;
	padding: 0;
	border: none;
	border-radius: 6px;
	cursor: pointer;
	position: relative;
	box-shadow: inset 0 0 0 1px rgba(0, 0, 0, 0.06);
	transition: transform 0.15s ease;

	&:hover {
		transform: scale(1.08);
	}

	&.active::after {
		content: '';
		position: absolute;
		inset: 0;
		border-radius: 6px;
		background:
			url('data:image/svg+xml;charset=utf-8,<svg width="12" height="12" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg"><path fill="white" d="M406.656 706.944L195.84 496.256a32 32 0 10-45.248 45.248l256 256 512-512a32 32 0 00-45.248-45.248L406.592 706.944z"></path></svg>')
			center / 12px 12px no-repeat;
		box-shadow: 0 0 0 2px #fff inset;
	}
}

.theme-color-custom {
	display: inline-flex;
	align-items: center;
	justify-content: center;
	background: var(--el-fill-color);
	color: var(--el-text-color-secondary);
	font-size: 14px;
	font-weight: 700;
	overflow: hidden;

	input {
		position: absolute;
		inset: 0;
		opacity: 0;
		cursor: pointer;
	}
}

.switch-panel {
	display: flex;
	flex-direction: column;
	gap: 2px;
}

.dialog-footer {
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 16px;
	width: 100%;
}

.persist-tip {
	margin: 0;
	flex: 1;
	min-width: 0;
	font-size: 12px;
	line-height: 1.55;
	text-align: left;
	color: var(--el-text-color-secondary);
}

.config-btn {
	display: flex;
	flex-shrink: 0;
	gap: 8px;

	.el-button {
		margin: 0;
	}
}

@media (max-width: 768px) {
	.settings-layout {
		grid-template-columns: 1fr;
	}

	.dialog-footer {
		flex-direction: column;
		align-items: stretch;
	}

	.config-btn {
		display: grid;
		grid-template-columns: 1fr;
	}
}
</style>

<style lang="scss">
.layout-settings-dialog {
	border-radius: 16px;
	overflow: hidden;

	.el-dialog__header {
		margin-right: 0;
		padding: 18px 20px 10px;
	}

	.el-dialog__body {
		padding: 8px 20px 4px;
		max-height: min(68vh, 640px);
		overflow: auto;
	}

	.el-dialog__footer {
		padding: 12px 20px 18px;
		border-top: 1px solid var(--el-border-color-lighter);
	}
}
</style>
