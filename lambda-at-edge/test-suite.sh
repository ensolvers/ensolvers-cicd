#!/bin/bash

# Set the "exit on error" option
set -e

# Validate and retrieve the directory path from the command line argument
if [[ -z "$1" ]]; then
  echo "Usage: $0 <directory_path>"
  exit 1
fi

directory_path="$1"

# Check if the directory exists
if [[ ! -d "$directory_path" ]]; then
  echo "Invalid directory path: $directory_path"
  exit 1
fi

# Iterate through each folder within the directory
for folder in "$directory_path"/*; do
  if [[ -d "$folder" ]]; then
    echo "Running Jest in $folder"
    cd "$folder"
    yarn install
    npx jest
    cd -
  fi
done
