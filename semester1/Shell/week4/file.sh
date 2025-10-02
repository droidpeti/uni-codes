#!/bin/bash
read -p "Enter a filename: " f
if [ -f "$f" ]
then
    echo "File exists!"
else
    echo "File not found!"
fi
