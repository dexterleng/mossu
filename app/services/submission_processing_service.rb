class SubmissionProcessingService
  def initialize(submission_zip_path:, output_dir:)
    @submission_zip_path = submission_zip_path
    @output_dir = output_dir
  end

  def perform
    extract(src_zip_file: submission_zip_path, dst_dir: extracted_dir)
    strip_comments(src_dir: extracted_dir, dst_dir: commentless_dir)
    original_path_map = flatten(src_dir: commentless_dir, dst_dir: output_dir)

    {
      submission_zip_path: submission_zip_path,
      output_dir: output_dir,
      original_path_map: original_path_map
    }
  ensure
    delete_temp_dir
  end

  private

  attr_reader :submission_zip_path, :output_dir

  def extract(src_zip_file:, dst_dir:)
    CommandExecutor.instance.execute!(
      "unzip -o #{src_zip_file} \"*.js\" -d #{dst_dir} -x \"*/node_modules/*\" -x \"node_modules/*\""
    )
  end

  def strip_comments(src_dir:, dst_dir:)
    SubmissionCommentStrippingService.new(src_dir: src_dir, dst_dir: dst_dir).perform
  end

  def flatten(src_dir:, dst_dir:)
    SubmissionFlatteningService.new(src_dir: src_dir, dst_dir: dst_dir).perform
  end

  def extracted_dir
    @extracted_dir ||= begin
      dir = File.join(temp_dir, 'extracted')
      FsUtils.mkdir(dir)
      dir
    end
  end

  def commentless_dir
    @commentless_dir ||= begin
      dir = File.join(temp_dir, 'commentless')
      FsUtils.mkdir(dir)
      dir
    end
  end

  def temp_dir
    @temp_dir ||= Dir.mktmpdir('mossu_submission_processing_service_')
  end

  def delete_temp_dir
    FsUtils.rm_rf(temp_dir)
  end
end
