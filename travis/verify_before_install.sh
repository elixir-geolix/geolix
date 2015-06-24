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

wget -q "http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz"
wget -q "http://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.mmdb.gz"

gunzip *
