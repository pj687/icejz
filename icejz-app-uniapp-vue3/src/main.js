import {
	createSSRApp
} from "vue";
import App from "./App.vue";

export function createApp() {
	const app = createSSRApp(App);
	
	// Vue 3 全局配置
	app.config.globalProperties.$adpid = "1111111111";
	app.config.globalProperties.$background = ["#8D75EF", "#4A6DFC"];
	
	return {
		app,
	};
}
