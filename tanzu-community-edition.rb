# Copyright 2021 VMware Tanzu Community Edition contributors. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

class TanzuCommunityEdition < Formula
  desc "Tanzu Community Edition"
  homepage "https://github.com/vmware-tanzu/community-edition"
  version "v0.10.0"
  head "https://github.com/vmware-tanzu/community-edition.git"

  if OS.mac?
    url "https://github.com/vmware-tanzu/community-edition/releases/download/#{version}/tce-darwin-amd64-#{version}.tar.gz"
    sha256 "1c40861e693ac99aa787d6de3ef6e07b7134446d9987a8ffea1155cb1c945d90"
  elsif OS.linux?
    url "https://github.com/vmware-tanzu/community-edition/releases/download/#{version}/tce-linux-amd64-#{version}.tar.gz"
    sha256 "7b246bb22f2fabd1cd2ea07ce533f10a5c5955670827e734d8c549595d106e6f"
  end

  def install
    bin.install "bin/tanzu"
    libexec.install Dir["bin/tanzu-plugin-*"]

    File.write("configure-tce.sh", brew_installer_script)
    File.chmod(0755, "configure-tce.sh")
    libexec.install "configure-tce.sh"

    File.write("uninstall.sh", brew_uninstall_script)
    File.chmod(0755, "uninstall.sh")
    libexec.install "uninstall.sh"
  end

  def post_install
    ohai "Thanks for installing Tanzu Community Edition!"
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
    ohai "* To cleanup and remove Tanzu Community Edition from your system, run the"
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

# install all plugins present in the bundle
mkdir -p "${XDG_DATA_HOME}/tanzu-cli"
for plugin in "${MY_DIR}"/tanzu-plugin*; do
  install "${plugin}" "${XDG_DATA_HOME}/tanzu-cli"
done

# copy the uninstall script to tanzu-cli directory
mkdir -p "${XDG_DATA_HOME}/tce"
install "${MY_DIR}/uninstall.sh" "${XDG_DATA_HOME}/tce"

# if plugin cache pre-exists, remove it so new plugins are detected
TANZU_PLUGIN_CACHE="${HOME}/.cache/tanzu/catalog.yaml"
if [[ -n "${TANZU_PLUGIN_CACHE}" ]]; then
  echo "Removing old plugin cache from ${TANZU_PLUGIN_CACHE}"
  rm -f "${TANZU_PLUGIN_CACHE}" > /dev/null
fi

# Make a backup of Kubernetes configs
set +o errexit
echo "Making a backup of your Kubernetes config files into /tmp"
tar cf /tmp/`date "+%Y%m%d%H%M"`-kubernetes-configs.tar ~/.kube ~/.kube-tkg ~/.tanzu ~/.config/tanzu 2>/dev/null
set -o errexit

# explicit init of tanzu cli and add Tanzu Community Edition repo
TANZU_CLI_NO_INIT=true tanzu init
#TCE_REPO="$(tanzu plugin repo list | grep tce)"
# if [[ -z "${TCE_REPO}"  ]]; then
#   tanzu plugin repo add --name tce --gcp-bucket-name tce-cli-plugins --gcp-root-path artifacts
# fi

# TCE_REPO="$(tanzu plugin repo list | grep core-admin)"
# if [[ -z "${TCE_REPO}"  ]]; then
#   tanzu plugin repo add --name core-admin --gcp-bucket-name tce-tanzu-cli-framework-admin --gcp-root-path artifacts-admin
# fi

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
