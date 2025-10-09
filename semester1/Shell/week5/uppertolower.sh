#!/bin/bash

for f in *; do
  lower=$(printf "%s" "$f" | tr '[:upper:]' '[:lower:]')
  [ "$f" != "$lower" ] && mv -i -- "$f" "$lower"
done
