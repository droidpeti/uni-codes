#!/bin/bash
to_upper() {
    echo "$1" | tr '[:lower:]' '[:upper:]';
}

to_lower() {
    echo "$1" | tr '[:upper:]' '[:lower:]';
}

if [ "$2" == "L" ]
then
    to_lower "$1"
elif [ "$2" == "U" ]
then
    to_upper "$1"
else
    echo "Second parameter should be 'L' or 'U'!"
fi
