#!/bin/bash
read -p "Enter n (Between 0 and 10): " n
if [ "$n" -lt 0 ]; then echo "Use a non-negative n" ; exit 1; fi
if [ "$n" -gt 10 ]; then echo "ENYJE" ; exit 1; fi
res=1
i=1
while [ $i -le $n ]
do
  res=$(expr $res \* $i)
  i=$(expr $i + 1)
done
echo $n! = $res
