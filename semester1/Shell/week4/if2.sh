#!/bin/bash
read -p "Enter age: " age
if [ $age -ge 18 ]
then
    echo "Adult"
else
    echo "Minor"
fi
