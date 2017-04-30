#!/usr/bin/env bash
cd "${TRAVIS_BUILD_DIR}"

# setup pip for "sudo: false"
mkdir -p vendor/python

export PYTHONPATH="${PYTHONPATH}:${TRAVIS_BUILD_DIR}/vendor/python"

# install python dependencies
pip install --target="${TRAVIS_BUILD_DIR}/vendor/python" --ignore-installed geoip2

# fetch geolite2 databases
mkdir -p data

cd data

wget -q "http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz"
wget -q "http://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz"

tar -xzf GeoLite2-City.tar.gz
tar -xzf GeoLite2-Country.tar.gz

find . -name '*.mmdb' -exec mv {} . \;

# reset working directory
cd "${TRAVIS_BUILD_DIR}"
