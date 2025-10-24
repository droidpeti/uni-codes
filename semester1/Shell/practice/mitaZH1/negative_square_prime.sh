#!/bin/bash

is_prime(){
    local num=$1

    if ! [[ "$num" =~ ^-?[0-9]+$ ]]; then
        echo "$num is fractional, so it cannot be prime."
        return
    fi

    if [ $(bc <<< "$num <= 1") -eq 1 ]; then
        echo "$num is not prime!"
        return
    fi
    
    if [ "$num" -eq 2 ]; then
        echo "$num is prime!"
        return
    fi
    if [ $(bc <<< "$num % 2") -eq 0 ]; then
        echo "$num is not prime!"
        return
    fi

    local i=3
    local sqrt_num=$(bc <<< "scale=0; sqrt($num)")
    
    while [ $i -le $sqrt_num ]; do
        if [ $(bc <<< "$num % $i") -eq 0 ]; then
            echo "$num is not a prime!"
            return
        fi
        i=$((i + 2))
    done
    
    echo "$num is a prime!"
}

is_square(){
    local num=$1
    if [ $(bc <<< "$num < 0") -eq 1 ]; then
        echo "$num is negative, so it cannot be a square number."
        return
    fi

    local is_sq=$(bc -l <<< "s = sqrt($num); s*s == $num")

    if [ "$is_sq" -eq 1 ]; then
        echo "$num is a square number!"
    else
        echo "$num is not a square number."
    fi
}

is_negative(){
    local num=$1
    if [ $(bc <<< "$num < 0") -eq 1 ]; then
        echo "$num is negative!"
    else
        echo "$num is not negative."
    fi
}

if [ "$#" -eq 0 ]; then
    echo "Please provide a number."
    exit 1
fi

NUM=$1

if ! [[ "$NUM" =~ ^-?([0-9]+(\.[0-9]*)?|\.[0-9]+)$ ]]; then
    echo "The parameter has to be a number!"
    exit 1
fi

is_prime "$NUM"
is_square "$NUM"
is_negative "$NUM"
