// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {CubicSplineLib} from "src/CubicSplineLib.sol";

contract CubicSplineTest is Test {
    CubicSplineLib.SplineSegment[] public spline;

    using CubicSplineLib for CubicSplineLib.SplineSegment[];

    function setUp() public {
        // The following spline is the natural cubic spline interpolation for:
        // [[0, 0], [0.8, 0.5], [0.9, 0.4], [1.0, 0.5]]
        spline.push(
            CubicSplineLib.SplineSegment({
                a: -1.496478873239436735e18,
                b: 0.000000000000000222e18,
                c: 1.582746478873239493e18,
                d: 0.0e18,
                knot0: 0.0e18,
                knot1: 0.8e18
            })
        );
        spline.push(
            CubicSplineLib.SplineSegment({
                a: 64.964788732394353588e18,
                b: -3.59154929577464177e18,
                c: -1.290492957746479208e18,
                d: 0.5e18,
                knot0: 0.8e18,
                knot1: 0.9e18
            })
        );
        spline.push(
            CubicSplineLib.SplineSegment({
                a: -52.992957746478872139e18,
                b: 15.897887323943663773e18,
                c: -0.059859154929577538e18,
                d: 0.400000000000000022e18,
                knot0: 0.9e18,
                knot1: 1.0e18
            })
        );
    }

    function testValidateValidSplines() public {
        spline.validate(); // spline with three segments
        spline.pop();
        spline.validate(); // spline with two segments
        spline.pop();
        spline.validate(); // spline with one segment
        assertEq(spline.length, 1); // make sure we don't break this test accidentally later
    }

    function testRevertValidateEmptySpline() public {
        delete spline;
        vm.expectRevert(abi.encodeWithSelector(CubicSplineLib.SplineCannotBeEmpty.selector));
        spline.validate();
    }

    function testRevertValidateSplineWithXGap() public {
        delete spline;
        spline.push(CubicSplineLib.SplineSegment({a: 0, b: 0, c: 0, d: 0, knot0: 1, knot1: 2}));
        spline.push(CubicSplineLib.SplineSegment({a: 0, b: 0, c: 0, d: 0, knot0: 3, knot1: 4}));
        vm.expectRevert(abi.encodeWithSelector(CubicSplineLib.InvalidSplineKnots.selector));
        spline.validate();
    }

    function testRevertValidateSplineWithYGap() public {
        delete spline;
        spline.push(CubicSplineLib.SplineSegment({a: 0, b: 0, c: 0, d: 0, knot0: 1, knot1: 2}));
        spline.push(CubicSplineLib.SplineSegment({a: 0, b: 0, c: 0, d: 1e18, knot0: 2, knot1: 3}));
        vm.expectRevert(abi.encodeWithSelector(CubicSplineLib.InvalidSplineKnots.selector));
        spline.validate();
    }

    function testRevertValidateSplineWithNonIncreasingKnots() public {
        delete spline;
        spline.push(CubicSplineLib.SplineSegment({a: 0, b: 0, c: 0, d: 0, knot0: 1, knot1: 0}));
        vm.expectRevert(abi.encodeWithSelector(CubicSplineLib.InvalidSplineKnots.selector));
        spline.validate();
    }

    function testRevertValidateSplineWithDuplicatedKnots() public {
        delete spline;
        spline.push(CubicSplineLib.SplineSegment({a: 0, b: 0, c: 0, d: 0, knot0: 0, knot1: 1}));
        spline.push(CubicSplineLib.SplineSegment({a: 0, b: 0, c: 0, d: 0, knot0: 0, knot1: 1}));
        vm.expectRevert(abi.encodeWithSelector(CubicSplineLib.InvalidSplineKnots.selector));
        spline.validate();
    }

    function testEvalPolynomial() public {
        assertApproxEqAbs(
            CubicSplineLib.evalPolynomial(2.19384473e18, 0.58131653e18, -0.13454918e18, 0.36528631e18, 0.32848131e18),
            0.4615701662620617e18,
            CubicSplineLib.EPSILON
        );
    }

    function testEvalWithSegmentIndex() public {
        // Evaluate a value in the first segment
        assertApproxEqAbs(
            CubicSplineLib.evalWithSegmentIndex(spline, 0, 0.5e18), 0.6043133802816902e18, CubicSplineLib.EPSILON
        );

        // Evaluate a value in the second segment
        assertApproxEqAbs(
            CubicSplineLib.evalWithSegmentIndex(spline, 1, 0.86020368e18),
            0.42346585119343416e18,
            CubicSplineLib.EPSILON
        );

        // Evaluate a value in the third segment
        assertApproxEqAbs(
            CubicSplineLib.evalWithSegmentIndex(spline, 2, 0.92962955e18), 0.410804860814757e18, CubicSplineLib.EPSILON
        );

        // Evaluate the bounds and knots of the spline
        assertApproxEqAbs(CubicSplineLib.evalWithSegmentIndex(spline, 0, 0.0e18), 0.0e18, CubicSplineLib.EPSILON);
        assertApproxEqAbs(CubicSplineLib.evalWithSegmentIndex(spline, 0, 0.8e18), 0.5e18, CubicSplineLib.EPSILON);
        assertApproxEqAbs(CubicSplineLib.evalWithSegmentIndex(spline, 1, 0.8e18), 0.5e18, CubicSplineLib.EPSILON);
        assertApproxEqAbs(CubicSplineLib.evalWithSegmentIndex(spline, 1, 0.9e18), 0.4e18, CubicSplineLib.EPSILON);
        assertApproxEqAbs(CubicSplineLib.evalWithSegmentIndex(spline, 2, 0.9e18), 0.4e18, CubicSplineLib.EPSILON);
        assertApproxEqAbs(CubicSplineLib.evalWithSegmentIndex(spline, 2, 1.0e18), 0.5e18, CubicSplineLib.EPSILON);
    }

    function testRevertEvalWithSegmentIndexValueOutOfBoundsLeft() public {
        vm.expectRevert(abi.encodeWithSelector(CubicSplineLib.ValueOutOfBounds.selector));
        CubicSplineLib.evalWithSegmentIndex(spline, 1, 0.75e18); // in the bounds of the spline but not the segment
    }

    function testRevertEvalWithSegmentIndexValueOutOfBoundsRight() public {
        vm.expectRevert(abi.encodeWithSelector(CubicSplineLib.ValueOutOfBounds.selector));
        CubicSplineLib.evalWithSegmentIndex(spline, 1, 0.95e18); // in the bounds of the spline but not the segment
    }

    function testRevertEvalWithSegmentIndexInvalidIndex() public {
        vm.expectRevert(abi.encodeWithSelector(CubicSplineLib.InvalidIndex.selector));
        CubicSplineLib.evalWithSegmentIndex(spline, spline.length, 1.0e18);
    }

    function testRevertEvalWithSegmentIndexInvalidIndexEmptySpline() public {
        delete spline;
        vm.expectRevert(abi.encodeWithSelector(CubicSplineLib.InvalidIndex.selector));
        CubicSplineLib.evalWithSegmentIndex(spline, 0, 0.0e18);
    }

    function testEvalWithBinarySearch() public {
        // Evaluate a value in the first segment
        assertApproxEqAbs(
            CubicSplineLib.evalWithBinarySearch(spline, 0.5e18), 0.6043133802816902e18, CubicSplineLib.EPSILON
        );

        // Evaluate a value in the second segment
        assertApproxEqAbs(
            CubicSplineLib.evalWithBinarySearch(spline, 0.86020368e18), 0.42346585119343416e18, CubicSplineLib.EPSILON
        );

        // Evaluate a value in the third segment
        assertApproxEqAbs(
            CubicSplineLib.evalWithBinarySearch(spline, 0.92962955e18), 0.410804860814757e18, CubicSplineLib.EPSILON
        );

        // Evaluate the bounds and knots of the spline
        assertApproxEqAbs(CubicSplineLib.evalWithBinarySearch(spline, 0.0e18), 0.0e18, CubicSplineLib.EPSILON);
        assertApproxEqAbs(CubicSplineLib.evalWithBinarySearch(spline, 0.8e18), 0.5e18, CubicSplineLib.EPSILON);
        assertApproxEqAbs(CubicSplineLib.evalWithBinarySearch(spline, 0.8e18), 0.5e18, CubicSplineLib.EPSILON);
        assertApproxEqAbs(CubicSplineLib.evalWithBinarySearch(spline, 0.9e18), 0.4e18, CubicSplineLib.EPSILON);
        assertApproxEqAbs(CubicSplineLib.evalWithBinarySearch(spline, 0.9e18), 0.4e18, CubicSplineLib.EPSILON);
        assertApproxEqAbs(CubicSplineLib.evalWithBinarySearch(spline, 1.0e18), 0.5e18, CubicSplineLib.EPSILON);
    }

    function testRevertEvalWithBinarySearchOutOfBoundsLeft() public {
        vm.expectRevert(abi.encodeWithSelector(CubicSplineLib.ValueOutOfBounds.selector));
        CubicSplineLib.evalWithBinarySearch(spline, spline[0].knot0 - 1.0e18);
    }

    function testRevertEvalWithBinarySearchOutOfBoundsRight() public {
        vm.expectRevert(abi.encodeWithSelector(CubicSplineLib.ValueOutOfBounds.selector));
        CubicSplineLib.evalWithBinarySearch(spline, spline[spline.length - 1].knot1 + 1.0e18);
    }
}
