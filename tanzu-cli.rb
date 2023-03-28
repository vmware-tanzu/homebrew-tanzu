# Copyright 2023 VMware, Inc. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

class TanzuCli < Formula
  desc "The core Tanzu command-line tool"
  homepage "https://github.com/vmware-tanzu/tanzu-cli"
  version "0.90.0-alpha.0"
  head "https://github.com/vmware-tanzu/tanzu-cli.git", branch: "main"

  checksums = {
    "darwin-amd64" => "cc9eb7c42ee4509abd08fbbfdc8dc80199c0d1c9b9b4dd400cd390dc448bd094",
    "linux-amd64"  => "cd2f5116a905788c8a02845b999cf124b97a53d8aeef83f6ab0f8f95b6c7935a",
  }

  # Switch this to "arm64" when it is supported by CLI builds
  $arch = "amd64"
  on_intel do
    $arch = "amd64"
  end

  $os = "darwin"
  on_linux do
    $os = "linux"
  end

  url "https://github.com/marckhouzam/tanzu-cli/releases/download/v#{version}/tanzu-cli-#{$os}-#{$arch}.tar.gz"
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
    assert_match "version: v#{version}", shell_output("#{bin}/tanzu version")

    output = shell_output("#{bin}/tanzu config get")
    assert_match "clientOptions", output
  end
end
