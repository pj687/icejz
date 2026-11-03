package net.icejz.framework.security.crypto;

import cn.hutool.core.util.HexUtil;
import cn.hutool.crypto.SecureUtil;
import cn.hutool.crypto.SmUtil;
import cn.hutool.crypto.asymmetric.KeyType;
import cn.hutool.crypto.asymmetric.SM2;
import org.bouncycastle.jcajce.provider.asymmetric.ec.BCECPrivateKey;
import org.bouncycastle.jcajce.provider.asymmetric.ec.BCECPublicKey;
import org.bouncycastle.util.encoders.Hex;

import java.security.KeyPair;
import java.security.PrivateKey;
import java.security.PublicKey;

/**
 * 国密SM2加密算法
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
public class Sm2Util {
    /**
     * 公钥
     */
    private final static String PUBLIC_KEY = "3059301306072a8648ce3d020106082a811ccf5501822d0342000417b623de43a93a94bf272b4a19cfb796c1acce8a65bc818357ccf9022ffa4ac35748eb5a502a435ec93b45b0038b59d8df36542d38cc48a9a507fbb210a65019";
    /**
     * 私钥
     */
    private final static String PRIVATE_KEY = "308193020100301306072a8648ce3d020106082a811ccf5501822d04793077020101042014cc9f79077cb4e680e98f09a13901c2a3ca92810d08287e473a52e44a6cb300a00a06082a811ccf5501822da1440342000417b623de43a93a94bf272b4a19cfb796c1acce8a65bc818357ccf9022ffa4ac35748eb5a502a435ec93b45b0038b59d8df36542d38cc48a9a507fbb210a65019";

    private final static SM2 sm2;

    static {
        sm2 = SmUtil.sm2(PRIVATE_KEY, PUBLIC_KEY);
    }

    /**
     * 加密
     *
     * @param data 明文
     * @return 加密后的密文
     */
    public static String encrypt(String data) {
        return sm2.encryptBase64(data, KeyType.PublicKey);
    }

    /**
     * 解密
     *
     * @param data 加密后的密文（hex，通常以 04 开头；也兼容 Base64）
     * @return 解密后的明文
     */
    public static String decrypt(String data) {
        if (data == null || data.isBlank()) {
            throw new IllegalArgumentException("SM2密文为空");
        }
        String cipher = data.trim();
        try {
            return sm2.decryptStr(cipher, KeyType.PrivateKey);
        } catch (Exception first) {
            // 兼容前端漏拼 / 多拼 04 前缀
            try {
                if (cipher.startsWith("04") || cipher.startsWith("04".toUpperCase())) {
                    return sm2.decryptStr(cipher.substring(2), KeyType.PrivateKey);
                }
                return sm2.decryptStr("04" + cipher, KeyType.PrivateKey);
            } catch (Exception ignored) {
                throw first;
            }
        }
    }

    /**
     * 前端可用的 SM2 非压缩公钥（以 04 开头）
     */
    public static String getPublicKeyHex() {
        PublicKey publicKey = sm2.getPublicKey();
        if (publicKey instanceof BCECPublicKey bcecPublicKey) {
            return Hex.toHexString(bcecPublicKey.getQ().getEncoded(false));
        }
        return "0417b623de43a93a94bf272b4a19cfb796c1acce8a65bc818357ccf9022ffa4ac35748eb5a502a435ec93b45b0038b59d8df36542d38cc48a9a507fbb210a65019";
    }

    public static void main(String[] args) {
        KeyPair keyPair = SecureUtil.generateKeyPair("SM2");
        System.out.println("privateKey：" + HexUtil.encodeHexStr(keyPair.getPrivate().getEncoded()));
        System.out.println("publicKey：" + HexUtil.encodeHexStr(keyPair.getPublic().getEncoded()));

        PublicKey publicKey = keyPair.getPublic();
        if (publicKey instanceof BCECPublicKey) {
            // 获取65字节非压缩缩的十六进制公钥串(0x04)
            String publicKeyHex = Hex.toHexString(((BCECPublicKey) publicKey).getQ().getEncoded(false));
            System.out.println("SM2公钥：" + publicKeyHex);
        }
        PrivateKey privateKey = keyPair.getPrivate();
        if (privateKey instanceof BCECPrivateKey) {
            // 获取32字节十六进制私钥串
            String privateKeyHex = ((BCECPrivateKey) privateKey).getD().toString(16);
            System.out.println("SM2私钥：" + privateKeyHex);
        }

        String password = "admin";
        String sm2Password = Sm2Util.encrypt(password);
        System.out.println("sm2 加密:" + sm2Password);
        System.out.println("sm2 解密:" + Sm2Util.decrypt(sm2Password));


        System.out.println("sm3 解密:" + SmUtil.sm3("admin"));
    }
}
