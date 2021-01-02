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
    print_stdout(stdout)
    print_stderr(stderr) if exit_code.zero?

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

  def print_stdout(stdout)
    logger.info "[stdout] #{stdout}"
  end

  def print_stderr(stderr)
    logger.warn "[stderr] #{stderr}"
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end
end