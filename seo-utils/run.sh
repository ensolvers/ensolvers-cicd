#!/bin/bash

BASEDIR=$(dirname "$0")
source "$BASEDIR/../utils/slack_notification.sh"

echo "This script runs Cypress tests for a list of URLs in a CSV file."
echo "The CSV file should have one URL per line, without quotes or spaces."
echo "The CSV file should be named 'urls.csv' and located in the 'data_entry' folder. or pass path of csv with '-d' argument"
echo "To print Cypress output to the console, use the '-v' argument."
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..." 

urls_dir="data_entry/urls.csv"
verbose=false

while getopts ":d:v" opt; do
  case $opt in
    d)
      urls_dir="$OPTARG"
      ;;
    v)
      verbose=true
      echo "Verbose mode enabled."
      ;;
    \?)
      echo "Opción inválida: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Verbose mode disabled."
      read -p "You need pass path in -d param this execute default csv in data_entry/urls.csv Press Enter to continue or Ctrl+C to cancel..."
      ;;
    esac
done

failed_count=0
failed_urls=""

while IFS=',' read -ra row; do
    url=${row[0]}
    echo "Running test for URL: $url"

    cypress_output=$(npx cypress run --browser chrome --spec cypress/e2e/spec.cy.js --env url="$url" 2>&1)
    cypress_exit_code=$?

    if [ $cypress_exit_code -ne 0 ]; then
        failed_count=$((failed_count + 1))
        failed_urls="$failed_urls\n$url"
    fi

    if [ "$verbose" = true ]; then
        echo "$cypress_output"
    fi
done < "$urls_dir"

slack_username="Cypress Bot:"
slack_emoji=":robot_face:"

slack_message="$slack_username :exclamation: *$failed_count URLs failed:*"
while read -r url; do
    slack_message+="\n $url"
done <<< "$failed_urls"

slack_notification "$slack_message"