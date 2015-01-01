#!/usr/bin/env bash

for x in {1..255}; do
  SEED=$(head -1 /dev/urandom | od -N 1 | awk '{ print $2 }'| sed s/^0*//)
  RANDOM=$SEED

  echo $((RANDOM%=255))"."$((RANDOM%=255))"."$((RANDOM%=255))"."$((RANDOM%=255)) >> ip_set.txt
done
