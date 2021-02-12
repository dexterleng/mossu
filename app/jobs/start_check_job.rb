class StartCheckJob < ApplicationJob
  queue_as :default

  def perform(check_id)
    stats_service.track('check') do
      check = Check.find(check_id)
      begin
        check.transition_to_active
        StartCheckService.new(check).perform
        check.transition_to_completed
      rescue StandardError => e
        check.transition_to_failed
        raise e
      end
    end
  end

  private

  def stats_service
    @stats_service ||= StatsService.new(namespace: 'sidekiq')
  end
end
