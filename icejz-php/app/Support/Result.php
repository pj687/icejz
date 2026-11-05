<?php

namespace Icejz\Support;

final class Result
{
    public static function ok(mixed $data = null, string $msg = 'success'): array
    {
        return ['code' => 0, 'msg' => $msg, 'data' => $data];
    }

    public static function error(string $msg = '服务器异常', int $code = 500): array
    {
        return ['code' => $code, 'msg' => $msg, 'data' => null];
    }

    public static function page(array $list, int $total, ?array $summary = null): array
    {
        return self::ok([
            'total' => $total,
            'list' => $list,
            'summary' => $summary,
        ]);
    }
}
