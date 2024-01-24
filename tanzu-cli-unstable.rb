# Copyright 2023 VMware, Inc. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

class TanzuCliUnstable < Formula
  desc "The core Tanzu command-line tool (unstable builds)"
  homepage "https://github.com/vmware-tanzu/tanzu-cli"
  version "1.2.0-rc.0"
  head "https://github.com/vmware-tanzu/tanzu-cli.git", branch: "main"

  checksums = {
    "darwin-amd64" => "ba4871dbdf45c6c16a12f24dd9248e8c356ba688269b7491b06fdba52f24d90f",
    "darwin-arm64" => "2b8d114d3df382cf2be0943af5029fd2fed9d3d981a8c39f2d5b86ba60ca92c5",
    "linux-amd64"  => "11276c3916b6f4fc28c92aa715b1c40577d9857bc3843afaed5cf5105a42cd83",
    "linux-arm64"  => "3a304d46aa082e0275ecf46439f1650719c887fb220d706ffa7a0dc93cab1acf",
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
