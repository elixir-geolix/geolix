#!/usr/bin/env bash
cd "${TRAVIS_BUILD_DIR}/verify"

rm -f ./ip_set.txt
. ./generate_ip_set.sh
