class SubmissionFlatteningService
  attr_reader :src_dir, :dst_dir

  def initialize(src_dir:, dst_dir:)
    @src_dir = src_dir
    @dst_dir = dst_dir
  end

  def perform
    original_path_map = {}

    src_files.each.with_index do |src_file, index|
      flattened_file_name = "#{index}.js"

      relative_path = FsUtils.relative_path(src_file, src_dir)
      dst_file = File.join(dst_dir, flattened_file_name)

      copy(src: src_file, dst: dst_file)
      original_path_map[flattened_file_name] = relative_path
    end

    original_path_map
  end

  private

  def src_files
    pattern = File.join(src_dir, '/**/*.js')
    Dir.glob(pattern).sort
  end

  def copy(src:, dst:)
    CommandExecutor.instance.execute!(
      "cp #{src} #{dst}"
    )
  end
end
