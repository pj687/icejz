<?php

namespace Icejz\Support;

final class Router
{
    /** @var list<array{method:string,pattern:string,handler:callable|array,auth:bool}> */
    private array $routes = [];

    public function get(string $path, callable|array $handler, bool $auth = true): void
    {
        $this->add('GET', $path, $handler, $auth);
    }

    public function post(string $path, callable|array $handler, bool $auth = true): void
    {
        $this->add('POST', $path, $handler, $auth);
    }

    public function put(string $path, callable|array $handler, bool $auth = true): void
    {
        $this->add('PUT', $path, $handler, $auth);
    }

    public function delete(string $path, callable|array $handler, bool $auth = true): void
    {
        $this->add('DELETE', $path, $handler, $auth);
    }

    public function add(string $method, string $path, callable|array $handler, bool $auth = true): void
    {
        $path = '/' . trim($path, '/');
        if ($path !== '/') {
            $path = rtrim($path, '/') ?: '/';
        }
        $this->routes[] = [
            'method' => strtoupper($method),
            'pattern' => $path,
            'handler' => $handler,
            'auth' => $auth,
        ];
    }

    /** @return array{handler:callable|array,params:array,auth:bool}|null */
    public function match(string $method, string $path): ?array
    {
        $method = strtoupper($method);
        $path = '/' . trim($path, '/');
        if ($path !== '/') {
            $path = rtrim($path, '/') ?: '/';
        }

        foreach ($this->routes as $route) {
            if ($route['method'] !== $method) {
                continue;
            }
            $params = $this->matchPath($route['pattern'], $path);
            if ($params !== null) {
                return [
                    'handler' => $route['handler'],
                    'params' => $params,
                    'auth' => $route['auth'],
                ];
            }
        }
        return null;
    }

    private function matchPath(string $pattern, string $path): ?array
    {
        $regex = preg_replace('#\{([a-zA-Z_][a-zA-Z0-9_]*)\}#', '(?P<$1>[^/]+)', $pattern);
        $regex = '#^' . $regex . '$#';
        if (!preg_match($regex, $path, $m)) {
            return null;
        }
        $params = [];
        foreach ($m as $k => $v) {
            if (!is_int($k)) {
                $params[$k] = $v;
            }
        }
        return $params;
    }
}
