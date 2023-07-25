![Header](header.png)

# Solidity Splines

[![CI](https://img.shields.io/github/actions/workflow/status/GabrielBianconi/solidity-splines/test.yml?branch=main&label=build)](https://img.shields.io/github/actions/workflow/status/GabrielBianconi/solidity-splines/test.yml?branch=main&label=build)
[![License: MIT](https://img.shields.io/badge/License-MIT-brightgreen.svg)](https://github.com/GabrielBianconi/solidity-splines/blob/main/LICENSE)

## Contracts

### `src/CubicSplineLib.sol`

This library provides functionality for evaluating simple cubic splines in Solidity.

It provides two methods for evaluation:

- `evalWithSegmentIndex`: This method is more gas efficient and can be used if the client knows the specific spline segment index in advance.
- `evalWithBinarySearch`: This method can be used if the index needs to be determined on the fly.

In addition, we provide a differential fuzz test against a reference Python implementation. Refer to `test/CubicSplineLib.t.sol:testFuzzEval` for more details.

## Testing

To run standard tests, use the following command:

```sh
npm run test
```

To run with longer fuzzing (100 runs), use the following command:

```sh
npm run test:fuzz
```
