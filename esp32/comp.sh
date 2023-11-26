#!/bin/bash

# exit if command fails
set -e

# Port eg --> "/dev/ttyUSB0"
MCP=""

# Filename
FN=""

# eg --> "esp32:esp32:esp32-poe-iso"
Board="" 

echo [*] Compiling...
arduino-cli compile --fqbn $Board

echo [*] Uploading...
arduino-cli upload --port $MCP --fqbn $Board $FN
