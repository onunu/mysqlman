require 'mysql2'
require 'yaml'

module Mysqlman
  class Connection
    CONFIG = YAML.load_file("#{Dir.pwd}/config/database.yml").map { |k, v| [k.to_sym, v] }.to_h.merge(database: 'mysql')

    attr_accessor :conn

    def initialize
      @conn = Mysql2::Client.new(CONFIG)
    end

    def query(query_string)
      @conn.query(query_string)
    end
  end
end
