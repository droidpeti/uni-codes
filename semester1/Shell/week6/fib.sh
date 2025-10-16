#!/bin/bash
fib() {
    local n=$1 a=0 b=1 seq="";
    for ((i=0;i<n;i++))
    do
        seq+="$a ";
        t=$((a+b));
        a=$b; b=$t;
    done
    echo "$seq"
}
fib "$@"
