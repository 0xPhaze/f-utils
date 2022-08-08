// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../src/fUtils.sol";

import "forge-std/Test.sol";

contract TestFUtils is Test {
    using fUtils for *;

    uint256 constant MAX = 100;
    uint256 constant MAX_CEIL = type(uint256).max - MAX;

    function assertIsSubset(uint256[] memory a, uint256[] memory b) internal {
        if (!a.isSubset(b)) fail("A <= B does not hold.");
    }

    // function assertIncludes(uint256[] memory arr, uint256 value) internal {
    //     if (!arr.includes(value)) {
    //         emit log_named_uint("Could not find", value);
    //         fail("Array does not include value");
    //     }
    // }

    function test_random_fail_SeedUnset() public {
        vm.expectRevert("Random seed unset.");
        random.next();
    }

    function test_range(uint256 from, uint256 size) public {
        size = bound(size, 0, MAX);
        from = bound(from, 0, MAX_CEIL);

        uint256 to = from + size;

        uint256[] memory range = from.range(to);

        for (uint256 i; i < size; i++) assertEq(range[i], from + i);
    }

    function test_shuffledRange(
        uint256 from,
        uint256 size,
        uint256 seed
    ) public {
        random.seed(seed);

        size = bound(size, 0, MAX);
        from = bound(from, 0, MAX_CEIL);

        uint256 to = from + size;

        uint256[] memory shuffled = from.shuffledRange(to);

        // local rejects should flag if this were always the case
        vm.assume(!shuffled.eq(from.range(to)));

        assertEq(shuffled.length, size);

        for (uint256 i; i < size; i++) console.log(shuffled[i]);

        assertIsSubset(shuffled, from.range(to));
    }

    function test_sort(
        uint256 from,
        uint256 size,
        uint256 seed
    ) public {
        random.seed(seed);

        size = bound(size, 0, MAX);
        from = bound(from, 0, MAX_CEIL);

        uint256 to = from + size;

        uint256[] memory shuffled = from.shuffledRange(to);

        assertEq(shuffled.sort(), from.range(to));
    }

    function test_randomSubset(
        uint256 from,
        uint256 size,
        uint256 subsetSize,
        uint256 seed
    ) public {
        random.seed(seed);

        size = bound(size, 0, MAX);
        from = bound(from, 0, MAX_CEIL);

        subsetSize = bound(subsetSize, 0, size);

        uint256 to = from + size;

        uint256[] memory range = from.range(to);
        uint256[] memory subset = range.randomSubset(subsetSize);

        assertIsSubset(subset, range);
    }
}
