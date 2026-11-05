<?php

return [
    'access_token_expire' => (int) env('ACCESS_TOKEN_EXPIRE', 28800),
    'refresh_token_expire' => (int) env('REFRESH_TOKEN_EXPIRE', 1209600),
    // Same key pair as icejz-boot Sm2Util
    'sm2_public_key_hex' => '0417b623de43a93a94bf272b4a19cfb796c1acce8a65bc818357ccf9022ffa4ac35748eb5a502a435ec93b45b0038b59d8df36542d38cc48a9a507fbb210a65019',
    'sm2_private_key_hex' => '14cc9f79077cb4e680e98f09a13901c2a3ca92810d08287e473a52e44a6cb300',
    'permit_urls' => [
        '/',
        '/sys/auth/captcha',
        '/sys/auth/captcha/enabled',
        '/sys/auth/captcha/check',
        '/sys/auth/public-key',
        '/sys/auth/login',
        '/sys/auth/token',
        '/sys/auth/send/code',
        '/sys/auth/mobile',
        '/sys/auth/third',
        '/sys/auth/complete-profile',
        '/sys/app/version',
        '/upload/*',
    ],
];
