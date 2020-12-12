class SubmissionCommentStrippingService
  attr_reader :src_dir, :dst_dir

  def initialize(src_dir:, dst_dir:)
    @src_dir = src_dir
    @dst_dir = dst_dir
  end

  def perform
    successes = []
    failures = []

    src_files.each do |src_file|
      relative_path = FsUtils.relative_path(src_file, src_dir)
      dst_file = File.join(dst_dir, relative_path)

      arg = { src: src_file, dst: dst_file }

      begin
        strip_comments(arg)
        successes << arg
      rescue CommandError => e
        failures << { arg: arg, error: e }
      end
    end

    [successes, failures]
  end

  private

  def src_files
    pattern = File.join(src_dir, '/**/*.js')
    Dir.glob(pattern).sort
  end

  def strip_comments(src:, dst:)
    CommandExecutor.instance.execute!(
      "node #{program} #{src} #{dst}"
    )
  end

  def program
    Rails.root.join('bin/comment_stripper/index.js')
  end
end
