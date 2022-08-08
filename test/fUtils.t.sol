// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../src/fUtils.sol";

import "forge-std/Test.sol";

contract TestFUtils is Test {
    using fUtils for *;

    uint256 constant MAX = 100;
    uint256 constant MAX_CEIL = type(uint256).max - MAX;

    function assertIncludes(uint256[] memory arr, uint256 value) internal {
        if (!arr.includes(value)) {
            emit log_named_uint("Could not find", value);
            fail("Array does not include value");
        }
    }

    function test_random_fail_SeedUnset() public {
        vm.expectRevert("Random seed unset.");
        random.next();
    }

    // function test_range(uint256 from, uint256 size) public {
    //     from = bound(from, 0, MAX_CEIL);
    //     size = bound(size, 0, MAX);

    //     uint256 to = from + size;

    //     uint256[] memory range = from.range(to);

    //     for (uint256 i; i < size; i++) assertEq(range[i], from + i);
    // }

    function test_shuffledRange(
        uint256 from,
        uint256 size,
        uint256 rand
    ) public {
        random.seed(rand);

        from = bound(from, 0, MAX_CEIL);
        size = bound(size, 0, MAX);

        uint256 to = from + size;

        uint256[] memory shuffled = from.shuffledRange(to);

        // local rejects should flag if this were always the case
        vm.assume(!shuffled.eq(from.range(to)));

        assertEq(shuffled.length, size);

        for (uint256 i; i < size; i++) console.log(shuffled[i]);

        for (uint256 i; i < size; i++) assertIncludes(shuffled, from + i);
    }

    function test_sort(
        uint256 from,
        uint256 size,
        uint256 rand
    ) public {
        random.seed(rand);

        from = bound(from, 0, MAX_CEIL);
        size = bound(size, 0, MAX);

        uint256 to = from + size;

        uint256[] memory shuffled = from.shuffledRange(to);

        assertEq(shuffled.sort(), from.range(to));
    }
}
