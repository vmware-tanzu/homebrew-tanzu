#!/bin/bash

# Copyright 2021 VMware Tanzu Community Edition contributors. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

version="${1:?TCE version argument empty. Example usage: ./hack/homebrew/update-homebrew-package.sh v0.10.0}"
: "${GITHUB_TOKEN:?GITHUB_TOKEN is not set}"

temp_dir=$(mktemp -d)

HOMEBREW_DIR="$(git rev-parse --show-toplevel)"

pushd "${temp_dir}"

TCE_REPO_RELEASES_URL="https://github.com/vmware-tanzu/community-edition/releases"
TCE_DARWIN_TAR_BALL_FILE="tce-darwin-amd64-${version}.tar.gz"
TCE_LINUX_TAR_BALL_FILE="tce-linux-amd64-${version}.tar.gz"
TCE_CHECKSUMS_FILE="tce-checksums.txt"

echo "Checking if the necessary files exist for the TCE ${version} release"

curl -f -I -L \
    "${TCE_REPO_RELEASES_URL}/download/${version}/${TCE_DARWIN_TAR_BALL_FILE}" > /dev/null || {
        echo "${TCE_DARWIN_TAR_BALL_FILE} is not accessible in TCE ${version} release"
        exit 1
    }

curl -f -I -L \
    "${TCE_REPO_RELEASES_URL}/download/${version}/${TCE_LINUX_TAR_BALL_FILE}" > /dev/null || {
        echo "${TCE_LINUX_TAR_BALL_FILE} is not accessible in TCE ${version} release"
        exit 1
    }

wget "${TCE_REPO_RELEASES_URL}/download/${version}/${TCE_CHECKSUMS_FILE}" || {
    echo "${TCE_CHECKSUMS_FILE} is not accessible in TCE ${version} release"
    exit 1
}

darwin_amd64_shasum=$(grep "${TCE_DARWIN_TAR_BALL_FILE}" ${TCE_CHECKSUMS_FILE} | cut -d ' ' -f 1)

linux_amd64_shasum=$(grep "${TCE_LINUX_TAR_BALL_FILE}" ${TCE_CHECKSUMS_FILE} | cut -d ' ' -f 1)


# Replacing old version with the latest stable released version.
# Using -i so that it works on Mac and Linux OS, so that it's useful for local development.
sed -i.bak "s/version \"v.*/version \"${version}\"/" "${HOMEBREW_DIR}"/tanzu-community-edition.rb
rm -fv "${HOMEBREW_DIR}"/tanzu-community-edition.rb.bak

# First occurrence of sha256 is for MacOS SHA sum
awk "/sha256 \".*/{c+=1}{if(c==1){sub(\"sha256 \\\".*\",\"sha256 \\\"${darwin_amd64_shasum}\\\"\",\$0)};print}" "${HOMEBREW_DIR}"/tanzu-community-edition.rb > "${HOMEBREW_DIR}"/tanzu-community-edition-updated.rb
mv "${HOMEBREW_DIR}"/tanzu-community-edition-updated.rb "${HOMEBREW_DIR}"/tanzu-community-edition.rb

# Second occurrence of sha256 is for Linux SHA sum
awk "/sha256 \".*/{c+=1}{if(c==2){sub(\"sha256 \\\".*\",\"sha256 \\\"${linux_amd64_shasum}\\\"\",\$0)};print}" "${HOMEBREW_DIR}"/tanzu-community-edition.rb > "${HOMEBREW_DIR}"/tanzu-community-edition-updated.rb
mv "${HOMEBREW_DIR}"/tanzu-community-edition-updated.rb "${HOMEBREW_DIR}"/tanzu-community-edition.rb
