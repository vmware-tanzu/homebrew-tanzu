# Copyright 2023 VMware, Inc. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

class TanzuCliUnstable < Formula
  desc "The core Tanzu command-line tool (unstable builds)"
  homepage "https://github.com/vmware-tanzu/tanzu-cli"
  version "1.2.0-alpha.0"
  head "https://github.com/vmware-tanzu/tanzu-cli.git", branch: "main"

  checksums = {
    "darwin-amd64" => "f1c310adedbc1339df18dce33c71856a030c76d921fd09a7734b50b2cd9f3f3b",
    "darwin-arm64" => "db2ae9a48bd78a956442d3765fd754fe415246893c42d831e9e06095d7eaddbe",
    "linux-amd64"  => "d06c3fc0cda7d1e353f3f6d52e849e43632de903428fc9d8acbf4d0646d3d526",
    "linux-arm64"  => "e1130289ae118cc0b465375da5c463f34c69d986a8d9e711a64e5643a9ca1090",
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
