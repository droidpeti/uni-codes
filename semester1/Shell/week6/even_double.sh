#!/bin/bash
is_even() { local n=$1; ((  n % 2  == 0 )); }
double() { local n=$1; echo $(( n * 2 )); }

if is_even "$1"
then
    echo "Even"
else 
    echo "Odd"
fi

double "$1"
