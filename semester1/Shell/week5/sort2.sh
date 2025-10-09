#!/bin/bash
tmpfile=$(mktemp)
while true
do
  read -p "Word (type 'end' to finish): " w
  [ "$w" = "end" ] && break
  echo "$w" >> "$tmpfile"
done
sort "$tmpfile"
rm -f "$tmpfile"
