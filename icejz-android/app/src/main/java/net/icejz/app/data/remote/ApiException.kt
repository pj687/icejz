package net.icejz.app.data.remote

class ApiException(
    val code: Int,
    override val message: String,
    val unauthorized: Boolean = false
) : Exception(message)
