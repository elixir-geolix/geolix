#!/usr/bin/env bash
cd "${TRAVIS_BUILD_DIR}"

# install elixir dependencies
mix local.hex --force
mix deps.get

# install python dependencies
pip install --target="${TRAVIS_BUILD_DIR}/vendor/python" --ignore-installed geoip2
