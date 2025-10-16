#!/bin/bash

fact() {
    local n=$1 r=1
    for ((i=2;i<=n;i++))
    do
        r=$((r*i))
    done
    echo "$r";
}
fact "$@"
