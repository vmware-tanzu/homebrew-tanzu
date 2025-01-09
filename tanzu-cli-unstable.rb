# Copyright 2023 VMware, Inc. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

class TanzuCliUnstable < Formula
  desc "The core Tanzu command-line tool (unstable builds)"
  homepage "https://github.com/vmware-tanzu/tanzu-cli"
  version "1.5.2-rc.0"
  head "https://github.com/vmware-tanzu/tanzu-cli.git", branch: "main"

  checksums = {
    "darwin-amd64" => "e0910262363d1cd3b358ef0a9bd62e791becec35441a934316cbf77e4ad3417f",
    "darwin-arm64" => "1163f7640bfe8e0cb2e0d527f7f754a6fbce9a6cfe556610a95f5b845f71ef84",
    "linux-amd64"  => "e27320bdb22e00b0079508a769b8b81527b9f8fc03a7a7f0c29d26049f83ccf7",
    "linux-arm64"  => "ac5fa9e1deb47362537150ad5be95f6b771616527b48aadd2d30b19a12fcd512",
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
