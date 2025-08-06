#!/bin/env python
from pathlib import Path
import argparse
import re
import os


def check_missing_vars(fp1, dict1, fp2, dict2):
    print('Checking for missing variables:')
    for var_name in dict1:
        val = dict2.get(var_name, None)
        if val is None:
            print(f"\t{var_name} from {fp1} not found in {fp2}")

    for var_name in dict2:
        val = dict1.get(var_name, None)
        if val is None:
            print(f"\t{var_name} from {fp2} not found in {fp1}")


def check_values(fp1, dict1, fp2, dict2):
    print('Checking for differing variable values:')
    for var_name in dict1:
        val1 = dict1.get(var_name)
        val2 = dict2.get(var_name)

        max_len = max(len(fp1), len(fp2))

        if val1 != val2:
            print(f"\t{var_name} differs;")
            print(f"\t{fp1.ljust(max_len)}: {val1.strip()}")
            print(f"\t{fp2.ljust(max_len)}: {val2.strip()}")
            print()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("env_one", type=Path, help="first path to env")
    parser.add_argument("env_two", type=Path, help="second path to env")
    # parser.add_argument("-cn", "--compare-name")
    # parser.add_argument("-cv", "--compare-cv")
    args = parser.parse_args()

    file1 = args.env_one
    file2 = args.env_two

    # Checking if files exists
    if not os.path.exists(file1):
        print(f"File not found: {file1}")
        return 0

    if not os.path.exists(file2):
        print(f"File not found: {file2}")
        return 0

    env_data1 = {}
    env_data2 = {}

    with open(file1, 'r') as file1_data:
        for line in file1_data:
            line = re.sub(r'#.*', '', line)  # Parsing out comments
            line_data = line.split('=')
            var_name = line_data[0]
            var_value = line_data[1]
            env_data1[var_name] = var_value

    with open(file2, 'r') as file2_data:
        for line in file2_data:
            line = re.sub(r'#.*', '', line)  # Parsing out comments
            line_data = line.split('=')
            var_name = line_data[0]
            var_value = line_data[1]
            env_data2[var_name] = var_value

    check_missing_vars(
        file1, env_data1,
        file2, env_data2
    )

    print("------------------------------")

    check_values(
        file1, env_data1,
        file2, env_data2
    )


if __name__ == "__main__":
    main()
