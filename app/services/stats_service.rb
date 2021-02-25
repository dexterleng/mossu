class StatsService
  attr_reader :namespace, :host, :port

  # host: localhost doesn't work for some reason
  def initialize(namespace:, host: '127.0.0.1', port: '8125')
    @namespace = namespace
    @host = host
    @port = port
  end

  delegate :increment, :timing, :gauge, :time, to: :statsd

  def track(event)
    increment("#{event}.started")
    result = time("#{event}.timing_ms") { yield }
    increment("#{event}.completed")
    result
  rescue => e
    increment("#{event}.failed")
    raise e
  end

  private

  def statsd
    @statsd ||= begin
      instance = Statsd.new host, port
      instance.namespace = "mossu.#{Rails.env}.#{namespace}"
      instance
    end
  end
end
