package ru.simohin.posusekam

import kotlin.test.*

class FibonacciTest {

    @Test
    fun testFibonacciNumbers() {
        assertFails {
            generateFibonacci(-1)
        }
        assertEquals(
            listOf(0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377),
            generateFibonacci(15)
        )
    }

}