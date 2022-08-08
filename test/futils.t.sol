// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../src/futils.sol";

import "forge-std/Test.sol";

contract TestFUtils is Test {
    using futils for *;

    uint256 constant MAX = 100;
    uint256 constant MAX_CEIL = type(uint256).max - MAX;

    function assertIncludes(uint256[] memory arr, uint256 value) internal {
        if (!arr.includes(value)) {
            emit log_named_uint("Could not find", value);
            fail("Array does not include value");
        }
    }

    function assertEq(uint256[] memory a, uint256[] memory b) internal {
        if (a.length != b.length) fail("Array size mismatch");

        for (uint256 i; i < a.length; i++)
            if (a[i] != b[i]) {
                emit log_named_uint("Array does not include value", a[i]);
                fail("Array a != b");
            }
    }

    // function test_range(uint256 from, uint256 size) public {
    //     from = bound(from, 0, MAX_CEIL);
    //     size = bound(size, 0, MAX);

    //     uint256 to = from + size;

    //     uint256[] memory range = from.range(to);

    //     console.log(range.loc());

    //     assertEq(range.length, size);

    //     for (uint256 i; i < size; i++) assertEq(range[i], from + i);
    // }

    // function test_shuffledRange(
    //     uint256 from,
    //     uint256 size,
    //     uint256 rand
    // ) public {
    //     from = bound(from, 0, MAX_CEIL);
    //     size = bound(size, 0, MAX);

    //     uint256 to = from + size;

    //     uint256[] memory shuffled = from.shuffledRange(to, rand);

    //     // global rejects would flag if this were always the case
    //     vm.assume(!shuffled.eq(from.range(to)));

    //     assertEq(shuffled.length, size);

    //     for (uint256 i; i < size; i++) console.log(shuffled[i]);

    //     for (uint256 i; i < size; i++) assertIncludes(shuffled, from + i);
    // }

    function log(uint256[] memory arr) {
        console.log("Arr [", arr.length, "]");
        for (uint256 i; i < arr.length; i++) console.log(i, arr[i]);
    }

    function test_sort(
        uint256 from,
        uint256 size,
        uint256 rand
    ) public {
        test_sort(from, size, rand);
    }

    function test_sort(
        uint256 from,
        uint256 size,
        uint256 rand
    ) internal {
        from = bound(from, 0, MAX_CEIL);
        size = bound(size, 0, MAX);

        uint256 to = from + size;

        uint256[] memory shuffled = from.shuffledRange(to, rand);
        uint256[] memory sorted = shuffled.sort();

        log(shuffled);
        log(sorted);
        // console.log();

        // fail();

        assertEq(sorted, from.range(to));
    }
}
