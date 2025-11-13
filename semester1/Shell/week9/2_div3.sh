#!/bin/bash

NUM=$1

if ! [[ "$NUM" =~ ^[0-9]+$ ]] || [ $NUM -eq 0 ]; then
    echo "The parameter has to be a whole, positive number!"
    exit 1
fi

if [ $(( $NUM % 3 )) -eq 0 ]; then
    echo "$NUM is divisible by 3"
else
    echo "$NUM is not divisible by 3"
fi