<?php

namespace Icejz\Support;

use Icejz\Middleware\AuthMiddleware;

final class Application
{
    private Router $router;

    public function __construct()
    {
        date_default_timezone_set((string) config('app.timezone', 'Asia/Shanghai'));
        $this->router = new Router();
    }

    public function router(): Router
    {
        return $this->router;
    }

    public function run(): void
    {
        if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'OPTIONS') {
            $this->cors();
            http_response_code(204);
            return;
        }

        $this->cors();
        $request = Request::capture();

        try {
            $matched = $this->router->match($request->method, $request->path);
            if ($matched === null) {
                $this->json(Result::error('Not Found', 404), 404);
                return;
            }

            $request->setRouteParams($matched['params']);
            if ($matched['auth']) {
                AuthMiddleware::handle($request);
            }

            $handler = $matched['handler'];
            if (is_array($handler)) {
                [$class, $method] = $handler;
                $controller = new $class();
                $result = $controller->{$method}($request);
            } else {
                $result = $handler($request);
            }

            if (is_array($result)) {
                $this->json($result);
            } elseif (is_string($result)) {
                header('Content-Type: text/plain; charset=utf-8');
                echo $result;
            }
        } catch (HttpException $e) {
            $code = $e->getErrorCode();
            $http = $code === 401 ? 401 : ($code === 403 ? 403 : 200);
            $this->json(Result::error($e->getMessage(), $code), $http);
        } catch (\Throwable $e) {
            $msg = config('app.debug') ? $e->getMessage() : '服务器异常';
            if (config('app.debug')) {
                error_log($e->getMessage() . "\n" . $e->getTraceAsString());
            }
            $this->json(Result::error($msg, 500));
        }
    }

    private function cors(): void
    {
        header('Access-Control-Allow-Origin: *');
        header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
        header('Access-Control-Allow-Headers: Authorization, Content-Type, X-Client-Type, X-Requested-With');
        header('Access-Control-Max-Age: 86400');
    }

    private function json(array $payload, int $httpStatus = 200): void
    {
        http_response_code($httpStatus);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    }
}
