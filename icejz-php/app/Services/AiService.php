<?php

namespace Icejz\Services;

use Icejz\Middleware\AuthMiddleware;
use Icejz\Support\Database;
use Icejz\Support\HttpException;

final class AiService
{
    public function robotInfo(): array
    {
        $params = $this->params([
            'AI_ROBOT_NAME', 'AI_ROBOT_AVATAR', 'AI_ROBOT_WELCOME', 'AI_ROBOT_HINT',
        ]);
        return [
            'name' => $params['AI_ROBOT_NAME'] ?? '小冰',
            'avatar' => $params['AI_ROBOT_AVATAR'] ?? null,
            'welcome' => $params['AI_ROBOT_WELCOME'] ?? '你好，我是小冰助手',
            'hint' => $params['AI_ROBOT_HINT'] ?? '有什么可以帮你的？',
        ];
    }

    /** @param array<string,mixed> $vo */
    public function chat(array $vo): array
    {
        $message = trim((string) ($vo['message'] ?? ''));
        if ($message === '') {
            throw new HttpException('消息不能为空');
        }
        $uid = AuthMiddleware::id();
        $sessionId = isset($vo['sessionId']) ? (int) $vo['sessionId'] : 0;
        if ($sessionId <= 0) {
            Database::execute(
                'INSERT INTO sys_ai_chat_session (user_id, title, create_time, update_time, deleted) VALUES (?, ?, ?, ?, 0)',
                [$uid, mb_substr($message, 0, 30), now(), now()]
            );
            $sessionId = (int) Database::lastId();
        }

        Database::execute(
            'INSERT INTO sys_ai_chat_message (session_id, role, content, create_time, deleted) VALUES (?, ?, ?, ?, 0)',
            [$sessionId, 'user', $message, now()]
        );

        $model = null;
        if (!empty($vo['modelId'])) {
            $model = Database::fetch('SELECT * FROM sys_ai_model WHERE id=? AND deleted=0', [(int) $vo['modelId']]);
        }
        if ($model === null) {
            $model = Database::fetch('SELECT * FROM sys_ai_model WHERE status=1 AND deleted=0 ORDER BY id ASC LIMIT 1');
        }

        $reply = $this->callModel($model, $message, is_array($vo['history'] ?? null) ? $vo['history'] : []);
        Database::execute(
            'INSERT INTO sys_ai_chat_message (session_id, role, content, create_time, deleted) VALUES (?, ?, ?, ?, 0)',
            [$sessionId, 'assistant', $reply, now()]
        );
        Database::execute(
            'UPDATE sys_ai_chat_session SET last_msg_time=?, update_time=? WHERE id=?',
            [now(), now(), $sessionId]
        );

        return [
            'content' => $reply,
            'modelId' => $model ? (int) $model['id'] : null,
            'modelName' => $model['name'] ?? null,
            'sessionId' => $sessionId,
        ];
    }

    public function sessionList(): array
    {
        $uid = AuthMiddleware::id();
        $rows = Database::fetchAll(
            'SELECT id, title, last_msg_time, create_time FROM sys_ai_chat_session WHERE user_id=? AND deleted=0 ORDER BY id DESC',
            [$uid]
        );
        return array_map(fn ($r) => [
            'id' => (int) $r['id'],
            'title' => $r['title'],
            'lastMsgTime' => $r['last_msg_time'],
            'createTime' => $r['create_time'],
        ], $rows);
    }

    public function sessionMessages(int $sessionId): array
    {
        $uid = AuthMiddleware::id();
        $session = Database::fetch(
            'SELECT id FROM sys_ai_chat_session WHERE id=? AND user_id=? AND deleted=0',
            [$sessionId, $uid]
        );
        if ($session === null) {
            throw new HttpException('会话不存在');
        }
        $rows = Database::fetchAll(
            'SELECT id, session_id, role, content, create_time FROM sys_ai_chat_message WHERE session_id=? AND deleted=0 ORDER BY id ASC',
            [$sessionId]
        );
        return array_map(fn ($r) => [
            'id' => (int) $r['id'],
            'sessionId' => (int) $r['session_id'],
            'role' => $r['role'],
            'content' => $r['content'],
            'createTime' => $r['create_time'],
        ], $rows);
    }

    /** @param array<string,mixed> $body */
    public function createSession(array $body): array
    {
        $uid = AuthMiddleware::id();
        $title = trim((string) ($body['title'] ?? '新会话'));
        Database::execute(
            'INSERT INTO sys_ai_chat_session (user_id, title, create_time, update_time, deleted) VALUES (?, ?, ?, ?, 0)',
            [$uid, $title !== '' ? $title : '新会话', now(), now()]
        );
        $id = (int) Database::lastId();
        return [
            'id' => $id,
            'title' => $title !== '' ? $title : '新会话',
            'lastMsgTime' => null,
            'createTime' => now(),
        ];
    }

    /** @param list<int|string> $ids */
    public function deleteSessions(array $ids): void
    {
        $uid = AuthMiddleware::id();
        foreach ($ids as $id) {
            Database::execute(
                'UPDATE sys_ai_chat_session SET deleted=1, update_time=? WHERE id=? AND user_id=?',
                [now(), (int) $id, $uid]
            );
        }
    }

    /** @param array<string,mixed>|null $model @param list<array<string,mixed>> $history */
    private function callModel(?array $model, string $message, array $history): string
    {
        if ($model === null || empty($model['api_url']) || empty($model['api_key'])) {
            return '（开发模式）已收到：' . $message . '。请在后台配置可用的 AI 模型后获得正式回复。';
        }

        $messages = [];
        foreach ($history as $h) {
            if (!empty($h['role']) && isset($h['content'])) {
                $messages[] = ['role' => (string) $h['role'], 'content' => (string) $h['content']];
            }
        }
        $messages[] = ['role' => 'user', 'content' => $message];

        $payload = [
            'model' => $model['model'] ?? $model['name'] ?? 'gpt-3.5-turbo',
            'messages' => $messages,
            'temperature' => 0.7,
        ];
        $url = rtrim((string) $model['api_url'], '/') . '/chat/completions';
        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POST => true,
            CURLOPT_HTTPHEADER => [
                'Content-Type: application/json',
                'Authorization: Bearer ' . $model['api_key'],
            ],
            CURLOPT_POSTFIELDS => json_encode($payload, JSON_UNESCAPED_UNICODE),
            CURLOPT_TIMEOUT => 60,
        ]);
        $resp = curl_exec($ch);
        $err = curl_error($ch);
        curl_close($ch);
        if ($resp === false) {
            return 'AI 调用失败：' . $err;
        }
        $data = json_decode($resp, true);
        return (string) ($data['choices'][0]['message']['content'] ?? ('AI 无响应：' . mb_substr((string) $resp, 0, 200)));
    }

    /** @param list<string> $keys @return array<string,string|null> */
    private function params(array $keys): array
    {
        if ($keys === []) {
            return [];
        }
        $in = implode(',', array_fill(0, count($keys), '?'));
        $rows = Database::fetchAll("SELECT param_key, param_value FROM sys_params WHERE param_key IN ($in)", $keys);
        $out = [];
        foreach ($rows as $r) {
            $out[$r['param_key']] = $r['param_value'];
        }
        return $out;
    }
}
