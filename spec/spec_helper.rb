require 'bundler/setup'
require 'mysqlman'
require 'pry'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  unmanaged_users = []
  config.before do
    unmanaged_users = Mysqlman::User.all.map(&:name_with_host)
  end
  config.after do
    all_users = Mysqlman::User.all.map(&:name_with_host)
    created_users = (all_users - unmanaged_users).map do |user|
      Mysqlman::User.new(user: user['user'], host: user['host'])
    end
    created_users.map(&:drop)
  end
end
