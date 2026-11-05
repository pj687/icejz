package net.icejz.app.data.remote

import kotlinx.serialization.json.Json
import net.icejz.app.BuildConfig
import net.icejz.app.data.local.AppCache
import okhttp3.Interceptor
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import com.jakewharton.retrofit2.converter.kotlinx.serialization.asConverterFactory
import java.util.concurrent.TimeUnit

object ApiClient {
    private lateinit var cache: AppCache
    private var onUnauthorized: (() -> Unit)? = null

    val json = Json {
        ignoreUnknownKeys = true
        encodeDefaults = true
        isLenient = true
        coerceInputValues = true
    }

    lateinit var api: ApiService
        private set

    fun init(appCache: AppCache) {
        cache = appCache
        val authInterceptor = Interceptor { chain ->
            val builder = chain.request().newBuilder()
            cache.getToken()?.let { builder.header("Authorization", it) }
            chain.proceed(builder.build())
        }
        val logging = HttpLoggingInterceptor().apply {
            level = if (BuildConfig.DEBUG) HttpLoggingInterceptor.Level.BODY
            else HttpLoggingInterceptor.Level.NONE
        }
        val client = OkHttpClient.Builder()
            .connectTimeout(15, TimeUnit.SECONDS)
            .readTimeout(60, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)
            .addInterceptor(authInterceptor)
            .addInterceptor(logging)
            .build()

        api = Retrofit.Builder()
            .baseUrl(ensureSlash(BuildConfig.BASE_URL))
            .client(client)
            .addConverterFactory(json.asConverterFactory("application/json".toMediaType()))
            .build()
            .create(ApiService::class.java)
    }

    fun setUnauthorizedHandler(handler: () -> Unit) {
        onUnauthorized = handler
    }

    fun notifyUnauthorized() {
        cache.removeToken()
        onUnauthorized?.invoke()
    }

    private fun ensureSlash(url: String): String = if (url.endsWith("/")) url else "$url/"
}

suspend fun <T> apiCall(block: suspend () -> net.icejz.app.data.model.ApiResult<T>): T {
    val result = block()
    if (result.code == 0) {
        @Suppress("UNCHECKED_CAST")
        return result.data as T
    }
    if (result.code == 401) {
        ApiClient.notifyUnauthorized()
        throw ApiException(401, result.msg ?: "未登录或登录已失效", unauthorized = true)
    }
    throw ApiException(result.code, result.msg ?: "请求失败")
}

suspend fun <T> apiCallNullable(block: suspend () -> net.icejz.app.data.model.ApiResult<T>): T? {
    val result = block()
    if (result.code == 0) return result.data
    if (result.code == 401) {
        ApiClient.notifyUnauthorized()
        throw ApiException(401, result.msg ?: "未登录或登录已失效", unauthorized = true)
    }
    throw ApiException(result.code, result.msg ?: "请求失败")
}
