#!/bin/bash

greet() {
    echo "Hello! Please enter your name: "

    read NAME

    echo "Hello, $NAME!"
}

calc() {
    echo "Hello! Please enter a number: "

    read NUM

    echo "2x$NUM = $(($NUM*2))"
}

file_exists() {
    echo "Hello! Please enter a file you want to check exists: "

    read FILE

    if [ ! -f $FILE ]; then
        echo "$FILE does not exist!"
        return
    fi
    echo "$FILE exists!"
}

menu() {
    PS3="Choose> ";
    select opt in "Greet" "Calc" "File Exists" "Quit"
    do
        case "$REPLY" in
            1) greet ;;
            2) calc ;;
            3) file_exists ;;
            4) echo "Bye"; break ;;
            *) echo "Invalid" ;;
        esac
    done
}
menu
