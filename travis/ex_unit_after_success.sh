#!/usr/bin/env bash
cd "${TRAVIS_BUILD_DIR}"

if [ 'true' = "${TRAVIS_COVERAGE}" ]; then
  mix coveralls.travis
fi
