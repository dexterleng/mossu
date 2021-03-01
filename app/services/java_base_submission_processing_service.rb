class JavaBaseSubmissionProcessingService
  attr_reader :submission_zip_path, :output_dir

  def initialize(submission_zip_path:, output_dir:)
    @submission_zip_path = submission_zip_path
    @output_dir = output_dir
  end

  def perform
    extract(src_zip_file: submission_zip_path, dst_dir: output_dir)
  end

  private

  def extract(src_zip_file:, dst_dir:)
    CommandExecutor.instance.execute!(
      "unzip -o #{src_zip_file} \"*.java\" -d #{dst_dir} -x \"*/node_modules/*\" -x \"node_modules/*\""
    )
  end
end
