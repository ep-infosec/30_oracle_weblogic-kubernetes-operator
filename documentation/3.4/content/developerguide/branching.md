---
title: "Branching"
date: 2019-02-23T17:19:29-05:00
draft: false
description: "Understand the operator repository branching strategy."
weight: 4
---

The `main` branch is protected and contains source for the latest completed features and bug fixes.  While this branch contains active work, we expect to keep it always "ready to release."  Therefore, longer running feature work will be performed on specific branches, such as `feature/dynamic-clusters`.

Because we want to balance separating destabilizing work into feature branches against the possibility of later difficult merges, we encourage developers working on features to pull out any necessary refactoring or improvements that are general purpose into their own shorter-lived branches and create pull requests to `main` when these smaller work items are completed.

All commits to `main` must pass the [integration test suite]({{< relref "/developerguide/integration-tests.md" >}}).  Please run these tests locally before submitting a pull request.  Additionally, each push to a branch in our GitHub repository triggers a run of a subset of the integration tests with the results visible [here](http://build.weblogick8s.org:8080/job/weblogic-kubernetes-operator-quicktest/).

Please submit pull requests to the `main` branch unless you are collaborating on a feature and have another target branch.  Please see details on the Oracle Contributor Agreement (OCA) and guidelines for pull requests in [Contribute to the operator]({{< relref "/developerguide/contributing#contributing-to-the-weblogic-kubernetes-operator-repository" >}}).

We will create git tags for each release candidate and generally available (GA) release of the operator.
