<?php

namespace Icejz\Services;

use Icejz\Support\Database;
use Icejz\Support\HttpException;
use Icejz\Support\RedisClient;
use Icejz\Support\Request;
use Icejz\Support\SmCrypto;

final class AuthService
{
    public function __construct(private CaptchaService $captcha = new CaptchaService())
    {
    }

    /** @param array<string,mixed> $login */
    public function loginByAccount(array $login, Request $request): array
    {
        $username = trim((string) ($login['username'] ?? ''));
        $passwordCipher = (string) ($login['password'] ?? '');
        $key = $login['key'] ?? null;
        $captcha = $login['captcha'] ?? null;

        if (!$this->captcha->validate(is_string($key) ? $key : null, is_string($captcha) ? $captcha : null)) {
            $this->saveLoginLog($username, 0, 1);
            throw new HttpException('验证码错误');
        }

        try {
            $password = SmCrypto::decrypt($passwordCipher);
        } catch (HttpException $e) {
            throw $e;
        } catch (\Throwable) {
            throw new HttpException('密码解密失败，请刷新页面后重试');
        }

        $user = Database::fetch(
            'SELECT * FROM sys_user WHERE username = ? AND deleted = 0 LIMIT 1',
            [$username]
        );
        if ($user === null || !SmCrypto::passwordMatches($password, (string) $user['password'])) {
            $this->saveLoginLog($username, 0, 0);
            throw new HttpException('用户名或密码错误');
        }
        if ((int) $user['status'] === 0) {
            $this->saveLoginLog($username, 0, 0);
            throw new HttpException($this->banTip($user));
        }

        $this->saveLoginLog($username, 1, 0);
        return TokenService::createToken((int) $user['id'], $request);
    }

    /** @param array<string,mixed> $login */
    public function loginByMobile(array $login, Request $request): array
    {
        $mobile = trim((string) ($login['mobile'] ?? ''));
        $code = trim((string) ($login['code'] ?? ''));
        $cached = RedisClient::get('sys:sms:code' . $mobile);
        if ($cached === null || $cached !== $code) {
            throw new HttpException('手机号或验证码错误');
        }
        RedisClient::del('sys:sms:code' . $mobile);

        $user = Database::fetch(
            'SELECT * FROM sys_user WHERE mobile = ? AND deleted = 0 LIMIT 1',
            [$mobile]
        );
        if ($user === null) {
            throw new HttpException('手机号或验证码错误');
        }
        if ((int) $user['status'] === 0) {
            throw new HttpException($this->banTip($user));
        }
        return TokenService::createToken((int) $user['id'], $request);
    }

    /** @param array<string,mixed> $send */
    public function sendCode(array $send): string|true
    {
        $mobile = trim((string) ($send['mobile'] ?? ''));
        $key = $send['key'] ?? null;
        $captcha = $send['captcha'] ?? null;
        if (!$this->captcha->validate(is_string($key) ? $key : null, is_string($captcha) ? $captcha : null)) {
            throw new HttpException('验证码错误');
        }

        $user = Database::fetch(
            'SELECT id FROM sys_user WHERE mobile = ? AND deleted = 0 LIMIT 1',
            [$mobile]
        );
        if ($user === null) {
            throw new HttpException('手机号未注册');
        }

        $intervalKey = 'sys:sms:interval:' . $mobile;
        if (RedisClient::exists($intervalKey)) {
            throw new HttpException('发送过于频繁，请稍后再试');
        }
        $hourKey = 'sys:sms:hour:' . $mobile;
        $hourCount = (int) (RedisClient::get($hourKey) ?? '0');
        if ($hourCount >= 10) {
            throw new HttpException('发送次数已达上限');
        }

        $code = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);
        RedisClient::set('sys:sms:code' . $mobile, $code, 600);
        RedisClient::set($intervalKey, '1', 60);
        if ($hourCount === 0) {
            RedisClient::set($hourKey, '1', 3600);
        } else {
            RedisClient::incr($hourKey);
        }

        if (config('app.sms_mock')) {
            return $code;
        }
        return true;
    }

    /** @param array<string,mixed> $user */
    private function banTip(array $user): string
    {
        $reason = trim((string) ($user['ban_reason'] ?? ''));
        if ($reason !== '') {
            return '抱歉，您的账号已被封禁：' . $reason;
        }
        return '抱歉，您的账号已被封禁，暂时无法登录。如有疑问，请联系系统管理员。';
    }

    private function saveLoginLog(string $username, int $status, int $operation): void
    {
        try {
            Database::execute(
                'INSERT INTO sys_log_login (username, status, operation, ip, user_agent, create_time)
                 VALUES (?, ?, ?, ?, ?, ?)',
                [$username, $status, $operation, $_SERVER['REMOTE_ADDR'] ?? '', $_SERVER['HTTP_USER_AGENT'] ?? '', now()]
            );
        } catch (\Throwable) {
            // table schema may differ; ignore logging failures
        }
    }
}
