<?php

use Icejz\Controllers\Member\PortalController;
use Icejz\Controllers\Sys\AiController;
use Icejz\Controllers\Sys\AppController;
use Icejz\Controllers\Sys\AuthController;
use Icejz\Controllers\Sys\MessageController;
use Icejz\Controllers\Sys\OrgController;
use Icejz\Controllers\Sys\RoleController;
use Icejz\Controllers\Sys\UserController;
use Icejz\Controllers\Sys\WorkbenchController;
use Icejz\Support\Application;
use Icejz\Support\Result;

/** @var Application $app */
$r = $app->router();

$r->get('/', fn () => 'Welcome to ICEJZ PHP ' . config('app.version'), false);

// ---- auth (permitAll) ----
$r->get('/sys/auth/captcha', [AuthController::class, 'captcha'], false);
$r->get('/sys/auth/captcha/enabled', [AuthController::class, 'captchaEnabled'], false);
$r->post('/sys/auth/captcha/check', [AuthController::class, 'captchaCheck'], false);
$r->get('/sys/auth/public-key', [AuthController::class, 'publicKey'], false);
$r->post('/sys/auth/login', [AuthController::class, 'login'], false);
$r->post('/sys/auth/send/code', [AuthController::class, 'sendCode'], false);
$r->post('/sys/auth/mobile', [AuthController::class, 'mobile'], false);
$r->post('/sys/auth/token', [AuthController::class, 'token'], false);
$r->post('/sys/auth/third', [AuthController::class, 'third'], false);
$r->post('/sys/auth/complete-profile', [AuthController::class, 'completeProfile'], false);
$r->post('/sys/auth/logout', [AuthController::class, 'logout'], true);

$r->get('/sys/app/version', [AppController::class, 'version'], false);

// ---- user ----
$r->get('/sys/user/info', [UserController::class, 'info']);
$r->put('/sys/user/info', [UserController::class, 'updateInfo']);
$r->put('/sys/user/password', [UserController::class, 'password']);
$r->get('/sys/user/device', [UserController::class, 'device']);
$r->delete('/sys/user/device/{accessToken}', [UserController::class, 'kickDevice']);
$r->get('/sys/user/login-security', [UserController::class, 'loginSecurity']);
$r->put('/sys/user/login-security', [UserController::class, 'saveLoginSecurity']);
$r->get('/sys/user/page', [UserController::class, 'page']);
$r->get('/sys/user/member-summary', [UserController::class, 'memberSummary']);

// ---- org / role ----
$r->get('/sys/org/list', [OrgController::class, 'list']);
$r->get('/sys/role/page', [RoleController::class, 'page']);

// ---- message ----
$r->get('/sys/message/my/page', [MessageController::class, 'myPage']);
$r->get('/sys/message/my/unread-count', [MessageController::class, 'unreadCount']);
$r->get('/sys/message/my/latest', [MessageController::class, 'latest']);
$r->get('/sys/message/my/{id}', [MessageController::class, 'myInfo']);
$r->put('/sys/message/my/{id}/read', [MessageController::class, 'read']);
$r->put('/sys/message/my/read-all', [MessageController::class, 'readAll']);

// ---- AI ----
$r->get('/sys/ai/robot/info', [AiController::class, 'robotInfo']);
$r->post('/sys/ai/chat', [AiController::class, 'chat']);
$r->get('/sys/ai/chat/session/list', [AiController::class, 'sessionList']);
$r->get('/sys/ai/chat/session/{id}/messages', [AiController::class, 'sessionMessages']);
$r->post('/sys/ai/chat/session', [AiController::class, 'createSession']);
$r->delete('/sys/ai/chat/session', [AiController::class, 'deleteSessions']);

// ---- workbench ----
$r->get('/sys/workbench/note/list', [WorkbenchController::class, 'noteList']);
$r->post('/sys/workbench/note', [WorkbenchController::class, 'noteSave']);
$r->delete('/sys/workbench/note', [WorkbenchController::class, 'noteDelete']);

// ---- member portal stubs ----
$portal = PortalController::class;
foreach ([
    ['GET', '/member/service-item/list', 'emptyList'],
    ['GET', '/member/service-item/{id}', 'notOpen'],
    ['GET', '/member/booking/page', 'emptyPage'],
    ['GET', '/member/order/page', 'emptyPage'],
    ['GET', '/member/activity/page', 'emptyPage'],
    ['GET', '/member/activity-signup/my/page', 'emptyPage'],
    ['GET', '/member/health-record/summary', 'ok'],
    ['GET', '/member/health-alert/my', 'emptyList'],
    ['GET', '/member/elder-archive', 'ok'],
] as [$method, $path, $action]) {
    $r->add($method, $path, [$portal, $action], true);
}

// fallback helper for unimplemented admin APIs
$r->get('/sys/menu/nav', fn () => Result::ok([]));
$r->get('/sys/menu/authority', fn () => Result::ok([]));
