class TestStatsJob < ApplicationJob
  queue_as :default

  def perform
    stats_service = StatsService.new(namespace: 'test_stats_job')
    stats_service.increment('started')
  end
end
