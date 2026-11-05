<?php

namespace Icejz\Middleware;

use Icejz\Services\TokenService;
use Icejz\Support\HttpException;
use Icejz\Support\Request;

final class AuthMiddleware
{
    /** @var array<string,mixed>|null */
    public static ?array $user = null;

    public static function handle(Request $request): void
    {
        $token = $request->bearerToken();
        if ($token === null || $token === '') {
            throw new HttpException('还未授权，不能访问', 401);
        }
        $user = TokenService::userByAccessToken($token);
        if ($user === null) {
            throw new HttpException('还未授权，不能访问', 401);
        }
        if ((int) ($user['status'] ?? 1) === 0) {
            throw new HttpException('抱歉，您的账号已被封禁，暂时无法登录。如有疑问，请联系系统管理员。', 401);
        }
        self::$user = $user;
        self::$user['accessToken'] = $token;
    }

    public static function id(): int
    {
        return (int) (self::$user['id'] ?? 0);
    }

    /** @return array<string,mixed> */
    public static function user(): array
    {
        if (self::$user === null) {
            throw new HttpException('还未授权，不能访问', 401);
        }
        return self::$user;
    }
}
