#!/bin/bash

# exit if command fails
set -e

# Port eg --> "/dev/ttyUSB0"
MCP=""

sudo arduino-cli monitor -p $MCP --config baudrate=115200
