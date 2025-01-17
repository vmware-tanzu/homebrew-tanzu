# Copyright 2023 VMware, Inc. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

class TanzuCli < Formula
  desc "The core Tanzu command-line tool"
  homepage "https://github.com/vmware-tanzu/tanzu-cli"
  version "1.5.2"
  head "https://github.com/vmware-tanzu/tanzu-cli.git", branch: "main"

  checksums = {
    "darwin-amd64" => "1072c60ed1b4d75a94ae7b40ce3747a2c115f7d190a8a9d9229a05427abf599c",
    "darwin-arm64" => "eff4aabf365f953de0cbac2782fcd4b367446f42076ce35b35224cb56b8b27fc",
    "linux-amd64"  => "bae905e967f17445de7d487d2b58421dcb503fa17845e27f6c316cc853b62aaf",
    "linux-arm64"  => "93c37247c4ad725c2e9b3675b88e8c3f6d8f43fe1ea91080e8ab3090c9598178",
  }

  $arch = "arm64"
  on_intel do
    $arch = "amd64"
  end

  $os = "darwin"
  on_linux do
    $os = "linux"
  end

  url "https://github.com/vmware-tanzu/tanzu-cli/releases/download/v#{version}/tanzu-cli-#{$os}-#{$arch}.tar.gz"
  sha256 checksums["#{$os}-#{$arch}"]

  def install
    # Intall the tanzu CLI
    bin.install "tanzu-cli-#{$os}_#{$arch}" => "tanzu"

    # Setup shell completion
    output = Utils.safe_popen_read(bin/"tanzu", "completion", "bash")
    (bash_completion/"tanzu").write output

    output = Utils.safe_popen_read(bin/"tanzu", "completion", "zsh")
    (zsh_completion/"_tanzu").write output

    output = Utils.safe_popen_read(bin/"tanzu", "completion", "fish")
    (fish_completion/"tanzu.fish").write output
  end

  # This verifies the installation
  test do
    # DO NOT set the eula or ceip values here as they would be persisted
    # for the user's release installation.  Instead, just use commands that
    # don't trigger the prompts.

    assert_match "version: v#{version}", shell_output("#{bin}/tanzu version")
    output = shell_output("#{bin}/tanzu plugin -h")
    assert_match "Manage CLI plugins", output
  end
end
