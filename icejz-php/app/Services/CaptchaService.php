<?php

namespace Icejz\Services;

use Icejz\Support\RedisClient;

final class CaptchaService
{
    private const TTL = 300;

    public function isEnabled(): bool
    {
        $row = \Icejz\Support\Database::fetch(
            'SELECT enabled FROM sys_captcha_config ORDER BY id ASC LIMIT 1'
        );
        if ($row === null) {
            return true;
        }
        return (int) $row['enabled'] === 1;
    }

    /** @return array<string,mixed> */
    public function generate(string $channel = 'pc'): array
    {
        if (!$this->isEnabled()) {
            return [
                'key' => '',
                'image' => null,
                'type' => 'none',
                'mode' => 'none',
                'tip' => '',
                'enabled' => false,
            ];
        }

        $code = (string) random_int(1000, 9999);
        $key = uuid32();
        RedisClient::set('sys:captcha:' . $key, 'number::' . $code, self::TTL);

        return [
            'key' => $key,
            'image' => $this->imageBase64($code),
            'type' => 'number',
            'mode' => 'input',
            'tip' => '请输入验证码',
            'enabled' => true,
        ];
    }

    public function validate(?string $key, ?string $captcha, bool $required = true): bool
    {
        if (!$this->isEnabled()) {
            return true;
        }
        if (!$required && ($key === null || $key === '') && ($captcha === null || $captcha === '')) {
            return true;
        }
        if ($key === null || $key === '' || $captcha === null || $captcha === '') {
            return false;
        }
        $redisKey = 'sys:captcha:' . $key;
        $stored = RedisClient::get($redisKey);
        RedisClient::del($redisKey);
        if ($stored === null) {
            return false;
        }
        $payload = $stored;
        if (str_contains($stored, '::')) {
            [, $payload] = explode('::', $stored, 2);
        }
        return strcasecmp(trim($payload), trim($captcha)) === 0;
    }

    public function check(?string $key, ?string $captcha): bool
    {
        if ($key === null || $captcha === null || $key === '' || $captcha === '') {
            return false;
        }
        $stored = RedisClient::get('sys:captcha:' . $key);
        if ($stored === null) {
            return false;
        }
        $payload = $stored;
        if (str_contains($stored, '::')) {
            [, $payload] = explode('::', $stored, 2);
        }
        return strcasecmp(trim($payload), trim($captcha)) === 0;
    }

    private function imageBase64(string $code): string
    {
        $w = 120;
        $h = 40;
        $im = imagecreatetruecolor($w, $h);
        $bg = imagecolorallocate($im, 245, 247, 250);
        $fg = imagecolorallocate($im, 30, 64, 120);
        imagefilledrectangle($im, 0, 0, $w, $h, $bg);
        for ($i = 0; $i < 6; $i++) {
            $line = imagecolorallocate($im, random_int(160, 220), random_int(160, 220), random_int(160, 220));
            imageline($im, random_int(0, $w), random_int(0, $h), random_int(0, $w), random_int(0, $h), $line);
        }
        imagestring($im, 5, 28, 12, $code, $fg);
        ob_start();
        imagepng($im);
        $bin = ob_get_clean() ?: '';
        imagedestroy($im);
        return 'data:image/png;base64,' . base64_encode($bin);
    }
}
