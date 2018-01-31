require 'mysqlman/connection'
require 'securerandom'
require 'logger'

module Mysqlman
  class User
    PASSWORD_LENGTH = 8
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

    attr_reader :user, :host, :role

    def initialize(user: , host: HOST_ALL, role: nil)
      @host = host
      @user = user
      @role = Role.find(role) if role != nil
    end

    def name_with_host
      { 'user' => @user, 'host' => @host }
    end

    def global_privileges
      Privilege::Global.new(user: self).all_privileges
    end

    def schema_privileges
      Privilege::Schema.new(user: self).all_privileges
    end

    def table_privileges
      Privilege::Table.new(user: self).all_privileges
    end

    def exists?
      conn = Connection.new
      user = conn.query("SELECT Host, User FROM mysql.user WHERE Host = '#{@host}' AND User = '#{@user}'").first
      !user.nil?
    end

    def create
      conn = Connection.new
      password = SecureRandom.urlsafe_base64(PASSWORD_LENGTH)
      conn.query("CREATE USER '#{@user}'@'#{@host}' IDENTIFIED BY '#{password}'")
      Logger.new(STDOUT).info("Created user: '#{@user}'@'#{@host}', password is '#{password}'")
      self
    end

    def drop
      conn = Connection.new
      conn.query("DROP USER '#{@user}'@'#{@host}'")
    end
  end
end
