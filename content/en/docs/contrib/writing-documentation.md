---
title: Writing documentation
description: Our goal is to keep the documentation informative and thorough. You can help to improve the documentation and keep it relevant as the project evolves.
weight: 11
---

We place high importance on the consistency and readability of documentation. We treat our
documentation like we treat our code: we aim to improve it as often as possible.

Documentation changes generally come in two forms:

1. General improvements: typo corrections, error fixes and better explanations through clearer
   writing and more examples.
1. New features: documentation of features that have been added to the project since the last
   release.

This section explains how writers can craft their documentation changes in the most useful and least
error-prone ways.

## How documentation is written

Though SpinKube's documentation is intended to be read as HTML at https://spinkube.dev/docs, we edit
it as a collection of plain text files written in [Markdown](https://en.wikipedia.org/wiki/Markdown)
for maximum flexibility.

SpinKube's documentation uses a documentation system known as [docsy](https://www.docsy.dev/), which
in turn is based on the [Hugo web framework](https://gohugo.io/). The basic idea is that
lightly-formatted plain-text documentation is transformed into HTML through a process known as
[Static Site Generation (SSG)](https://en.wikipedia.org/wiki/Static_site_generator).

### Previewing your changes locally

If you want to run your own local Hugo server to preview your changes as you work:

1. Fork the [`spinframework/spinkube-docs`](https://github.com/spinframework/spinkube-docs) repository on
   GitHub.
1. Clone your fork to your computer.
1. Read the `README.md` file for instructions on how to build the site from source.
1. Continue with the usual development workflow to edit files, commit them, push changes up to your
  fork, and create a pull request. If you're not sure how to do this, see [writing code]({{< ref
  "writing-code" >}}) for tips.

## Making quick changes

If you’ve just spotted something you’d like to change while using the documentation, the website has
a shortcut for you:

1. Click **Edit this page** in the top right-hand corner of the page.
1. If you don't already have an up-to-date fork of the project repo, you are prompted to get one -
   click **Fork this repository and propose changes** or **Update your Fork** to get an up-to-date
   version of the project to edit.

## Filing issues

If you've found a problem in the documentation, but you're not sure how to fix it yourself, please
file an issue in the [documentation repository](https://github.com/spinframework/spinkube-docs/issues).
You can also file an issue about a specific page by clicking the **Create Issue** button in the top
right-hand corner of the page.
