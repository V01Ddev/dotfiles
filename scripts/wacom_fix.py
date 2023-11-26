#!/bin/python3 
import os



def cleaning(text):

    ltext = text.splitlines()
    #split x into vars 
    
    arr = []

    for i in ltext:
        i = i[6:]
        arr.append(i)
    
    return arr



def getting_info():

    list_devices = "xinput | grep Wacom"
    menu = os.system(list_devices)
    
    print("-----")

    print("your pen should be known as '{model} Pen stylus'")
    pen_id = str(input("wacom pen's id --> "))

    print()
    
    list_monitors = "xrandr | grep connected"
    os.system(list_monitors)
    mon_name = str(input("monitor --> "))

    return pen_id, mon_name



def main(xin, xscreen):

    print()

    print("-----")
    print("mapping input device to output device")
    os.system(f"xinput map-to-output {xin} {xscreen}")



if __name__ == "__main__":

    print("simple script to map wacom tablet your main screen using xinput and xrandr")
    print("Scripted by www.v01d.dev")
    print("-----")
    
    xin, mon_name = getting_info()

    main(xin, mon_name)

