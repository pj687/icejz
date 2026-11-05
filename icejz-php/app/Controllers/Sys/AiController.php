<?php

namespace Icejz\Controllers\Sys;

use Icejz\Services\AiService;
use Icejz\Support\Request;
use Icejz\Support\Result;

final class AiController
{
    public function robotInfo(): array
    {
        return Result::ok((new AiService())->robotInfo());
    }

    public function chat(Request $request): array
    {
        return Result::ok((new AiService())->chat($request->json()));
    }

    public function sessionList(): array
    {
        return Result::ok((new AiService())->sessionList());
    }

    public function sessionMessages(Request $request): array
    {
        return Result::ok((new AiService())->sessionMessages((int) $request->param('id')));
    }

    public function createSession(Request $request): array
    {
        return Result::ok((new AiService())->createSession($request->json()));
    }

    public function deleteSessions(Request $request): array
    {
        $ids = $request->json();
        if (!is_array($ids)) {
            $ids = [];
        }
        (new AiService())->deleteSessions($ids);
        return Result::ok();
    }
}
