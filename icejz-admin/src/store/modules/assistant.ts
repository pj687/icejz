import { defineStore } from 'pinia'
import { ref } from 'vue'

const POS_KEY = 'icejz-assistant-fab-pos'
const DOCK_HIDDEN_KEY = 'icejz-assistant-fab-dock-hidden'

type FabPos = { x: number; y: number }

const loadPos = (): FabPos | null => {
	try {
		const raw = localStorage.getItem(POS_KEY)
		if (!raw) return null
		const parsed = JSON.parse(raw)
		if (typeof parsed?.x === 'number' && typeof parsed?.y === 'number') {
			return parsed
		}
	} catch {
		// ignore
	}
	return null
}

const loadDockHidden = () => {
	try {
		return localStorage.getItem(DOCK_HIDDEN_KEY) === '1'
	} catch {
		return false
	}
}

export const useAssistantStore = defineStore('assistant', () => {
	const open = ref(false)
	const draft = ref('')
	const robotName = ref('小冰')
	const welcome = ref('你好，我是 ICEJZ 小冰，有什么可以帮你的？')
	const fabPos = ref<FabPos | null>(loadPos())
	const dockHidden = ref(loadDockHidden())

	const openPanel = (text?: string) => {
		if (text) {
			draft.value = text
		}
		open.value = true
	}

	const closePanel = () => {
		open.value = false
	}

	const togglePanel = () => {
		open.value = !open.value
	}

	const setRobotProfile = (profile: { name?: string; welcome?: string }) => {
		if (profile.name) robotName.value = profile.name
		if (profile.welcome) welcome.value = profile.welcome
	}

	const setFabPos = (pos: FabPos) => {
		fabPos.value = pos
		localStorage.setItem(POS_KEY, JSON.stringify(pos))
	}

	const setDockHidden = (hidden: boolean) => {
		dockHidden.value = hidden
		localStorage.setItem(DOCK_HIDDEN_KEY, hidden ? '1' : '0')
	}

	const toggleDockHidden = () => {
		setDockHidden(!dockHidden.value)
	}

	return {
		open,
		draft,
		robotName,
		welcome,
		fabPos,
		dockHidden,
		openPanel,
		closePanel,
		togglePanel,
		setRobotProfile,
		setFabPos,
		setDockHidden,
		toggleDockHidden
	}
})
