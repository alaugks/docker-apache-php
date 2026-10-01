<?php

namespace App\Tests;

use App\DummyClass;
use PHPUnit\Framework\Attributes\CoversClass;
use PHPUnit\Framework\TestCase;

#[CoversClass(DummyClass::class)]
class DummyClassTest extends TestCase
{
    public function testDummy(): void
    {
        $object = new DummyClass();
        $this->assertEquals('Hallo World', $object->dummy());
    }
}
