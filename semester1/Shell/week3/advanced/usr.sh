#!/bin/bash
who | awk '{print $1}' | sort -u >> logfile.txt
echo "Saved users to logfile.txt"