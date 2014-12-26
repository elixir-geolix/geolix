#!/usr/bin/env bash
cd "${TRAVIS_BUILD_DIR}"

mix local.hex --force
mix deps.get
