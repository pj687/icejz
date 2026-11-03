<template>
	<ShowcaseShell title="图片裁剪" desc="选择本地图片后自由裁剪，支持预览与下载">
		<template #actions>
			<el-button @click="handleUpload">选择图片</el-button>
			<el-button type="primary" @click="handleDownload">下载裁剪结果</el-button>
			<input ref="fileRef" style="display: none" type="file" accept="image/*" @change="handleFileChange" />
		</template>

		<div class="crop-layout">
			<div class="panel stage">
				<div class="img-cropper">
					<img ref="imgRef" :src="cropperImg" alt="crop source" />
				</div>
			</div>
			<div class="panel preview-wrap">
				<strong>实时预览</strong>
				<div class="img-preview"></div>
				<p>1:1 比例 · 适合头像与封面裁切</p>
			</div>
		</div>
	</ShowcaseShell>
</template>

<script lang="ts" setup>
import Cropper from 'cropperjs'
import 'cropperjs/dist/cropper.css'
import { nextTick, onBeforeUnmount, ref } from 'vue'
import ShowcaseShell from '../ShowcaseShell.vue'

const imgRef = ref()
const cropperImg = ref('/mascot/xiaobing-main.png?v=crop1')
const fileRef = ref()
const cropper = ref<any>(null)

nextTick(() => {
	initCropper()
})

onBeforeUnmount(() => {
	cropper.value?.destroy?.()
})

const initCropper = () => {
	cropper.value = new Cropper(imgRef.value, {
		viewMode: 1,
		dragMode: 'move',
		initialAspectRatio: 1,
		background: true,
		autoCropArea: 0.8,
		aspectRatio: 1,
		preview: '.img-preview'
	})
}

const handleUpload = () => {
	fileRef.value.click()
}

const handleFileChange = (e: any) => {
	const file = e.target.files[0]
	if (!file) return
	const URL = window.URL || window.webkitURL
	cropper.value.replace(URL.createObjectURL(file))
}

const handleDownload = () => {
	cropper.value.getCroppedCanvas().toBlob(function (blob: any) {
		const link = document.createElement('a')
		link.href = URL.createObjectURL(blob)
		link.setAttribute('download', 'icejz-crop.png')
		document.body.appendChild(link)
		link.click()
		document.body.removeChild(link)
	})
	cropper.value.crop()
}
</script>

<style scoped lang="scss">
.crop-layout {
	display: grid;
	grid-template-columns: minmax(0, 1.4fr) minmax(240px, 0.7fr);
	gap: 16px;
}

.panel {
	border-radius: 20px;
	border: 1px solid rgba(0, 168, 232, 0.12);
	background: color-mix(in srgb, var(--sc-panel, #fff) 90%, transparent);
	box-shadow: 0 10px 24px rgba(15, 40, 64, 0.04);
}

.stage {
	padding: 14px;
	overflow: hidden;
}

.img-cropper {
	width: 100%;
	height: min(460px, 58vh);
	border-radius: 14px;
	overflow: hidden;
	background: #0f1724;

	:deep(img) {
		display: block;
		max-width: 100%;
	}
}

.preview-wrap {
	display: flex;
	flex-direction: column;
	align-items: center;
	gap: 14px;
	padding: 22px 18px;

	strong {
		align-self: flex-start;
		font-size: 14px;
		color: #0f1724;
	}

	p {
		margin: 0;
		font-size: 12.5px;
		color: #94a3b8;
	}
}

.img-preview {
	width: min(280px, 100%);
	aspect-ratio: 1;
	overflow: hidden;
	border-radius: 18px;
	border: 1px solid rgba(0, 168, 232, 0.16);
	background: var(--sc-soft, #f8fafc);
	box-shadow: inset 0 0 0 6px rgba(255, 255, 255, 0.7);
}

@media (max-width: 960px) {
	.crop-layout {
		grid-template-columns: 1fr;
	}
}
</style>
