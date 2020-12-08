class CommandError < RuntimeError
  def initialize(cmd_result)
    @cmd_result = cmd_result
  end

  def to_s
    "An error occurred while running a command. Command: '%s'; Exit Code: '%d'; Stdout: %s; Stderr: %s" %
      [cmd_result.command, cmd_result.exit_code, cmd_result.stdout, cmd_result.stderr]
  end

  private

  attr_reader :cmd_result
end
