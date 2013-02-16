# By devault, command runs only when story is finished
class FinishedCommand < Command

  def run!
    check_finishes unless run?
    system cmd
  end

  private

    # Checks to see if the most recent commit finishes the story
    # We look for 'Finishes' or 'Delivers' and issue a warning if neither is
    # in the most recent commit. (Also supports 'Finished' and 'Delivered'.)
    def check_finishes
      unless `git log -1` =~ /Finishe(s|d)|Deliver(s|ed)|Fixe(s|d)/i
        warning =  "Warning: Unfinished story\n"
        warning += "Run `git commit --amend` to add 'Finishes' or 'Delivers' "
        warning += "to the commit message\n"
        warning += "Use --run to override"
        $stderr.puts warning
        exit 1
      end
    end

    def run?
      options.run
    end
end