#!/bin/bash

NUM=$1

if ! [[ "$NUM" =~ ^-[0-9]+$ ]]; then
    echo "The parameter has to be a whole, negative number!"
    exit 1
fi

if [ $(( $NUM % 2 )) -eq 0 ]; then
    echo "$NUM is even!"
else
    echo "$NUM is odd!"
fi