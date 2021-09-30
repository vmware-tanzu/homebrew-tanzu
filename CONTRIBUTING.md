# Homebrew-Tanzu

The homebrew-tanzu project team welcomes contributions from the community. Before you start working with homebrew-tanzu, please
read our [Developer Certificate of Origin](https://cla.vmware.com/dco). All contributions to this repository must be
signed as described on that page. Your signature certifies that you wrote the patch or have the right to pass it on
as an open-source patch.

## Contribution workflow

This section describes the process for contributing a bug fix or new feature.

### Before you submit a pull request

This project operates according to the _talk, then code_ rule.
If you plan to submit a pull request for anything more than a typo or obvious bug fix,
first you _should_ [raise an issue][new-issue] to discuss your proposal, before submitting any code.

### Commit message and PR guidelines

- Have a short subject on the first line and a body.
- Use the imperative mood (ie "If applied, this commit will (subject)" should make sense).
- Put a summary of the main area affected by the commit at the start,
with a colon as delimiter. For example 'docs:', 'extensions/(extensionname):', 'design:' or something similar.
- Do not merge commits that don't relate to the affected issue (e.g. "Updating from PR comments", etc). Should
the need to cherrypick a commit or rollback arise, it should be clear what a specific commit's purpose is.
- If the main branch has moved on, you'll need to rebase before we can merge,
so merging upstream main or rebasing from upstream before opening your
PR will probably save you some time.

Pull requests *must* include a `Fixes #NNNN` or `Updates #NNNN` comment.
Remember that `Fixes` will close the associated issue, and `Updates` will link the PR to it.

#### Sample commit message

```text
extensions/extenzi: Add quux functions

To implement the quux functions from #xxyyz, we need to
flottivate the crosp, then ensure that the orping is
appred.

Fixes #xxyyz

Signed-off-by: Your Name <you@youremail.com>
```

### Merging commits

Maintainers should prefer to merge pull requests with the [Squash and merge](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/about-pull-request-merges#squash-and-merge-your-pull-request-commits) option.
This option is preferred for a number of reasons.
First, it causes GitHub to insert the pull request number in the commit subject which makes it easier to track which PR changes landed in.
Second, it gives maintainers an opportunity to edit the commit message to conform to TCE standards and general [good practice](https://chris.beams.io/posts/git-commit/).
Finally, a one-to-one correspondence between pull requests and commits makes it easier to manage reverting changes and increases the reliability of bisecting the tree (since CI runs at a pull request granularity).

At a maintainer's discretion, pull requests with multiple commits can be merged with the [Create a merge commit](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/about-pull-request-merges) option.
Merging pull requests with multiple commits can make sense in cases where a change involves code generation or mechanical changes that can be cleanly separated from semantic changes.
The maintainer should review commit messages for each commit and make sure that each commit builds and passes tests.

## Contributor License Agreement

All contributors to this project must have a signed Contributor License
Agreement (**"CLA"**) on file with us. The CLA grants us the permissions we
need to use and redistribute your contributions as part of the project; you or
your employer retain the copyright to your contribution. Before a PR can pass
all required checks, our CLA action will prompt you to accept the agreement.
Head over to [https://cla.vmware.com/](https://cla.vmware.com/) to see your
current agreement(s) on file or to sign a new one.

We generally only need you (or your employer) to sign our CLA once and once
signed, you should be able to submit contributions to any VMware project.

Note: if you would like to submit an "_obvious fix_" for something like a typo,
formatting issue or spelling mistake, you may not need to sign the CLA.

[new-issue]: https://github.com/vmware-tanzu/homebrew-tanzu/issues/new/

