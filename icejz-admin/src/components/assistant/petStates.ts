/** Codex / Petdex V1 九态精灵表约定 */
export type IcePetState =
	| 'idle'
	| 'running-right'
	| 'running-left'
	| 'waving'
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
	fps: 9,
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
		name: 'waving',
		row: 3,
		frames: 4,
		fps: 5.5,
		loop: true,
		holdMs: 1800,
		short: '招呼',
		label: '挥手打招呼',
		tip: '嗨～小冰跟你打招呼！',
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

export const RANDOM_PET_STATES: IcePetState[] = ['waving', 'waiting', 'review', 'running', 'failed']
