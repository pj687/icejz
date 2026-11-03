import type { IcePetState } from './petStates'

const V = 'v1'

/** 各动作对应真实姿态图（不透明 PNG） */
export const POSE_SRC: Record<string, string> = {
	idle: `/mascot/xiaobing-pet/poses/idle.png?${V}`,
	'walk-a': `/mascot/xiaobing-pet/poses/walk-a.png?${V}`,
	'walk-b': `/mascot/xiaobing-pet/poses/walk-b.png?${V}`,
	'walk-left-a': `/mascot/xiaobing-pet/poses/walk-left-a.png?${V}`,
	'walk-left-b': `/mascot/xiaobing-pet/poses/walk-left-b.png?${V}`,
	jump: `/mascot/xiaobing-pet/poses/jump.png?${V}`,
	fail: `/mascot/xiaobing-pet/poses/fail.png?${V}`,
	wait: `/mascot/xiaobing-pet/poses/wait.png?${V}`,
	busy: `/mascot/xiaobing-pet/poses/busy.png?${V}`,
	review: `/mascot/xiaobing-pet/poses/review.png?${V}`,
	fly: '/mascot/xiaobing-head.png?v=2'
}

/** 每个状态的帧序列（切真实姿态，不做混帧） */
export const POSE_FRAMES: Record<IcePetState, string[]> = {
	idle: ['idle', 'idle', 'idle', 'idle', 'idle', 'idle'],
	'running-right': ['walk-a', 'walk-a', 'walk-b', 'walk-b', 'walk-a', 'walk-a', 'walk-b', 'walk-b'],
	'running-left': [
		'walk-left-a',
		'walk-left-a',
		'walk-left-b',
		'walk-left-b',
		'walk-left-a',
		'walk-left-a',
		'walk-left-b',
		'walk-left-b'
	],
	dance: ['idle', 'idle', 'idle', 'idle', 'idle', 'idle'],
	jumping: ['idle', 'jump', 'jump', 'jump', 'idle'],
	failed: ['fail', 'fail', 'fail', 'fail', 'fail', 'fail', 'fail', 'fail'],
	waiting: ['wait', 'wait', 'wait', 'wait', 'wait', 'wait'],
	running: ['busy', 'busy', 'busy', 'busy', 'busy', 'busy'],
	review: ['review', 'review', 'review', 'review', 'review', 'review']
}

export function poseUrl(key: string) {
	return POSE_SRC[key] || POSE_SRC.idle
}
