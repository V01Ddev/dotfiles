#!/bin/python3
import argparse
import os
import shlex
import subprocess
import tempfile


def run(cmd, quiet=False):
   print(f"[*] $ {shlex.join(cmd)}")
   if not quiet:
      return subprocess.run(cmd).returncode
   done = subprocess.run(cmd, capture_output=True, text=True)
   if done.returncode != 0 and done.stderr.strip():
      print(done.stderr.strip())
   return done.returncode



def rotate_180(file_name, out_name):
   """Copy file_name with every page turned 180 degrees.

   The M2070 PPD has no Orientation option, so cupsd quietly drops
   -o orientation-requested=6 and the even pages come out upside down.
   Rotating the page content itself is the only form of it the driver
   passes through to the printer.
   """
   cmd = ["gs", "-q", "-dNOPAUSE", "-dBATCH", "-dAutoRotatePages=/None",
          "-sDEVICE=pdfwrite", f"-sOutputFile={out_name}",
          "-c", "<</Orientation 2>> setpagedevice", "-f", file_name]
   return run(cmd, quiet=True)



def odd_pages(file_name):
   print("[*] Running odd command")
   return run(["lp", "-o", "page-set=odd", file_name])



def even_pages(file_name):
   print("[*] Running even command")
   return run(["lp", "-o", "page-set=even", "-o", "outputorder=reverse", file_name])



def main():

   print("[*] Script made my www.v01d.dev")
   print("[*] Duplex printing for the Xpress M2070")


   parser = argparse.ArgumentParser()
   parser.add_argument("file", help="filename to input")
   args = parser.parse_args()

   if os.path.isfile(args.file):
      print(f"[*] {args.file} found, printing starting...")
   else:
      print(f"[*] {args.file} was not found. Please make sure file name is correct.")
      exit()

   # Rotate before the first pass, so a failure costs no paper.
   fd, rotated = tempfile.mkstemp(prefix="M2070_duplex-", suffix=".pdf")
   os.close(fd)

   # keep only goes True if the even pass fails, so that pass can be retried
   # without reprinting the odd pages. Everything else gets cleaned up.
   keep = False
   try:
      print("[*] Rotating the pages 180 degrees for the second pass...")
      if rotate_180(args.file, rotated) != 0 or os.path.getsize(rotated) == 0:
         print("[*] Could not rotate the file, is it a PDF? Nothing was printed.")
         exit(1)

      print(f"[*] Printing odd pages of '{args.file}'...")
      if odd_pages(args.file) != 0:
         print("[*] The odd page pass failed. Nothing else was printed.")
         exit(1)

      input("[*] Press enter once the pages have been reinserted as they have been printed...")

      print(f"[*] Printing even pages of '{args.file}'...")
      if even_pages(rotated) != 0:
         keep = True
         print("[*] The even page pass failed. The rotated copy is still at:")
         print(f"[*]   {rotated}")
         print(f"[*] Retry with: lp -o page-set=even -o outputorder=reverse {rotated}")
         exit(1)
   except KeyboardInterrupt:
      print("\n[*] Aborted, the even pages were not sent.")
      exit(1)
   finally:
      if not keep:
         os.unlink(rotated)




if __name__ == "__main__":
   main()
