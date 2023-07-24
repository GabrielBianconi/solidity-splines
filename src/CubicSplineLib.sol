// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library CubicSplineLib {
    // =========================================================================
    //                                  ERRORS
    // =========================================================================

    error InvalidIndex();
    error InvalidSplineKnots();
    error SplineCannotBeEmpty();
    error ValueOutOfBounds();

    // =========================================================================
    //                                  STRUCTS
    // =========================================================================

    // @dev `knot1` is repetitive in a SplineSegment[] array but this saves gas during evaluation
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
     * @notice Validate that the spline is well-formed. Namely, that:
     *           - the spline is not empty
     *           - the spline is continuous
     *           - the knots are in ascending order
     *
     * @dev We use this somewhat cumbersome iterative implementation to save on gas vs. a naive loop.
     *
     * @param spline The spline to validate
     */
    function validate(SplineSegment[] storage spline) internal view {
        if (spline.length == 0) revert SplineCannotBeEmpty();

        SplineSegment memory segment = spline[0];
        SplineSegment memory next_segment;

        if (segment.knot0 >= segment.knot1) revert InvalidSplineKnots();

        for (uint256 i = 1; i < spline.length; i++) {
            next_segment = spline[i];

            int256 y = evalPolynomial(segment.a, segment.b, segment.c, segment.d, segment.knot1 - segment.knot0);
            int256 next_y = evalPolynomial(next_segment.a, next_segment.b, next_segment.c, next_segment.d, 0);

            if (segment.knot1 != next_segment.knot0 || !approxEq(y, next_y) || next_segment.knot0 >= next_segment.knot1)
            {
                revert InvalidSplineKnots();
            }

            segment = next_segment;
        }
    }

    /**
     * @notice Evaluate a cubic polynomial at a given point: y = a * x^3 + b * x^2 + c * x + d
     *
     * @param a The coefficient of x^3
     * @param b The coefficient of x^2
     * @param c The coefficient of x
     * @param d The constant term
     * @param x The point at which to evaluate the polynomial
     *
     * @return The value of the polynomial at x
     */
    function evalPolynomial(int256 a, int256 b, int256 c, int256 d, int256 x) internal pure returns (int256) {
        int256 x2 = mulWad(x, x);
        int256 x3 = mulWad(x2, x);

        return mulWad(a, x3) + mulWad(b, x2) + mulWad(c, x) + d;
    }

    /**
     * @notice Evaluate a spline at a given point, with the correct segment provided.
     *
     * @dev If the segment index is not known, use `evalWithBinarySearch` instead.
     *
     * @param spline The spline to evaluate
     * @param index The index of the spline segment to evaluate
     * @param x The point at which to evaluate the spline
     *
     * @return The value of the spline at x
     */
    function evalWithSegmentIndex(SplineSegment[] storage spline, uint256 index, int256 x)
        internal
        view
        returns (int256)
    {
        if (index >= spline.length) revert InvalidIndex();

        SplineSegment memory segment = spline[index];

        if (x < segment.knot0 || x > segment.knot1) revert ValueOutOfBounds();

        return evalPolynomial(segment.a, segment.b, segment.c, segment.d, x - segment.knot0);
    }

    /**
     * @notice Evaluate a spline at a given point, without providing the speicific segment.
     *
     * @dev If the segment index is known, use `evalWithSegmentIndex` instead.
     *
     * @param spline The spline to evaluate
     * @param x The point at which to evaluate the spline
     *
     * @return The value of the spline at x
     */
    function evalWithBinarySearch(SplineSegment[] storage spline, int256 x) internal view returns (int256) {
        uint256 low = 0;
        uint256 high = spline.length - 1;

        if (x < spline[low].knot0 || x > spline[high].knot1) revert ValueOutOfBounds();

        while (low < high) {
            uint256 mid = (low + high) / 2;

            if (spline[mid].knot1 < x) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }

        SplineSegment memory segment = spline[low];

        return evalPolynomial(segment.a, segment.b, segment.c, segment.d, x - segment.knot0);
    }

    // =========================================================================
    //                               MATH HELPERS
    // =========================================================================

    int256 public constant WAD = 1e18; // a, b, c, d, knot0, knot1, and x have this precision
    uint256 public constant EPSILON = 1e6; // two fixed-precision numbers are considered equal if their difference is less than this (for `approxEq`)

    /**
     * @notice Compute the absolute value of a signed integer
     *
     * @param x The signed integer
     *
     * @return The absolute value of x
     */
    function abs(int256 x) internal pure returns (uint256) {
        return uint256(x < 0 ? -x : x);
    }

    /**
     * @notice Check if two fixed-precision numbers are approximately equal (within `EPSILON` precision)
     *
     * @param x The first number
     * @param y The second number
     *
     * @return True if the numbers are approximately equal, false otherwise
     */
    function approxEq(int256 x, int256 y) internal pure returns (bool) {
        return abs(x - y) <= EPSILON;
    }

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
