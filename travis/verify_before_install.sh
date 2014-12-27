#!/usr/bin/env bash
cd "${TRAVIS_BUILD_DIR}"

export ELIXIR=1.0.2

mkdir -p vendor/elixir

wget -q "https://github.com/elixir-lang/elixir/releases/download/v${ELIXIR}/Precompiled.zip"
unzip -qq Precompiled.zip -d vendor/elixir

export PATH="${PATH}:${TRAVIS_BUILD_DIR}/vendor/elixir/bin"

# fetch geolite2 databases
mkdir -p data

cd data

wget -q "http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz"
wget -q "http://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.mmdb.gz"

gunzip *
