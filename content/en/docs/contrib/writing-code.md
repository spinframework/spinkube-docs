---
title: Writing code
description: Fix a bug, or add a new feature. You can make a pull request and see your code in the next version of SpinKube!
weight: 10
---

Interested in giving back to the community a little? Maybe you've found a bug in SpinKube that you'd
like to see fixed, or maybe there's a small feature you want added.

Contributing back to SpinKube itself is the best way to see your own concerns addressed. This may
seem daunting at first, but it's a well-traveled path with documentation, tooling, and a community
to support you. We'll walk you through the entire process, so you can learn by example.

## Who's this tutorial for?

For this tutorial, we expect that you have at least a basic understanding of how SpinKube works.
This means you should be comfortable going through the existing tutorials on deploying your first
app to SpinKube. It is also worthwhile learning a bit of Rust, since many of SpinKube's projects are
written in Rust. If you don't, [Learn Rust](https://www.rust-lang.org/learn) is a great place to
start.

Those of you who are unfamiliar with `git` and GitHub will find that this tutorial and its links
include just enough information to get started. However, you'll probably want to read some more
about these different tools if you plan on contributing to SpinKube regularly.

For the most part though, this tutorial tries to explain as much as possible, so that it can be of
use to the widest audience.

## Code of Conduct

As a contributor, you can help us keep the SpinKube community open and inclusive. Please read and
follow our [Code of Conduct](https://github.com/spinframework/governance/blob/main/CODE_OF_CONDUCT.md).

## Install git

For this tutorial, you'll need Git installed to download the current development version of SpinKube
and to generate a branch for the changes you make.

To check whether or not you have Git installed, enter `git` into the command line. If you get
messages saying that this command could not be found, you'll have to download and install it. See
[Git's download page](https://git-scm.com/download) for more information.

If you're not that familiar with Git, you can always find out more about its commands (once it's
installed) by typing `git help` into the command line.

## Fork the repository

SpinKube is hosted on GitHub, and you'll need a GitHub account to contribute. If you don't have one,
you can sign up for free at [GitHub](https://github.com).

SpinKube's repositories are organized under the [spinframework GitHub
organization](https://github.com/spinframework). Once you have an account, fork one of the repositories
by visiting the repository's page and clicking "Fork" in the upper right corner.

Then, from the command line, clone your fork of the repository. For example, if you forked the
`spin-operator` repository, you would run:

```shell
git clone https://github.com/YOUR-USERNAME/spin-operator.git
```

## Read the README

Each repository in the SpinKube organization has a README file that explains what the project does
and how to get started. This is a great place to start, as it will give you an overview of the
project and how to run the test suite.

## Run the test suite

When contributing to a project, it's very important that your code changes don't introduce bugs. One
way to check that the project still works after you make your changes is by running the project's
test suite. If all the tests still pass, then you can be reasonably sure that your changes work and
haven't broken other parts of the project. If you've never run the project's test suite before, it's
a good idea to run it once beforehand to get familiar with its output.

Most projects have a command to run the test suite. This is usually something like `make test` or
`cargo test`. Check the project's README file for instructions on how to run the test suite. If
you're not sure, you can always ask for help in the `#spinkube` channel [on
Slack](https://cloud-native.slack.com/archives/C06PC7JA1EE).

## Find an issue to work on

If you're not sure where to start, you can look for issues labeled `good first issue` in the
repository you're interested in. These issues are often much simpler in nature and specifically
tagged as being good for new contributors to work on.

## Create a branch

Before making any changes, create a new branch for the issue:

```shell
git checkout -b issue-123
```

Choose any name that you want for the branch. `issue-123` is an example. All changes made in this
branch will be specific to the issue and won't affect the main copy of the code that we cloned
earlier.

## Write some tests for your issue

If you're fixing a bug, write a test (or multiple tests) that reproduces the bug. If you're adding a
new feature, write a test that verifies the feature works as expected. This will help ensure that
your changes work as expected and don't break other parts of the project.

## Confirm the tests fail

Now that we've written a test, we need to confirm that it fails. This is important because it
verifies that the test is actually testing what we think it is. If the test passes, then it's not
actually testing the issue we're trying to fix.

To run the test suite, refer to the project's README or reach out on
[Slack](https://cloud-native.slack.com/archives/C06PC7JA1EE).

## Make the changes

Now that we have a failing test, we can make the changes to the code to fix the issue. This is the
fun part! Use your favorite text editor to make the changes.

## Confirm the tests pass

After making the changes, run the test suite again to confirm that the tests pass. If the tests
pass, then you can be reasonably sure that your changes work as expected.

Once you've verified that your changes and test are working correctly, it's a good idea to run the
entire test suite to verify that your change hasn't introduced any bugs into other areas of the
project. While successfully passing the entire test suite doesn't guarantee your code is bug free,
it does help identify many bugs and regressions that might otherwise go unnoticed.

## Commit your changes

Once you've made your changes and confirmed that the tests pass, commit your changes to your branch:

```shell
git add .
git commit -m "Fix issue 123"
```

## Push your changes

Now that you've committed your changes to your branch, push your branch to your fork on GitHub:

```shell
git push origin issue-123
```

## Create a pull request

Once you've pushed your changes to your fork on GitHub, you can create a pull request. This is a
request to merge your changes into the main copy of the code. To create a pull request, visit your
fork on GitHub and click the "New pull request" button.

## Write documentation

If your changes introduce new features or change existing behavior, it's important to update the
documentation. This helps other contributors understand your changes and how to use them.

See the guide on [writing documentation]({{< ref "writing-documentation" >}}) for more information.

## Next steps

Congratulations! You've made a contribution to SpinKube.

After a pull request has been submitted, it needs to be reviewed by a maintainer. Reach out on the
`#spinkube` channel on the [CNCF Slack](https://cloud-native.slack.com/archives/C06PC7JA1EE) to ask
for a review.
