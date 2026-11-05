<?php

namespace Icejz\Support;

use Rtgm\sm\RtSm2;
use Rtgm\sm\RtSm3;

/**
 * SM2/SM3 helpers aligned with icejz-boot Sm2Util / Sm3PasswordEncoder.
 */
final class SmCrypto
{
    public static function publicKeyHex(): string
    {
        return (string) config('security.sm2_public_key_hex');
    }

    public static function privateKeyHex(): string
    {
        return (string) config('security.sm2_private_key_hex');
    }

    public static function decrypt(string $cipher): string
    {
        $cipher = trim($cipher);
        if ($cipher === '') {
            throw new HttpException('SM2密文为空', 500);
        }

        $sm2 = new RtSm2('hex', true);
        $priv = self::privateKeyHex();
        $candidates = [];

        // Raw hex (sm-crypto / frontend)
        if (ctype_xdigit(str_replace(["\r", "\n", ' '], '', $cipher))) {
            $hex = strtolower(str_replace(["\r", "\n", ' '], '', $cipher));
            $candidates[] = ['hex', $hex];
            if (str_starts_with($hex, '04')) {
                $candidates[] = ['hex', substr($hex, 2)];
            } else {
                $candidates[] = ['hex', '04' . $hex];
            }
        }

        // Base64 (Hutool encryptBase64) — try as hex of raw bytes and ASN.1
        $bin = base64_decode($cipher, true);
        if ($bin !== false && $bin !== '') {
            $candidates[] = ['hex', bin2hex($bin)];
            $candidates[] = ['asn1', $bin];
            $candidates[] = ['asn1', $cipher];
        }

        $last = null;
        foreach ($candidates as [$mode, $payload]) {
            try {
                if ($mode === 'asn1') {
                    if (is_string($payload) && !ctype_xdigit($payload)) {
                        $asn1 = base64_decode($payload, true);
                        if ($asn1 === false) {
                            $asn1 = $payload;
                        }
                    } else {
                        $asn1 = hex2bin($payload);
                        if ($asn1 === false) {
                            $asn1 = $payload;
                        }
                    }
                    $plain = $sm2->doDecryptASN1($asn1, $priv, true);
                } else {
                    $plain = $sm2->doDecrypt($payload, $priv, true);
                }
                if (is_string($plain) && $plain !== '') {
                    return $plain;
                }
            } catch (\Throwable $e) {
                $last = $e;
            }
        }

        throw new HttpException('密码解密失败，请刷新页面后重试', 500, $last);
    }

    public static function sm3(string $raw): string
    {
        $sm3 = new RtSm3();
        return strtolower($sm3->digest($raw));
    }

    public static function passwordMatches(string $raw, string $encoded): bool
    {
        return hash_equals(strtolower($encoded), self::sm3($raw));
    }
}
