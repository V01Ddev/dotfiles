#!/bin/python3 
import os


# sudo xsetwacom set 27 MapToOutput 1920x1080+0+0

def getting_info():

    list_devices = "sudo xsetwacom list devices"
    menu = os.system(list_devices)
    
    print("-----")

    pen_id = str(input("wacom pen's id --> "))

    print()
    
    # list_monitors = "xrandr | grep connected"
    # os.system(list_monitors)
    # mon_name = str(input("monitor --> "))
    mon_name = "1920x1080+0+0"

    return pen_id, mon_name



def main(xin, xscreen):

    print()

    print("-----")
    print("mapping input device to output device")
    os.system(f"sudo xsetwacom set {xin} MapToOutput 1920x1080+0+0")



if __name__ == "__main__":

    print("simple script to map wacom tablet your main screen using xwacom")
    print("Scripted by www.v01d.dev")
    print("-----")
    
    xin, mon_name = getting_info()

    main(xin, mon_name)

