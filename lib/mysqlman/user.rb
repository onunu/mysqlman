require 'mysqlman/connection'

module Mysqlman
  class User
    class << self
      def all
        conn = Connection.new
        conn.query('SELECT Host, User FROM mysql.user').map do |row|
          self.new(host: row['Host'], user: row['User'])
        end
      end
    end

    HOST_ALL = '%'

    attr_reader :user, :host

    def initialize(user: , host: HOST_ALL)
      @host = host
      @user = user
    end

    def global_privileges
      Privilege::Global.new(user: @user, host: @host).all_privileges
    end

    def schema_privileges(schema_name)
      Privilege::Schema.new(user: @user, host: @host, schema: schema_name).all_privileges
    end
  end
end
