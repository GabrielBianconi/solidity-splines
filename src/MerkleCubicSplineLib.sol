// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

library MerkleCubicSplineLib {
    // =========================================================================
    //                                  ERRORS
    // =========================================================================

    error InvalidMerkleProof();
    error ValueOutOfBounds(int256 x, int256 min, int256 max);

    // =========================================================================
    //                                  STRUCTS
    // =========================================================================

    struct SplineSegment {
        int256 a; // y = a * x**3
        int256 b; //   + b * x**2
        int256 c; //   + c * x
        int256 d; //   + d
        int256 knot0; // with knot0 <= x
        int256 knot1; //                 <= knot1
    }

    // =========================================================================
    //                              CORE FUNCTIONS
    // =========================================================================

    /**
     * @notice Verify a spline segment against a Merkle proof
     *
     * @param segment The spline segment
     * @param proof The Merkle proof
     * @param root The Merkle root
     */
    function verifySplineSegment(SplineSegment memory segment, bytes32[] memory proof, bytes32 root) internal pure {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(segment))));

        if (!MerkleProof.verify(proof, root, leaf)) {
            revert InvalidMerkleProof();
        }
    }

    /**
     * @notice Evaluate a spline segment at a given point: y = a * x^3 + b * x^2 + c * x + d
     *
     * @param segment The spline segment
     * @param x The point at which to evaluate the polynomial
     *
     * @return The value of the polynomial at x
     */
    function evalSplineSegment(SplineSegment memory segment, int256 x) internal pure returns (int256) {
        if (x < segment.knot0 || x > segment.knot1) {
            revert ValueOutOfBounds(x, segment.knot0, segment.knot1);
        }

        x = x - segment.knot0; // shift x to be relative to knot0

        int256 x2 = mulWad(x, x);
        int256 x3 = mulWad(x2, x);

        return mulWad(segment.a, x3) + mulWad(segment.b, x2) + mulWad(segment.c, x) + segment.d;
    }

    // =========================================================================
    //                               MATH HELPERS
    // =========================================================================

    int256 public constant WAD = 1e18; // a, b, c, d, knot0, knot1, and x have this precision

    /**
     * @notice Multiply two fixed-precision numbers, rounding down.
     *
     * @dev Both numbers should have `WAD` precision.
     *
     * @param x The first number
     * @param y The second number
     *
     * @return The product of x and y, in WAD precision
     */
    function mulWad(int256 x, int256 y) internal pure returns (int256) {
        return (x * y) / WAD;
    }
}
