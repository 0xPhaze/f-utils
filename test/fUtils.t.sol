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

    function assertNotIncludes(uint256[] memory arr, uint256 value) internal {
        if (arr.includes(value)) fail(string.concat("Array includes unexpected value.", vm.toString(value)));
    }

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

        uint256[] memory range = from.range(to);
        uint256[] memory shuffled = from.shuffledRange(to);

        // local rejects should flag if this were always the case
        vm.assume(!shuffled.eq(range));

        assertIsSubset(range, shuffled);
    }

    function test_sort(uint256[] memory input, uint256 seed) public {
        random.seed(seed);

        uint256[] memory sorted = input.sort();

        for (uint256 i = 1; i < sorted.length; i++) assertTrue(sorted[i - 1] <= sorted[i]);

        // still does not guarantee
        // equality of "sets"
        assertIsSubset(sorted, input);
        assertIsSubset(input, sorted);
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

    /// @dev tests would not be conclusive for
    /// general arrays that include duplicates
    function test_union(
        uint256[] memory a,
        uint256[] memory b,
        uint256 seed
    ) public {
        random.seed(seed);

        uint256[] memory union = a.union(b);

        assertIsSubset(a, union);
        assertIsSubset(b, union);
    }

    /// @dev assumes unique elements
    function test_exclusion(
        uint256 fromA,
        uint256 sizeA,
        uint256 fromB,
        uint256 sizeB,
        uint256 seed
    ) public {
        random.seed(seed);

        sizeA = bound(sizeA, 0, MAX);
        sizeB = bound(sizeB, 0, MAX);

        fromA = bound(fromA, 0, MAX_CEIL);
        fromB = bound(fromB, 0, MAX_CEIL);

        uint256 toA = fromA + sizeA;
        uint256 toB = fromB + sizeB;

        uint256[] memory setA = fromA.shuffledRange(toA);
        uint256[] memory setB = fromB.shuffledRange(toB);

        uint256[] memory set = setA.exclusion(setB);

        assertIsSubset(set, setA);

        for (uint256 i; i < setB.length; i++) assertNotIncludes(set, setB[i]);
    }

    // function test_filterIndices(uint256 seed) public {
    //     random.seed(seed);
    // }
}
