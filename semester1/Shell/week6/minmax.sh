#!/bin/bash
minmax() {
    local min=$1 max=$1;
    for x in "$@"
    do
        (( x < min)) && min=$x
        (( x > max)) && max=$x
    done
    echo "$min $max"
}
minmax "$@"