require 'optparse'

module Options

  # Returns a list of options unknown to a particular options parser.
  # For example, if '-a' is a known option but '-b' and '-c' are not,
  # unknown_options(parser, ['-a', '-b', '-c']) returns ['-b', '-c'].
  # It also preserves arguments, so 
  # unknown_options(parser, ['-a', '-b', '-c', 'foo bar']) returns 
  # ['-b', '-c', 'foo bar'].
  def self.unknown_options(parser, initial_args)
    unknown = []                                     
    recursive_parse = Proc.new do |arg_list|                   
      begin
        parser.parse! arg_list                      
      rescue OptionParser::InvalidOption => e
        unknown.concat(e.args)
        while !arg_list.empty? && arg_list.first[0] != "-"
          unknown << arg_list.shift
        end
        recursive_parse.call(arg_list)
      end
    end
    recursive_parse.call(initial_args)
    unknown
  end

end