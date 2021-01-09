class StartCheckService
  attr_reader :check

  def initialize(check)
    @check = check
  end

  def perform
    base_submission_path = nil
    if check.base_submission.attached?
      deserialized_base_submission_zip = deserialize_base_submission_zip
      BaseSubmissionProcessingService.new(submission_zip_path: deserialized_base_submission_zip, output_dir: extracted_base_submission_dir).perform
      base_submission_path = extracted_base_submission_dir
    end

    processed_submission_results, = process_submissions
    process_submission_paths = processed_submission_results.map { |r| r[:output_dir] }

    result_url = upload_submissions(process_submission_paths, base_submission_path)
    download_report(result_url)
    zip_report
    attach_report

    unanonymize_policies = submissions_unanonymization_policies(processed_submission_results)
    unanonymize_report(src: report_path, dst: unanonymized_report_path, policies: unanonymize_policies)

    zip_unanonymized_report
    attach_unanonymized_report
    nil
  ensure
    delete_temp_dir
  end

  private

  def process_submissions
    successes = []
    failures = []

    submissions = check.submissions
    submissions.each do |submission|
      zip = deserialize_submission_zip(submission)
      successes << process_submission(zip, submission)
    rescue StandardError => e
      failures << { submission: submission, error: e }
    end

    [successes, failures]
  end

  def attach_report
    check
      .report
      .attach(
        io: File.open(report_zip),
        filename: 'report.zip',
        content_type: 'application/zip'
      )
  end

  def attach_unanonymized_report
    check
      .unanonymized_report
      .attach(
        io: File.open(unanonymized_report_zip),
        filename: 'unanonymized_report.zip',
        content_type: 'application/zip'
      )
  end

  def download_report(result_url)
    MossReportDownloadingService.new(result_url: result_url, dst_report: report_path).perform
  end

  def unanonymize_report(args)
    UnanonymizeReportService.new(args).perform
  end

  def submissions_unanonymization_policies(processed_submission_results)
    processed_submission_results.map { |r| submission_unanonymization_policies(r) }
                                .reduce(:merge)
  end

  def submission_unanonymization_policies(processed_submission_result)
    directory_from = processed_submission_result[:output_dir]
    # MOSS adds a backslash in the report to directories if missing
    directory_from += '/' unless directory_from.ends_with?('/')
    directory_to = File.basename(processed_submission_result[:submission_zip_path])
    directory_policy = {}
    directory_policy[directory_from] = directory_to

    file_policies = processed_submission_result[:original_path_map]

    directory_policy.merge(file_policies)
  end

  def zip_report
    zip_folder(src: report_path, dst: report_zip)
  end

  def report_path
    @report_path ||= begin
      dir = File.join(temp_dir, 'report')
      mkdir(dir)
      dir
    end
  end

  def report_zip
    File.join(temp_dir, 'report.zip')
  end

  def zip_unanonymized_report
    zip_folder(src: unanonymized_report_path, dst: unanonymized_report_zip)
  end

  def unanonymized_report_path
    @unanonymized_report_path ||= begin
      dir = File.join(temp_dir, 'unanonymized_report')
      mkdir(dir)
      dir
    end
  end

  def unanonymized_report_zip
    File.join(temp_dir, 'unanonymized_report.zip')
  end

  def upload_submissions(submission_paths, base_submission_path = nil)
    MossUploadingService.new(submissions: submission_paths, base_submission: base_submission_path).perform!
  end

  def process_submission(zip, submission)
    processed_submission_path = processed_submission(submission)
    mkdir(processed_submission_path)
    result = SubmissionProcessingService.new(submission_zip_path: zip, output_dir: processed_submission_path).perform

    file_count = Dir.glob(File.join(processed_submission_path, '**', '*')).select { |file| File.file?(file) }.count
    raise StandardError.new("Zero files found in processed_submission_path #{processed_submission_path}") if file_count.zero?

    result
  end

  def processed_submission(submission)
    File.join(processed_submissions_dir, submission.id.to_s)
  end

  def processed_submissions_dir
    @processed_submissions_dir ||= begin
      dir = File.join(temp_dir, 'processed_submissions')
      mkdir(dir)
      dir
    end
  end

  def deserialized_submission_zip(submission)
    File.join(extracted_submissions_dir, "#{submission.id}_#{submission.zip_file.filename}")
  end

  def extracted_submissions_dir
    @extracted_submissions_dir ||= begin
      dir = File.join(temp_dir, 'extracted_submissions')
      mkdir(dir)
      dir
    end
  end

  def deserialize_submission_zip(submission)
    path = deserialized_submission_zip(submission)
    File.open(path, 'wb') do |file|
      file.write(submission.zip_file.download)
    end
    path
  end

  def extracted_base_submission_dir
    @extracted_base_submission_dir ||= begin
      dir = File.join(temp_dir, 'base_submission')
      mkdir(dir)
      dir
    end
  end

  def deserialize_base_submission_zip
    deserialized_base_submission_zip = File.join(temp_dir, 'base_submission.zip')
    File.open(deserialized_base_submission_zip, 'wb') do |file|
      file.write(check.base_submission.download)
    end
    deserialized_base_submission_zip
  end

  def temp_dir
    @temp_dir ||= Dir.mktmpdir('mossu_start_check_service_')
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

  def zip_folder(src:, dst:)
    absolute_dst = File.expand_path(dst)
    CommandExecutor.instance.execute!(
      "cd #{src} && zip -r #{absolute_dst} ."
    )
  end
end
