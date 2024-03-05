#!/bin/bash

root_dir="$1"

update_submodules() {
    cd "$1" || exit
    echo "Replacing SSH to HTTPS on [$1/.gitmodules]"
    sed -i "s|git@github.com:|https://github.com/|g" .gitmodules
    git submodule update --init
}

find "$root_dir" -type f -name ".gitmodules" | while read -r file; do
    dir=$(dirname "$file")
    echo "Fetching submodule [$dir]..."
    update_submodules "$dir"
done
