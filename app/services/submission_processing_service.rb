class SubmissionProcessingService
  def initialize(submission_zip_path:, output_dir:)
    @submission_zip_path = submission_zip_path
    @output_dir = output_dir
  end

  def perform
    extract(src_zip_file: submission_zip_path, dst_dir: extracted_dir)
    strip_comments(src_dir: extracted_dir, dst_dir: commentless_dir)
    original_path_map = flatten(src_dir: commentless_dir, dst_dir: flattened_dir)
    commit_to_output_dir(src_dir: flattened_dir, original_path_map: original_path_map)
    nil
  ensure
    delete_temp_dir
  end

  private

  attr_reader :submission_zip_path, :output_dir

  def extract(src_zip_file:, dst_dir:)
    CommandExecutor.instance.execute!(
      "unzip -o #{src_zip_file} \"*.js\" -d #{dst_dir} -x */node_modules/*"
    )
  end

  def strip_comments(src_dir:, dst_dir:)
    SubmissionCommentStrippingService.new(src_dir: src_dir, dst_dir: dst_dir).perform
  end

  def flatten(src_dir:, dst_dir:)
    SubmissionFlatteningService.new(src_dir: src_dir, dst_dir: dst_dir).perform
  end

  def commit_to_output_dir(src_dir:, original_path_map:)
    copy_folder_contents(src_dir: src_dir, dst_dir: output_dir)
    original_path_map_file = File.join(output_dir, 'original_path_map.json')
    File.write(original_path_map_file, original_path_map.to_json)
  end

  def extracted_dir
    @extracted_dir ||= begin
      dir = File.join(temp_dir, 'extracted')
      mkdir(dir)
      dir
    end
  end

  def flattened_dir
    @flattened_dir ||= begin
      dir = File.join(temp_dir, 'flattened')
      mkdir(dir)
      dir
    end
  end

  def commentless_dir
    @commentless_dir ||= begin
      dir = File.join(temp_dir, 'commentless')
      mkdir(dir)
      dir
    end
  end

  def temp_dir
    @temp_dir ||= Dir.mktmpdir('mossu_submission_processing_service_')
  end

  def delete_temp_dir
    CommandExecutor.instance.execute!(
      "rm -rf #{temp_dir}"
    )
  end

  def mkdir(dir)
    CommandExecutor.instance.execute!(
      "mkdir #{dir}"
    )
  end

  def copy_folder_contents(src_dir:, dst_dir:)
    CommandExecutor.instance.execute!(
      "cp -R #{File.join(src_dir, '*')} #{dst_dir}"
    )
  end
end
