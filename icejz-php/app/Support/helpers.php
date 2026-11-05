<?php

use Icejz\Support\Env;

if (!function_exists('env')) {
    function env(string $key, mixed $default = null): mixed
    {
        return Env::get($key, $default);
    }
}

if (!function_exists('config')) {
    function config(string $key, mixed $default = null): mixed
    {
        return \Icejz\Support\Config::get($key, $default);
    }
}

if (!function_exists('base_path')) {
    function base_path(string $path = ''): string
    {
        $base = dirname(__DIR__, 2);
        return $path === '' ? $base : $base . DIRECTORY_SEPARATOR . ltrim(str_replace(['/', '\\'], DIRECTORY_SEPARATOR, $path), DIRECTORY_SEPARATOR);
    }
}

if (!function_exists('now')) {
    function now(): string
    {
        return date('Y-m-d H:i:s');
    }
}

if (!function_exists('uuid32')) {
    function uuid32(): string
    {
        return str_replace('-', '', sprintf(
            '%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
            mt_rand(0, 0xffff),
            mt_rand(0, 0xffff),
            mt_rand(0, 0xffff),
            mt_rand(0, 0x0fff) | 0x4000,
            mt_rand(0, 0x3fff) | 0x8000,
            mt_rand(0, 0xffff),
            mt_rand(0, 0xffff),
            mt_rand(0, 0xffff)
        ));
    }
}

if (!function_exists('camel_keys')) {
    /** @param array<string,mixed> $row */
    function camel_keys(array $row): array
    {
        $out = [];
        foreach ($row as $k => $v) {
            $ck = is_string($k) ? lcfirst(str_replace(' ', '', ucwords(str_replace('_', ' ', $k)))) : $k;
            $out[$ck] = is_array($v) ? camel_keys($v) : $v;
        }
        return $out;
    }
}
