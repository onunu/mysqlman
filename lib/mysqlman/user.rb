require 'mysqlman/connection'

module Mysqlman
  class User
    HOST_ALL = '%'
    class << self
      def all
        conn = Connection.new
        conn.query('SELECT Host, User FROM mysql.user').map do |row|
          self.new(host: row['Host'], user: row['User'])
        end
      end

      def find(user, host = HOST_ALL)
        conn = Connection.new
        user = conn.query("SELECT Host, User FROM mysql.user WHERE Host = '#{host}' AND User = '#{user}'").first
        self.new(host: user['Host'], user: user['User']) if !user.nil?
      end
    end

    attr_reader :user, :host

    def initialize(user: , host: HOST_ALL)
      @host = host
      @user = user
    end

    def name_with_host
      { 'user' => @user, 'host' =>  @host }
    end

    def global_privileges
      Privilege::Global.new(user: self).all_privileges
    end

    def schema_privileges
      Privilege::Schema.new(user: self).all_privileges
    end
  end
end
