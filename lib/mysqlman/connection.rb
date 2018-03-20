require 'mysql2'
require 'yaml'
require 'singleton'
require 'logger'

module Mysqlman
  class Connection
    include Singleton

    attr_accessor :conn

    def initialize
      config = YAML.load_file(MANAGER_CONFIG).map { |k, v| [k.to_sym, v] }.to_h
      config.merge(database: 'mysql')
      @conn = Mysql2::Client.new(config)
    end

    def query(query_string)
      @conn.query(query_string)
    end
  end
end
