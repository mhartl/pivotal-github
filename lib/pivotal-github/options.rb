require 'optparse'

module Options

  def self.unknown_options(parser, initial_args=ARGV.dup)
    other_args = []                                     
    rec_parse = Proc.new do |arg_list|                   
      begin
          parser.parse! arg_list                      
      rescue OptionParser::InvalidOption => e
          other_args += e.args                        
          while arg_list[0] && arg_list[0][0,1] != "-"
              other_args << arg_list.shift            
          end
          rec_parse.call arg_list                     
      end
    end
    rec_parse.call initial_args                         
    other_args                                          
  end

end