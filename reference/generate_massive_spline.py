import csv
from decimal import Decimal

import eth_abi
import numpy as np
import scipy


WAD = int(1e18) # spline parameters will be represented in fixed-precision based on WAD


def generate_massive_spline():
    np.random.seed(0)

    # Generate a random number of segments [1, 128]
    num_segments = 4096

    # Generate coordinates for the knots
    x_coords = np.random.uniform(-1024, 1024, size=num_segments + 1)
    y_coords = np.random.uniform(-1024, 1024, size=num_segments + 1)

    # Sort the x-coordinates
    x_coords.sort()

    # Generate the spline
    spline = scipy.interpolate.CubicSpline(x_coords, y_coords, bc_type="natural")

    # Generate the spline segment parameters (with knots) in fixed-precision, taking into account numerical issues
    spline_params = np.vstack([spline.c, x_coords[:-1], x_coords[1:]]).T # array of N spline segments with shape (N, 6)
    
    # Convert values to fixed-precision
    spline_params = array2D_to_fixed_precision(spline_params)

    # Convert values to string and write to file
    spline_params = [[str(v) for v in e] for e in spline_params]

    with open("massive_spline.csv", "w") as f:
        writer = csv.writer(f)
        writer.writerows(spline_params)

    # Print an example for testing
    print("Example:")
    print(f"x = 1.5 (1500000000000000000)")
    y = spline(1.5)
    print(f"y = {y} ({int(y.astype(Decimal) * WAD)})")

    
def array2D_to_fixed_precision(arr):
    arr = arr.astype(Decimal).tolist() # make it a nested list of Decimal
    arr = [[int(v * WAD) for v in e] for e in arr] # make it a nested list of integers with WAD precision
    return arr


if __name__ == "__main__":
    generate_massive_spline()
