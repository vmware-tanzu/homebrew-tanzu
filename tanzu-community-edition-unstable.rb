# Copyright 2022 VMware Tanzu Community Edition contributors. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

class TanzuCommunityEditionUnstable < Formula
  desc "Tanzu Community Edition (Unstable)"
  homepage "https://github.com/vmware-tanzu/community-edition"
  version "v0.12.0-rc.2"
  head "https://github.com/vmware-tanzu/community-edition.git"

  if OS.mac?
    url "https://github.com/vmware-tanzu/community-edition/releases/download/#{version}/tce-darwin-amd64-#{version}.tar.gz"
    sha256 "371cc717fb97a3bc9dec28516232972bc2aa8c0343238bede48529a89118fbd3"
  elsif OS.linux?
    url "https://github.com/vmware-tanzu/community-edition/releases/download/#{version}/tce-linux-amd64-#{version}.tar.gz"
    sha256 "caf5d47f363d108e7ab8f38b46392e55b5d8f4ac6ddf380f312c98a59fc1d1d3"
  end

  def install
    bin.install "tanzu"
    # TODO: find exact directory name with pattern, and not hard code the name,
    # similar to TCE tar ball's install.sh script.
    # TODO: copy default-local directory contents to libexec, maybe under a specific directory
    # like "tanzu-plugin" which will later be moved to tanzu-plugins directory
    libexec.install Dir["default-local"]

    File.write("configure-tce.sh", brew_installer_script)
    File.chmod(0755, "configure-tce.sh")
    libexec.install "configure-tce.sh"

    File.write("uninstall.sh", brew_uninstall_script)
    File.chmod(0755, "uninstall.sh")
    libexec.install "uninstall.sh"
  end

  def post_install
    ohai "Thanks for installing Tanzu Community Edition (Unstable)!"
    ohai "The Tanzu CLI has been installed on your system"
    ohai "\n"
    ohai "******************************************************************************"
    ohai "* To initialize all plugins required by Tanzu Community Edition, an additional"
    ohai "* step is required. To complete the installation, please run the following"
    ohai "* shell script:"
    ohai "*"
    ohai "* #{libexec}/configure-tce.sh"
    ohai "*"
    ohai "******************************************************************************"
    ohai "\n"
    ohai "* To cleanup and remove Tanzu Community Edition (Unstable) from your system, run the"
    ohai "* following script:"
    ohai "#{libexec}/uninstall.sh"
    ohai "\n"
  end

  # Homebrew requires tests.
  test do
    assert_match("ceaa474", shell_output("#{bin}/tanzu version", 2))
  end

  def brew_installer_script
    <<-EOF
#!/bin/bash

# Copyright 2021 VMware Tanzu Community Edition contributors. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

set -o errexit
set -o nounset
set -o pipefail
set +o xtrace

ALLOW_INSTALL_AS_ROOT="${ALLOW_INSTALL_AS_ROOT:-""}"
if [[ "$EUID" -eq 0 && "${ALLOW_INSTALL_AS_ROOT}" != "true" ]]; then
  echo "Do not run this script as root"
  exit 1
fi

MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "MY_DIR: ${MY_DIR}"
BUILD_OS=$(uname 2>/dev/null || echo Unknown)

case "${BUILD_OS}" in
  Linux)
    XDG_DATA_HOME="${HOME}/.local/share"
    XDG_CONFIG_HOME="${HOME}/.config"
    ;;
  Darwin)
    XDG_DATA_HOME="${HOME}/Library/Application Support"
    XDG_CONFIG_HOME="${HOME}/.config"
    ;;
  *)
    echo "${BUILD_OS} is unsupported"
    exit 1
    ;;
esac
echo "${XDG_DATA_HOME}"

# if plugin cache pre-exists, remove it so new plugins are detected
TANZU_PLUGIN_CACHE="${HOME}/.cache/tanzu/catalog.yaml"
if [[ -n "${TANZU_PLUGIN_CACHE}" ]]; then
  echo "Removing old plugin cache from ${TANZU_PLUGIN_CACHE}"
  rm -f "${TANZU_PLUGIN_CACHE}" > /dev/null
fi

# copy the uninstall script to tanzu-cli directory
mkdir -p "${XDG_DATA_HOME}/tce"
install "${MY_DIR}/uninstall.sh" "${XDG_DATA_HOME}/tce"

# install all plugins present in the bundle
mkdir -p "${XDG_CONFIG_HOME}/tanzu-plugins"

cp -r "${MY_DIR}/default-local/." "${XDG_CONFIG_HOME}/tanzu-plugins"
# install plugins
tanzu plugin install builder
tanzu plugin install codegen
tanzu plugin install cluster
tanzu plugin install kubernetes-release
tanzu plugin install login
tanzu plugin install management-cluster
tanzu plugin install package
tanzu plugin install pinniped-auth
tanzu plugin install secret
tanzu plugin install conformance
tanzu plugin install diagnostics
tanzu plugin install unmanaged-cluster

# Make a backup of Kubernetes configs
set +o errexit
echo "Making a backup of your Kubernetes config files into /tmp"
tar cf /tmp/`date "+%Y%m%d%H%M"`-kubernetes-configs.tar ~/.kube ~/.kube-tkg ~/.tanzu ~/.config/tanzu 2>/dev/null
set -o errexit

TCE_REPO="$(tanzu plugin repo list | grep tce)"
if [[ -z "${TCE_REPO}"  ]]; then
  tanzu plugin repo add --name tce --gcp-bucket-name tce-tanzu-cli-plugins --gcp-root-path artifacts
fi

TCE_REPO="$(tanzu plugin repo list | grep core-admin)"
if [[ -z "${TCE_REPO}"  ]]; then
  tanzu plugin repo add --name core-admin --gcp-bucket-name tce-tanzu-cli-framework-admin --gcp-root-path artifacts-admin
fi

echo "Installation complete!"
EOF
  end

  def brew_uninstall_script
    <<-EOF
#!/bin/bash

# Copyright 2021 VMware Tanzu Community Edition contributors. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# set -o errexit
set -o nounset
set -o pipefail
set +o xtrace

BUILD_OS=$(uname 2>/dev/null || echo Unknown)

case "${BUILD_OS}" in
  Linux)
    XDG_DATA_HOME="${HOME}/.local/share"
    ;;
  Darwin)
    XDG_DATA_HOME="${HOME}/Library/Application Support"
    ;;
  *)
    echo "${BUILD_OS} is unsupported"
    exit 1
    ;;
esac
echo "${XDG_DATA_HOME}"

rm -rf "${XDG_DATA_HOME}/tanzu-cli" \
  "${XDG_DATA_HOME}/tce" \
  ${HOME}/.cache/tanzu/catalog.yaml \
  ${HOME}/.config/tanzu/config.yaml \
  ${HOME}/.config/tanzu/tkg/bom \
  ${HOME}/.config/tanzu/tkg/providers \
  ${HOME}/.config/tanzu/tkg/.tanzu.lock \
  ${HOME}/.config/tanzu/tkg/compatibility/tkg-compatibility.yaml

echo "Cleanup complete!"
echo
echo "Removing the Tanzu CLI..."
echo
brew uninstall tanzu-community-edition
EOF
  end
end
