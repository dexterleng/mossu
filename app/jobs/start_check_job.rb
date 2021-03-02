class StartCheckJob < ApplicationJob
  queue_as :default

  def perform(options)
    check_id = options[:check_id]
    language = options[:language]
    check_service = check_service(language)
    stats_service.track('check') do
      check = Check.find(check_id)
      begin
        check.transition_to_active
        check_service.new(check).perform
        check.transition_to_completed
      rescue StandardError => e
        check.transition_to_failed
        raise e
      end
    end
  end

  private

  def check_service(language)
    return JavaStartCheckService if language == 'java'
    return PythonStartCheckService if language == 'python'

    StartCheckService
  end

  def stats_service
    @stats_service ||= StatsService.new(namespace: 'sidekiq')
  end
end
