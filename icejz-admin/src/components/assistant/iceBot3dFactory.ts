import * as THREE from 'three'

export type IceBotAction = 'idle' | 'wave' | 'spin' | 'nod' | 'jump'

export interface IceBotRig {
	root: THREE.Group
	body: THREE.Group
	head: THREE.Group
	leftArm: THREE.Group
	rightArm: THREE.Group
	leftLeg: THREE.Group
	rightLeg: THREE.Group
	visorGlow: THREE.Object3D
	coreGlow: THREE.Object3D
	setAction: (action: IceBotAction) => void
	update: (dt: number, elapsed: number) => void
	dispose: () => void
}

interface PreparedTex {
	texture: THREE.Texture
	imageData: ImageData | null
}

/** 去掉绿幕/黑底，返回干净贴图与像素数据 */
const prepareTexture = (src: THREE.Texture): PreparedTex => {
	const img = src.image as HTMLImageElement | ImageBitmap | undefined
	if (!img || !('width' in img)) {
		src.colorSpace = THREE.SRGBColorSpace
		src.anisotropy = 8
		src.needsUpdate = true
		return { texture: src, imageData: null }
	}

	const w = img.width
	const h = img.height
	const canvas = document.createElement('canvas')
	canvas.width = w
	canvas.height = h
	const ctx = canvas.getContext('2d', { willReadFrequently: true })
	if (!ctx) {
		src.colorSpace = THREE.SRGBColorSpace
		return { texture: src, imageData: null }
	}

	ctx.drawImage(img as CanvasImageSource, 0, 0)
	const data = ctx.getImageData(0, 0, w, h)
	const px = data.data
	for (let i = 0; i < px.length; i += 4) {
		const r = px[i]
		const g = px[i + 1]
		const b = px[i + 2]
		const a = px[i + 3]
		if (g > 140 && g > r + 40 && g > b + 40) {
			px[i + 3] = 0
			continue
		}
		if (a > 200 && r < 18 && g < 18 && b < 18) {
			px[i + 3] = 0
		}
	}
	ctx.putImageData(data, 0, 0)

	const tex = new THREE.CanvasTexture(canvas)
	tex.colorSpace = THREE.SRGBColorSpace
	tex.anisotropy = 8
	tex.premultiplyAlpha = true
	tex.needsUpdate = true
	src.dispose()
	return { texture: tex, imageData: data }
}

/** 按透明度扫描轮廓，生成可挤出的立绘外形 */
const buildSilhouetteShape = (
	imageData: ImageData,
	worldW: number,
	worldH: number,
	samples = 64,
	alphaThreshold = 36
): THREE.Shape | null => {
	const { width: w, height: h, data } = imageData
	const left: THREE.Vector2[] = []
	const right: THREE.Vector2[] = []

	for (let row = 0; row < samples; row++) {
		const v = row / (samples - 1)
		const iy = Math.min(h - 1, Math.floor(v * (h - 1)))
		let minX = -1
		let maxX = -1
		for (let ix = 0; ix < w; ix++) {
			if (data[(iy * w + ix) * 4 + 3] > alphaThreshold) {
				if (minX < 0) minX = ix
				maxX = ix
			}
		}
		if (minX < 0) continue
		const y = worldH / 2 - v * worldH
		const xL = (minX / Math.max(w - 1, 1) - 0.5) * worldW
		const xR = (maxX / Math.max(w - 1, 1) - 0.5) * worldW
		// 略微外扩，避免贴图边缘露馅
		const pad = worldW * 0.008
		left.push(new THREE.Vector2(xL - pad, y))
		right.push(new THREE.Vector2(xR + pad, y))
	}

	if (left.length < 4) return null

	const shape = new THREE.Shape()
	shape.moveTo(left[0].x, left[0].y)
	for (let i = 1; i < left.length; i++) shape.lineTo(left[i].x, left[i].y)
	for (let i = right.length - 1; i >= 0; i--) shape.lineTo(right[i].x, right[i].y)
	shape.closePath()
	return shape
}

/**
 * 立绘贴图正面 + 实体挤出侧边（亚克力立牌），侧面不再是假切片
 */
export const createIceBotRig = (rawTexture: THREE.Texture): IceBotRig => {
	const { texture, imageData } = prepareTexture(rawTexture)
	const materials: THREE.Material[] = []
	const geometries: THREE.BufferGeometry[] = []

	const root = new THREE.Group()
	const body = new THREE.Group()
	const head = new THREE.Group()
	const leftArm = new THREE.Group()
	const rightArm = new THREE.Group()
	const leftLeg = new THREE.Group()
	const rightLeg = new THREE.Group()
	const visorGlow = new THREE.Object3D()
	const coreGlow = new THREE.Object3D()

	const img = texture.image as { width: number; height: number }
	const aspect = img?.width && img?.height ? img.width / img.height : 1
	const height = 2.35
	const width = height * aspect
	const depth = 0.2

	const figure = new THREE.Group()

	const shape = imageData ? buildSilhouetteShape(imageData, width, height) : null
	if (shape) {
		const extrudeGeo = new THREE.ExtrudeGeometry(shape, {
			depth,
			bevelEnabled: true,
			bevelThickness: 0.028,
			bevelSize: 0.022,
			bevelSegments: 2,
			curveSegments: 1
		})
		extrudeGeo.translate(0, 0, -depth / 2)
		geometries.push(extrudeGeo)

		const edgeMat = new THREE.MeshStandardMaterial({
			color: 0xf4f9fc,
			metalness: 0.12,
			roughness: 0.4,
			emissive: 0xb8dff2,
			emissiveIntensity: 0.04
		})
		materials.push(edgeMat)
		figure.add(new THREE.Mesh(extrudeGeo, edgeMat))
	} else {
		// 兜底：圆角厚板
		const box = new THREE.Mesh(
			new THREE.BoxGeometry(width * 0.72, height * 0.92, depth),
			new THREE.MeshStandardMaterial({ color: 0xf4f9fc, metalness: 0.1, roughness: 0.45 })
		)
		geometries.push(box.geometry)
		materials.push(box.material as THREE.Material)
		figure.add(box)
	}

	const faceMat = new THREE.MeshBasicMaterial({
		map: texture,
		transparent: true,
		alphaTest: 0.12,
		depthWrite: true,
		side: THREE.FrontSide,
		toneMapped: false
	})
	materials.push(faceMat)

	const frontGeo = new THREE.PlaneGeometry(width, height)
	geometries.push(frontGeo)
	const front = new THREE.Mesh(frontGeo, faceMat)
	front.position.z = depth / 2 + 0.002
	figure.add(front)

	const backMat = new THREE.MeshBasicMaterial({
		map: texture,
		color: 0xe8f3f9,
		transparent: true,
		alphaTest: 0.2,
		depthWrite: false,
		side: THREE.FrontSide,
		toneMapped: false
	})
	materials.push(backMat)
	const backGeo = new THREE.PlaneGeometry(width, height)
	geometries.push(backGeo)
	const back = new THREE.Mesh(backGeo, backMat)
	back.position.z = -depth / 2 - 0.002
	back.rotation.y = Math.PI
	figure.add(back)

	figure.position.y = height * 0.5
	body.add(figure)
	root.add(body)

	const shadow = new THREE.Mesh(
		new THREE.CircleGeometry(0.52, 40),
		new THREE.MeshBasicMaterial({
			color: 0x0a3d5c,
			transparent: true,
			opacity: 0.15,
			depthWrite: false
		})
	)
	shadow.rotation.x = -Math.PI / 2
	shadow.position.y = 0.01
	shadow.scale.set(1.05, 0.55, 1)
	materials.push(shadow.material as THREE.Material)
	geometries.push(shadow.geometry)
	root.add(shadow)

	let action: IceBotAction = 'idle'
	let actionT = 0
	const baseY = 0

	const setAction = (next: IceBotAction) => {
		action = next
		actionT = 0
		body.rotation.set(0, 0, 0)
		body.position.set(0, baseY, 0)
		body.scale.set(1, 1, 1)
	}

	const update = (dt: number, elapsed: number) => {
		actionT += dt
		const breath = Math.sin(elapsed * 2.2) * 0.028

		if (action === 'idle') {
			body.position.y = baseY + breath
			body.rotation.z = Math.sin(elapsed * 1.1) * 0.02
			;(shadow.material as THREE.MeshBasicMaterial).opacity = 0.13 + Math.abs(Math.sin(elapsed * 2.2)) * 0.035
		} else if (action === 'wave') {
			body.position.y = baseY + breath + 0.03
			body.rotation.z = Math.sin(actionT * 12) * 0.14
			if (actionT > 1.2) setAction('idle')
		} else if (action === 'spin') {
			body.rotation.y += dt * 9
			body.position.y = baseY + 0.05
			if (actionT > 1.15) setAction('idle')
		} else if (action === 'nod') {
			body.rotation.x = Math.sin(actionT * 9) * 0.18
			if (actionT > 1.0) setAction('idle')
		} else if (action === 'jump') {
			const jump = Math.abs(Math.sin(actionT * 9)) * 0.38
			body.position.y = baseY + jump
			body.scale.set(1 - jump * 0.06, 1 + jump * 0.1, 1)
			shadow.scale.set(1.05 + jump * 0.2, 0.55 + jump * 0.1, 1)
			if (actionT > 0.85) {
				shadow.scale.set(1.05, 0.55, 1)
				setAction('idle')
			}
		}
	}

	const dispose = () => {
		for (const g of geometries) g.dispose()
		for (const m of materials) m.dispose()
		texture.dispose()
	}

	return {
		root,
		body,
		head,
		leftArm,
		rightArm,
		leftLeg,
		rightLeg,
		visorGlow,
		coreGlow,
		setAction,
		update,
		dispose
	}
}
