#!/bin/bash
set -eu

function_code_root=$1
function_name=$2

echo "Deploying function in $function_code_root to $function_name"
cd $function_code_root
rm -rf function.zip
zip -r function.zip *.js *.json node_modules
aws lambda update-function-code --function-name $function_name --zip-file fileb://function.zip
rm -rf function.zip