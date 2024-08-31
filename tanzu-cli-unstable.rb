# Copyright 2023 VMware, Inc. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

class TanzuCliUnstable < Formula
  desc "The core Tanzu command-line tool (unstable builds)"
  homepage "https://github.com/vmware-tanzu/tanzu-cli"
  version "1.5.0-alpha.0"
  head "https://github.com/vmware-tanzu/tanzu-cli.git", branch: "main"

  checksums = {
    "darwin-amd64" => "eec412ecc23243cb4f1598faacaf430655cbcc335d9aaecf1a2326c9600934a8",
    "darwin-arm64" => "6cc4c94527ceecf066be7f9e469a95fa2aedfcc890f97ede59ac8be63fa22ed5",
    "linux-amd64"  => "1d9eb33add896a3eaefdb1b8a7b5557306227f1011879860120e6078ca28559b",
    "linux-arm64"  => "3c13fb0dee52181f739b3811d592bdf65d646351ead6c7037a5c76376984cc22",
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
