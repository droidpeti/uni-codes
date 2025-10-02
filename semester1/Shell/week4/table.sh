#!/bin/bash
for i in {1..10}; do
    row=""
    for j in {1..10}; do
        row+=$(printf "%4d" $((i*j)))
    done
    echo "$row"
done
