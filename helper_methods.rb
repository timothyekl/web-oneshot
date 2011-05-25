module Helpers
  # Define loggers
  def log_verbose(s)
    if @options[:verbose] == true
      puts s
    end
  end

  # Define authentication helper(s)
  def accept_auth(user, pass)
    if @options[:user] == nil && @options[:pass] == nil
      return true
    elsif @options[:user] == user && @options[:pass] == nil
      return true
    elsif @options[:user] == nil && @options[:pass] == pass
      return true
    elsif @options[:user] == user && @options[:pass] == pass
      return true
    else
      return false
    end
  end
end
