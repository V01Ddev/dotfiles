#!/bin/python3
import argparse
import os



def comp(file_in, margin):

    str(file_in)
    int(margin)

    if os.path.isfile(file_in) != True:
        print("[*] File not found")
        exit()

    file_out = os.path.splitext(file_in)[0]

    command = f"pandoc {file_in} -V geometry:margin={margin}in -o {file_out}.pdf"

    os.system(command)



if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("file", help="filename to input")
    parser.add_argument("-m", "--margin", nargs='?', default=0.8, help="margin size in inches, defaults to 0.8")

    args = parser.parse_args()

    comp(args.file, args.margin)
