module FsUtils
  class << self
    def relative_path(absolute, base)
      Pathname.new(absolute)
            .relative_path_from(Pathname.new(base))
            .to_s
    end

    def rm_rf(dir)
      CommandExecutor.instance.execute!(
        "rm -rf #{dir}"
      )
    end

    def mkdir(dir)
      CommandExecutor.instance.execute!(
        "mkdir #{dir}"
      )
    end

    def mkdirp(dir)
      CommandExecutor.instance.execute!(
        "mkdir -p #{dir}"
      )
    end

    def zip_folder(src:, dst:)
      absolute_dst = File.expand_path(dst)
      CommandExecutor.instance.execute!(
        "cd #{src} && zip -r #{absolute_dst} ."
      )
    end

    def copy(src:, dst:)
      CommandExecutor.instance.execute!(
        "cp #{src} #{dst}"
      )
    end

    def copy_folder_contents(src_dir:, dst_dir:)
      CommandExecutor.instance.execute!(
        "cp -R #{File.join(src_dir, '*')} #{dst_dir}"
      )
    end
  end
end
