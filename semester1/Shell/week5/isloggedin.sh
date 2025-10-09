#!/bin/bash

user="$1"
[ -z "$user" ] && { echo "Usage: -$0 username"; exit 1; }
while true
do
  if who | grep -qw "$user"; then
    echo "$(date): $user is logged in" | tee -a login.log
  else
    echo "$(date): $user is NOT logged in" | tee -a login.log
  fi
  sleep 30
done
