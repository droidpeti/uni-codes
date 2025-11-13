#!/bin/bash

if [ "$#" -eq 0 ]; then
    echo "No parameters were provided"
    exit 0
fi

PROD=1

for arg in "$@"; do
    if ! [[ "$arg" =~ ^[0-9]+$ ]]; then
        echo "The parameters have to be numbers!"
        exit 1
    fi
    PROD=$((PROD * arg))
done

echo "The product of the numbers is: $PROD"
