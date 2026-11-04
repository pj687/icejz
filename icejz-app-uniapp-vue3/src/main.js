import {
	createSSRApp
} from "vue";
import App from "./App.vue";
import i18n from "./locale/index.js";
import { installIceToast, showIceToast } from "./utils/iceToast.js";

export function createApp() {
	const app = createSSRApp(App);

	app.use(i18n);
	installIceToast();
	app.config.globalProperties.$iceToast = showIceToast;

	// Vue 3 全局配置
	app.config.globalProperties.$adpid = "1111111111";
	app.config.globalProperties.$background = ["#8D75EF", "#4A6DFC"];

	return {
		app,
	};
}
