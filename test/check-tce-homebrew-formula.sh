#!/bin/bash

# Copyright 2021 VMware Tanzu Community Edition contributors. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
HOMEBREW_TAP_REPO_PATH="${MY_DIR}"/..

HOMEBREW_DIR="$(mktemp -d)"

trap '{ rm -rf -- "${HOMEBREW_DIR}"; }' EXIT

curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C "${HOMEBREW_DIR}"

shellenv=$("${HOMEBREW_DIR}"/bin/brew shellenv)

eval "${shellenv}"

brew update --force --quiet

brew install --formula "${HOMEBREW_TAP_REPO_PATH}"/tanzu-community-edition.rb

tce_installation_dir=("${HOMEBREW_DIR}"/Cellar/tanzu-community-edition/*)

if [ ${#tce_installation_dir[@]} != 1 ]; then
    echo "TCE was not installed!"
    exit 1
fi

"${tce_installation_dir[0]}"/libexec/configure-tce.sh

tanzu version

tanzu cluster version

tanzu conformance version

tanzu diagnostics version

tanzu kubernetes-release version

tanzu management-cluster version

tanzu package version

tanzu standalone-cluster version

tanzu pinniped-auth version

tanzu builder version

tanzu login version

"${tce_installation_dir[0]}"/libexec/uninstall.sh

set +o xtrace
source ~/.bash_profile
set -o xtrace

if [[ -n "$(command -v tanzu)" ]]; then
    echo "tanzu command still exists!"
    exit 1
fi
