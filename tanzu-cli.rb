# Copyright 2023 VMware, Inc. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

class TanzuCli < Formula
  desc "The core Tanzu command-line tool"
  homepage "https://github.com/vmware-tanzu/tanzu-cli"
  version "0.81.1"
  head "https://github.com/vmware-tanzu/tanzu-cli.git", branch: "main"

  checksums = {
    "darwin-amd64" => "5efabdcbe2061342a37405e9f716697d85c5cc3a5c7c3332de6e6d4791294e62",
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

  url "http://build-squid.eng.vmware.com/build/mts/release/bora-21556621/publish/lin64/tanzu-cli/tanzu_cli/tanzu-cli-darwin-amd64.tar.gz"
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
    # TODO(khouzam): enable when `tanzu version` does not trigger the CEIP prompt
    # assert_match "version: v#{version}", shell_output("#{bin}/tanzu version")

    # Run the test with the completion command because it won't
    # trigger the CEIP prompt
    output = shell_output("#{bin}/tanzu completion bash")
    assert_match "__start_tanzu", output
  end
end
