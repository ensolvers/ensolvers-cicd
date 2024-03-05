#!/bin/bash

update_submodules() {
    cd "$1" || exit
    sed -i "s|git@github.com:|https://github.com/|g" .gitmodules
    git submodule update --init
}

find . -type f -name ".gitmodules" | while read -r file; do
    dir=$(dirname "$file")
    echo "Fetching submodule [$dir]..."
    update_submodules "$dir"
done
