<?php

namespace Icejz\Controllers\Sys;

use Icejz\Middleware\AuthMiddleware;
use Icejz\Services\TokenService;
use Icejz\Services\UserService;
use Icejz\Support\Request;
use Icejz\Support\Result;

final class UserController
{
    public function info(): array
    {
        return Result::ok((new UserService())->info());
    }

    public function updateInfo(Request $request): array
    {
        (new UserService())->updateInfo($request->json());
        return Result::ok();
    }

    public function password(Request $request): array
    {
        (new UserService())->updatePassword($request->json());
        return Result::ok();
    }

    public function device(Request $request): array
    {
        $token = (string) (AuthMiddleware::user()['accessToken'] ?? '');
        return Result::ok(TokenService::deviceList(AuthMiddleware::id(), $token));
    }

    public function kickDevice(Request $request): array
    {
        TokenService::kickDevice(AuthMiddleware::id(), (string) $request->param('accessToken'));
        return Result::ok();
    }

    public function loginSecurity(): array
    {
        return Result::ok((new UserService())->loginSecurity());
    }

    public function saveLoginSecurity(Request $request): array
    {
        (new UserService())->saveLoginSecurity($request->json());
        return Result::ok();
    }

    public function page(Request $request): array
    {
        $page = max(1, (int) $request->query('page', 1));
        $limit = max(1, min(100, (int) $request->query('limit', 10)));
        $data = (new UserService())->page(
            $page,
            $limit,
            $request->query('username') ? (string) $request->query('username') : null,
            $request->query('mobile') ? (string) $request->query('mobile') : null
        );
        return Result::ok($data);
    }

    public function memberSummary(): array
    {
        return Result::ok([
            'memberCount' => 0,
            'todayActive' => 0,
            'orderCount' => 0,
        ]);
    }
}
