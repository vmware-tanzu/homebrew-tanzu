# homebrew-tanzu
Homebrew tap for the [Tanzu CLI](https://github.com/vmware-tanzu/tanzu-cli)

## Installation

```console
brew tap vmware-tanzu/tanzu  # Only needs to be done once for the machine

brew install tanzu-cli
```

To upgrade to a new release: `brew update && brew upgrade tanzu-cli`

To uninstall: `brew uninstall tanzu-cli`

Installing with Homebrew will automatically setup shell completion for
`bash`, `zsh` and `fish`.

### Installing a Specific Version

At the time of writing, Homebrew only officially supported installing the
latest version of a formula, however the following workaround allows to install
a specific version by first extracting it to a local tap:

```console
brew tap-new local/tap
brew extract --version=1.0.0 vmware-tanzu/tanzu/tanzu-cli local/tap
brew install tanzu-cli@1.0.0

# To uninstall such an installation
brew uninstall tanzu-cli@1.0.0
```

### Installing a Pre-Release

Pre-releases of the Tanzu CLI are made available to get early feedback before
a new version is released.  Pre-releases are available through Homebrew
using a different package name: `tanzu-cli-unstable`.

**Note**: Just like installing a new version, installing a pre-release will
replace the `tanzu` binary of any previous installation.

```console
brew tap vmware-tanzu/tanzu  # If not already done on this machine

brew install tanzu-cli-unstable --overwrite

# To uninstall such an installation
brew uninstall tanzu-cli-unstable
```