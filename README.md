![Header](header.png)

# Solidity Splines

[![CI](https://img.shields.io/github/actions/workflow/status/GabrielBianconi/solidity-splines/test.yml?branch=main&label=build)](https://img.shields.io/github/actions/workflow/status/GabrielBianconi/solidity-splines/test.yml?branch=main&label=build)
[![License: MIT](https://img.shields.io/badge/License-MIT-brightgreen.svg)](https://github.com/GabrielBianconi/solidity-splines/blob/main/LICENSE)

This project was an experiment to practice concepts like differential fuzzing and Merkle proofs.

## Contracts

### `src/CubicSplineLib.sol`

This library provides functionality for evaluating simple cubic splines in Solidity.

It provides two methods for evaluation:

- `evalWithSegmentIndex`: This method is more gas efficient and can be used if the client knows the specific spline segment index in advance.
- `evalWithBinarySearch`: This method can be used if the index needs to be determined on the fly.

In addition, we provide a differential fuzz test against a reference Python implementation. Refer to `test/CubicSplineLib.t.sol:testFuzzEval` for more details.

### `src/MerkleCubicSplineLib.sol`

This library offers a solution for evaluating large cubic splines in Solidity using Merkle proofs. This method is particularly useful when dealing with large cubic splines, as it eliminates the need to store the entire spline on-chain.

Instead of storing the full spline, this approach involves computing a Merkle tree that includes every spline segment. Only the Merkle root of this tree is stored in the contract. Clients can then provide data about a specific segment when calling the library, and use a Merkle proof to validate the segment's authenticity.

In practice, clients will use the following two methods for evaluation:

```solidity
MerkleCubicSplineLib.verifySplineSegment(segment, proof, root); // verify the validity of the segment
MerkleCubicSplineLib.evalSplineSegment(segment, x); // evaluate x in the segment
```

For a concrete example, refer to `test/MerkleCubicSplineLib.t.sol` and the following reference scripts:

```sh
cd reference/
python generate_massive_spline.py
npx ts-node generate_massive_spline_merkle_tree.ts
npx ts-node generate_massive_spline_merkle_proof.ts
```

These scripts will guide you through the process of creating a large cubic spline, generating its Merkle tree, and creating a Merkle proof.

## Testing

To run standard tests, use the following command:

```sh
npm run test
```

To run with longer fuzzing (100 runs), use the following command:

```sh
npm run test:fuzz
```
