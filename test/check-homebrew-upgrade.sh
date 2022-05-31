#!/bin/bash

# Copyright 2021 VMware Tanzu Community Edition contributors. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

if [[ -z "${BUILD_VERSION}" ]]; then
    echo "BUILD_VERSION is not set"
    exit 1
fi

# select for GA or unstable (non-GA) homebrew file
HOMEBREW_FORMULA="tanzu-community-edition.rb"
PREVIOUS_VERSION="$(grep -E "version.+\"v[0-9]+.[0-9]+.[0-9]+\"" ./tanzu-community-edition-unstable.rb | cut -d"\"" -f2)"
if [[ "${BUILD_VERSION}" == *"-"* ]]; then
    HOMEBREW_FORMULA="tanzu-community-edition-unstable.rb"
    PREVIOUS_VERSION="$(grep -E "version.+\"v[0-9]+.[0-9]+.[0-9]+\"" ./tanzu-community-edition.rb | cut -d"\"" -f2)"
fi

HOMEBREW_TAP_REPO_PATH="$(git rev-parse --show-toplevel)"

# checking current TCE version
BUILD_VERSION="${PREVIOUS_VERSION}" "${HOMEBREW_TAP_REPO_PATH}/test/check-tce-homebrew-formula.sh"

# Temporary homebrew formula file creation 
cat "${HOMEBREW_TAP_REPO_PATH}/${HOMEBREW_FORMULA}" > "${HOMEBREW_TAP_REPO_PATH}/temp-${HOMEBREW_FORMULA}"
rm -fv "${HOMEBREW_TAP_REPO_PATH}/temp-${HOMEBREW_FORMULA}"

BUILD_VERSION="${BUILD_VERSION}" "${HOMEBREW_TAP_REPO_PATH}/test/update-homebrew-formula.sh"

# checking latest TCE version
"${HOMEBREW_TAP_REPO_PATH}/test/check-tce-homebrew-formula.sh"
cp "${HOMEBREW_TAP_REPO_PATH}/temp-${HOMEBREW_FORMULA}" "${HOMEBREW_TAP_REPO_PATH}/${HOMEBREW_FORMULA}"

# cleaning up the temp files
rm -fv "${HOMEBREW_TAP_REPO_PATH}/temp-${HOMEBREW_FORMULA}"
