#!/bin/bash
say_hi() { read -p "Name: " n; echo "Hi, $n!"; }
show_time() { date "+%F %T"; }
calc_sum() { read -p "A: " a; read -p "B: " b; echo $((a+b)); }

menu() {
    PS3="Choose> ";
    select opt in "Say hi" "Show time" "Sum" "Quit"
    do
        case "$REPLY" in
            1) say_hi ;;
            2) show_time ;;
            3) calc_sum ;;
            4) echo "Bye"; break ;;
            *) echo "Invalid" ;;
        esac
    done
}
menu