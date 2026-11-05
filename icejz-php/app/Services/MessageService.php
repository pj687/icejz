<?php

namespace Icejz\Services;

use Icejz\Middleware\AuthMiddleware;
use Icejz\Support\Database;
use Icejz\Support\HttpException;

final class MessageService
{
    public function myPage(int $page, int $limit, ?string $title = null, ?int $readStatus = null): array
    {
        $uid = AuthMiddleware::id();
        $where = ['mu.receiver_id = ?', 'm.deleted = 0'];
        $params = [$uid];
        // compatible column names: receiver_id / user_id
        $hasReceiver = $this->hasColumn('sys_message_user', 'receiver_id');
        if (!$hasReceiver) {
            $where = ['mu.user_id = ?', 'm.deleted = 0'];
        }
        if ($title) {
            $where[] = 'm.title LIKE ?';
            $params[] = '%' . $title . '%';
        }
        if ($readStatus !== null) {
            $where[] = 'mu.read_status = ?';
            $params[] = $readStatus;
        }
        $ws = implode(' AND ', $where);
        $joinUser = $hasReceiver ? 'mu.receiver_id' : 'mu.user_id';
        $total = (int) (Database::fetch(
            "SELECT COUNT(*) AS c FROM sys_message_user mu INNER JOIN sys_message m ON m.id = mu.message_id WHERE $ws",
            $params
        )['c'] ?? 0);
        $offset = max(0, ($page - 1) * $limit);
        $rows = Database::fetchAll(
            "SELECT m.id, mu.id AS receive_id, m.title, m.content, m.type, m.sender_id, m.sender_name, m.send_time, m.create_time, mu.read_status, mu.read_time
             FROM sys_message_user mu
             INNER JOIN sys_message m ON m.id = mu.message_id
             WHERE $ws
             ORDER BY m.id DESC
             LIMIT $limit OFFSET $offset",
            $params
        );
        return ['total' => $total, 'list' => array_map([$this, 'mapMy'], $rows), 'summary' => null];
    }

    public function unreadCount(): int
    {
        $uid = AuthMiddleware::id();
        $col = $this->hasColumn('sys_message_user', 'receiver_id') ? 'receiver_id' : 'user_id';
        $row = Database::fetch(
            "SELECT COUNT(*) AS c FROM sys_message_user WHERE $col = ? AND read_status = 0",
            [$uid]
        );
        return (int) ($row['c'] ?? 0);
    }

    public function latest(int $limit = 5): array
    {
        $page = $this->myPage(1, $limit);
        return $page['list'];
    }

    public function myInfo(int $id): array
    {
        $uid = AuthMiddleware::id();
        $col = $this->hasColumn('sys_message_user', 'receiver_id') ? 'receiver_id' : 'user_id';
        $row = Database::fetch(
            "SELECT m.id, mu.id AS receive_id, m.title, m.content, m.type, m.sender_id, m.sender_name, m.send_time, m.create_time, mu.read_status, mu.read_time
             FROM sys_message_user mu
             INNER JOIN sys_message m ON m.id = mu.message_id
             WHERE m.id = ? AND mu.$col = ? LIMIT 1",
            [$id, $uid]
        );
        if ($row === null) {
            throw new HttpException('消息不存在');
        }
        Database::execute(
            "UPDATE sys_message_user SET read_status=1, read_time=? WHERE message_id=? AND $col=?",
            [now(), $id, $uid]
        );
        $row['read_status'] = 1;
        $row['read_time'] = now();
        return $this->mapMy($row);
    }

    public function read(int $id): void
    {
        $uid = AuthMiddleware::id();
        $col = $this->hasColumn('sys_message_user', 'receiver_id') ? 'receiver_id' : 'user_id';
        Database::execute(
            "UPDATE sys_message_user SET read_status=1, read_time=? WHERE message_id=? AND $col=?",
            [now(), $id, $uid]
        );
    }

    public function readAll(): void
    {
        $uid = AuthMiddleware::id();
        $col = $this->hasColumn('sys_message_user', 'receiver_id') ? 'receiver_id' : 'user_id';
        Database::execute(
            "UPDATE sys_message_user SET read_status=1, read_time=? WHERE $col=? AND read_status=0",
            [now(), $uid]
        );
    }

    /** @param array<string,mixed> $r */
    private function mapMy(array $r): array
    {
        return [
            'id' => (int) $r['id'],
            'receiveId' => isset($r['receive_id']) ? (int) $r['receive_id'] : null,
            'title' => $r['title'],
            'content' => $r['content'],
            'type' => isset($r['type']) ? (int) $r['type'] : 0,
            'senderId' => isset($r['sender_id']) ? (int) $r['sender_id'] : null,
            'senderName' => $r['sender_name'] ?? null,
            'sendTime' => $r['send_time'] ?? null,
            'createTime' => $r['create_time'] ?? null,
            'readStatus' => (int) ($r['read_status'] ?? 0),
            'readTime' => $r['read_time'] ?? null,
        ];
    }

    private function hasColumn(string $table, string $column): bool
    {
        static $cache = [];
        $k = $table . '.' . $column;
        if (!array_key_exists($k, $cache)) {
            $db = config('database.database');
            $row = Database::fetch(
                'SELECT COUNT(*) AS c FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=? AND TABLE_NAME=? AND COLUMN_NAME=?',
                [$db, $table, $column]
            );
            $cache[$k] = ((int) ($row['c'] ?? 0)) > 0;
        }
        return $cache[$k];
    }
}
