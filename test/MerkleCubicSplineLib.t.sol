// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {MerkleCubicSplineLib} from "src/MerkleCubicSplineLib.sol";

contract MerkleCubicSplineTest is Test {
    uint256 public constant EPSILON = 1e18 / 1e8; // numbers within 1e-8 (%) are considered equal

    /**
     * @dev To reproduce the parameters used in these tests, refer to the following reference scripts:
     *
     * ```
     * cd reference/
     * python generate_massive_spline.py
     * npx ts-node generate_massive_spline_merkle_tree.ts
     * npx ts-node generate_massive_spline_merkle_proof.ts
     * ```
     */
    function testVerifySplineSegment() public pure {
        MerkleCubicSplineLib.SplineSegment memory segment = MerkleCubicSplineLib.SplineSegment({
            a: 850322082038873436717056,
            b: -193210195392489616048128,
            c: 9783525765966179860480,
            d: 443446867106462171136,
            knot0: 1417418794111199488,
            knot1: 1553925984175975936
        });

        bytes32[] memory proof = new bytes32[](12);
        proof[0] = hex"a4985bb431415ef7d0dd508e7eb43287f0267aaa7c839728a2fa5b663ca06e21";
        proof[1] = hex"af3206e0291d7a2d54700d60dde276df640a69e1c9f850b4b8b3fc653e52f77b";
        proof[2] = hex"1aaabb97ef73524ce4f5cd62b451e2156a4286026200c377391ca6dec84c0260";
        proof[3] = hex"3f8bf91a925c12bef1960b458a8c0d611b536bb1fc4269ce124dd07921940055";
        proof[4] = hex"4fcfe1910079b53f010e93f3501c697acb5ea8a00a8406a752e6f7d25ceb6dc7";
        proof[5] = hex"c59e81471e2a1406e39fe5503113558f8e0b9b83c87bc1bc377ffcaf05aaa0db";
        proof[6] = hex"2c0c912f4617b69be4e7ea084b1fa58de7630d71f2988f1c3e937f91d07cd366";
        proof[7] = hex"aa204f067820a85275dbbdfc179f0fd82d63916fef4ff17cef46bf42f80bc10f";
        proof[8] = hex"bbb5d8ea7b07c2f05aca94072ee68806d48577a49442ad28039fc02af40ac257";
        proof[9] = hex"64198553685547de108ce009a4a4e645463da33bb93bb8f1cb5e61608b160f2e";
        proof[10] = hex"e595831d8839afc2dee63fbf3d87ffe098e002dcca3b7e42b5be0413657b2b1e";
        proof[11] = hex"bd1903ad0b288da7683b39d3405c3f4d97881bb089255ad8671bd53e382bbcdf";

        bytes32 root = hex"b35a0a06d15b4958a1084a6f6cb936ebf96b473cbd0e04b7dac2ff1c54930549";

        MerkleCubicSplineLib.verifySplineSegment(segment, proof, root);
    }

    function testRevertVerifySplineSegmentInvalidSegment() public {
        MerkleCubicSplineLib.SplineSegment memory segment = MerkleCubicSplineLib.SplineSegment({
            a: 850322082038873436717056 + 1,
            b: -193210195392489616048128,
            c: 9783525765966179860480,
            d: 443446867106462171136,
            knot0: 1417418794111199488,
            knot1: 1553925984175975936
        });

        bytes32[] memory proof = new bytes32[](12);
        proof[0] = hex"a4985bb431415ef7d0dd508e7eb43287f0267aaa7c839728a2fa5b663ca06e21";
        proof[1] = hex"af3206e0291d7a2d54700d60dde276df640a69e1c9f850b4b8b3fc653e52f77b";
        proof[2] = hex"1aaabb97ef73524ce4f5cd62b451e2156a4286026200c377391ca6dec84c0260";
        proof[3] = hex"3f8bf91a925c12bef1960b458a8c0d611b536bb1fc4269ce124dd07921940055";
        proof[4] = hex"4fcfe1910079b53f010e93f3501c697acb5ea8a00a8406a752e6f7d25ceb6dc7";
        proof[5] = hex"c59e81471e2a1406e39fe5503113558f8e0b9b83c87bc1bc377ffcaf05aaa0db";
        proof[6] = hex"2c0c912f4617b69be4e7ea084b1fa58de7630d71f2988f1c3e937f91d07cd366";
        proof[7] = hex"aa204f067820a85275dbbdfc179f0fd82d63916fef4ff17cef46bf42f80bc10f";
        proof[8] = hex"bbb5d8ea7b07c2f05aca94072ee68806d48577a49442ad28039fc02af40ac257";
        proof[9] = hex"64198553685547de108ce009a4a4e645463da33bb93bb8f1cb5e61608b160f2e";
        proof[10] = hex"e595831d8839afc2dee63fbf3d87ffe098e002dcca3b7e42b5be0413657b2b1e";
        proof[11] = hex"bd1903ad0b288da7683b39d3405c3f4d97881bb089255ad8671bd53e382bbcdf";

        bytes32 root = hex"b35a0a06d15b4958a1084a6f6cb936ebf96b473cbd0e04b7dac2ff1c54930549";

        vm.expectRevert(abi.encodeWithSelector(MerkleCubicSplineLib.InvalidMerkleProof.selector));
        MerkleCubicSplineLib.verifySplineSegment(segment, proof, root);
    }

    function testVerifySplineSegmentInvalidProof() public {
        MerkleCubicSplineLib.SplineSegment memory segment = MerkleCubicSplineLib.SplineSegment({
            a: 850322082038873436717056,
            b: -193210195392489616048128,
            c: 9783525765966179860480,
            d: 443446867106462171136,
            knot0: 1417418794111199488,
            knot1: 1553925984175975936
        });

        bytes32[] memory proof = new bytes32[](12);
        proof[0] = hex"a4985bb431415ef7d0dd508e7eb43287f0267aaa7c839728a2fa5b663ca06e20"; // incorrect last character
        proof[1] = hex"af3206e0291d7a2d54700d60dde276df640a69e1c9f850b4b8b3fc653e52f77b";
        proof[2] = hex"1aaabb97ef73524ce4f5cd62b451e2156a4286026200c377391ca6dec84c0260";
        proof[3] = hex"3f8bf91a925c12bef1960b458a8c0d611b536bb1fc4269ce124dd07921940055";
        proof[4] = hex"4fcfe1910079b53f010e93f3501c697acb5ea8a00a8406a752e6f7d25ceb6dc7";
        proof[5] = hex"c59e81471e2a1406e39fe5503113558f8e0b9b83c87bc1bc377ffcaf05aaa0db";
        proof[6] = hex"2c0c912f4617b69be4e7ea084b1fa58de7630d71f2988f1c3e937f91d07cd366";
        proof[7] = hex"aa204f067820a85275dbbdfc179f0fd82d63916fef4ff17cef46bf42f80bc10f";
        proof[8] = hex"bbb5d8ea7b07c2f05aca94072ee68806d48577a49442ad28039fc02af40ac257";
        proof[9] = hex"64198553685547de108ce009a4a4e645463da33bb93bb8f1cb5e61608b160f2e";
        proof[10] = hex"e595831d8839afc2dee63fbf3d87ffe098e002dcca3b7e42b5be0413657b2b1e";
        proof[11] = hex"bd1903ad0b288da7683b39d3405c3f4d97881bb089255ad8671bd53e382bbcdf";

        bytes32 root = hex"b35a0a06d15b4958a1084a6f6cb936ebf96b473cbd0e04b7dac2ff1c54930549";

        vm.expectRevert(abi.encodeWithSelector(MerkleCubicSplineLib.InvalidMerkleProof.selector));
        MerkleCubicSplineLib.verifySplineSegment(segment, proof, root);
    }

    function testVerifySplineSegmentInvalidRoot() public {
        MerkleCubicSplineLib.SplineSegment memory segment = MerkleCubicSplineLib.SplineSegment({
            a: 850322082038873436717056,
            b: -193210195392489616048128,
            c: 9783525765966179860480,
            d: 443446867106462171136,
            knot0: 1417418794111199488,
            knot1: 1553925984175975936
        });

        bytes32[] memory proof = new bytes32[](12);
        proof[0] = hex"a4985bb431415ef7d0dd508e7eb43287f0267aaa7c839728a2fa5b663ca06e21";
        proof[1] = hex"af3206e0291d7a2d54700d60dde276df640a69e1c9f850b4b8b3fc653e52f77b";
        proof[2] = hex"1aaabb97ef73524ce4f5cd62b451e2156a4286026200c377391ca6dec84c0260";
        proof[3] = hex"3f8bf91a925c12bef1960b458a8c0d611b536bb1fc4269ce124dd07921940055";
        proof[4] = hex"4fcfe1910079b53f010e93f3501c697acb5ea8a00a8406a752e6f7d25ceb6dc7";
        proof[5] = hex"c59e81471e2a1406e39fe5503113558f8e0b9b83c87bc1bc377ffcaf05aaa0db";
        proof[6] = hex"2c0c912f4617b69be4e7ea084b1fa58de7630d71f2988f1c3e937f91d07cd366";
        proof[7] = hex"aa204f067820a85275dbbdfc179f0fd82d63916fef4ff17cef46bf42f80bc10f";
        proof[8] = hex"bbb5d8ea7b07c2f05aca94072ee68806d48577a49442ad28039fc02af40ac257";
        proof[9] = hex"64198553685547de108ce009a4a4e645463da33bb93bb8f1cb5e61608b160f2e";
        proof[10] = hex"e595831d8839afc2dee63fbf3d87ffe098e002dcca3b7e42b5be0413657b2b1e";
        proof[11] = hex"bd1903ad0b288da7683b39d3405c3f4d97881bb089255ad8671bd53e382bbcdf";

        bytes32 root = hex"b35a0a06d15b4958a1084a6f6cb936ebf96b473cbd0e04b7dac2ff1c54930548"; // incorrect last character

        vm.expectRevert(abi.encodeWithSelector(MerkleCubicSplineLib.InvalidMerkleProof.selector));
        MerkleCubicSplineLib.verifySplineSegment(segment, proof, root);
    }

    function testEvalSplineSegment() public {
        MerkleCubicSplineLib.SplineSegment memory segment = MerkleCubicSplineLib.SplineSegment({
            a: 850322082038873436717056,
            b: -193210195392489616048128,
            c: 9783525765966179860480,
            d: 443446867106462171136,
            knot0: 1417418794111199488,
            knot1: 1553925984175975936
        });

        int256 x = 1.5e18;

        assertApproxEqAbs(MerkleCubicSplineLib.evalSplineSegment(segment, x), 412.635700285127e18, EPSILON);
    }

    function testRevertEvalSplineSegmentValueOutOfBoundsLeft() public {
        MerkleCubicSplineLib.SplineSegment memory segment =
            MerkleCubicSplineLib.SplineSegment({a: 0, b: 0, c: 0, d: 0, knot0: 2e18, knot1: 3e18});

        int256 x = 1e18;

        vm.expectRevert(
            abi.encodeWithSelector(MerkleCubicSplineLib.ValueOutOfBounds.selector, x, segment.knot0, segment.knot1)
        );
        MerkleCubicSplineLib.evalSplineSegment(segment, x);
    }

    function testRevertEvalSplineSegmentValueOutOfBoundsRight() public {
        MerkleCubicSplineLib.SplineSegment memory segment =
            MerkleCubicSplineLib.SplineSegment({a: 0, b: 0, c: 0, d: 0, knot0: 2e18, knot1: 3e18});

        int256 x = 4e18;

        vm.expectRevert(
            abi.encodeWithSelector(MerkleCubicSplineLib.ValueOutOfBounds.selector, x, segment.knot0, segment.knot1)
        );
        MerkleCubicSplineLib.evalSplineSegment(segment, x);
    }
}
