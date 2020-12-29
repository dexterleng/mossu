class StartCheckService
  attr_reader :check

  def initialize(check)
    @check = check
  end

  def perform
    processed_submission_paths, = process_submissions
    result_url = upload_submissions(processed_submission_paths)
    download_report(result_url)
    attach_report

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
      path = process_submission(zip, submission)
      successes << path
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

  def download_report(result_url)
    MossReportDownloadingService.new(result_url: result_url, dst_report: report_zip).perform
  end

  def report_zip
    File.join(temp_dir, 'report.zip')
  end

  def upload_submissions(submission_paths)
    MossUploadingService.new(submissions: submission_paths).perform!
  end

  def process_submission(zip, submission)
    processed_submission_path = processed_submission(submission)
    mkdir(processed_submission_path)
    SubmissionProcessingService.new(submission_zip_path: zip, output_dir: processed_submission_path).perform
    processed_submission_path
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
    File.join(extracted_submissions_dir, "#{submission.id}.zip")
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
end