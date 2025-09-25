#!/bin/bash

read -p "Enter a number: " n
if [ $n -gt 10 ] #-gt nagyobb, -ge nagyobb/egyenlo, -lt, -le
then
  echo "Greater than 10"
else
  echo "Less than 10"
fi