require 'mysqlman/connection'

module Mysqlman
  module Privileges
    class Global
      TABLE = 'information_schema.USER_PRIVILEGES'
      COLUMNS = {type: 'PRIVILEGE_TYPE', grant_option: 'IS_GRANTABLE'}
      USAGE_PRIV = {type: 'USAGE', grant_option: false}

      def initialize(user:)
        @user = user
        @conn = Connection.new
        reload_privileges
      end

      def fetch
        reload_privileges
      end

      def revoke(priv)
        @conn.query("REVOKE #{priv[:type]} ON *.* FROM '#{@user.user}'@'#{@user.host}'")
        reload_privileges
      end

      private

      def reload_privileges
        privileges = @conn.query("SELECT #{COLUMNS.values.join(',')} FROM #{TABLE} WHERE GRANTEE = '\\\'#{@user.user}\\\'@\\\'#{@user.host}\\\''")
        @privileges = privileges.to_a.map { |row| {type: row[COLUMNS[:type]], grant_option: row[COLUMNS[:grant_option]] == 'YES' ? true : false} }
      end
    end
  end
end
