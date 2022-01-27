#!/bin/bash

# Copyright 2021 VMware Tanzu Community Edition contributors. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

version="${1:?TCE version argument empty. Example usage: ./hack/homebrew/update-homebrew-package.sh v0.10.0}"
: "${GITHUB_TOKEN:?GITHUB_TOKEN is not set}"

MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
HOMEBREW_TAP_REPO_PATH="${MY_DIR}"/..

# checking current TCE version
"${HOMEBREW_TAP_REPO_PATH}"/test/check-tce-homebrew-formula.sh

# Temprory home brew formulae file creation 
cat "${HOMEBREW_TAP_REPO_PATH}"/tanzu-community-edition.rb > "${HOMEBREW_TAP_REPO_PATH}"/tanzu-community-edition-temp.rb
rm -fv "${HOMEBREW_TAP_REPO_PATH}"/tanzu-community-edition-temp.rb.bak

"${HOMEBREW_TAP_REPO_PATH}"/test/update-homebrew-formula.sh "${version}"

# checking lates TCE stable version
"${HOMEBREW_TAP_REPO_PATH}"/test/check-tce-homebrew-formula.sh

cp "${HOMEBREW_TAP_REPO_PATH}"/tanzu-community-edition-temp.rb "${HOMEBREW_TAP_REPO_PATH}"/tanzu-community-edition.rb

# cleaning up the tenp files
rm -fv "${HOMEBREW_TAP_REPO_PATH}"/tanzu-community-edition-temp.rb
