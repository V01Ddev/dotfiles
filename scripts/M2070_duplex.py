#!/bin/python3
import os
import argparse




def odd_pages(file_name):
   odd_cmd = f"lp -o page-set=odd {file_name}"
   print("[*] Running odd command")
   os.system(odd_cmd)



def even_pages(file_name):
   even_cmd = f"lp -o page-set=even -o orientation-requested=6 -o outputorder=reverse {file_name}"
   print("[*] Running even command")
   os.system(even_cmd)



def main():

    print("[*] Script made my www.v01d.dev")
    print("[*] Duplex printing for thge Xpress M2070")


    parser = argparse.ArgumentParser()
    parser.add_argument("file", help="filename to input")
    args = parser.parse_args()
    
    if os.path.isfile(args.file):
        print(f"[*] {args.file} found, printing starting...")
    else:
        print(f"[*] {args.file} was not found. Please make sure file name is correct.")
        exit()

    
    print(f"[*] Printing odd pages of '{args.file}'...")
    odd_pages(args.file)
    input("[*] Press enter once pages have been reinserted as they have been printed...")

    print(f"[*] Printing even pages of '{args.file}'...")
    even_pages(args.file)




if __name__ == "__main__":
    main()
