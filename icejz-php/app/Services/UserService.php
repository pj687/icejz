<?php

namespace Icejz\Services;

use Icejz\Middleware\AuthMiddleware;
use Icejz\Support\Database;
use Icejz\Support\HttpException;
use Icejz\Support\SmCrypto;

final class UserService
{
    public function info(): array
    {
        $user = AuthMiddleware::user();
        $detail = TokenService::loadUserDetail((int) $user['id']);
        $posts = [];
        if ($detail['postIdList'] !== []) {
            $in = implode(',', array_map('intval', $detail['postIdList']));
            $rows = Database::fetchAll("SELECT post_name FROM sys_post WHERE id IN ($in) AND deleted = 0");
            $posts = array_column($rows, 'post_name');
        }
        $detail['postNameList'] = $posts;
        return $detail;
    }

    /** @param array<string,mixed> $vo */
    public function updateInfo(array $vo): void
    {
        $id = AuthMiddleware::id();
        Database::execute(
            'UPDATE sys_user SET real_name=?, gender=?, email=?, mobile=?, update_time=? WHERE id=? AND deleted=0',
            [
                $vo['realName'] ?? null,
                $vo['gender'] ?? null,
                $vo['email'] ?? null,
                $vo['mobile'] ?? null,
                now(),
                $id,
            ]
        );
    }

    /** @param array<string,mixed> $vo */
    public function updatePassword(array $vo): void
    {
        $id = AuthMiddleware::id();
        $user = Database::fetch('SELECT password FROM sys_user WHERE id=? AND deleted=0', [$id]);
        if ($user === null) {
            throw new HttpException('用户不存在');
        }
        $password = (string) ($vo['password'] ?? '');
        $newPassword = (string) ($vo['newPassword'] ?? '');
        try {
            $password = SmCrypto::decrypt($password);
            $newPassword = SmCrypto::decrypt($newPassword);
        } catch (HttpException $e) {
            throw $e;
        } catch (\Throwable) {
            throw new HttpException('密码解密失败，请刷新页面后重试');
        }
        if (!SmCrypto::passwordMatches($password, (string) $user['password'])) {
            throw new HttpException('原密码错误');
        }
        Database::execute(
            'UPDATE sys_user SET password=?, update_time=? WHERE id=?',
            [SmCrypto::sm3($newPassword), now(), $id]
        );
    }

    public function loginSecurity(): array
    {
        $u = Database::fetch(
            'SELECT multi_device_login, multi_device_max FROM sys_user WHERE id=? AND deleted=0',
            [AuthMiddleware::id()]
        );
        return [
            'multiDeviceLogin' => isset($u['multi_device_login']) ? (int) $u['multi_device_login'] : null,
            'multiDeviceMax' => isset($u['multi_device_max']) ? (int) $u['multi_device_max'] : null,
        ];
    }

    /** @param array<string,mixed> $vo */
    public function saveLoginSecurity(array $vo): void
    {
        Database::execute(
            'UPDATE sys_user SET multi_device_login=?, multi_device_max=?, update_time=? WHERE id=?',
            [
                array_key_exists('multiDeviceLogin', $vo) ? $vo['multiDeviceLogin'] : null,
                array_key_exists('multiDeviceMax', $vo) ? $vo['multiDeviceMax'] : null,
                now(),
                AuthMiddleware::id(),
            ]
        );
    }

    public function page(int $page, int $limit, ?string $username = null, ?string $mobile = null): array
    {
        $where = ['u.deleted = 0'];
        $params = [];
        if ($username) {
            $where[] = 'u.username LIKE ?';
            $params[] = '%' . $username . '%';
        }
        if ($mobile) {
            $where[] = 'u.mobile LIKE ?';
            $params[] = '%' . $mobile . '%';
        }
        $ws = implode(' AND ', $where);
        $total = (int) (Database::fetch("SELECT COUNT(*) AS c FROM sys_user u WHERE $ws", $params)['c'] ?? 0);
        $offset = max(0, ($page - 1) * $limit);
        $rows = Database::fetchAll(
            "SELECT u.id, u.username, u.real_name, u.avatar, u.gender, u.email, u.mobile, u.org_id, u.status, u.super_admin, u.create_time, o.name AS org_name
             FROM sys_user u LEFT JOIN sys_org o ON o.id = u.org_id
             WHERE $ws ORDER BY u.id DESC LIMIT $limit OFFSET $offset",
            $params
        );
        $list = array_map(fn ($r) => [
            'id' => (int) $r['id'],
            'username' => $r['username'],
            'realName' => $r['real_name'],
            'avatar' => $r['avatar'],
            'gender' => $r['gender'] !== null ? (int) $r['gender'] : null,
            'email' => $r['email'],
            'mobile' => $r['mobile'],
            'orgId' => $r['org_id'] !== null ? (int) $r['org_id'] : null,
            'orgName' => $r['org_name'],
            'status' => (int) $r['status'],
            'superAdmin' => (int) $r['super_admin'],
            'createTime' => $r['create_time'],
        ], $rows);
        return ['total' => $total, 'list' => $list, 'summary' => null];
    }
}
