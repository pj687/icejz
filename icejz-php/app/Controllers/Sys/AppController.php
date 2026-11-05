<?php

namespace Icejz\Controllers\Sys;

use Icejz\Support\Result;

final class AppController
{
    public function version(): array
    {
        return Result::ok([
            'name' => config('app.name'),
            'version' => config('app.version'),
            'application' => 'icejz-php',
        ]);
    }
}
