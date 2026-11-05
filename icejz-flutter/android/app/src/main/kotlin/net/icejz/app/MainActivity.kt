package net.icejz.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "net.icejz.app/sm2"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "encrypt" -> {
                    try {
                        val plain = call.argument<String>("plain")
                            ?: throw IllegalArgumentException("plain 不能为空")
                        val publicKey = call.argument<String>("publicKey")
                        val cipher = if (publicKey.isNullOrBlank()) {
                            Sm2Util.encrypt(plain)
                        } else {
                            Sm2Util.encrypt(plain, publicKey)
                        }
                        result.success(cipher)
                    } catch (e: Exception) {
                        result.error("SM2_ERROR", e.message ?: "SM2 加密失败", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
