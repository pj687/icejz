package net.icejz.app

import org.bouncycastle.asn1.gm.GMNamedCurves
import org.bouncycastle.crypto.engines.SM2Engine
import org.bouncycastle.crypto.params.ECDomainParameters
import org.bouncycastle.crypto.params.ECPublicKeyParameters
import org.bouncycastle.crypto.params.ParametersWithRandom
import org.bouncycastle.jce.provider.BouncyCastleProvider
import org.bouncycastle.math.ec.ECPoint
import org.bouncycastle.util.encoders.Hex
import java.security.SecureRandom
import java.security.Security

/**
 * SM2 C1C3C2，输出带 04 前缀的 hex，与 uniapp / 管理端一致。
 */
object Sm2Util {
    const val DEFAULT_PUBLIC_KEY =
        "0417b623de43a93a94bf272b4a19cfb796c1acce8a65bc818357ccf9022ffa4ac35748eb5a502a435ec93b45b0038b59d8df36542d38cc48a9a507fbb210a65019"

    init {
        if (Security.getProvider(BouncyCastleProvider.PROVIDER_NAME) == null) {
            Security.addProvider(BouncyCastleProvider())
        }
    }

    fun encrypt(plain: String, publicKeyHex: String = DEFAULT_PUBLIC_KEY): String {
        require(plain.isNotEmpty()) { "待加密内容不能为空" }
        val key = normalizePublicKey(publicKeyHex)
        val x9 = GMNamedCurves.getByName("sm2p256v1")
        val domain = ECDomainParameters(x9.curve, x9.g, x9.n, x9.h)
        val point: ECPoint = x9.curve.decodePoint(Hex.decode(key))
        val pubKey = ECPublicKeyParameters(point, domain)
        val engine = SM2Engine(SM2Engine.Mode.C1C3C2)
        engine.init(true, ParametersWithRandom(pubKey, SecureRandom()))
        val bytes = plain.toByteArray(Charsets.UTF_8)
        val cipher = engine.processBlock(bytes, 0, bytes.size)
        val hex = Hex.toHexString(cipher).lowercase()
        return if (hex.startsWith("04")) hex else "04$hex"
    }

    private fun normalizePublicKey(key: String): String {
        val hex = key.trim().lowercase().removePrefix("0x")
        if (hex.isEmpty()) return DEFAULT_PUBLIC_KEY
        if (hex.startsWith("04") && hex.length >= 130) return hex
        if (hex.length == 128) return "04$hex"
        return DEFAULT_PUBLIC_KEY
    }
}
