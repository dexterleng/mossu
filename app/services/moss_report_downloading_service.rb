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
    CommandExecutor.instance.execute!(cmd, chdir: dst_report)
    nil
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
end
