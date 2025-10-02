#!/bin/bash
read -p "Number: " n
if [ "$n" -lt 2 ]; then echo "Not prime"; exit 0; fi
for ((i=2;i*i<=n;i++)); do
    if (( n % i == 0)); then echo "Not prime"; exit 0; fi
done
echo "Prime"
