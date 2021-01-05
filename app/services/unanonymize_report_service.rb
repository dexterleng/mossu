class UnanonymizeReportService
  attr_reader :src, :dst, :policies

  def initialize(src:, dst:, policies:)
    @src = src
    @dst = dst
    @policies = policies
  end

  def perform
    src_files = Dir.glob(File.join(src, '/**/*'))
      .reject { |f| File.directory?(f) }
      .sort
    src_files.each do |src_file|
      src_text = File.read(src_file)
      dst_text = src_text
      dst_text = unanonymize_text(src_text, policies) if src_file.ends_with?('.html')

      relative_path = FsUtils.relative_path(src_file, src)
      dst_file = File.join(dst, relative_path)
      dst_file_enclosing_folder = File.expand_path(File.join(dst_file, '..'))
      mkdirp(dst_file_enclosing_folder)
      File.write(dst_file, dst_text)
    end
  end

  private

  def unanonymize_text(src, policies)
    re = Regexp.new(policies.keys.map { |x| Regexp.escape(x) }.join('|'))
    src.gsub(re, policies)
  end

  def mkdirp(dir)
    CommandExecutor.instance.execute!(
      "mkdir -p #{dir}"
    )
  end
end
