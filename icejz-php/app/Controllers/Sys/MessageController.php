<?php

namespace Icejz\Controllers\Sys;

use Icejz\Services\MessageService;
use Icejz\Support\Request;
use Icejz\Support\Result;

final class MessageController
{
    public function myPage(Request $request): array
    {
        $page = max(1, (int) $request->query('page', 1));
        $limit = max(1, min(100, (int) $request->query('limit', 10)));
        $title = $request->query('title') ? (string) $request->query('title') : null;
        $readStatus = $request->query('readStatus');
        $rs = $readStatus === null || $readStatus === '' ? null : (int) $readStatus;
        return Result::ok((new MessageService())->myPage($page, $limit, $title, $rs));
    }

    public function unreadCount(): array
    {
        return Result::ok((new MessageService())->unreadCount());
    }

    public function latest(Request $request): array
    {
        $limit = max(1, min(50, (int) $request->query('limit', 5)));
        return Result::ok((new MessageService())->latest($limit));
    }

    public function myInfo(Request $request): array
    {
        return Result::ok((new MessageService())->myInfo((int) $request->param('id')));
    }

    public function read(Request $request): array
    {
        (new MessageService())->read((int) $request->param('id'));
        return Result::ok();
    }

    public function readAll(): array
    {
        (new MessageService())->readAll();
        return Result::ok();
    }
}
