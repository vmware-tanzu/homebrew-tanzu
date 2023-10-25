# Copyright 2023 VMware, Inc. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

class TanzuCliUnstable < Formula
  desc "The core Tanzu command-line tool (unstable builds)"
  homepage "https://github.com/vmware-tanzu/tanzu-cli"
  version "1.1.0-rc.0"
  head "https://github.com/vmware-tanzu/tanzu-cli.git", branch: "main"

  checksums = {
    "darwin-amd64" => "81b6330dc8481c1aa51d4fc76aabe3ae132bd76d207a531d4481c8578ad9d5d7",
    "darwin-arm64" => "d0d18be55efe25f3407bdca51dc7ba29db76eb8864f00404e23c449a69cf06cd",
    "linux-amd64"  => "e6c83fde072512435a2910fa297bdf4f9906950044ccc12faa91eadcf376eebe",
    "linux-arm64"  => "a72e01baf0f8173b92141b266e28f21461bd9641a3fd44e1acc31b125e9ee8fc",
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
