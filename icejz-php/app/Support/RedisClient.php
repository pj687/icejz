<?php

namespace Icejz\Support;

use Predis\Client;

final class RedisClient
{
    private static ?Client $client = null;

    public static function client(): Client
    {
        if (self::$client === null) {
            $c = config('redis');
            $params = [
                'scheme' => 'tcp',
                'host' => $c['host'],
                'port' => $c['port'],
                'database' => $c['database'],
            ];
            if (!empty($c['password'])) {
                $params['password'] = $c['password'];
            }
            self::$client = new Client($params);
        }
        return self::$client;
    }

    public static function set(string $key, mixed $value, ?int $ttl = null): void
    {
        $payload = is_string($value) ? $value : json_encode($value, JSON_UNESCAPED_UNICODE);
        if ($ttl !== null && $ttl > 0) {
            self::client()->setex($key, $ttl, $payload);
        } else {
            self::client()->set($key, $payload);
        }
    }

    public static function get(string $key): ?string
    {
        $v = self::client()->get($key);
        return $v === null ? null : (string) $v;
    }

    public static function getJson(string $key): mixed
    {
        $v = self::get($key);
        if ($v === null) {
            return null;
        }
        $decoded = json_decode($v, true);
        return json_last_error() === JSON_ERROR_NONE ? $decoded : $v;
    }

    public static function del(string $key): void
    {
        self::client()->del([$key]);
    }

    public static function exists(string $key): bool
    {
        return (bool) self::client()->exists($key);
    }

    public static function ttl(string $key): int
    {
        return (int) self::client()->ttl($key);
    }

    public static function incr(string $key): int
    {
        return (int) self::client()->incr($key);
    }

    public static function expire(string $key, int $ttl): void
    {
        self::client()->expire($key, $ttl);
    }
}
