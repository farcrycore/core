# How to contribute

Third-party patches are essential for keeping FarCry great. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

To get started, sign the [Contributor License Agreement](https://www.clahub.com/agreements/farcrycore/core)

(tldr; we use a standard [harmonyagreements.org](http://harmonyagreements.org) copyright assignment agreement. we ask contributors to assign copyright to Daemon Pty Limited, the custodian of the current FarCry code base. this allows us to modify the license in the future should it be necessary; for example, FarCry moved from CPL to GPL license at version 4.0)

## FarCry Core vs Plugins

New functionality is often directed toward plugins to provide a slimmer
FarCry Core, reducing its surface area, and to allow greater freedom for
plugin maintainers to ship releases at their own cadence, rather than
being held to the cadence of FarCry releases. 

Generally, new content types and non-generic services should be added through plugins.

If you are unsure of whether your contribution should be implemented as a
plugin or part of FarCry Core, ask on the [FarCry Discourse Forum](http://discourse.farcrycore.org)

## Getting Started

* Make sure you have a [Jira account](http://farcry.jira.com)
* Make sure you have a [GitHub account](https://github.com/signup/free)
* Submit a ticket for your issue, assuming one does not already exist.
  * Clearly describe the issue including steps to reproduce when it is a bug.
  * Make sure you fill in the earliest version that you know has the issue.
* Fork the repository on GitHub

## Making Changes

* Create a topic branch from where you want to base your work.
  * This is usually the maintenance branch for the latest version of FarCry; for example, branch `p710` maintains v7.1.x of FarCry
  * Only target earlier release branches if you are certain your fix must be on that branch.
  * To quickly create a topic branch based on `p710`; `git checkout -b
    fix/master/my_contribution p710`. Please avoid working directly on the
    `p710` branch.
* Make commits of logical units.
* Check for unnecessary whitespace with `git diff --check` before committing.
* Make sure your commit messages are in the proper format.

````
    FC-1234: Make the example in CONTRIBUTING imperative and concrete

    Without this patch applied the example commit message in the CONTRIBUTING
    document is not a concrete example.  This is a problem because the
    contributor is left to imagine what the commit message should look like
    based on a description rather than an example.  This patch fixes the
    problem by making the example concrete and imperative.

    The first line is a real life imperative statement with a ticket number
    from our issue tracker.  The body describes the behavior without the patch,
    why this is a problem, and how the patch fixes the problem when applied.
````

## Making Trivial Changes

### Documentation

For changes of a trivial nature to comments and documentation, it is not
always necessary to create a new ticket in Jira. In this case, it's ok to omit the ticket number. 

````
    Add documentation commit example to CONTRIBUTING

    There is no example for contributing a documentation commit
    to the FarCry Core repository. This is a problem because the contributor
    is left to assume how a commit of this nature may appear.

    The first line is a real life imperative statement with '(doc)' in
    place of what would have been the ticket number in a 
    non-documentation related commit. The body describes the nature of
    the new documentation or comments added.
````

## Submitting Changes

* Sign the [Contributor License Agreement](https://www.clahub.com/agreements/farcrycore/core)
* Push your changes to a topic branch in your fork of the repository
* Submit a pull request to the repository in the FarCry Core (farcrycore) organization
* Update your Jira ticket to mark that you have submitted code and are ready for it to be reviewed (Status: Resolved)
  * Include a link to the pull request in the ticket.
* The core team looks at Pull Requests on a regular basis in a weekly triage
  meeting
* After feedback has been given we expect responses within two weeks. After two
  weeks we may close the pull request if it isn't showing any activity.

# Additional Resources

* [Bug tracker (Jira)](http://farcry.jira.com)
* [Contributor License Agreement](https://www.clahub.com/agreements/farcrycore/core)
* [General GitHub documentation](http://help.github.com/)
* [GitHub pull request documentation](http://help.github.com/send-pull-requests/)
* [FarCry Discourse Forum](http://discourse.farcrycore.org)