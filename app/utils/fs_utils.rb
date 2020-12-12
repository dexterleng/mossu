module FsUtils
  class << self
    def relative_path(absolute, base)
      Pathname.new(absolute)
            .relative_path_from(Pathname.new(base))
            .to_s
    end
  end
end