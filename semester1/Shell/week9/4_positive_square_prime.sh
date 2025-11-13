#!/bin/bash

is_prime(){
    local num=$1

    if ! [[ "$num" =~ ^-?[0-9]+$ ]]; then
        echo "$num is not an integer, so it cannot be prime"
        return
    fi

    if (( num <= 1 )); then
        echo "$num is not prime!"
        return
    fi
    
    if (( num == 2 )); then
        echo "$num is prime!"
        return
    fi
    if (( num % 2 == 0 )); then
        echo "$num is not prime!"
        return
    fi

    local i=3
    
    while (( i * i <= num )); do
        if (( num % i == 0 )); then
            echo "$num is not prime"
            return 1
        fi
        i=$((i + 2))
    done
    
    echo "$num is a prime!"
}

is_square(){
    local num=$1
    if [[ "$num" == -* ]]; then
        echo "$num is negative, so it cannot be a square number"
        return
    fi

    local i=1
    while (( i * i < num )); do
        ((i++))
    done

    if (( i * i == num )); then
        echo "$num is a square number!"
    else
        echo "$num is not a square number"
    fi
}

is_positive(){
    local num=$1
    if [ "$num" -gt 0 ]; then
        echo "$num is positive!"
    else
        echo "$num is not positive"
    fi
}

if [ "$#" -eq 0 ]; then
    echo "Please provide a number"
    exit 1
fi

NUM=$1

if ! [[ "$NUM" =~ ^-?([0-9]+(\.[0-9]*)?|\.[0-9]+)$ ]]; then
    echo "The parameter has to be a number!"
    exit 1
fi

is_prime "$NUM"
is_square "$NUM"
is_positive "$NUM"
