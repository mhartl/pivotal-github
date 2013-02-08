# pivotal-github

The `pivotal-github` gem facilitates a Pivotal Tracker–GitHub workflow inspired by [Logical Reality](http://lrdesign.com/). As per usual, there are several projects (notably [git-flow](https://github.com/nvie/gitflow) and [git-pivotal](https://github.com/trydionel/git-pivotal)) that implement similar solutions, but none met my exact needs.

## Installation

Add this line to your application's Gemfile:

    gem 'pivotal-github', '~> 0.5.0'

Then install the gem with Bundler:

    $ bundle install

You can also install it directly as follows:

    $ gem install pivotal-github

## Usage

The `pivotal-github` gem adds several additional Git commands to the local environment. There is only one non-trivial addition, `git story-commit`; the others are simple (tiny) bash scripts. (In fact, the current Ruby code looks over-engineered: there is a base `Command` class with only one derived class, `StoryCommit`. This is an artifact of history, as there used to be other commands, but I decided that the other cases were better served by plain bash scripts.) The `git story-commit` command automatically incorporates the Pivotal Tracker story id into the commit messages, while adding options to mark the story **Finished** or **Delivered**. 

The `git story-commit` command makes the assumption that the first string of digits in the branch name is the story id. This means that, when the story id is `6283185`, the branch names `6283185-add-markdown-support`, `6283185_add_markdown_support`, and `add-markdown-support-6283185` all work, but `add-42-things-6283185` doesn't.

The full set of commands is as follows:

### git story-commit

`git story-commit` makes a standard `git commit` with the story number added to the commit message. This automatically adds a link at Pivotal Tracker between the story and the diff when the branch gets pushed up to GitHub. 

For example, when on a branch called `6283185-add-markdown-support`, the `git story-commit` command automatically adds `[#6283185]` to the commit message:
	
    $ git story-commit -am "Add foo bars"
	[6283185-add-markdown-support 6f56414] [#6283185] Add foo bars

To mark a story as **Finished**, add the `-f` flag:

    $ git story-commit -f -am "Remove baz quuxes"
	[6283185-add-markdown-support 7g56429] [Finishes #6283185] Remove baz quuxes

#### Options

	$ git story-commit -h
	    Usage: git story-commit [options]
	        -m, --message MESSAGE            add a commit message (including story #)
	        -f, --finish                     mark story as finished
	        -d, --deliver                    mark story as delivered
	        -a, --all                        commit all changed files
	        -h, --help                       this usage guide

Additionally, `git story-commit` accepts any options valid for `git commit`. (`git story-commit` supports the `-a` flag even though that's a valid option to `git commit` so that the compound flag in `git story-commit -am "message"` works.)

### git story-push

`git story push` creates a remote branch at `origin` with the name of the current branch:

    $ git story-push
    * [new branch]      6283185-add-markdown-support -> 6283185-add-markdown-support

#### Options

	Usage: git story-push [options]
	    -t, --target TARGET              push to a given target (defaults to origin)
	    -h, --help                       this usage guide

Additionall, `git story-push` accepts any options valid for `git push`.

### git story-pull

`git story-pull` syncs the local `master` with the remote `master`. On a branch called `6283185-add-markdown-support`, `git story-pull` is equivalent to the following:

    $ git checkout master
    $ git pull
    $ git checkout 6283185-add-markdown-support

The purpose of `git story-pull` it to prepare the local story branch for rebasing against `master`:

    $ git story-pull
    $ git rebase master

(This is essentially equivalent to 

    $ git fetch
    $ git rebase origin/master

but I don't like having `master` and `origin/master` be different since that means you have to remember to run `git pull` on `master` some time down the line.)

#### Options

    Usage: git story-pull [options]
        -d, --development BRANCH         development branch (defaults to master)
        -h, --help                       this usage guide

Additionally, `git story-pull` accepts any options valid for `git pull`.
    
### git story-merge

`git story-merge` merges the current branch into `master`. On a branch called `6283185-add-markdown-support`, `git story-merge` is equivalent to the following: 

    $ git checkout master
    $ git merge --no-ff 6283185-add-markdown-support

Note that this effectively changes the default merge behavior from fast-forward to no-fast-forward, which makes it possible to see from `git log` which of the commit objects together have implemented a story. As noted in [A successful Git branching model](http://nvie.com/posts/a-successful-git-branching-model/),

> The `--no-ff` flag causes the merge to always create a new commit object, even if the merge could be performed with a fast-forward. This avoids losing information about the historical existence of a feature branch and groups together all commits that together added the feature… Yes, it will create a few more (empty) commit objects, but the gain is much bigger that that cost.

Because of the way options are chained, passing the option `--ff` to `git story-merge` will override the `--no-ff` flag and restore the fast-forward behavior.

#### Options

		Usage: git story-merge [options]
		    -d, --development BRANCH         development branch (defaults to master)
		    -h, --help                       this usage guide

Additionally, `git story-merge` accepts any options valid for `git merge`.

## Configuration

In order to use the `pivotal-github` gem, you need to configure a [post-receive hook for Pivotal Tracker at GitHub](https://www.pivotaltracker.com/help/api?version=v3#github_hooks) for your repository. (To find your Pivotal Tracker API token, go to your user profile and scroll to the bottom.) 

The `pivotal-github` command names follow the Git convention of being verbose (e.g., unlike Subversion, Git doesn't natively support `co` for `checkout`), but I recommend setting up aliases as necessary. Here are some suggestions:

    $ git config --global alias.sc story-commit
    $ git config --global alias.sp story-push    
    $ git config --global alias.sl story-pull
    $ git config --global alias.sm story-merge

A single-developer workflow would then look like this:

    $ git co -b 6283185-add-markdown-support
    $ git sp
    <work>
    $ git sc -am "Added foo"
    $ git push
    <more work>
    $ git sc -am "Added bar"
    <complete story>
    $ git sc -f -am "Added baz"
    $ git push
    $ git sl
    $ git rebase master
    $ git sm

Note that this workflow uses `git sp` (and subsequent invocations of `git push`) only to create a remote backup. The principal purpose of `git story-push` is to support the integrated code review workflow described below.
    
## Workflow with integrated code reivew

The `pivotal-github` gem is degined to support a workflow involving integrated code review, which has the usual benefits: at least two pairs of eyes see any committed code, and at least two brains know basically what the committed code does. The cost is that having a second developer involved can slow you down. I suggest using your judgment to determine which workflow makes the most sense on a story-by-story basis.

Here's the process in detail:

### Developer #1 (Alice)

1. Start an issue at [Pivotal Tracker](http://pivotaltracker.com/) and copy the story id to your buffer
2. Create a branch in the local Git repository containing the story id and a brief description: `git checkout -b 6283185-add-markdown-support`
3. Create a remote branch at [GitHub](http://github.com/) using `git story-push`
3. Use `git story-commit` to make commits, which includes the story number in the commit message: `git story-commit -am "Add syntax highlighting"`
4. Continue pushing up after each commit using `git push` as usual
4. When done with the story, add `-f` to mark the story as **Finished** using `git story-commit -f -am "Add paragraph breaks"` or as **Delivered** using `git story-commit -d -am "Add paragraph breaks"`
4. Rebase against `master` using `git story-pull` followed by `git rebase master` or `git rebase master --interactive` (optionally squashing commit messages as described in the article [A Git Workflow for Agile Teams](http://reinh.com/blog/2009/03/02/a-git-workflow-for-agile-teams.html))
4. Push up with `git push`
6. At the GitHub page for the repo, select **Branches** and submit a pull request
7. **(experimental)** Add a story of type Chore to Pivotal Tracker and assign it to Developer #2 (Bob)
8. Continue working, taking care to branch off of the current story branch if its changes are required to continue

### Developer #2 (Bob)

1. Select **Pull Requests** at GitHub and review the pull request diffs
2. If acceptable, merge the branch by clicking on the button at GitHub
3. If not acceptable, manually change the state at Pivotal Tracker to **Rejected** and leave a note (at GitHub or at Pivotal Tracker) indicating the reason
4. **(experimental)** If the branch can't be automatically merged, make a Chore to resolve any conflicts and assign it to Alice

Note that the commits will appear on the story as soon as Alice creates a remote branch (and as she pushes to it), but it won't be marked **Finished** or **Delivered** until Bob merges the pull request into `master`.

## Merge conflicts

This section contains some suggestions for resolving merge conflicts. First, set up a visual merge tool by installing [diffmerge](http://www.sourcegear.com/diffmerge/). Then add the following to the `.gitconfig` file in your home directory:

    [mergetool "diffmerge"]
      cmd = diffmerge --merge --result=$MERGED $LOCAL $BASE $REMOTE
      trustExitCode = false

When the branch can't automatically be merged at GitHub, follow these steps:

### Devleloper #1 (Alice)

1. While on the story branch, run `git story-pull`
2. Rebase against `master` with `git rebase master` **or** merge with `master` using `git merge master`
4. Either handle resulting conflicts by hand or use the visual merge tool: `git mergetool`
5. Commit the change: `git commit -a`
6. Push up the modified branch: `git push`
7. **(experimental)** Add a Chore to revisit the pull request and assign to Developer #2 (Bob) 


Now Bob should be able to merge in the pull request automatically using the nice big green button at GitHub.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
