package net.icejz.app

import android.app.Application
import net.icejz.app.data.local.AppCache
import net.icejz.app.data.remote.ApiClient

class IcejzApp : Application() {
    lateinit var cache: AppCache
        private set

    override fun onCreate() {
        super.onCreate()
        instance = this
        cache = AppCache(this)
        ApiClient.init(cache)
    }

    companion object {
        lateinit var instance: IcejzApp
            private set
    }
}
