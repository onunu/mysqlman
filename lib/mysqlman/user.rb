require 'securerandom'
require 'logger'

module Mysqlman
  class User
    PASSWORD_LENGTH = 8
    class << self
      def all
        conn = Connection.instance
        conn.query('SELECT Host, User FROM mysql.user').map do |row|
          new(host: row['Host'], user: row['User'])
        end
      end

      def find(user, host = HOST_ALL)
        conn = Connection.instance
        user = conn.query("SELECT Host, User FROM mysql.user WHERE Host = '#{host}' AND User = '#{user}'").first
        new(host: user['Host'], user: user['User']) unless user.nil?
      end
    end

    attr_reader :user, :host, :role, :privs

    def initialize(user:, host: HOST_ALL, role: nil)
      @host = host
      @user = user
      @role = Role.find(role) unless role.nil?
      @privs = Privs.new(self)
      @conn = Connection.instance
    end

    def name_with_host
      { 'user' => @user, 'host' => @host }
    end

    def exists?
      user = @conn.query("SELECT Host, User FROM mysql.user WHERE Host = '#{@host}' AND User = '#{@user}'").first
      !user.nil?
    end

    def create(debug = false)
      password = debug ? '******' : SecureRandom.urlsafe_base64(PASSWORD_LENGTH)
      @conn.query("CREATE USER '#{@user}'@'#{@host}' IDENTIFIED BY '#{password}'") unless debug
      Logger.new(STDOUT).info("Create user: '#{@user}'@'#{@host}', password is '#{password}'")
      self
    end

    def drop(debug = false)
      @conn.query("DROP USER '#{@user}'@'#{@host}'") unless debug
      Logger.new(STDOUT).info("Delete user: '#{@user}'@'#{@host}'")
    end
  end
end
