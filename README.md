# Pivotal::Github

**NOTE:** This gem is as-yet unreleased. 

This gem facilitates the Pivotal Tracker–GitHub workflow used by Logical Reality Design.

## Installation & Configuration

Add this line to your application's Gemfile:

    gem 'pivotal-github'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pivotal-github

Next, configure a [post-receive hook for Pivotal Tracker at GitHub](https://www.pivotaltracker.com/help/api?version=v3#github_hooks). This will allow commit messages to be associated automatically with Pivotal Tracker tickets, and will also allow Git commits to update Pivotal Tracker ticket statuses.

## Process

Developer #1:

1. Start an issue in [Pivotal Tracker](http://pivotaltracker.com/)
2. Create a branch in the local Git repository containing the ticket number and a brief description: `git checkout -b 628318_add_markdown_support`
3. When making commits, include the ticket number in the commit message: `git commit -m "[#628318] Add syntax highlighting"`
4. When done with the ticket, add `Finishes` along with the ticket number in the commit message: `git commit -m "[Finishes #628318] Add paragraph breaks"`
5. Push the branch up to [GitHub](http://github.com/)
6. Issue a pull request
7. Add a ticket of type Chore to Pivotal Tracker and assign it to the person who should review the pull request [This step is experimental]

Until the pull request is accepted, you can continue working on new tickets, taking care to branch off of the current branch if you need its changes to continue.

Developer #2:

1. Review the pull request diffs
2. If acceptable, merge the branch
3. If not acceptable, manually change the state to Rejected
4. If there are conflicts, make a Chore ticket to resolve the conflicts and assign to Developer #1

Step #2 will automatically attach the commits as comments to the ticket at Pivotal Tracker and mark the ticket as finished.

## Merge conflicts

This section contains some suggestions for resolving merge conflicts. First, set up a visual merge tool by installing [diffmerge](http://www.sourcegear.com/diffmerge/). Then add the following to the `.gitconfig` file in your home directory:

    [mergetool "diffmerge"]
      cmd = diffmerge --merge --result=$MERGED $LOCAL $BASE $REMOTE
      trustExitCode = false

When the branch can't automatically be merged at GitHub, follow these steps:

Devleloper #1:

1. Pull the branch in (while on `master`): `git pull`
2. Check it out (this automatically creates a tracking branch): `git checkout -b 628318_add_markdown_support`
3. Merge with `master`: `git merge master`
4. Either handle the conflict by hand or use the visual merge tool: `git mergetool`
5. Commit the change: `git commit -a`
6. Push up the modified branch: `git push`
7. Add a Chore ticket to revisit the pull request and assign to Developer #2 [This step is experimental]

Now Developer #2 should be able to merge in the pull request using the nice big green button at GitHub.

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
