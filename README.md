# pivotal-github

**NOTE:** This gem is as-yet unreleased. 

This gem facilitates a Pivotal Tracker–GitHub workflow inspired by [Logical Reality](http://lrdesign.com/).

## Installation

Add this line to your application's Gemfile:

    gem 'pivotal-github'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pivotal-github


## Usage

The `pivotal-github` gem adds several additional Git commands to the local environment.

### git story-commit

`git story-commit` makes a standard `git commit` with the story number added to the commit message. This automatically adds a link at Pivotal Tracker between the story and the diff at GitHub. 

For example, when on a branch called `6283185-add-markdown-support`, the `git story-commit` command automatically adds `[#6283185]` to the commit message:
	
    $ git story-commit -am "Add foo bars"
	[6283185-add-markdown-support 6f56414] [#6283185] Add foo bars


Here's the full usage info:

	$ git story-commit -h
	    Usage: git story-commit [options]
	        -m, --message MESSAGE            add a commit message (including story #)
	        -f, --finish                     mark story as finished
	        -d, --deliver                    mark story as delivered
	        -a, --all                        commit all changed files
	        -h, --help                       this usage guide

Additionally, `git story-commit` accepts any options valid for `git commit`.

### git story-push

`git story push` creates a remote branch at `origin` with the name of the current branch:

    $ git story-push
    * [new branch]      6283185-add-markdown-support -> 6283185-add-markdown-support
    
                     this usage guide

`git story-push` accepts any options valid for `git push`.

### git story-pull

`git story-pull` syncs the local `master` with the remote `master`. On a branch called `6283185-add-markdown-support`, `git story-pull` is equivalent to the following:

    $ git checkout master
    $ git pull
    $ git checkout 6283185-add-markdown-support

The purpose of `git story-pull` it to prepare the local story branch for rebasing against `master`:

    $ git story-pull
    $ git rebase master

This is essentially equivalent to 

    $ git fetch
    $ git rebase origin/master

but I don't like having `master` and `origin/master` be different since it forces you to remember to run `git pull` on `master` some time down the line. 
    
### git story-merge

`git story-merge` merges the current branch into `master`. On a branch called `6283185-add-markdown-support`, `git story-merge` is equivalent to the following: 

    $ git checkout master
    $ git merge 6283185-add-markdown-support

## Configuration

In order to use the `pivotal-github` gem, you need to configure a [post-receive hook for Pivotal Tracker at GitHub](https://www.pivotaltracker.com/help/api?version=v3#github_hooks) for your repository. (To find your Pivotal Tracker API token, go to your user profile and scroll to the bottom.) 

The `pivotal-github` command names follow the Git convention of being verbose (it's telling that, unlike Subversion, Git doesn't natively support `co` for `checkout`), but I recommend setting up aliases as necessary. Here are some suggestions:

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

Note that this workflow uses `git sp` (and subsequent invocations of `git push`) only to create a remote storage backup. The principal purpose of `git story-push` is to support the integrated code review workflow described below.
    
## Workflow

The `pivotal-github` gem is degined to support a workflow that involves integrated code review, which has the usual advantages: at least two pairs of eyes see any committed code, and at least two brains know basically what the committed code does. Here's the process in detail:

### Developer #1 (Alice)

1. Start an issue at [Pivotal Tracker](http://pivotaltracker.com/)
2. Create a branch in the local Git repository containing the story number and a brief description: `git checkout -b 6283185-add-markdown-support`
3. Create a remote branch at [GitHub](http://github.com/) using `git story-push`
3. Use `git story-commit` to make commits, which includes the story number in the commit message: `git story-commit -am "Add syntax highlighting"`
4. Continue pushing up after each commit using `git push` as usual
4. When done with the story, add `-f` to mark the story as finished: `git story-commit -f -am "Add paragraph breaks"` 
4. Rebase against `master` using `git story-pull` followed by `git rebase master` or `git rebase master --interactive` (optionally squashing commit messages as described in the article [A Git Workflow for Agile Teams](http://reinh.com/blog/2009/03/02/a-git-workflow-for-agile-teams.html))
4. Push up with `git push`
6. At the GitHub page for the repo, select "Branches" and submit a pull request
7. **(experimental)** Add a story of type Chore to Pivotal Tracker and assign it to Developer #2 (Bob)


### Developer #2 (Bob)

1. Review the pull request diffs
2. If acceptable, merge the branch
3. If not acceptable, manually change the state at Pivotal Tracker to Rejected
4. **(experimental)** If there are conflicts, make a Chore to resolve the conflicts and assign it to Alice

Until Bob accepts the pull request, Alice can continue working on new stories, taking care to branch off of the current branch if she needs its changes to continue. Note that the commits will appear on the story as soon as Alice creates a remote branch (and as she pushes to it), but it won't be marked 'finished' or 'delivered' until Bob merges the pull request into `master`.

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
