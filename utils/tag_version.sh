#!/bin/bash
 
set -e

green='\033[0;32m';
yellow='\033[0;33m';
red='\033[0;31m';
reset='\033[0m';
cyan='\033[0;36m'

prompt() {
	loop=true
	echo -e "${green}[PROMPT]${reset} $1 [Y/N]"
	while ($loop); do
		read response
		case $response in
			[yY])
			    loop=false;
				break
			;;
			[nN]) 
				exit
			;;
			*)
				echo -e "${red}Invalid response.${reset}"
			;;
		esac
	done
}

prompt "Apply tag for the following repository: ${green}$(git config --get remote.origin.url)${reset}?";

initial_number=${1:-1}
tag_prefix=${2:-build}

git pull

current_tag=$(git tag --points-at HEAD | grep "^$tag_prefix" | tail -1)

echo -e "${cyan}[INFO] Params initial_number=${green}$initial_number${cyan}, tag_prefix=${green}$tag_prefix${reset}"

# if no current tag, ensure that a new one is created
if [[ -z $current_tag ]]; then
    echo -e "${cyan}[INFO] Current commit not tagged, getting last tag with prefix${reset}"
    last_tag=$(git tag | grep "^$tag_prefix" | tail -1)

    new_version_tag=""
    if [[ -z $last_tag ]]; then
        # if no first tag, then generate it
        echo -e "${yellow}[WARN] No previous build tag, starting with initial tag${reset}"
        new_version_tag="$tag_prefix-$(seq -w $initial_number 10000 | head -n1)"
    else
        echo -e "${cyan}[INFO] Get last build number and increment it${reset}"
        current_version=$(echo $last_tag | cut -d'-' -f2)
        new_version=$((10#$current_version+1))
        new_version_tag="$tag_prefix-$(seq -w $new_version 10000 | head -n1)"
    fi
    
    prompt "Apply tag: ${green}$new_version_tag${reset}?";
    
    git tag $new_version_tag
    git push --tags
fi

current_tag=$(git tag --points-at HEAD | grep "^$tag_prefix" | tail -1)
current_version=$(echo $current_tag | cut -d'-' -f2)

echo -e "${cyan}[INFO] HEAD tagged with: ${green}$current_tag${cyan}, current version: ${green}$((10#$current_version))${reset}"

export BUILD=$((10#$current_version))

