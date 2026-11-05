package net.icejz.app.data.local

import android.content.Context
import android.content.SharedPreferences
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import net.icejz.app.data.model.UserInfo

class AppCache(context: Context) {
    private val prefs: SharedPreferences =
        context.getSharedPreferences("icejz_cache", Context.MODE_PRIVATE)
    private val json = Json { ignoreUnknownKeys = true; encodeDefaults = true }

    fun setToken(token: String) = prefs.edit().putString(KEY_TOKEN, token).apply()
    fun getToken(): String? = prefs.getString(KEY_TOKEN, null)?.takeIf { it.isNotBlank() }
    fun removeToken() = prefs.edit().remove(KEY_TOKEN).apply()

    fun setUserInfo(user: UserInfo) {
        prefs.edit().putString(KEY_USER, json.encodeToString(user)).apply()
    }

    fun getUserInfo(): UserInfo? {
        val raw = prefs.getString(KEY_USER, null) ?: return null
        return runCatching { json.decodeFromString<UserInfo>(raw) }.getOrNull()
    }

    fun removeUserInfo() = prefs.edit().remove(KEY_USER).apply()

    fun clear() = prefs.edit().clear().apply()

    fun set(key: String, value: String) = prefs.edit().putString(key, value).apply()
    fun get(key: String): String? = prefs.getString(key, null)
    fun remove(key: String) = prefs.edit().remove(key).apply()

    fun isGuideDone(): Boolean = prefs.getString(KEY_GUIDE, null) == "1"
    fun markGuideDone() = prefs.edit().putString(KEY_GUIDE, "1").apply()
    fun clearGuideDone() = prefs.edit().remove(KEY_GUIDE).apply()

    companion object {
        private const val KEY_TOKEN = "token"
        private const val KEY_USER = "userInfo"
        private const val KEY_GUIDE = "icejz_guide_done"
    }
}
