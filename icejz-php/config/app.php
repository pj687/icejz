<?php

return [
    'name' => env('APP_NAME', 'ICEJZ'),
    'version' => env('APP_VERSION', '1.0.5'),
    'debug' => filter_var(env('APP_DEBUG', true), FILTER_VALIDATE_BOOLEAN),
    'url' => env('APP_URL', 'http://localhost:8080'),
    'timezone' => 'Asia/Shanghai',
    'sms_mock' => filter_var(env('SMS_MOCK', true), FILTER_VALIDATE_BOOLEAN),
    'storage_path' => env('STORAGE_PATH', 'storage/upload'),
    'storage_domain' => env('STORAGE_DOMAIN', 'http://localhost:8080'),
];
