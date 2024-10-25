<?php

namespace App\Tests;

use App\DummyClass;
use PHPUnit\Framework\TestCase;

/**
 * @covers
 */
class DummyClassTest extends TestCase
{
    public function testDummy(): void
    {
        $object = new DummyClass();
        $this->assertEquals('Hallo World', $object->dummy());
    }
}
