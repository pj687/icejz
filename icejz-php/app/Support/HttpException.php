<?php

namespace Icejz\Support;

use Exception;

final class HttpException extends Exception
{
    public function __construct(string $message, private int $errorCode = 500, ?\Throwable $previous = null)
    {
        parent::__construct($message, $errorCode, $previous);
    }

    public function getErrorCode(): int
    {
        return $this->errorCode;
    }
}
