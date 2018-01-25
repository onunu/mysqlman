require 'mysqlman/connection'
require 'logger'

module Mysqlman
  class Initializer
    def initialize
      @conn = Connection.new
      @logger = Logger.new(STDOUT)
    end

    def init!
      File.exists?(EXCLUDE_FILE) ? @logger.info('skip: creation excludes.d') : create_exclude_config
      Dir.exists?(ROLE_DIR) ? @logger.info('skip: creation roles.d') : create_roles_dir
      #create_users_dir unless Dir.exists?(USER_DIR)
    end

    private

    def create_exclude_config
      unless Dir.exists?(EXCLUDE_DIR)
        Dir.mkdir(EXCLUDE_DIR)
        @logger.info("create: #{EXCLUDE_DIR}")
      end
      File.open(EXCLUDE_FILE, 'w') { |file| file.puts(User.all.map(&:name_with_host).to_yaml) }
      @logger.info("create: #{EXCLUDE_FILE}")
    end

    #def roles_file_path
    #  File.join(CONFIG_DIR, 'roles.d', 'sample.yml')
    #end

    #def users_file_path
    #  File.join(CONFIG_DIR, 'users.d', 'sample.yml')
    #end
  end
end
