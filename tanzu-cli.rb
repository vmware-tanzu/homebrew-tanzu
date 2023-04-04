# Copyright 2023 VMware, Inc. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

class TanzuCli < Formula
  desc "The core Tanzu command-line tool"
  homepage "https://github.com/vmware-tanzu/tanzu-cli"
  version "0.0.18"
  head "https://github.com/vmware-tanzu/tanzu-cli.git", branch: "main"

  checksums = {
    "darwin-amd64" => "d91719840534d564ff3e3f8512ae2302620444e34fa53919927cb6d185fa735d",
    "linux-amd64"  => "c9967ea224a9b2cb0edd9a061a157e234b83ed4876757b1eada0f3025214e4b6",
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

  url "http://build-squid.eng.vmware.com/build/mts/release/bora-21550143/publish/lin64/tanzu-cli/tanzu_cli/tanzu-cli-darwin-amd64.tar.gz"
#  url "https://github.com/marckhouzam/tanzu-cli/releases/download/v#{version}/tanzu-cli-#{$os}-#{$arch}.tar.gz"
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
