#!/bin/bash

grep '^root' /etc/passwd
grep 'bash$' /etc/passwd | head -n 5
