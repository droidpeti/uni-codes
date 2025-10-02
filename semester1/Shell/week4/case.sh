#!/bin/bash
read -p "Continue? (Y/n): " ans
case $ans in
    y) echo "Yes" ;;
    "") echo "Yes" ;;
    n) echo "No" ;;
    *) echo "Invalid" ;;
esac
