#!/bin/bash
pass="secret"
input=""
until [ "$input" = "$pass" ]
do
    read -p "Enter password: " input
done
echo "Yippie!"
