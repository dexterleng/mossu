class CommandExecutor
  @instance = new

  private_class_method :new

  def self.instance
    @instance
  end

  def execute(cmd, options = {})
    print_cmd(cmd)
    stdout, stderr, status = Open3.capture3(cmd, options)
    exit_code = status.to_i

    logger.info stdout
    logger.info stderr

    CommandResult.new(
      command: cmd,
      exit_code: exit_code,
      stdout: stdout,
      stderr: stderr
    )
  end

  def execute!(cmd, options = {})
    cmd_result = execute(cmd, options)
    raise CommandError.new(cmd_result) unless cmd_result.exit_code.zero?
    cmd_result
  end

  private

  def print_cmd(cmd)
    logger.info "[command] #{cmd}"
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end
end