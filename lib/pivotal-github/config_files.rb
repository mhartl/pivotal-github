module ConfigFiles

  # Returns the Pivotal Tracker API token.
  def api_token
    config_filename('.api_token', 'your Pivotal tracker API token')
  end

  # Returns the Pivotal Tracker project id.
  def project_id
    config_filename('.project_id', 'the Pivotal tracker project id')
  end

  # Facilitate the creation of config variables based on files.
  def config_filename(filename, description)
    if File.exist?(filename)
      add_to_gitignore(filename)
      varname = '@' + filename.sub('.', '')
      value = File.read(filename).strip
      instance_variable_set(varname, value)
    else
      puts "Please create a file called '#{filename}'"
      puts "containing #{description}."
      add_to_gitignore(filename)
      exit 1
    end
  end

  private

    # Adds a filename to the .gitignore file (if necessary).
    # This is put in as a security precaution, especially to keep the
    # Pivotal Tracker API key from leaking.
    def add_to_gitignore(filename)
      gitignore = '.gitignore'
      if File.exist?(gitignore)
        contents = File.read(gitignore)
        unless contents =~ /#{filename}/
          # Prepend a newline if the file doesn't end in a newline.
          line = contents == contents.chomp ? "\n#{filename}" : filename
          File.open(gitignore, 'a') { |f| f.puts(line) }
          puts "Added #{filename} to .gitignore"
        end
      end
    end
end