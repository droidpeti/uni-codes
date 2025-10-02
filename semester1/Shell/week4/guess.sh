#!/bin/bash

secret=$(( RANDOM % 10 + 1 ))
while true; do
    read -p "Guess (1-10): " g
    if [ "$g" -eq "$secret" ]; then echo "Correct!"; break
    elif [ "$g" -lt "$secret" ]; then echo "Too low"
    else echo "Too high"; fi
done
