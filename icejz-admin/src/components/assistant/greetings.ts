/** 小冰打招呼文案 */

export type GreetKind = 'hello' | 'greet' | 'tip' | 'idle' | 'bye'

const recentMap = new Map<string, string[]>()
const RECENT_LIMIT = 8

const pickFresh = <T>(key: string, list: T[]): T => {
	const recent = recentMap.get(key) || []
	const pool = list.filter(item => !recent.includes(String(item)))
	const chosen = (pool.length ? pool : list)[Math.floor(Math.random() * (pool.length ? pool.length : list.length))]
	const next = [...recent, String(chosen)].slice(-RECENT_LIMIT)
	recentMap.set(key, next)
	return chosen
}

const periodLabel = (hour = new Date().getHours()) => {
	if (hour < 5) return '深夜'
	if (hour < 9) return '早上'
	if (hour < 12) return '上午'
	if (hour < 14) return '中午'
	if (hour < 18) return '下午'
	if (hour < 22) return '晚上'
	return '夜深了'
}

const nameOf = (userName?: string, fallback = '管理员') => (userName || '').trim() || fallback

export const getShortHello = (userName?: string) => {
	const name = nameOf(userName)
	const hour = new Date().getHours()
	if (hour < 5) return pickFresh('short', [`夜深了，${name}`, `还没睡吗，${name}`, `深夜好，${name}`, `${name}，夜里也好呀`])
	if (hour < 9) return pickFresh('short', [`早上好，${name}`, `早啊，${name}`, `新的一天，${name}`, `早安呀，${name}`])
	if (hour < 12) return pickFresh('short', [`上午好，${name}`, `嗨，${name}`, `上午好呀，${name}`, `${name}，上午好～`])
	if (hour < 14) return pickFresh('short', [`中午好，${name}`, `午安，${name}`, `中午好呀，${name}`, `${name}，午安～`])
	if (hour < 18) return pickFresh('short', [`下午好，${name}`, `下午嗨，${name}`, `下午好呀，${name}`, `${name}，下午好～`])
	if (hour < 22) return pickFresh('short', [`晚上好，${name}`, `晚好，${name}`, `晚上好呀，${name}`, `${name}，晚上好～`])
	return pickFresh('short', [`夜深了，${name}`, `深夜好，${name}`, `早点休息，${name}`, `${name}，夜里慢一点`])
}

/** 时段问候：开机 / 回显用 */
export const getTimeHello = (userName?: string) => {
	const name = nameOf(userName)
	const hour = new Date().getHours()
	const period = periodLabel(hour)

	const lines: string[] = []
	if (hour < 5) {
		lines.push(
			`夜深了，${name}还在忙吗？小冰陪你～`,
			`这么晚还在线，注意休息哦，${name}`,
			`${name}，深夜加班也要喝口水呀`,
			`嘿，${name}，月亮都困了，你还精神满满～`,
			`深夜模式启动！${name}需要小冰帮忙吗？`,
			`这么晚了还在冲刺吗，${name}？我在呢`,
			`${name}，星空值班员小冰报道～`,
			`夜猫子 ${name} 你好，我醒着的`
		)
	} else if (hour < 9) {
		lines.push(
			`早啊，${name}！新的一天从 ICEJZ 开始～`,
			`${period}好，${name}，今天也一起加油！`,
			`早上好呀 ${name}，洗把脸，我们开工～`,
			`${name}，晨光正好，小冰已上线`,
			`嗨，${name}！今天想先做哪件事？`,
			`早起的 ${name} 有小冰陪伴～`,
			`新的一天，${name} 辛苦啦，有事叫我`,
			`早安！${name}，咖啡续上了吗？`,
			`${name}，清晨的第一句：你好呀～`,
			`叮！${name} 的早间小冰已送达`
		)
	} else if (hour < 12) {
		lines.push(
			`${period}好，${name}，需要小冰帮忙吗？`,
			`嗨，${name}，工作顺利吗？点我聊聊～`,
			`${name}，上午进度怎么样，我来搭把手`,
			`上午好～${name}，菜单、权限、代码生成都行`,
			`看到你了，${name}！小冰随时待命`,
			`${name}，卡住了就问我，别憋着哦`,
			`嗨嗨，${name}，今天状态不错吧？`,
			`上午好呀，${name}，一起把事情推进一点`,
			`${name}，上午好！能量条给你加满～`,
			`滴滴，${name}，上午场小冰已就位`
		)
	} else if (hour < 14) {
		lines.push(
			`中午好，${name}，记得吃饭呀～`,
			`${name}，午间休息一下，有事再叫小冰`,
			`午安！${name}，吃饱了才有力气敲代码`,
			`${name}，午饭时间到，别只啃面包哦`,
			`中午好呀～${name}，小憩五分钟也好`,
			`${name}，午后继续冲之前，先和我打个招呼`,
			`午饭吃了吗，${name}？吃完再战！`,
			`中场休息～${name}，需要我查点什么吗？`,
			`午安安，${name}，小冰帮你看会儿盘～`,
			`${name}，太阳当顶，先补充能量吧`
		)
	} else if (hour < 18) {
		lines.push(
			`${period}好，${name}，进度还顺利吗？`,
			`嗨 ${name}，小冰随时待命～`,
			`下午好，${name}，要不要让我帮你开工作台？`,
			`${name}，下午茶时间，也欢迎来找我聊聊`,
			`下午好呀～${name}，卡点了就喊一声`,
			`${name}，傍晚前再推进一截，我帮你想办法`,
			`嗨嗨，${name}，系统配置、用户权限尽管问`,
			`下午好！${name}，小冰已续航完毕`,
			`${name}，午后阳光正好，我们继续～`,
			`叮咚，${name} 的下午搭子上线啦`
		)
	} else if (hour < 22) {
		lines.push(
			`晚上好，${name}，今天辛苦啦～`,
			`${name}，晚上还有事找小冰吗？`,
			`晚好呀，${name}，收个尾还是冲刺一波？`,
			`${name}，夜里效率高的话，我陪你～`,
			`晚上好！${name}，灯光亮起，小冰也亮起`,
			`${name}，一天将尽，需要我帮忙复盘吗？`,
			`嗨，${name}，晚饭吃了吗？吃完再敲也不迟`,
			`晚上好～${name}，有问题尽管砸过来`,
			`${name}，夜色温柔，小冰也温柔在线`,
			`晚间问候送达：你好呀，${name}`
		)
	} else {
		lines.push(
			`夜深了，${name}，早点休息哦`,
			`${name}，小冰先陪你收个尾～`,
			`这么晚还在线，${name}真拼，注意身体`,
			`${name}，收工前要不要再问我一句？`,
			`深夜好，${name}，星星和我都在看着你～`,
			`${name}，明天还要继续，今晚别太晚啦`,
			`深夜电台：${name}，我还醒着哦`,
			`${name}，困了就歇，我帮你记着待办`
		)
	}
	return pickFresh('time', lines)
}

/** 点「招呼」专用：更活泼、更多样 */
export const getGreetHello = (userName?: string) => {
	const name = nameOf(userName, '你')
	const period = periodLabel()
	const lines = [
		`${name}好呀～小冰向你挥挥手！`,
		`嗨嗨，${name}！今天也请多指教～`,
		`收到问候！${name}，小冰在这儿呢`,
		`${period}好，${name}，给你比个心（空气版）`,
		`哇，${name}主动打招呼，小冰开心！`,
		`你好你好，${name}，我是 ICEJZ 小冰`,
		`${name}，挥手握手（虚拟的），合作愉快！`,
		`叮～问候已送达，${name}请查收`,
		`嗨，${name}！需要我帮你开工作台吗？`,
		`${name}，小冰报到：状态良好，随时待命`,
		`嘿嘿，被发现了～${name}有什么吩咐？`,
		`你好呀 ${name}，风里雨里，小冰等你`,
		`${period}安，${name}！来，击个掌～`,
		`小冰向 ${name} 郑重问好！（然后偷笑）`,
		`${name}，今天想先聊功能，还是先吐槽需求？`,
		`哈喽 ${name}！权限、菜单、生成器，尽管问`,
		`遇见 ${name} 的概率：100%。你好～`,
		`${name}好！小冰电量充足，可以开始聊天啦`,
		`挥手三次：嗨、嗨、嗨～${name}看到了吗？`,
		`${name}，正式问候一下：很高兴为你服务`,
		`呀，${name}点招呼了！我立刻精神抖擞`,
		`早上好中午好晚上好——总之，${name}好！`,
		`${name}，小冰用挥手翻译：Nice to see you`,
		`滴滴，${name}的专属问候通道已接通`,
		`${period}好呀～${name}，要不要顺便问我个问题？`,
		`小冰登场！面向 ${name}，微笑，挥手，完成`,
		`${name}，你好呀～今天也一起把事情做漂亮`,
		`哈喽哈喽，${name}！我把耳朵竖起来听你说`,
		`问候加载完毕：Hi ${name}，我是小冰`,
		`${name}一打招呼，我就知道今天会顺利一点点`
	]
	return pickFresh('greet', lines)
}

export const getIdleTips = () =>
	pickFresh('idle', [
		'点我可以打开对话哦～',
		'想生成业务代码？问我就行',
		'权限、菜单、配置…我都能聊',
		'拖我可以挪到你顺手的位置',
		'有问题尽管问，我是小冰',
		'试试问我：怎么打开工作台？',
		'今天的任务安排好了吗？',
		'需要代码生成器入口吗？',
		'用户管理、角色授权，问我就懂',
		'本地模型和线上模型，都能接好哦',
		'双击我也行，马上打开对话窗',
		'系统配置里有短信、邮件，迷路了喊我',
		'卡住了？描述一下现象，我帮你理思路',
		'工作台入口在这儿，需要我带路吗？',
		'今天也要元气满满呀～',
		'嘿，别忘了保存你正在改的配置',
		'想快速找菜单？告诉我关键词',
		'日志、附件、参数…平台功能我熟悉',
		'休息一下眼睛，再继续也不迟',
		'有新想法可以先跟我说一声～',
		'调用失败了？先检查模型是否启用、API Key 是否有效',
		'若提示 401 / Authentication Fails，多半是 Key 问题，不是提示词',
		'你好呀～我是 ICEJZ 的小冰',
		'点「招呼」还能再听我喊一声',
		'晚上效率高的话，记得喝杯水',
		'代码生成、权限对齐，我都能参谋',
		'单击变身，双击对话——首页那只我也懂',
		'想听我打招呼？点一下「招呼」按钮',
		'我可以陪你过一遍角色授权流程',
		'需求变来变去时，先让我帮你理清单',
		'嘿，别一个人闷头试，问我更快'
	])

export const getClickHello = (userName?: string) => {
	const name = nameOf(userName, '你')
	return pickFresh('click', [
		`收到！${name}，我们开始聊吧～`,
		`来啦来啦，${name}有什么事？`,
		`小冰在听，请讲～`,
		`好呀，我准备好啦！`,
		`呼叫成功！${name}请指示～`,
		`我在！${name}想先问哪一块？`,
		`嘀～小冰已接通`,
		`嗯嗯，我听着呢，${name}`,
		`来了！今天也请多指教～`,
		`收到指令，正在打开对话…`,
		`嗨 ${name}，说吧，我记笔记了`,
		`好的好的，小冰上线服务中`,
		`${name}点到我了，马上为你服务`,
		`在的在的，${name}请讲重点～`,
		`连接建立：小冰 ↔ ${name}`,
		`我来啦！问题可以一次丢过来`
	])
}

export const getDashboardLead = (userName?: string) => {
	const name = nameOf(userName)
	const period = periodLabel()
	return pickFresh('dash', [
		`${period}好，${name}！我是助手小冰，可以帮你打开工作台、查功能，或直接在下方提问。`,
		`嗨，${name}，今天想先做哪件事？工作台、用户管理还是代码生成都可以找我。`,
		`${name}，小冰已就位～拖我、点我，或直接发问都行。`,
		`欢迎回来，${name}！平台总览在眼前，需要向导的话喊一声小冰。`,
		`${name}，${period}状态怎么样？进度、权限、生成器，我都能搭把手。`,
		`你好呀 ${name}，我是 ICEJZ 小冰。点「呼叫小冰」就能开始聊天。`,
		`${period}好～${name}，先看看本周计划，还是直接丢个问题给我？`,
		`${name}，有我在，系统配置和研发协作会轻松一点。试试看吧！`,
		`嗨嗨，${name}！今天也请多多关照，小冰随时待命。`,
		`${name}，从这里进入工作台，或问我「怎么生成业务代码？」`,
		`${name}，首页这只小冰：单击变身，双击打开对话哦`,
		`欢迎回家，${name}。今日运势：提问有求必应（大概）`
	])
}

export const buildGreeting = (kind: GreetKind, userName?: string) => {
	if (kind === 'greet') return getGreetHello(userName)
	if (kind === 'hello') return getTimeHello(userName)
	if (kind === 'tip' || kind === 'idle') return getIdleTips()
	return getClickHello(userName)
}