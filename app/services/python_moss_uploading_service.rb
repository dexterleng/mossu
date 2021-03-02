class PythonMossUploadingService
  class ParseError < RuntimeError; end

  attr_reader :submissions, :base_submission

  def initialize(submissions:, base_submission:)
    @submissions = submissions
    @base_submission = base_submission
  end

  def perform!
    cmd_result = CommandExecutor.instance.execute!(command)
    parse_result_url!(cmd_result.stdout)
  end

  private

  def parse_result_url!(stdout)
    lines = stdout.split("\n")
    raise ParseError.new unless lines.count.positive?

    url = lines[-1]
    raise ParseError.new unless url.starts_with?('http://moss.stanford.edu/results/')

    url
  end

  def command
    cmd = "#{program} -m 10 -n 250 -l python"

    unless base_submission.nil?
      pattern = File.join(base_submission, '/**/*.py')
      base_files = Dir.glob(pattern).sort
      base_files.each do |base_file|
        cmd += " -b #{base_file}"
      end
    end

    cmd += ' -d'
    submissions.each do |submission|
      pattern = File.join(submission, '*.py')
      cmd += " #{pattern}"
    end

    cmd
  end

  def program
    Rails.root.join('bin/mossnet')
  end
end