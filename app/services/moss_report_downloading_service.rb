class MossReportDownloadingService
  attr_reader :result_url, :dst_report

  def initialize(result_url:, dst_report:)
    @result_url = result_url
    @dst_report = dst_report
  end

  def perform
    cmd = "
      wget \
        -e robots=off \
        --no-parent \
        --convert-links \
        --page-requisites \
        -m #{result_url_with_backslash}
    "
    CommandExecutor.instance.execute!(cmd, chdir: temp_dir)
    zip_folder(src: temp_dir, dst: dst_report)
    nil
  ensure
    delete_temp_dir
  end

  private

  # wget does not download the index.html if the url does not end with a /
  # http://moss.stanford.edu/results/2/5921567138667 should be transformed into
  # http://moss.stanford.edu/results/2/5921567138667/
  def result_url_with_backslash
    @result_url_with_backslash ||= begin
      url = result_url
      url += '/' unless url.ends_with?('/')
      url
    end
  end

  def temp_dir
    @temp_dir ||= Dir.mktmpdir('mossu_report_downloading_service_')
  end

  def zip_folder(src:, dst:)
    absolute_dst = File.expand_path(dst)
    CommandExecutor.instance.execute!(
      "cd #{src} && zip -r #{absolute_dst} ."
    )
  end

  def delete_temp_dir
    CommandExecutor.instance.execute!(
      "rm -rf #{temp_dir}"
    )
  end
end
