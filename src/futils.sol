// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";

/// @notice utils for array manipulation
/// @author phaze (https://github.com/0xPhaze)
library futils {
    /* ------------- utils ------------- */

    function slice(uint256[] memory arr, uint256 to) internal pure returns (uint256[] memory out) {
        return slice(arr, 0, to);
    }

    function slice(
        uint256[] memory arr,
        uint256 from,
        uint256 to
    ) internal pure returns (uint256[] memory out) {
        if (to > arr.length) return arr;
        if (to < from) return new uint256[](0);

        unchecked {
            uint256 n = to - from;
            out = new uint256[](n);

            for (uint256 i = 0; i < n; ++i) out[i] = arr[from + i];
        }
    }

    function _slice(
        uint256[] memory arr,
        uint256 from,
        uint256 to
    ) internal pure returns (uint256[] memory out) {
        if (to > arr.length) return arr;
        if (to < from) to = from;

        assembly {
            out := add(arr, mul(0x20, from))
            mstore(out, sub(to, from))
        }
    }

    function range(uint256 from, uint256 to) internal pure returns (uint256[] memory out) {
        if (to <= from) return new uint256[](0);

        unchecked {
            uint256 n = to - from;
            out = new uint256[](n);

            for (uint256 i; i < n; ++i) out[i] = from + i;
        }
    }

    function copy(uint256[] memory from) internal pure returns (uint256[] memory to) {
        uint256 n = from.length;

        to = new uint256[](n);

        unchecked {
            for (uint256 i = 0; i < n; ++i) to[i] = from[i];
        }

        return to;
    }

    function _copy(uint256[] memory from, uint256[] memory to) internal pure returns (uint256[] memory) {
        uint256 n = from.length;

        unchecked {
            for (uint256 i = 0; i < n; ++i) to[i] = from[i];
        }

        return to;
    }

    function shuffle(uint256[] memory arr, uint256 rand) internal pure returns (uint256[] memory out) {
        return _shuffle(copy(arr), rand);
    }

    function _shuffle(uint256[] memory arr, uint256 rand) internal pure returns (uint256[] memory out) {
        out = arr;

        uint256 n = arr.length;
        uint256 c;

        unchecked {
            for (uint256 i; i < n; ++i) {
                c = i + (uint256(keccak256(abi.encode(rand, i))) % (n - i));
                (out[i], out[c]) = (out[c], out[i]);
            }
        }
    }

    function shuffledRange(
        uint256 from,
        uint256 to,
        uint256 rand
    ) internal pure returns (uint256[] memory out) {
        if (to <= from) return new uint256[](0);

        unchecked {
            uint256 n = to - from;
            out = new uint256[](n);

            uint256 c;

            for (uint256 i = 0; i < n; ++i) {
                c = uint256(keccak256(abi.encode(rand, i))) % (i + 1);
                (out[c], out[i]) = (from + i, out[c]);
            }
        }
    }

    function eq(uint256[] memory a, uint256[] memory b) internal pure returns (bool) {
        uint256 aSize = a.length;
        if (aSize != b.length) return false;

        for (uint256 i; i < aSize; i++) if (a[i] != b[i]) return false;
        return true;
    }

    function exclude(uint256[] memory arr, uint256[] memory exc) internal pure returns (uint256[] memory out) {
        uint256 excLength = exc.length;
        if (excLength == 0) return arr;

        uint256 arrLength = arr.length;

        out = new uint256[](arrLength);

        uint256 k;

        for (uint256 i; i < arrLength; i++)
            for (uint256 j; j < excLength; j++) if (!includes(arr, exc[j])) out[k++] = arr[i];

        assembly {
            mstore(out, k)
        }
    }

    function sort(uint256[] memory arr) internal pure returns (uint256[] memory) {
        return _sort(copy(arr));
    }

    function _sort(uint256[] memory arr) internal pure returns (uint256[] memory) {
        uint256 n = arr.length;
        for (uint256 i; i < n; i++) {
            for (uint256 j = i + 1; j < n; j++) {
                if (arr[j] < arr[i]) (arr[i], arr[j]) = (arr[j], arr[i]);
            }
        }
        return arr;
    }

    function randomSubset(
        uint256[] memory arr,
        uint256 n,
        uint256 rand
    ) internal pure returns (uint256[] memory out) {
        return _randomSubset(copy(arr), n, rand);
    }

    function _randomSubset(
        uint256[] memory arr,
        uint256 n,
        uint256 rand
    ) internal pure returns (uint256[] memory out) {
        uint256 arrLength = arr.length;

        if (arrLength <= n) n = arrLength;

        out = arr;

        uint256 c;

        unchecked {
            for (uint256 i; i < n; ++i) {
                c = i + (uint256(keccak256(abi.encode(rand, i))) % (arrLength - i));
                (out[i], out[c]) = (out[c], out[i]);
            }
        }

        out = _slice(out, 0, n);
    }

    function extend(uint256[] memory arr, uint256 value) internal pure returns (uint256[] memory out) {
        uint256 arrLength = arr.length;
        out = _copy(arr, new uint256[](arrLength + 1));
        out[arrLength] = value;
    }

    function includes(uint256[] memory arr, uint256 item) internal pure returns (bool out) {
        for (uint256 i; i < arr.length; ++i) if (arr[i] == item) return true;
    }

    function includes(bytes32[] memory arr, bytes32 item) internal pure returns (bool out) {
        for (uint256 i; i < arr.length; ++i) if (arr[i] == item) return true;
    }

    function includes(address[] memory arr, address item) internal pure returns (bool out) {
        for (uint256 i; i < arr.length; ++i) if (arr[i] == item) return true;
    }

    /* ------------- uint8 ------------- */

    function toMemory(uint8[1] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](1);
            for (uint256 i; i < 1; ++i) out[i] = arr[i];
        }
    }

    function toMemory(uint8[2] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](2);
            for (uint256 i; i < 2; ++i) out[i] = arr[i];
        }
    }

    function toMemory(uint8[3] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](3);
            for (uint256 i; i < 3; ++i) out[i] = arr[i];
        }
    }

    function toMemory(uint8[4] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](4);
            for (uint256 i; i < 4; ++i) out[i] = arr[i];
        }
    }

    function toMemory(uint8[5] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](5);
            for (uint256 i; i < 5; ++i) out[i] = arr[i];
        }
    }

    function toMemory(uint8[6] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](6);
            for (uint256 i; i < 6; ++i) out[i] = arr[i];
        }
    }

    function toMemory(uint8[7] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](7);
            for (uint256 i; i < 7; ++i) out[i] = arr[i];
        }
    }

    function toMemory(uint8[8] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](8);
            for (uint256 i; i < 8; ++i) out[i] = arr[i];
        }
    }

    function toMemory(uint8[9] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](9);
            for (uint256 i; i < 9; ++i) out[i] = arr[i];
        }
    }

    function toMemory(uint8[10] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](10);
            for (uint256 i; i < 10; ++i) out[i] = arr[i];
        }
    }

    /* ------------- uint16 ------------- */

    function toMemory(uint16[1] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](1);
            for (uint256 i; i < 1; ++i) out[i] = arr[i];
        }
    }

    function toMemory(uint16[2] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](2);
            for (uint256 i; i < 2; ++i) out[i] = arr[i];
        }
    }

    function toMemory(uint16[3] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](3);
            for (uint256 i; i < 3; ++i) out[i] = arr[i];
        }
    }

    function toMemory(uint16[4] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](4);
            for (uint256 i; i < 4; ++i) out[i] = arr[i];
        }
    }

    function toMemory(uint16[5] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](5);
            for (uint256 i; i < 5; ++i) out[i] = arr[i];
        }
    }

    function toMemory(uint16[6] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](6);
            for (uint256 i; i < 6; ++i) out[i] = arr[i];
        }
    }

    function toMemory(uint16[7] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](7);
            for (uint256 i; i < 7; ++i) out[i] = arr[i];
        }
    }

    function toMemory(uint16[8] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](8);
            for (uint256 i; i < 8; ++i) out[i] = arr[i];
        }
    }

    function toMemory(uint16[9] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](9);
            for (uint256 i; i < 9; ++i) out[i] = arr[i];
        }
    }

    function toMemory(uint16[10] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](10);
            for (uint256 i; i < 10; ++i) out[i] = arr[i];
        }
    }

    /* ------------- uint256 ------------- */

    function toMemory(uint256[1] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](1);
            for (uint256 i; i < 1; ++i) out[i] = arr[i];
        }
    }

    function toMemory(uint256[2] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](2);
            for (uint256 i; i < 2; ++i) out[i] = arr[i];
        }
    }

    function toMemory(uint256[3] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](3);
            for (uint256 i; i < 3; ++i) out[i] = arr[i];
        }
    }

    function toMemory(uint256[4] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](4);
            for (uint256 i; i < 4; ++i) out[i] = arr[i];
        }
    }

    function toMemory(uint256[5] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](5);
            for (uint256 i; i < 5; ++i) out[i] = arr[i];
        }
    }

    function toMemory(uint256[6] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](6);
            for (uint256 i; i < 6; ++i) out[i] = arr[i];
        }
    }

    function toMemory(uint256[7] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](7);
            for (uint256 i; i < 7; ++i) out[i] = arr[i];
        }
    }

    function toMemory(uint256[8] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](8);
            for (uint256 i; i < 8; ++i) out[i] = arr[i];
        }
    }

    function toMemory(uint256[9] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](9);
            for (uint256 i; i < 9; ++i) out[i] = arr[i];
        }
    }

    function toMemory(uint256[10] memory arr) internal pure returns (uint256[] memory out) {
        unchecked {
            out = new uint256[](10);
            for (uint256 i; i < 10; ++i) out[i] = arr[i];
        }
    }

    /* ------------- debug ------------- */

    /// @notice split data to chunks of 32 bytes
    function toBytes32Array(bytes memory data) internal pure returns (bytes32[] memory split) {
        uint256 numEl = (data.length + 31) >> 5;

        split = new bytes32[](numEl);

        uint256 loc_;

        assembly {
            loc_ := add(split, 32)
        }

        mstore(loc_, data);
    }

    /// @notice stores data at offset while preserving existing memory
    function mstore(uint256 offset, bytes memory data) internal pure {
        uint256 slot;

        uint256 size = data.length;

        uint256 lastFullSlot = size >> 5;

        for (; slot < lastFullSlot; slot++) {
            assembly {
                let rel_ptr := mul(slot, 32)
                let chunk := mload(add(add(data, 32), rel_ptr))
                mstore(add(offset, rel_ptr), chunk)
            }
        }

        assembly {
            let mask := shr(shl(3, and(size, 31)), sub(0, 1))
            let rel_ptr := mul(slot, 32)
            let chunk := mload(add(add(data, 32), rel_ptr))
            let prev_data := mload(add(offset, rel_ptr))
            mstore(add(offset, rel_ptr), or(and(chunk, not(mask)), and(prev_data, mask)))
        }
    }

    /// @notice gets minimum required bytes to store value
    function getRequiredBytes(uint256 value) internal pure returns (uint256) {
        uint256 numBytes = 1;

        for (; numBytes < 32; ++numBytes) {
            value = value >> 8;
            if (value == 0) break;
        }

        return numBytes;
    }

    function dump(uint256 location, uint256 numSlots) internal view {
        bytes32 m;
        for (uint256 i; i < numSlots; i++) {
            assembly {
                m := mload(add(location, mul(32, i)))
            }
            console.log(location, 32 * i);
            console.logBytes32(m);
        }
    }

    function dump(bytes memory arg) internal view {
        dump(loc(arg), (arg.length + 1) / 32 + 1);
    }

    function dump(bytes32[] memory arg) internal view {
        dump(loc(arg), arg.length + 1);
    }

    function loc(bytes memory arr) internal pure returns (uint256 loc_) {
        assembly { loc_ := arr } // prettier-ignore
    }

    function loc(bytes32[] memory arr) internal pure returns (uint256 loc_) {
        assembly { loc_ := arr } // prettier-ignore
    }

    function loc(uint256[] memory arr) internal pure returns (uint256 loc_) {
        assembly { loc_ := arr } // prettier-ignore
    }

    function scrambleMem(bytes32[] memory arr) internal pure {
        return scrambleMem(loc(arr) + 32, arr.length * 32);
    }

    function scrambleMem(uint256 offset, uint256 bytesLen) internal pure {
        uint256 slot;
        bytes32 rand;

        uint256 lastFullSlot = bytesLen >> 5;

        for (; slot < lastFullSlot; slot++) {
            rand = keccak256(abi.encodePacked(slot));

            assembly {
                mstore(add(offset, mul(slot, 32)), rand)
            }
        }

        uint256 mask = type(uint256).max >> ((bytesLen & 31) << 3);

        rand = keccak256(abi.encodePacked(slot));

        assembly {
            let location := add(offset, mul(slot, 32))
            let data := mload(location)
            mstore(location, or(and(data, mask), and(rand, not(mask))))
        }
    }

    function scrambleStorage(uint256 offset, uint256 numSlots) public {
        bytes32 rand;
        for (uint256 slot; slot < numSlots; slot++) {
            rand = keccak256(abi.encodePacked(offset + slot));

            assembly {
                sstore(add(slot, offset), rand)
            }
        }
    }

    function mstore(
        uint256 offset,
        bytes32 val,
        uint256 bytesLen
    ) internal pure {
        assembly {
            let mask := shr(mul(bytesLen, 8), sub(0, 1))
            mstore(offset, or(and(val, not(mask)), and(mload(offset), mask)))
        }
    }
}
