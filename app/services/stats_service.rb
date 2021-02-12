class StatsService
  attr_reader :namespace, :host, :port

  # host: localhost doesn't work for some reason
  def initialize(namespace:, host: '127.0.0.1', port: '8125')
    @namespace = namespace
    @host = host
    @port = port
  end

  delegate :increment, to: :statsd

  private

  def statsd
    @statsd ||= begin
      instance = Statsd.new host, port
      instance.namespace = "mossu.#{Rails.env}.#{namespace}"
      instance
    end
  end
end
