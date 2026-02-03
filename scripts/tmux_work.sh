#!/bin/bash

window_name=""
project_path="$HOME/Work/..."

tmux new-session -d -s "$window_name"

tmux send-keys -t "$window_name:1" "cd $project_path" C-m
tmux send-keys -t "$window_name:1" "source .venv/bin/activate" C-m

tmux new-window -t "$window_name:2"
tmux send-keys -t "$window_name:2" "cd $project_path" C-m
