<?php

namespace Icejz\Services;

use Icejz\Support\Database;
use Icejz\Support\HttpException;
use Icejz\Support\RedisClient;
use Icejz\Support\Request;

final class TokenService
{
    /** @return array{access_token:string,refresh_token:string,accessTokenExpire:string,refreshTokenExpire:string} */
    public static function createToken(int $userId, Request $request): array
    {
        $accessExpireSec = (int) config('security.access_token_expire', 28800);
        $refreshExpireSec = (int) config('security.refresh_token_expire', 1209600);
        $accessToken = uuid32();
        $refreshToken = uuid32();
        $now = time();
        $accessExpire = date('Y-m-d H:i:s', $now + $accessExpireSec);
        $refreshExpire = date('Y-m-d H:i:s', $now + $refreshExpireSec);

        $loginIp = $request->ip();
        $userAgent = mb_substr($request->userAgent(), 0, 500);
        $clientType = $request->clientType();

        $multi = self::isMultiDevice($userId);
        Database::begin();
        try {
            $oldList = Database::fetchAll(
                'SELECT id, access_token FROM sys_user_token WHERE user_id = ? ORDER BY id ASC',
                [$userId]
            );

            if (!$multi) {
                foreach ($oldList as $old) {
                    if (!empty($old['access_token'])) {
                        RedisClient::del('sys:token:' . $old['access_token']);
                    }
                }
                if ($oldList === []) {
                    Database::execute(
                        'INSERT INTO sys_user_token (user_id, access_token, access_token_expire, refresh_token, refresh_token_expire, login_ip, user_agent, client_type, create_time)
                         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
                        [$userId, $accessToken, $accessExpire, $refreshToken, $refreshExpire, $loginIp, $userAgent, $clientType, now()]
                    );
                } else {
                    $id = $oldList[0]['id'];
                    Database::execute(
                        'UPDATE sys_user_token SET access_token=?, access_token_expire=?, refresh_token=?, refresh_token_expire=?, login_ip=?, user_agent=?, client_type=? WHERE id=?',
                        [$accessToken, $accessExpire, $refreshToken, $refreshExpire, $loginIp, $userAgent, $clientType, $id]
                    );
                    for ($i = 1; $i < count($oldList); $i++) {
                        Database::execute('DELETE FROM sys_user_token WHERE id=?', [$oldList[$i]['id']]);
                    }
                }
            } else {
                Database::execute(
                    'INSERT INTO sys_user_token (user_id, access_token, access_token_expire, refresh_token, refresh_token_expire, login_ip, user_agent, client_type, create_time)
                     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
                    [$userId, $accessToken, $accessExpire, $refreshToken, $refreshExpire, $loginIp, $userAgent, $clientType, now()]
                );
            }
            Database::commit();
        } catch (\Throwable $e) {
            Database::rollBack();
            throw $e;
        }

        $user = self::loadUserDetail($userId);
        $user['loginIp'] = $loginIp;
        $user['userAgent'] = $userAgent;
        $user['clientType'] = $clientType;
        $user['loginTime'] = now();
        RedisClient::set('sys:token:' . $accessToken, $user, $accessExpireSec);

        return [
            'access_token' => $accessToken,
            'refresh_token' => $refreshToken,
            'accessTokenExpire' => $accessExpire,
            'refreshTokenExpire' => $refreshExpire,
        ];
    }

    public static function logout(?string $accessToken): void
    {
        if ($accessToken === null || $accessToken === '') {
            return;
        }
        RedisClient::del('sys:token:' . $accessToken);
        Database::execute('DELETE FROM sys_user_token WHERE access_token = ?', [$accessToken]);
    }

    /** @return array{access_token:string,accessTokenExpire:string} */
    public static function refresh(string $refreshToken): array
    {
        $row = Database::fetch('SELECT * FROM sys_user_token WHERE refresh_token = ? LIMIT 1', [$refreshToken]);
        if ($row === null) {
            throw new HttpException('refresh_token 无效', 400);
        }
        if (strtotime((string) $row['refresh_token_expire']) < time()) {
            throw new HttpException('refresh_token 已过期', 400);
        }

        $accessExpireSec = (int) config('security.access_token_expire', 28800);
        $accessToken = uuid32();
        $accessExpire = date('Y-m-d H:i:s', time() + $accessExpireSec);

        if (!empty($row['access_token'])) {
            RedisClient::del('sys:token:' . $row['access_token']);
        }
        Database::execute(
            'UPDATE sys_user_token SET access_token=?, access_token_expire=? WHERE id=?',
            [$accessToken, $accessExpire, $row['id']]
        );

        $user = self::loadUserDetail((int) $row['user_id']);
        RedisClient::set('sys:token:' . $accessToken, $user, $accessExpireSec);

        return [
            'access_token' => $accessToken,
            'accessTokenExpire' => $accessExpire,
        ];
    }

    /** @return array<string,mixed>|null */
    public static function userByAccessToken(string $accessToken): ?array
    {
        $cached = RedisClient::getJson('sys:token:' . $accessToken);
        if (is_array($cached) && isset($cached['id'])) {
            return $cached;
        }
        $row = Database::fetch(
            'SELECT * FROM sys_user_token WHERE access_token = ? LIMIT 1',
            [$accessToken]
        );
        if ($row === null) {
            return null;
        }
        if (strtotime((string) $row['access_token_expire']) < time()) {
            return null;
        }
        $user = self::loadUserDetail((int) $row['user_id']);
        $ttl = max(1, strtotime((string) $row['access_token_expire']) - time());
        RedisClient::set('sys:token:' . $accessToken, $user, $ttl);
        return $user;
    }

    /** @return list<array<string,mixed>> */
    public static function deviceList(int $userId, string $currentToken): array
    {
        $rows = Database::fetchAll(
            'SELECT access_token, login_ip, user_agent, client_type, create_time, access_token_expire
             FROM sys_user_token WHERE user_id = ? ORDER BY id DESC',
            [$userId]
        );
        $list = [];
        foreach ($rows as $r) {
            $list[] = [
                'accessToken' => $r['access_token'],
                'loginIp' => $r['login_ip'],
                'userAgent' => $r['user_agent'],
                'clientType' => $r['client_type'],
                'loginTime' => $r['create_time'],
                'accessTokenExpire' => $r['access_token_expire'],
                'current' => $r['access_token'] === $currentToken,
            ];
        }
        return $list;
    }

    public static function kickDevice(int $userId, string $accessToken): void
    {
        $row = Database::fetch(
            'SELECT id FROM sys_user_token WHERE user_id = ? AND access_token = ? LIMIT 1',
            [$userId, $accessToken]
        );
        if ($row === null) {
            throw new HttpException('设备不存在', 500);
        }
        RedisClient::del('sys:token:' . $accessToken);
        Database::execute('DELETE FROM sys_user_token WHERE id = ?', [$row['id']]);
    }

    private static function isMultiDevice(int $userId): bool
    {
        $param = Database::fetch("SELECT param_value FROM sys_params WHERE param_key = 'MULTI_DEVICE_LOGIN' LIMIT 1");
        $systemMulti = $param && filter_var($param['param_value'], FILTER_VALIDATE_BOOLEAN);
        if (!$systemMulti) {
            return false;
        }
        $user = Database::fetch('SELECT multi_device_login FROM sys_user WHERE id = ? AND deleted = 0', [$userId]);
        if ($user && $user['multi_device_login'] !== null) {
            return (int) $user['multi_device_login'] === 1;
        }
        return true;
    }

    /** @return array<string,mixed> */
    public static function loadUserDetail(int $userId): array
    {
        $u = Database::fetch(
            'SELECT u.*, o.name AS org_name
             FROM sys_user u
             LEFT JOIN sys_org o ON o.id = u.org_id AND o.deleted = 0
             WHERE u.id = ? AND u.deleted = 0 LIMIT 1',
            [$userId]
        );
        if ($u === null) {
            throw new HttpException('用户不存在', 500);
        }
        $roleIds = Database::fetchAll('SELECT role_id FROM sys_user_role WHERE user_id = ?', [$userId]);
        $postIds = Database::fetchAll('SELECT post_id FROM sys_user_post WHERE user_id = ?', [$userId]);
        return [
            'id' => (int) $u['id'],
            'username' => $u['username'],
            'realName' => $u['real_name'],
            'avatar' => $u['avatar'],
            'signature' => $u['signature'] ?? null,
            'gender' => isset($u['gender']) ? (int) $u['gender'] : null,
            'email' => $u['email'],
            'mobile' => $u['mobile'],
            'orgId' => $u['org_id'] !== null ? (int) $u['org_id'] : null,
            'orgName' => $u['org_name'] ?? null,
            'status' => (int) $u['status'],
            'superAdmin' => (int) ($u['super_admin'] ?? 0),
            'banReason' => $u['ban_reason'] ?? null,
            'banTime' => $u['ban_time'] ?? null,
            'banExpireTime' => $u['ban_expire_time'] ?? null,
            'multiDeviceLogin' => isset($u['multi_device_login']) ? (int) $u['multi_device_login'] : null,
            'multiDeviceMax' => isset($u['multi_device_max']) ? (int) $u['multi_device_max'] : null,
            'roleIdList' => array_map(fn ($r) => (int) $r['role_id'], $roleIds),
            'postIdList' => array_map(fn ($r) => (int) $r['post_id'], $postIds),
            'createTime' => $u['create_time'] ?? null,
        ];
    }
}
