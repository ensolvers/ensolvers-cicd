#!/bin/bash

root_dir="$1"
skip_cd_absolute_path="$2"
absolute_path=$(realpath $root_dir)

echo "PWD: [$(pwd)]"
echo "Root dir: [$root_dir]. Absolute path: $absolute_path"

update_submodules() {
    cd "$1" || exit
    echo "Replacing SSH to HTTPS on [$1/.gitmodules]"

    if [ "$(uname)" == "Darwin" ]; then
        sed -i '' "s|git@github.com:|https://github.com/|g" .gitmodules
    else
        sed -i "s|git@github.com:|https://github.com/|g" .gitmodules
    fi

    git submodule update --init
}

find "$root_dir" -type f -name ".gitmodules" | while read -r file; do
    dir=$(dirname "$file")
    echo "Fetching submodule [$dir]..."
    if [[ -z $skip_cd_absolute_path ]]; then
      cd $absolute_path
    fi
    update_submodules "$dir"
done
