require "bundler/setup"
require "pytty"
require "pytty/client/cli"
require "pytty/daemon/cli"

require "kommando"
RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def runner(*args)
  args_string = args.join " "
  k = Kommando.run "bundle exec #{args_string}"
  k
end

def pyttyd(*args)
  runner (["pyttyd"] + args)
end

def pytty(*args)
  runner (["pytty"] + args)
end