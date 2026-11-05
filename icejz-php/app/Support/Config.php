<?php

namespace Icejz\Support;

final class Config
{
    /** @var array<string,mixed> */
    private static array $items = [];

    public static function load(string $dir): void
    {
        foreach (glob(rtrim($dir, '/\\') . DIRECTORY_SEPARATOR . '*.php') ?: [] as $file) {
            $name = basename($file, '.php');
            self::$items[$name] = require $file;
        }
    }

    public static function get(string $key, mixed $default = null): mixed
    {
        $parts = explode('.', $key);
        $cur = self::$items;
        foreach ($parts as $p) {
            if (!is_array($cur) || !array_key_exists($p, $cur)) {
                return $default;
            }
            $cur = $cur[$p];
        }
        return $cur;
    }
}
