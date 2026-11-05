<?php

namespace Icejz\Controllers\Sys;

use Icejz\Services\AuthService;
use Icejz\Services\CaptchaService;
use Icejz\Services\TokenService;
use Icejz\Support\Result;
use Icejz\Support\Request;
use Icejz\Support\SmCrypto;

final class AuthController
{
    public function captcha(Request $request): array
    {
        $channel = (string) $request->query('channel', 'pc');
        return Result::ok((new CaptchaService())->generate($channel));
    }

    public function captchaEnabled(): array
    {
        return Result::ok((new CaptchaService())->isEnabled());
    }

    public function captchaCheck(Request $request): array
    {
        $body = $request->json();
        $ok = (new CaptchaService())->check(
            isset($body['key']) ? (string) $body['key'] : null,
            isset($body['captcha']) ? (string) $body['captcha'] : null
        );
        return Result::ok($ok);
    }

    public function publicKey(): array
    {
        return Result::ok(SmCrypto::publicKeyHex());
    }

    public function login(Request $request): array
    {
        $token = (new AuthService())->loginByAccount($request->json(), $request);
        return Result::ok($token);
    }

    public function sendCode(Request $request): array
    {
        $result = (new AuthService())->sendCode($request->json());
        if ($result === true) {
            return Result::ok();
        }
        return Result::ok($result);
    }

    public function mobile(Request $request): array
    {
        $token = (new AuthService())->loginByMobile($request->json(), $request);
        return Result::ok($token);
    }

    public function token(Request $request): array
    {
        $refresh = (string) ($request->query('refreshToken') ?? $request->input('refreshToken', ''));
        return Result::ok(TokenService::refresh($refresh));
    }

    public function logout(Request $request): array
    {
        TokenService::logout($request->bearerToken());
        return Result::ok();
    }

    public function completeProfile(Request $request): array
    {
        // Client expects this; boot missing — accept and no-op / soft update.
        return Result::ok('ok');
    }

    public function third(): array
    {
        return Result::error('第三方登录暂未开通');
    }
}
