class Files
  def initialize(pwd, show_hidden)
    @dir = Dir.open pwd
    @show_hidden = show_hidden
    @files = @dir.entries.sort
  end

  # puts Files.new('/home/jacek/', false).data.to_json
  def data
    { pwd: @dir.to_path,
      show_hidden: @show_hidden,
      files:
        if @show_hidden
          @files
        else
          @files.reject { |f| f.start_with?(".") }
        end
    }
  end
end
