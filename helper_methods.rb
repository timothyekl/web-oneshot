module Helpers
  # Define loggers
  def log_verbose(s)
    if @options[:verbose] == true
      puts s
    end
  end

  # Define authentication helper(s)
  def accept_auth(user, pass)
    [@options[:user], @options[:pass]] == [user, pass]
  end
end
