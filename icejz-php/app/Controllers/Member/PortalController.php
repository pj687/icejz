<?php

namespace Icejz\Controllers\Member;

use Icejz\Support\Result;

/**
 * Member portal stubs — same strategy as icejz-boot (not yet opened).
 */
final class PortalController
{
    public function emptyList(): array
    {
        return Result::ok([]);
    }

    public function emptyPage(): array
    {
        return Result::ok(['total' => 0, 'list' => [], 'summary' => null]);
    }

    public function notOpen(): array
    {
        return Result::error('尚未开通');
    }

    public function ok(): array
    {
        return Result::ok();
    }
}
