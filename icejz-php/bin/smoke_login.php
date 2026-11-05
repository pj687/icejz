<?php

require dirname(__DIR__) . '/vendor/autoload.php';
require dirname(__DIR__) . '/app/Support/helpers.php';

Icejz\Support\Env::load(dirname(__DIR__) . '/.env');
Icejz\Support\Config::load(dirname(__DIR__) . '/config');

$base = getenv('ICEJZ_BASE') ?: 'http://127.0.0.1:8080';

function http_get(string $url, array $headers = []): string
{
    $ch = curl_init($url);
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => $headers,
        CURLOPT_TIMEOUT => 10,
    ]);
    $body = curl_exec($ch);
    if ($body === false) {
        throw new RuntimeException('GET failed: ' . curl_error($ch));
    }
    return $body;
}

$cap = json_decode(http_get("$base/sys/auth/captcha?channel=app"), true);
$key = $cap['data']['key'];
$redis = new Predis\Client(['host' => '127.0.0.1', 'port' => 6379, 'database' => 1]);
$stored = $redis->get('sys:captcha:' . $key);
$code = str_contains((string) $stored, '::') ? explode('::', (string) $stored, 2)[1] : (string) $stored;
echo "key=$key code=$code\n";

$sm2 = new Rtgm\sm\RtSm2('hex', true);
$pwd = $sm2->doEncrypt('123456', Icejz\Support\SmCrypto::publicKeyHex());
if (!str_starts_with($pwd, '04')) {
    $pwd = '04' . $pwd;
}

$body = json_encode([
    'username' => 'admin',
    'password' => $pwd,
    'key' => $key,
    'captcha' => $code,
], JSON_UNESCAPED_UNICODE);

$ch = curl_init("$base/sys/auth/login");
curl_setopt_array($ch, [
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_POST => true,
    CURLOPT_HTTPHEADER => ['Content-Type: application/json', 'X-Client-Type: app'],
    CURLOPT_POSTFIELDS => $body,
]);
$resp = curl_exec($ch);
echo $resp, "\n";
$data = json_decode((string) $resp, true);
if (($data['code'] ?? 1) === 0) {
    $token = $data['data']['access_token'];
    echo http_get("$base/sys/user/info", ["Authorization: $token"]), "\n";
    echo http_get("$base/sys/message/my/unread-count", ["Authorization: $token"]), "\n";
    echo http_get("$base/sys/ai/robot/info", ["Authorization: $token"]), "\n";
}
