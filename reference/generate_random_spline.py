from decimal import Decimal

import eth_abi
import numpy as np
import scipy

WAD = int(1e18) # spline parameters will be represented in fixed-precision based on WAD

def generate_random_spline_test(seed: int):
    np.random.seed(seed)

    # Generate a random number of segments [1, 128]
    num_segments = np.random.randint(1, 128 + 1)

    # Generate coordinates for the knots
    x_coords = np.random.uniform(-1024, 1024, size=num_segments + 1)
    y_coords = np.random.uniform(-1024, 1024, size=num_segments + 1)

    # Sort the x-coordinates
    x_coords.sort()

    # Generate the spline
    spline = scipy.interpolate.CubicSpline(x_coords, y_coords, bc_type="natural")

    # Generate the spline segment parameters (with knots) in fixed-precision, taking into account numerical issues
    spline_params = np.vstack([spline.c, x_coords[:-1], x_coords[1:]]).T # array of N spline segments with shape (N, 6)
    

    # Generate 128 test cases
    x_test = np.random.uniform(x_coords[0], x_coords[-1], size=128)
    y_test = spline(x_test)

    # Calculate the index of the spline segment for each test case
    index_test = (np.argmax(x_test.reshape(-1, 1) < x_coords.reshape(1, -1), axis=1) - 1).tolist()

    # Convert values to fixed-precision
    spline_params = array2D_to_fixed_precision(spline_params)
    x_test = array1D_to_fixed_precision(x_test)
    y_test = array1D_to_fixed_precision(y_test)

    # Encode the result
    abi_types = ["int256[6][]", "int256[128]", "int256[128]", "uint256[128]"]
    
    encoded_values = eth_abi.encode(abi_types, [spline_params, x_test, y_test, index_test])

    # Print the result
    print('0x' + encoded_values.hex(), end="")

    
def array1D_to_fixed_precision(arr):
    arr = arr.astype(Decimal).tolist() # make it a list of Decimal
    arr = [int(v * WAD) for v in arr] # make it a list of integers with WAD precision
    return arr

def array2D_to_fixed_precision(arr):
    arr = arr.astype(Decimal).tolist() # make it a nested list of Decimal
    arr = [[int(v * WAD) for v in e] for e in arr] # make it a nested list of integers with WAD precision
    return arr


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("seed", help="The random seed.", type=int)
    args = parser.parse_args()

    generate_random_spline_test(args.seed)
