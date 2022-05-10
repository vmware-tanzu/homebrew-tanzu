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
HOMEBREW_INSTALL_DIR="tanzu-community-edition"
if [[ "${BUILD_VERSION}" == *"-"* ]]; then
    HOMEBREW_FORMULA="tanzu-community-edition-unstable.rb"
    HOMEBREW_INSTALL_DIR="tanzu-community-edition-unstable"
fi

HOMEBREW_TAP_REPO_PATH="$(git rev-parse --show-toplevel)"
HOMEBREW_WORKING_DIR="$(mktemp -d)"

trap '{ rm -rf -- "${HOMEBREW_WORKING_DIR}"; }' EXIT

curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C "${HOMEBREW_WORKING_DIR}"

shellenv=$("${HOMEBREW_WORKING_DIR}"/bin/brew shellenv)

eval "${shellenv}"

brew update --force --quiet
brew install --formula "${HOMEBREW_TAP_REPO_PATH}/${HOMEBREW_FORMULA}"

tce_installation_dir=("${HOMEBREW_WORKING_DIR}/Cellar/${HOMEBREW_INSTALL_DIR}/${BUILD_VERSION}")


pushd "${tce_installation_dir}" || exit 1

    ./libexec/configure-tce.sh

    # TODO: this needs to dynamically pick up on these things
    tanzu version
    tanzu cluster version
    tanzu conformance version
    tanzu diagnostics version
    tanzu unmanaged-cluster version
    tanzu kubernetes-release version
    tanzu management-cluster version
    tanzu package version
    tanzu standalone-cluster version
    tanzu pinniped-auth version
    tanzu builder version
    tanzu login version
    # TODO: end

    ./libexec/uninstall.sh

    set +o xtrace
    source ~/.bash_profile
    set -o xtrace

    if [[ -n "$(command -v tanzu)" ]]; then
        echo "tanzu command still exists!"
        exit 1
    fi

popd || exit 1