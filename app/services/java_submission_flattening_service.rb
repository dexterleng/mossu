class JavaSubmissionFlatteningService
  attr_reader :src_dir, :dst_dir

  def initialize(src_dir:, dst_dir:)
    @src_dir = src_dir
    @dst_dir = dst_dir
  end

  def perform
    original_path_map = {}

    src_files.each.with_index do |src_file, index|
      flattened_file_name = "#{index}.java"

      relative_path = FsUtils.relative_path(src_file, src_dir)
      dst_file = File.join(dst_dir, flattened_file_name)

      copy(src: src_file, dst: dst_file)
      original_path_map[flattened_file_name] = relative_path
    end

    original_path_map
  end

  private

  def src_files
    pattern = File.join(src_dir, '/**/*.java')
    Dir.glob(pattern).sort
  end

  def copy(src:, dst:)
    FsUtils.copy(src: src, dst: dst)
  end
end
