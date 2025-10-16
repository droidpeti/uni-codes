#!/bin/bash
exists() { [[ -f "$1" ]]; }
count_lines() { wc -l < "$1"; }
if exists "$1"
then
    count_lines "$1"
else
    echo "No such file!"
fi