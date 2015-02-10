#!/usr/bin/env bash
cd "${TRAVIS_BUILD_DIR}/verify"

rm -f ./ip_set.txt
. ./generate_ip_set.sh

# verify geolix results
cd "${TRAVIS_BUILD_DIR}/verify/geolix"

mix compile
mix geolix.verify

# verify python results
cd "${TRAVIS_BUILD_DIR}/verify/python"

python verify.py

# diff results
cd "${TRAVIS_BUILD_DIR}/verify"

diff geolix_results.txt python_results.txt
