<?php

namespace Icejz\Controllers\Sys;

use Icejz\Support\Database;
use Icejz\Support\Result;

final class OrgController
{
    public function list(): array
    {
        $rows = Database::fetchAll(
            'SELECT id, pid, name, sort, create_time FROM sys_org WHERE deleted = 0 ORDER BY sort ASC, id ASC'
        );
        $list = array_map(fn ($r) => [
            'id' => (int) $r['id'],
            'pid' => (int) $r['pid'],
            'name' => $r['name'],
            'sort' => (int) ($r['sort'] ?? 0),
            'createTime' => $r['create_time'],
        ], $rows);
        return Result::ok($list);
    }
}
