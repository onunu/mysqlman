require 'logger'

module Mysqlman
  class Initializer
    def initialize
      @conn = Connection.instance
      @logger = Logger.new(STDOUT)
    end

    def init
      File.exist?(EXCLUDE_FILE) ? @logger.info('skip: creation excludes.d') : create_exclude_config
      Dir.exist?(ROLE_DIR) ? @logger.info('skip: creation roles.d') : create_roles_dir
      Dir.exist?(USER_DIR) ? @logger.info('skip: creation users.d') : create_users_dir
    end

    private

    def create_exclude_config
      unless Dir.exist?(EXCLUDE_DIR)
        Dir.mkdir(EXCLUDE_DIR)
        @logger.info("created: #{EXCLUDE_DIR}")
      end
      File.open(EXCLUDE_FILE, 'w') { |file| file.puts(User.all.map(&:name_with_host).to_yaml) }
      @logger.info("created: #{EXCLUDE_FILE}")
    end

    def create_roles_dir
      Dir.mkdir(ROLE_DIR)
      @logger.info("created: #{ROLE_DIR}")
    end

    def create_users_dir
      Dir.mkdir(USER_DIR)
      @logger.info("created: #{USER_DIR}")
    end
  end
end
