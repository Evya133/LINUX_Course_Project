#!/usr/bin/env python3
import argparse
import matplotlib.pyplot as plt

def main():
    parser = argparse.ArgumentParser(description="Plot plant data from CLI arguments.")
    parser.add_argument("--plant", required=True, help="Plant name")
    parser.add_argument("--height", type=float, nargs='+', required=True, help="List of plant heights")
    parser.add_argument("--leaf_count", type=int, nargs='+', required=True, help="List of leaf counts")
    parser.add_argument("--dry_weight", type=float, nargs='+', required=True, help="List of dry weights")
    args = parser.parse_args()

    print(f"Plant: {args.plant}")
    print(f"Heights: {args.height}")
    print(f"Leaf Counts: {args.leaf_count}")
    print(f"Dry Weights: {args.dry_weight}")

    # Generate a diagram (example: plot all three measurements)
    plt.figure()
    plt.plot(args.height, label="Height")
    plt.plot(args.leaf_count, label="Leaf Count")
    plt.plot(args.dry_weight, label="Dry Weight")
    plt.title(f"Plant Data for {args.plant}")
    plt.legend()
    out_filename = f"{args.plant}_diagram.png"
    plt.savefig(out_filename)
    plt.show()

if __name__ == "__main__":
    main()
