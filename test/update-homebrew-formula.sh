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
if [[ "${BUILD_VERSION}" == *"-"* ]]; then
    HOMEBREW_FORMULA="tanzu-community-edition-unstable.rb"
fi

HOMEBREW_DIR="$(git rev-parse --show-toplevel)"

TCE_REPO_RELEASES_URL="https://github.com/vmware-tanzu/community-edition/releases"
TCE_DARWIN_TAR_BALL_FILE="tce-darwin-amd64-${BUILD_VERSION}.tar.gz"
TCE_LINUX_TAR_BALL_FILE="tce-linux-amd64-${BUILD_VERSION}.tar.gz"
TCE_CHECKSUMS_FILE="tce-checksums.txt"

pushd "${HOMEBREW_DIR}" || exit 1

	echo "Checking if the necessary files exist for the TCE ${BUILD_VERSION} release"

	wget --spider -q \
	    "${TCE_REPO_RELEASES_URL}/download/${BUILD_VERSION}/${TCE_DARWIN_TAR_BALL_FILE}" > /dev/null || {
		echo "${TCE_DARWIN_TAR_BALL_FILE} is not accessible in TCE ${BUILD_VERSION} release"
		exit 1
	    }

	wget --spider -q \
	    "${TCE_REPO_RELEASES_URL}/download/${BUILD_VERSION}/${TCE_LINUX_TAR_BALL_FILE}" > /dev/null || {
		echo "${TCE_LINUX_TAR_BALL_FILE} is not accessible in TCE ${BUILD_VERSION} release"
		exit 1
	    }

	wget "${TCE_REPO_RELEASES_URL}/download/${BUILD_VERSION}/${TCE_CHECKSUMS_FILE}" || {
	    echo "${TCE_CHECKSUMS_FILE} is not accessible in TCE ${BUILD_VERSION} release"
	    exit 1
	}

	darwin_amd64_shasum=$(grep "${TCE_DARWIN_TAR_BALL_FILE}" "${TCE_CHECKSUMS_FILE}" | cut -d ' ' -f1)
	linux_amd64_shasum=$(grep "${TCE_LINUX_TAR_BALL_FILE}" "${TCE_CHECKSUMS_FILE}" | cut -d ' ' -f1)
	rm -f "${TCE_CHECKSUMS_FILE}"


	# Replacing old version with the latest stable released version.
	sed -i.bak -E "s/version \"v.*/version \"${BUILD_VERSION}\"/" "${HOMEBREW_FILE}" && rm "${HOMEBREW_FILE}.bak"
	# First occurrence of sha256 is for MacOS SHA sum
	awk "/sha256 \".*/{c+=1}{if(c==1){sub(\"sha256 \\\".*\",\"sha256 \\\"${darwin_amd64_shasum}\\\"\",\$0)};print}" "${HOMEBREW_FILE}" > "tmp-${HOMEBREW_FILE}"
	mv "tmp-${HOMEBREW_FILE}" "${HOMEBREW_FILE}"
	# Second occurrence of sha256 is for Linux SHA sum
	awk "/sha256 \".*/{c+=1}{if(c==2){sub(\"sha256 \\\".*\",\"sha256 \\\"${linux_amd64_shasum}\\\"\",\$0)};print}" "${HOMEBREW_FILE}" > "tmp-${HOMEBREW_FILE}"
	mv "tmp-${HOMEBREW_FILE}" "${HOMEBREW_FILE}"

popd || exit 1

