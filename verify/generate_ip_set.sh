#!/usr/bin/env bash

for i in {1..1000}; do
  echo $((RANDOM%=255))"."$((RANDOM%=255))"."$((RANDOM%=255))"."$((RANDOM%=255)) >> ip_set.txt
done
