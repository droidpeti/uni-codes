#!/bin/bash

wc -l /etc/passwd
wc -w README.txt 2>/dev/null || echo "README.txt not found"
