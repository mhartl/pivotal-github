# pivotal-github

The `pivotal-github` gem facilitates a [Pivotal&nbsp;Tracker](http://pivotaltracker.com/)–[GitHub](http://github.com/) workflow inspired by the workflow used by [Logical Reality](http://lrdesign.com/). (Despite its name, `pivotal-github` also works fine with [Bitbucket](http://bitbucket.com/); see **Configuration** below.) As per usual, there are several projects (notably [git-flow](https://github.com/nvie/gitflow) and [git-pivotal](https://github.com/trydionel/git-pivotal)) that implement similar solutions, but none met my exact needs, so I rolled my own.

## Installation

You can install the `pivotal-github` gem directly as follows:

    $ gem install pivotal-github

The full workflow described herein requires some of the Git utilities from [git-utils](https://github.com/mhartl/git-utils), so it is recommended to install those as well.

## Usage

The `pivotal-github` gem adds several additional Git commands to the local environment. The main addition, `git story-commit`, automatically incorporates the Pivotal Tracker story id(s) into the commit messages, while adding options to mark the story **Finished** or **Delivered**.

The `git story-commit` command makes the assumption that any string of eight or more digits in the branch name is a story id. (As of this writing, Pivotal Tracker ids are eight digits long, so shorter digit strings aren't valid ids.) This means that the branch names `62831853-add-markdown-support`, `62831853_add_markdown_support`, `add-markdown-support-62831853`, and `rails_4_0_62831853` all correspond to story id `62831853`, while `add-things-62831853-31415926` corresponds to both `62831853` *and* `31415926`.

The full set of commands is as follows:

### git story-commit

`git story-commit` makes a standard `git commit` with the story number added to the commit message. This automatically adds a link at Pivotal Tracker between the story and the diff when the branch gets pushed up to GitHub.

For example, when on a branch called `add-markdown-support-62831853`, the `git story-commit` command automatically adds `[#62831853]` to the commit message:

    $ git story-commit -am "Add foo bars"
    [add-markdown-support-62831853 6f56414] Add foo bars

The commit message is multiline and includes the story id:

    Add foo bars

    [#62831853]

(Previous versions of `pivotal-github` put the story id on the same line as the commit summary (per the usage at the [Pivotal Tracker API](https://www.pivotaltracker.com/help/api?version=v3)), but placing it in a separate line gives the user direct control over the length of the message. It also looks less cluttered.)

To mark a story as **Finished**, add the `-f` flag:

    $ git story-commit -f -am "Remove baz quuxes"

This gives the message

    Remove baz quuxes

    [Finishes #62831853]

To mark a story as **Delivered**, add the `-d` flag:

    $ git story-commit -d -am "Remove baz quuxes"

The message in this case is

    Remove baz quuxes

    [Delivers #62831853]

Either the `-f` flag or the `-d` flag can be combined with other flags, yielding commands like

    $ git story-commit -dam "Remove baz quuxes"

`git story commit` supports multiple story numbers as well. For example, with a branch called `add-things-62831853-31415926`, we could deliver both stories as follows:

    $ git story-commit -dam "Remove baz quuxes"
    [add-things-62831853-31415926 7g56429] Remove baz quuxes

The message here is

    Remove baz quuxes

    [Delivers #62831853 #31415926]

#### Options

    $ git story-commit -h
        Usage: git story-commit [options]
            -m, --message MESSAGE            add a commit message (including story #)
            -f, --finish                     mark story as finished
            -d, --deliver                    mark story as delivered
            -a, --all                        commit all changed files
            -h, --help                       this usage guide

Additionally, `git story-commit` accepts any options valid for `git commit`. (`git story-commit` supports the `-a` flag even though that's a valid option to `git commit` so that the compound flag in `git story-commit -am "message"` works.)

### git story-merge

`git story-merge` merges the current branch into the target branch (defaults to `master`). On a branch called `add-markdown-support-62831853`, `git story-merge` is equivalent to the following:

    $ git checkout master
    $ git merge --no-ff --log add-markdown-support-62831853 -m "#[62831853]"

Note that this effectively changes the default merge behavior from fast-forward to no-fast-forward, which makes it possible to use `git log` to see which of the commit objects together have implemented a story. As noted in [A successful Git branching model](http://nvie.com/posts/a-successful-git-branching-model/),

> The `--no-ff` flag causes the merge to always create a new commit object, even if the merge could be performed with a fast-forward. This avoids losing information about the historical existence of a feature branch and groups together all commits that together added the feature… Yes, it will create a few more (empty) commit objects, but the gain is much bigger than that cost.

The `--log` option puts the commit messages from the individual commits in the merge message, while the `-m` flag adds the story id to the commit (optionally marking it finished or delivered with the `-f` or `-d` flag, respectively). Including the story id arranges for the merge commit itself to appear in the activity log at Pivotal Tracker, which is especially useful for viewing the full diff represented by the story.

Because of the way options are chained, passing `-ff` or `--no-log` to `git story-merge` will override the `--no-ff` or `--log` flags (respectively) and thus restore the default behavior of `git merge`.

Finally, experience shows that it's easy to forget to mark a story finished when making the final commit. As a reminder, the `git story-merge` command exits with a warning if the most recent commit doesn't contain 'Finishes' or 'Delivers' (or 'Finished', 'Delivered', 'Fixes', or 'Fixed'). This behavior can be overriden with the `--override` option.

#### Options

    Usage: git story-merge [branch] [options]
        -o, --override                   override unfinished story warning
        -f, --finish                     mark story as finished
        -d, --deliver                    mark story as delivered
        -h, --help                       this usage guide

Additionally, `git story-merge` accepts any options valid for `git merge`.

### git story-pull-request

`git story-pull-request` opens the proper remote URL to issue a pull request for the current branch (OS&nbsp;X&ndash;only):

    $ git story-pull-request

By default, `git story-pull-request` issues a `git push-branch` as well (from [git-utils](https://github.com/mhartl/git-utils)), just in case the local branch hasn't yet been pushed up to the remote repository.

As with `git story-merge`, by default `git story-pull-request` exits with a warning if the most recent commit doesn't finish the story.

#### Options

    Usage: git story-pull-request [options]
        -o, --override                   override unfinished story warning
        -h, --help                       this usage guide

### git story-accept

`git story-accept` examines the repository log and changes every **Delivered** story to **Accepted**. This makes it possible to accept a pull request by merging into master and then mark all the associated stories **Accepted**  by running `git story-accept`. This saves having to manually keep track of the correspondences.

The purpose of `git story-accept` is to accept stories that have been merged into `master`, so by default it works only on the master branch. This requirement can be overridden by the `--override` option.

In order to avoid reading the entire Git log every time it's run, by default `git story-accept` stops immediately after finding a story that has already been accepted. The assumption is that `git story-accept` is run immediately after merging a pull request into a master branch that is always up-to-date, so that there are no delivered but unaccepted stories further down in the log.

`git story-accept` requires the existence of `.api_token` and `.project_id` files containing the Pivotal Tracker API token and project id, respectively. The user is prompted to create them if they are not present. (They aren't read from the command line using `gets` due to an incompatibility with options passing.)

#### Options

    Usage: git story-accept
        -o, --override                   override master branch requirement
        -a, --all                        process all stories (entire log)
        -h, --help                       this usage guide

### story-open

The `story-open` command (no `git`) opens the current story in the default browser (OS&nbsp;X&ndash;only):

    $ story-open


## Configuration

In order to use the `pivotal-github` gem, you need to configure a post-receive hook for your repository. At GitHub, navigate to `Settings > Service Hooks > Pivotal Tracker` and paste in your Pivotal Tracker API token. (To find your Pivotal Tracker API token, go to your user profile and scroll to the bottom.) Be sure to check the **Active** box to activate the post-receive hook. At Bitbucket, click on the gear icon to view the settings, click on `Services`, select `Pivotal Tracker`, and paste in your Pivotal Tracker API key. In addition, the `git story-accept` command requires the existence of `.api_token` and `.project_id` files containing the Pivotal Tracker API token and project id, respectively.

The `pivotal-github` command names follow the Git convention of being verbose (e.g., unlike Subversion, Git doesn't natively support `co` for `checkout`), but I recommend setting up aliases as necessary. Here are some suggestions, formatted so that they can be pasted directly into a terminal window:

    git config --global alias.sc story-commit
    git config --global alias.sm story-merge
    git config --global alias.spr story-pull-request
    git config --global alias.sa story-accept

I also recommend setting up an alias for `git push-branch` from [git-utils](https://github.com/mhartl/git-utils):

    git config --global alias.pb push-branch

A single-developer workflow would then look like this:

    $ git co -b add-markdown-support-62831853
    $ git pb
    <work>
    $ git sc -am "Added foo"
    $ git push
    <more work>
    $ git sc -am "Added bar"
    <complete story>
    $ git sc -f -am "Added baz"
    $ git push
    $ git sync
    $ git rebase master
    $ git sm
    $ git sa

Here `git sync` is from [git-utils](https://github.com/mhartl/git-utils).

## Workflow with integrated code reivew

The `pivotal-github` gem is designed to support a workflow involving integrated code review, which has the usual benefits: at least two pairs of eyes see any committed code, and at least two brains know basically what the committed code does. The cost is that having a second developer involved can slow you down. I suggest using your judgment to determine which workflow makes the most sense on a story-by-story basis.

Here's the process in detail:

### Developer #1 (Alice)

1. Start an issue at [Pivotal Tracker](http://pivotaltracker.com/) and copy the story id to your buffer
2. Create a branch in the local Git repository containing the story id and a brief description: `git checkout -b add-markdown-support-62831853`
3. Create a remote branch at [GitHub](http://github.com/) using `git push-branch`
3. Use `git story-commit` to make commits, which includes the story number in the commit message: `git story-commit -am "Add syntax highlighting"`
4. Continue pushing up after each commit using `git push` as usual
4. When done with the story, add `-f` to mark the story as **Finished** using `git story-commit -fam "Add paragraph breaks"` or as **Delivered** using `git story-commit -dam "Add paragraph breaks"`
4. Rebase against `master` using `git sync` followed by `git rebase master` or `git rebase master --interactive` (optionally squashing commit messages as described in the article [A Git Workflow for Agile Teams](http://reinh.com/blog/2009/03/02/a-git-workflow-for-agile-teams.html))
4. Push up with `git push`
6. At the GitHub page for the repo, select **Branches** and submit a pull request
6. (On OS X, replace the previous two steps with `git story-pull-request`)
6. Assign the pull request to Bob at GitHub
7. On the Pivotal Tracker story, add a comment with the pull request URL, and optionally change the **Owner** to Bob
8. Continue working, taking care to branch off of the current story branch if its changes are required to continue

Rather than immediately submitting a pull request, Alice can also continue by branching off the previous story branch, working on a set of related features, and then issue Bob a pull request for the final branch when she reaches a natural stopping place.


### Developer #2 (Bob)

1. Select **Pull Requests** at GitHub and review the pull request diffs
2. If acceptable, merge the pull request into master, run `git pull` on `master` to pull in the changes, and run `git story-accept` to mark the corresponding stories accepted
3. If not acceptable, manually change the state at Pivotal Tracker to **Rejected** and leave a note (at GitHub or at Pivotal Tracker) indicating the reason
4. If the branch can't be automatically merged, mark the story as **Rejected**

### Developer #1 (Alice)

1. After getting the GitHub notification that the pull request has been merged, mark the Pivotal Tracker story finished (unless assigned to Bob)
2. If the pull request was rejected, make the necessary changes and follow the previous steps above


## Merge conflicts

This section contains some suggestions for resolving merge conflicts. First, set up a visual merge tool by installing [diffmerge](http://www.sourcegear.com/diffmerge/). Then add the following to the `.gitconfig` file in your home directory:

    [mergetool "diffmerge"]
      cmd = diffmerge --merge --result=$MERGED $LOCAL $BASE $REMOTE
      trustExitCode = false

When the branch can't automatically be merged at GitHub, follow these steps:

### Devleloper #1 (Alice)

1. While on the story branch, run `git sync`
2. Rebase against `master` with `git rebase master` **or** merge with `master` using `git merge master`
4. Either handle resulting conflicts by hand or use the visual merge tool: `git mergetool`
5. Commit the change: `git commit -a`
6. Push up the modified branch: `git push`
7. **(experimental)** Add a Chore to revisit the pull request and assign to Developer #2 (Bob)


Now Bob should be able to merge in the pull request automatically using the nice big green button at GitHub.

## Contributing

1. Fork it
2. Run the tests with `rspec spec/`
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add failing tests, then add the feature
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
