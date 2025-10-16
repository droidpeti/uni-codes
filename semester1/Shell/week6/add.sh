#!/bin/bash
add() {
    local a=$1 b=$2;
    echo $(( a + b ));
}
add "$@"
