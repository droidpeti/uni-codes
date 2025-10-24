#!/bin/bash

if [ "$#" -eq 0 ]; then
    echo "No arguments were provided."
    exit 0
fi

SUM=0

for arg in "$@"; do
    if ! [[ "$arg" =~ ^[0-9]+$ ]]; then
        echo "The parameters have to be numbers!"
        exit 1
    fi
    SUM=$((SUM + arg))
done

echo "The sum of the numbers is: $SUM"
