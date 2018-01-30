module Mysqlman
  class Runner
    def initialize
      @current_users = current_users
      @managed_users = managed_users
    end

    def run
      delete_unknown_user
    end

    private

    def current_users
      User.all.map { |u| exclude_users.include?({user: u.user, host: u.host}) ? nil : u }.compact
    end

    def exclude_users
      @exclude_users ||= Dir.glob("#{EXCLUDE_DIR}/*.yml").map do |file|
        YAML.load_file(file).map do |u|
          { user: u['user'], host: u['host'] || '%'}
        end
      end.flatten
    end

    def managed_users
      Dir.glob("#{USER_DIR}/*.yml").map do |file|
        difinitions = YAML.load_file(file)
        difinitions.map do |role, users|
          users.map do |user|
            { role: role, user: user.keys.first, host: user['host'] || HOST_ALL }
          end
        end
      end.flatten
    end

    def delete_unknown_user
      managed_users = @managed_users.map do |u|
        { user: u[:user], host: u[:host] }
      end
      @current_users.each do |u|
        binding.pry
        u.drop unless managed_users.include?({ user: u.user, host: u.host })
      end
    end
  end
end
