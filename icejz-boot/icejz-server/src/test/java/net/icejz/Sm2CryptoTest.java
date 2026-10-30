package net.icejz;

import cn.hutool.core.util.HexUtil;
import cn.hutool.core.util.StrUtil;
import cn.hutool.crypto.SecureUtil;
import cn.hutool.crypto.SmUtil;
import cn.hutool.crypto.asymmetric.KeyType;
import cn.hutool.crypto.asymmetric.SM2;
import net.icejz.framework.security.crypto.Sm2Util;
import org.bouncycastle.jcajce.provider.asymmetric.ec.BCECPrivateKey;
import org.bouncycastle.jcajce.provider.asymmetric.ec.BCECPublicKey;
import org.bouncycastle.util.encoders.Hex;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.security.KeyPair;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.util.Scanner;

/**
 * SM2 密钥生成与加解密匹配测试。
 * <p>
 * 运行交互式匹配：在 IDE 中直接运行本类 {@link #main(String[])}，
 * 或执行 {@code mvn -pl icejz-server -Dtest=Sm2CryptoTest#interactiveMatchTest test}
 * （交互模式建议用 main）。
 */
public class Sm2CryptoTest {

    @Test
    @DisplayName("生成一对新的 SM2 公私钥并打印多种格式")
    void generateKeyPair() {
        KeyPair keyPair = SecureUtil.generateKeyPair("SM2");

        String privateEncoded = HexUtil.encodeHexStr(keyPair.getPrivate().getEncoded());
        String publicEncoded = HexUtil.encodeHexStr(keyPair.getPublic().getEncoded());

        System.out.println("========== 新生成的 SM2 密钥对 ==========");
        System.out.println("PKCS#8 私钥(hex)：" + privateEncoded);
        System.out.println("X.509  公钥(hex)：" + publicEncoded);

        PublicKey publicKey = keyPair.getPublic();
        if (publicKey instanceof BCECPublicKey bcecPublicKey) {
            // 65 字节非压缩公钥（0x04 开头），可给前端 sm-crypto 使用
            String publicKeyHex = Hex.toHexString(bcecPublicKey.getQ().getEncoded(false));
            System.out.println("SM2 公钥(非压缩, 前端可用)：" + publicKeyHex);
        }

        PrivateKey privateKey = keyPair.getPrivate();
        if (privateKey instanceof BCECPrivateKey bcecPrivateKey) {
            String privateKeyHex = bcecPrivateKey.getD().toString(16);
            System.out.println("SM2 私钥(D值)：" + privateKeyHex);
        }

        Assertions.assertNotNull(keyPair.getPrivate());
        Assertions.assertNotNull(keyPair.getPublic());
        Assertions.assertTrue(StrUtil.isNotBlank(privateEncoded));
        Assertions.assertTrue(StrUtil.isNotBlank(publicEncoded));
    }

    @Test
    @DisplayName("使用平台内置密钥对明文加解密匹配（登录同款 Sm2Util）")
    void encryptDecryptWithBuiltInKeys() {
        String plain = "123456";
        String cipher = Sm2Util.encrypt(plain);
        String decrypted = Sm2Util.decrypt(cipher);

        System.out.println("明文：" + plain);
        System.out.println("SM2 密文：" + cipher);
        System.out.println("解密结果：" + decrypted);
        System.out.println("SM3(明文)：" + SmUtil.sm3(plain));

        Assertions.assertEquals(plain, decrypted);
    }

    @Test
    @DisplayName("临时密钥对：加密后用私钥解密应能匹配")
    void encryptDecryptWithGeneratedKeys() {
        KeyPair keyPair = SecureUtil.generateKeyPair("SM2");
        SM2 sm2 = SmUtil.sm2(keyPair.getPrivate(), keyPair.getPublic());

        String plain = "icejz-login-test";
        String cipher = sm2.encryptBase64(plain, KeyType.PublicKey);
        String decrypted = sm2.decryptStr(cipher, KeyType.PrivateKey);

        System.out.println("临时密钥加解密：plain=" + plain + ", decrypt=" + decrypted);
        Assertions.assertEquals(plain, decrypted);
    }

    @Test
    @DisplayName("输入匹配：断言给定明文经 Sm2Util 加密后可还原")
    void matchInputSample() {
        // 可按需改成你要验证的口令
        assertMatch("123456");
        assertMatch("admin");
        assertMatch("hello-icejz");
    }

    private void assertMatch(String plain) {
        String cipher = Sm2Util.encrypt(plain);
        String decrypted = Sm2Util.decrypt(cipher);
        Assertions.assertEquals(plain, decrypted, "SM2 加解密不匹配：" + plain);
        System.out.println("[OK] 匹配成功 plain=" + plain + " sm3=" + SmUtil.sm3(plain));
    }

    /**
     * 交互式：生成密钥 / 输入明文做加解密匹配测试。
     */
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        System.out.println("===== ICEJZ SM2 工具 =====");
        System.out.println("1) 生成新的 SM2 公私钥");
        System.out.println("2) 使用平台内置密钥：输入明文 → 加密 → 解密 → 匹配");
        System.out.println("3) 使用平台内置密钥：只算 SM3（数据库密码摘要）");
        System.out.println("q) 退出");

        while (true) {
            System.out.print("\n请选择功能 [1/2/3/q]：");
            String op = StrUtil.trim(scanner.nextLine());
            if ("q".equalsIgnoreCase(op) || "exit".equalsIgnoreCase(op)) {
                System.out.println("已退出");
                break;
            }
            switch (op) {
                case "1" -> printGeneratedKeys();
                case "2" -> interactiveEncryptMatch(scanner);
                case "3" -> interactiveSm3(scanner);
                default -> System.out.println("无效选项，请重新输入");
            }
        }
    }

    private static void printGeneratedKeys() {
        KeyPair keyPair = SecureUtil.generateKeyPair("SM2");
        System.out.println("---------- 新密钥 ----------");
        System.out.println("PKCS#8 私钥(hex)：" + HexUtil.encodeHexStr(keyPair.getPrivate().getEncoded()));
        System.out.println("X.509  公钥(hex)：" + HexUtil.encodeHexStr(keyPair.getPublic().getEncoded()));

        if (keyPair.getPublic() instanceof BCECPublicKey publicKey) {
            System.out.println("SM2 公钥(非压缩)：" + Hex.toHexString(publicKey.getQ().getEncoded(false)));
        }
        if (keyPair.getPrivate() instanceof BCECPrivateKey privateKey) {
            System.out.println("SM2 私钥(D值)：" + privateKey.getD().toString(16));
        }
    }

    private static void interactiveEncryptMatch(Scanner scanner) {
        System.out.print("请输入要加密的明文（如 123456）：");
        String plain = scanner.nextLine();
        if (StrUtil.isBlank(plain)) {
            System.out.println("明文不能为空");
            return;
        }
        try {
            String cipher = Sm2Util.encrypt(plain);
            String decrypted = Sm2Util.decrypt(cipher);
            boolean matched = StrUtil.equals(plain, decrypted);
            System.out.println("密文：" + cipher);
            System.out.println("解密：" + decrypted);
            System.out.println("匹配：" + (matched ? "成功 ✓" : "失败 ✗"));
            System.out.println("SM3 ：" + SmUtil.sm3(plain));
        } catch (Exception e) {
            System.out.println("加解密失败：" + e.getMessage());
        }
    }

    private static void interactiveSm3(Scanner scanner) {
        System.out.print("请输入明文计算 SM3：");
        String plain = scanner.nextLine();
        if (StrUtil.isBlank(plain)) {
            System.out.println("明文不能为空");
            return;
        }
        System.out.println("SM3 = " + SmUtil.sm3(plain));
    }
}
