#!/bin/bash

root_dir="$1"
skip_cd_absolute_path="$2"
absolute_path=$(realpath "$root_dir")

echo "PWD: [$(pwd)]"
echo "Root dir: [$root_dir]. Absolute path: $absolute_path"

update_submodules() {
    cd "$1" || exit
    echo "Replacing SSH to HTTPS on [$1/.gitmodules]"

    if [ -n "$GITHUB_TOKEN" ]; then
        replacement="https://$GITHUB_TOKEN@github.com/"
    else
        replacement="https://github.com/"
    fi

    if [ "$(uname)" == "Darwin" ]; then
        sed -i '' "s|git@github.com:|$replacement|g" .gitmodules
    else
        sed -i "s|git@github.com:|$replacement|g" .gitmodules
    fi

    git submodule update --init
}

find "$root_dir" -type f -name ".gitmodules" | while read -r file; do
    dir=$(dirname "$file")

    # skip any .gitmodules under a node_modules directory
    if [[ "$dir" == *node_modules* ]]; then
        echo "Skipping submodule in node_modules: $dir"
        continue
    fi

    echo "Fetching submodule [$dir]..."
    if [[ -z $skip_cd_absolute_path ]]; then
      cd "$absolute_path"
    fi
    update_submodules "$dir"
done
