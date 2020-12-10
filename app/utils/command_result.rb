class CommandResult
  attr_reader :command, :exit_code, :stdout, :stderr

  def initialize(command:, exit_code:, stdout:, stderr:)
    @command = command
    @exit_code = exit_code
    @stdout = stdout
    @stderr = stderr
  end
end
