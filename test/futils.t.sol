// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";

import "../src/futils.sol";

contract TestFUtils is Test {
    using futils for *;

    function test_random_fail_SeedUnset() public {
        vm.expectRevert("Random seed unset.");
        random.next();
    }

    struct T {
        uint256 a;
        uint256 b;
    }

    /// @dev needs more testing
    function test_toEncodedArrayType() public {
        T[] memory t = new T[](4);
        t[0] = T({a: 0x111, b: 0x222});
        t[1] = T({a: 0x333, b: 0x444});
        t[2] = T({a: 0x555, b: 0x666});
        t[3] = T({a: 0x777, b: 0x888});

        bytes memory tdata = abi.encode(t[0], t[1], t[2], t[3]).toEncodedArrayType(64);

        T[] memory t2 = abi.decode(tdata, (T[]));

        assertEq(t[0].a, t2[0].a);
        assertEq(t[0].b, t2[0].b);
        assertEq(t[1].a, t2[1].a);
        assertEq(t[1].b, t2[1].b);
        assertEq(t[2].a, t2[2].a);
        assertEq(t[2].b, t2[2].b);
        assertEq(t[3].a, t2[3].a);
        assertEq(t[3].b, t2[3].b);
    }

    function test_toMemory() public {
        uint256[] memory arr = new uint256[](3);
        arr[0] = 0x123;
        arr[1] = 0x124;
        arr[2] = 0x125;

        assertEq(arr, [0x123, 0x124, 0x125].toMemory());
    }

    function testToStringArray() public {
        string[4] memory arr = ["test123", "", "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAa", "xx"];
        string[] memory arr2 = arr.toMemory();

        assertEq(arr[0], arr2[0]);
        assertEq(arr[1], arr2[1]);
        assertEq(arr[2], arr2[2]);
        assertEq(arr[3], arr2[3]);
    }

    // function test_filterIndices(uint256 seed) public {
    //     random.seed(seed);
    // }
}

contract TestSets is Test {
    using futils for *;

    uint256 constant MAX = 100;
    uint256 constant MAX_CEIL = type(uint256).max - MAX;

    /* ------------- helpers ------------- */

    function assertIsSubset(uint256[] memory a, uint256[] memory b) internal {
        if (!a.isSubset(b)) fail("A <= B does not hold.");
    }

    function assertNotIncludes(uint256[] memory arr, uint256 value) internal {
        if (arr.includes(value)) fail(string.concat("Array includes unexpected value.", vm.toString(value)));
    }

    /* ------------- test ------------- */

    function test_sort(uint256[] memory input, uint256 seed) public {
        random.seed(seed);

        uint256[] memory sorted = input.sort();

        for (uint256 i = 1; i < sorted.length; i++) {
            assertTrue(sorted[i - 1] <= sorted[i]);
        }

        // still does not guarantee
        // equality of "sets"
        assertIsSubset(sorted, input);
        assertIsSubset(input, sorted);
    }

    function test_randomSubset(uint256 from, uint256 size, uint256 subsetSize, uint256 seed) public {
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
    function test_union(uint256[] memory a, uint256[] memory b, uint256 seed) public {
        random.seed(seed);

        uint256[] memory union = a.union(b);

        assertIsSubset(a, union);
        assertIsSubset(b, union);
    }

    /// @dev assumes unique elements
    function test_exclusion(uint256 fromA, uint256 sizeA, uint256 fromB, uint256 sizeB, uint256 seed) public {
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

        for (uint256 i; i < setB.length; i++) {
            assertNotIncludes(set, setB[i]);
        }
    }

    /* ------------- permutations ------------- */

    function testQuickPerm() public {
        uint256[] memory array = [3, 1, 4, 5].toMemory();

        uint256[] memory arraySorted = array.sort();
        uint256[][] memory perms = array.quickPerm();

        for (uint256 i; i < perms.length; i++) {
            for (uint256 j; j < perms.length; j++) {
                if (i != j) {
                    assertFalse(perms[i].eq(perms[j]));
                }
            }
            assertTrue(perms[i].sort().eq(arraySorted));
        }
    }

    function testInvPerm() public {
        uint256[][] memory perms = 0.range(4).quickPerm();

        for (uint256 n; n < perms.length; n++) {
            uint256[] memory perm = perms[n];
            uint256[] memory inv = perm.invPerm();

            for (uint256 i; i < inv.length; i++) {
                assertEq(inv[perm[i]], i);
            }
        }
    }
}
