/** Codex / Petdex V1 九态精灵表约定 */
export type IcePetState =
	| 'idle'
	| 'running-right'
	| 'running-left'
	| 'dance'
	| 'jumping'
	| 'failed'
	| 'waiting'
	| 'running'
	| 'review'

export type IcePetAction = IcePetState

export const PET_SHEET = {
	src: '/mascot/xiaobing-pet/spritesheet.webp?v=hatch8',
	fallbackSrc: '/mascot/xiaobing-pet/spritesheet.png?v=hatch8',
	cellW: 192,
	cellH: 208,
	cols: 8,
	rows: 9,
	width: 1536,
	height: 1872
} as const

/**
 * 奶龙合拍手势舞专用条（hatch-pet 192×208 单元格）
 * 列：哭高、哭低、交叉、打开、左抓、右抓、左圈、右圈
 * sequence 按五组节拍展开播放索引
 */
export const DANCE_SHEET = {
	src: '/mascot/xiaobing-dance/spritesheet.webp?v=hepai1',
	fallbackSrc: '/mascot/xiaobing-dance/spritesheet.png?v=hepai1',
	cellW: 192,
	cellH: 208,
	cols: 8,
	rows: 1,
	width: 1536,
	height: 208,
	/** 精灵表唯一姿势数 */
	frames: 8,
	fps: 5,
	/** 合拍序列：右手哭×2 → 交叉打开 → 抓手 → 交叉×4 → 画圈×3 */
	sequence: [
		0, 1, 0, 1, // 右手哭两次
		2, 3, // 交叉再打开
		4, 3, 5, 3, // 依次抓手
		2, 3, 2, 3, 2, 3, 2, 3, // 交叉四次
		6, 7, 6, 7, 6, 7 // 左右画圈三次
	] as const
} as const

/** 机体 ↔ 飞行 变身专用条（非 Codex 九态行） */
export const MORPH_SHEET = {
	src: '/mascot/xiaobing-morph/spritesheet.webp?v=1',
	fallbackSrc: '/mascot/xiaobing-morph/spritesheet.png?v=1',
	cellW: 192,
	cellH: 208,
	cols: 6,
	rows: 2,
	width: 1152,
	height: 416,
	frames: 6,
	/** 略提帧率，配合缓动节奏更顺 */
	fps: 14,
	/** 整段变身目标时长（毫秒），帧间隔按 ease 分配 */
	durationMs: 720,
	/** row0: 机体→飞行；row1: 飞行→机体 */
	rowBotToFly: 0,
	rowFlyToBot: 1
} as const

/** 各尺寸相对 192×208 单元格的缩放 */
export const PET_SIZE_SCALE: Record<'sm' | 'md' | 'lg' | 'xl', number> = {
	sm: 0.48,
	md: 0.72,
	lg: 0.92,
	xl: 1.05
}

export const PET_STATES: Array<{
	name: IcePetState
	row: number
	frames: number
	/** 越低单次动作越长、越顺滑可读 */
	fps: number
	loop: boolean
	/** 循环帧来回播（举手→放下更自然，避免硬切回第 0 帧） */
	pingPong?: boolean
	/** 循环动作持续多久后回 idle（毫秒） */
	holdMs: number
	short: string
	label: string
	tip: string
	group: 'move' | 'react' | 'work'
}> = [
	{
		name: 'idle',
		row: 0,
		frames: 6,
		fps: 4,
		loop: true,
		holdMs: 0,
		short: '待机',
		label: '待机呼吸',
		tip: '待机中～',
		group: 'react'
	},
	{
		name: 'running-right',
		row: 1,
		frames: 8,
		fps: 6,
		loop: true,
		holdMs: 4800,
		short: '右走',
		label: '向右走',
		tip: '向右溜达～',
		group: 'move'
	},
	{
		name: 'running-left',
		row: 2,
		frames: 8,
		fps: 6,
		loop: true,
		holdMs: 4800,
		short: '左走',
		label: '向左走',
		tip: '向左溜达～',
		group: 'move'
	},
	{
		/** 合拍手势舞：DANCE_SHEET.sequence 逐拍播放（非九态行） */
		name: 'dance',
		row: 0,
		frames: DANCE_SHEET.sequence.length,
		fps: DANCE_SHEET.fps,
		loop: true,
		holdMs: Math.round((DANCE_SHEET.sequence.length / DANCE_SHEET.fps) * 1000) + 400,
		short: '合拍',
		label: '合拍手势舞',
		tip: '合拍！哭两下、交叉、抓手、再交叉、画圈～',
		group: 'react'
	},
	{
		name: 'jumping',
		row: 4,
		frames: 5,
		fps: 5.5,
		loop: false,
		holdMs: 0,
		short: '跳跃',
		label: '开心跳跃',
		tip: '蹦一下～',
		group: 'react'
	},
	{
		name: 'failed',
		row: 5,
		frames: 8,
		fps: 4,
		loop: false,
		holdMs: 0,
		short: '委屈',
		label: '出错委屈',
		tip: '呜…好像出错了',
		group: 'react'
	},
	{
		name: 'waiting',
		row: 6,
		frames: 6,
		fps: 4,
		loop: true,
		holdMs: 5200,
		short: '等待',
		label: '等待指令',
		tip: '等你指令…',
		group: 'work'
	},
	{
		name: 'running',
		row: 7,
		frames: 6,
		fps: 4.5,
		loop: true,
		holdMs: 4800,
		short: '忙碌',
		label: '专注忙碌',
		tip: '小冰正在忙～',
		group: 'work'
	},
	{
		name: 'review',
		row: 8,
		frames: 6,
		fps: 4,
		loop: true,
		holdMs: 5200,
		short: '审阅',
		label: '认真审阅',
		tip: '认真看一看…',
		group: 'work'
	}
]

/** 动作栏展示（不含待机、左右走、跳跃） */
export const DOCK_PET_STATES = PET_STATES.filter(
	s => s.name !== 'idle' && s.group !== 'move' && s.name !== 'jumping'
)

export const PET_STATE_MAP = Object.fromEntries(PET_STATES.map(s => [s.name, s])) as Record<
	IcePetState,
	(typeof PET_STATES)[number]
>

export const RANDOM_PET_STATES: IcePetState[] = ['dance', 'waiting', 'review', 'running', 'failed']
