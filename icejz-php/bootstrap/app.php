<?php

use Icejz\Support\Application;
use Icejz\Support\Config;
use Icejz\Support\Env;

require_once dirname(__DIR__) . '/vendor/autoload.php';
require_once dirname(__DIR__) . '/app/Support/helpers.php';

Env::load(dirname(__DIR__) . '/.env');
Config::load(dirname(__DIR__) . '/config');

$app = new Application();
require dirname(__DIR__) . '/routes/api.php';

return $app;
