#!/bin/bash

if [ "$1" = "--help" ]; then
  echo "Usage: $0 n1 n2 ... (max 10 numbers)"
  exit 0
fi

count=$#
if [ $count -gt 10 ]; then echo "ENYJE max 10 parameter"; exit 1; fi
sum=0
for x in "$@"; do sum=$((sum + x)); done
echo "Sum = $sum"
