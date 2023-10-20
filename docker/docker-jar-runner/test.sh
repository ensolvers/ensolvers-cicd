#!/bin/bash

# Signal handler for SIGTERM
handle_sigterm() {
    echo "SIGTERM HANDLING"
    exit 0
}

# Set the trap for SIGTERM
trap 'handle_sigterm' SIGTERM

echo "Your PID is: $$"


while true; do
    echo "Running"
    sleep 1
done

