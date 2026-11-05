<?php

namespace Icejz\Controllers\Sys;

use Icejz\Support\Database;
use Icejz\Support\Request;
use Icejz\Support\Result;

final class RoleController
{
    public function page(Request $request): array
    {
        $page = max(1, (int) $request->query('page', 1));
        $limit = max(1, min(100, (int) $request->query('limit', 10)));
        $total = (int) (Database::fetch('SELECT COUNT(*) AS c FROM sys_role WHERE deleted = 0')['c'] ?? 0);
        $offset = ($page - 1) * $limit;
        $rows = Database::fetchAll(
            "SELECT id, name, role_code, remark, create_time FROM sys_role WHERE deleted = 0 ORDER BY id DESC LIMIT $limit OFFSET $offset"
        );
        $list = array_map(fn ($r) => [
            'id' => (int) $r['id'],
            'name' => $r['name'],
            'roleCode' => $r['role_code'] ?? null,
            'remark' => $r['remark'] ?? null,
            'createTime' => $r['create_time'],
        ], $rows);
        return Result::ok(['total' => $total, 'list' => $list, 'summary' => null]);
    }
}
