# Copyright 2023 VMware, Inc. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

class TanzuCli < Formula
  desc "The core Tanzu command-line tool"
  homepage "https://github.com/vmware-tanzu/tanzu-cli"
  version "1.5.1"
  head "https://github.com/vmware-tanzu/tanzu-cli.git", branch: "main"

  checksums = {
    "darwin-amd64" => "326ff2e301938125685d85f9c9bc64fbdd99668f506b87fe32655b366ef32948",
    "darwin-arm64" => "8eea654044309a84d3d774bfb88ff58ba42962acd387943e683625fb6b1f04f8",
    "linux-amd64"  => "3e7675817eae030d8c4df76d92c0ee1f47ec690028d9bba3ed1d5b0473198690",
    "linux-arm64"  => "89c96a46744bc50d39d92ea2b9aa72b6028d932a7683efc55a334a5d4fe18c5d",
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
