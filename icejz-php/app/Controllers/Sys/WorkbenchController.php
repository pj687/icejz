<?php

namespace Icejz\Controllers\Sys;

use Icejz\Middleware\AuthMiddleware;
use Icejz\Support\Database;
use Icejz\Support\Request;
use Icejz\Support\Result;

final class WorkbenchController
{
    public function noteList(Request $request): array
    {
        $uid = AuthMiddleware::id();
        $ym = (string) $request->query('yearMonth', date('Y-m'));
        $rows = Database::fetchAll(
            'SELECT id, content, note_date, create_time FROM sys_workbench_note
             WHERE user_id = ? AND deleted = 0 AND DATE_FORMAT(note_date, "%Y-%m") = ?
             ORDER BY note_date ASC, id ASC',
            [$uid, $ym]
        );
        $list = array_map(fn ($r) => [
            'id' => (int) $r['id'],
            'content' => $r['content'],
            'noteDate' => $r['note_date'],
            'createTime' => $r['create_time'],
        ], $rows);
        return Result::ok($list);
    }

    public function noteSave(Request $request): array
    {
        $body = $request->json();
        Database::execute(
            'INSERT INTO sys_workbench_note (user_id, content, note_date, create_time, update_time, deleted)
             VALUES (?, ?, ?, ?, ?, 0)',
            [
                AuthMiddleware::id(),
                (string) ($body['content'] ?? ''),
                (string) ($body['noteDate'] ?? date('Y-m-d')),
                now(),
                now(),
            ]
        );
        return Result::ok();
    }

    public function noteDelete(Request $request): array
    {
        $ids = $request->json();
        if (!is_array($ids)) {
            $ids = [];
        }
        foreach ($ids as $id) {
            Database::execute(
                'UPDATE sys_workbench_note SET deleted=1, update_time=? WHERE id=? AND user_id=?',
                [now(), (int) $id, AuthMiddleware::id()]
            );
        }
        return Result::ok();
    }
}
