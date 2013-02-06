# pivotal-github

**NOTE:** This gem is as-yet unreleased. 

This gem facilitates the Pivotal Tracker–GitHub workflow used by Logical Reality Design.

## Installation & Configuration

Add this line to your application's Gemfile:

    gem 'pivotal-github'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pivotal-github

Next, configure a [post-receive hook for Pivotal Tracker at GitHub](https://www.pivotaltracker.com/help/api?version=v3#github_hooks) for your repository. This will allow commit messages to be associated automatically with Pivotal Tracker stories, and will also allow Git commits to update Pivotal Tracker story statuses.

## Process

### Developer #1:

1. Start an issue in [Pivotal Tracker](http://pivotaltracker.com/)
2. Create a branch in the local Git repository containing the story number and a brief description: `git checkout -b 6283185-add-markdown-support`
3. Create a remote branch at [GitHub](http://github.com/) using `git create-remote`
3. Use `git record` to make commits, which includes the story number in the commit message: `git record -am "Add syntax highlighting"`
4. Continue pushing up after each commit using `git push` as usual
4. When done with the story, add `-f` to mark the story as finished: `git record -f -am "Add paragraph breaks"` and push up with `git push`
6. At the GitHub page for the repo, select "Branches" and click on the pull request button
7. Add a story of type Chore to Pivotal Tracker and assign it to the person who should review the pull request [*This step is experimental*]

Until the pull request is accepted, you can continue working on new stories, taking care to branch off of the current branch if you need its changes to continue. Note that the commits will appear on the story as soon as you create a remote brach (and as you push to it), but it won't be marked 'finished' or 'delivered' until the pull request is merged as described below.

### Developer #2:

1. Review the pull request diffs
2. If acceptable, merge the branch
3. If not acceptable, manually change the state to Rejected
4. If there are conflicts, make a Chore to resolve the conflicts and assign to Developer #1

Step #2 will automatically mark the story as finished or delivered.

## Merge conflicts

This section contains some suggestions for resolving merge conflicts. First, set up a visual merge tool by installing [diffmerge](http://www.sourcegear.com/diffmerge/). Then add the following to the `.gitconfig` file in your home directory:

    [mergetool "diffmerge"]
      cmd = diffmerge --merge --result=$MERGED $LOCAL $BASE $REMOTE
      trustExitCode = false

When the branch can't automatically be merged at GitHub, follow these steps:

Devleloper #1:

1. Pull the branch in (while on `master`): `git pull`
2. Check it out (this automatically creates a tracking branch): `git checkout -b 6283185-add-markdown-support`
3. Merge with `master`: `git merge master`
4. Either handle the conflict by hand or use the visual merge tool: `git mergetool`
5. Commit the change: `git commit -a`
6. Push up the modified branch: `git push`
7. Add a Chore to revisit the pull request and assign to Developer #2 [*This step is experimental*]

Now Developer #2 should be able to merge in the pull request using the nice big green button at GitHub.

## Usage

When on a branch called `6283185-add-markdown-support`, the `git record` command automatically adds `[#6283185]` to the commits:
	
    $ git record -am "Add foo bars"
	[6283185-add-markdown-support 6f56414] [#6283185] Add foo bars

Similarly, `git create-remote` automatically creates a remote branch with the name of the current branch:

    $ git create-remote
    * [new branch]      6283185-add-markdown-support -> 6283185-add-markdown-support
    
Here's the full usage info:

	$ git record -h
	    Usage: git record [options]
	        -m, --message MESSAGE            add a commit message (including story #)
	        -f, --finish                     mark story as finished
	        -d, --deliver                    mark story as delivered
	        -a, --all                        commit all changed files
	        -h, --help                       this usage guide

Additionally, `git record` accepts any options valid for `git commit`.

	$ git create-remote -h
	Usage: git create-remote [options]
	    -t, --target TARGET              push to a given target (defaults to origin)
	    -h, --help                       this usage guide

Additionally, `git create-remote` accepts any options valid for `git push`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
