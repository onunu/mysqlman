require 'mysqlman/connection'
require 'yaml'
require 'logger'

module Mysqlman
  module Privileges
    class Global
      TABLE = 'information_schema.USER_PRIVILEGES'
      COLUMNS = {type: 'PRIVILEGE_TYPE', grant_option: 'IS_GRANTABLE'}
      USAGE_PRIV = {type: 'USAGE'}

      def self.all_privileges(grant_option: false)
        privs = YAML.load_file(File.join(__dir__, 'all_privileges.yml'))['global_privileges'].keys.map do |priv|
          { type: priv }
        end
        grant_option ? privs.push(type: 'GRANT OPTION') : privs
      end

      def initialize(user:)
        @user = user
        @conn = Connection.new
        @logger = Logger.new(STDOUT)
        reload_privileges
      end

      def fetch
        reload_privileges
      end

      def revoke(priv)
        query = "REVOKE #{priv[:type]} ON *.* FROM '#{@user.user}'@'#{@user.host}'"
        @conn.query(query)
        @logger.info(query)
        reload_privileges
      end

      def grant(priv)
        query = "GRANT #{priv[:type]} ON *.* TO '#{@user.user}'@'#{@user.host}'"
        @conn.query(query)
        @logger.info(query)
        reload_privileges
      end

      private

      def reload_privileges
        privs = @conn.query("SELECT #{COLUMNS.values.join(',')} FROM #{TABLE} WHERE GRANTEE = '\\\'#{@user.user}\\\'@\\\'#{@user.host}\\\''").to_a
        is_grant = privs.all? { |priv| priv['IS_GRANTABLE'] == 'YES' }
        formated = privs.map { |priv| {type: priv[COLUMNS[:type]]} }
        is_grant ? formated.push(type: 'GRANT OPTION') : formated
      end
    end
  end
end
