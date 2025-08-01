class Files
  def initialize(pwd, show_hidden)
    @dir = Dir.open pwd
    @show_hidden = show_hidden
    @files = @dir
               .entries
               .sort
               .map { |f|  File.new(File.join(@dir.path, f)) }
               .map { |f|
      { name: File.basename(f),
        executable: File.executable?(f),
        extname: File.extname(f),
        ftype: File.ftype(f),
        size: File.size(f),
        mtime: File.stat(f).mtime,
        mode: File.stat(f).mode,
        symlink: File.stat(f).symlink?
      }
    }
  end

  # puts Files.new('/home/jacek/', false).data.to_json
  def data
    { pwd: @dir.to_path,
      show_hidden: @show_hidden,
      files:
        if @show_hidden
          @files
        else
          @files.reject { |f|  f[:name].start_with?(".") }
        end
    }
  end
end
