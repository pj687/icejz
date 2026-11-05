<?php

namespace Icejz\Support;

final class Request
{
    private array $routeParams = [];
    private ?array $json = null;

    public function __construct(
        public readonly string $method,
        public readonly string $path,
        public readonly array $query,
        public readonly array $server,
        public readonly array $headers,
        private readonly string $rawBody,
    ) {
    }

    public static function capture(): self
    {
        $method = strtoupper($_SERVER['REQUEST_METHOD'] ?? 'GET');
        $uri = $_SERVER['REQUEST_URI'] ?? '/';
        $path = parse_url($uri, PHP_URL_PATH) ?: '/';
        $path = '/' . trim($path, '/');
        if ($path !== '/') {
            $path = rtrim($path, '/') ?: '/';
        }

        $headers = [];
        foreach ($_SERVER as $k => $v) {
            if (str_starts_with($k, 'HTTP_')) {
                $name = str_replace(' ', '-', ucwords(strtolower(str_replace('_', ' ', substr($k, 5)))));
                $headers[$name] = $v;
            }
        }
        if (isset($_SERVER['CONTENT_TYPE'])) {
            $headers['Content-Type'] = $_SERVER['CONTENT_TYPE'];
        }
        if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
            $headers['Authorization'] = $_SERVER['HTTP_AUTHORIZATION'];
        }

        return new self($method, $path === '' ? '/' : $path, $_GET, $_SERVER, $headers, file_get_contents('php://input') ?: '');
    }

    public function setRouteParams(array $params): void
    {
        $this->routeParams = $params;
    }

    public function param(string $key, mixed $default = null): mixed
    {
        return $this->routeParams[$key] ?? $default;
    }

    public function query(string $key, mixed $default = null): mixed
    {
        return $this->query[$key] ?? $default;
    }

    public function input(string $key, mixed $default = null): mixed
    {
        $json = $this->json();
        if (array_key_exists($key, $json)) {
            return $json[$key];
        }
        return $_POST[$key] ?? $default;
    }

    public function json(): array
    {
        if ($this->json === null) {
            $decoded = json_decode($this->rawBody, true);
            $this->json = is_array($decoded) ? $decoded : [];
        }
        return $this->json;
    }

    public function all(): array
    {
        return array_merge($this->query, $this->json(), $_POST);
    }

    public function header(string $name, mixed $default = null): mixed
    {
        foreach ($this->headers as $k => $v) {
            if (strcasecmp($k, $name) === 0) {
                return $v;
            }
        }
        return $default;
    }

    public function bearerToken(): ?string
    {
        $auth = $this->header('Authorization');
        if (is_string($auth) && $auth !== '') {
            if (stripos($auth, 'Bearer ') === 0) {
                return trim(substr($auth, 7));
            }
            return trim($auth);
        }
        $q = $this->query('access_token');
        return is_string($q) && $q !== '' ? $q : null;
    }

    public function ip(): string
    {
        return $this->server['HTTP_X_FORWARDED_FOR']
            ?? $this->server['REMOTE_ADDR']
            ?? '127.0.0.1';
    }

    public function userAgent(): string
    {
        return (string) ($this->server['HTTP_USER_AGENT'] ?? '');
    }

    public function clientType(): string
    {
        $header = $this->header('X-Client-Type');
        if (is_string($header) && $header !== '') {
            return strtolower(trim($header));
        }
        $ua = strtolower($this->userAgent());
        if ($ua === '') {
            return 'pc';
        }
        if (str_contains($ua, 'micromessenger')) {
            return 'mp';
        }
        if (
            str_contains($ua, 'uni-app') || str_contains($ua, 'miniprogram') ||
            str_contains($ua, 'android') || str_contains($ua, 'iphone') ||
            str_contains($ua, 'ipad') || str_contains($ua, 'mobile')
        ) {
            return 'app';
        }
        return 'pc';
    }
}
