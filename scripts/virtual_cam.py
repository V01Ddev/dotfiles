#!/bin/python
import shutil
import os


def is_tool(name):
    """Check whether `name` is on PATH and marked as executable."""
    return shutil.which(name) is not None


def checking_loopback():
    res = os.popen("whereis v4l2loopback")
    out = res.read().split(':')[1]
    if len(out) >= 2:
        return True
    else:
        return False


def main():
    print("Please ensure v4l2loopback is installed")
    if not checking_loopback():
        print("Can't find v4l2loopback")
        return 0

    for i in ["modprobe", "ffmpeg"]:
        if not is_tool(i):
            print(f"Tool not found, install {i}")
            return 0

    print("Reloading v4l2loopback")
    cmd = "sudo modprobe -r v4l2loopback"
    if os.system(cmd) != 0:
        print("Failed to reload v4l2loopback")

    print("Loading module")
    cmd = """sudo modprobe v4l2loopback devices=1 \
video_nr=10 card_label="VirtualCam" exclusive_caps=1"""
    if os.system(cmd) != 0:
        print(f"Failed to load module: {cmd}")

    print("Running stream")
    cmd = """ffmpeg -video_size 1920x1080 -framerate 30 -f x11grab \
-i :0.0+0,0 -pix_fmt yuv420p -f v4l2 /dev/video10"""
    os.system(cmd)


if __name__ in "__main__":
    main()
