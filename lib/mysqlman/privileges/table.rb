require 'mysqlman/connection'

module Mysqlman
  module Privileges
    class Table
      TABLE = 'information_schema.TABLE_PRIVILEGES'
      COLUMNS = {table: 'TABLE_NAME', schema: 'TABLE_SCHEMA', type: 'PRIVILEGE_TYPE', grant_option: 'IS_GRANTABLE'}

      def initialize(user:)
        @user = user
        @conn = Connection.new
        reload_privileges
      end

      def fetch
        reload_privileges
      end

      private

      def reload_privileges
        privileges = @conn.query("SELECT #{COLUMNS.values.join(',')} FROM #{TABLE} WHERE GRANTEE = '\\\'#{@user.user}\\\'@\\\'#{@user.host}\\\''")
        @privileges = privileges.to_a.map { |row| {table: row[COLUMNS[:table]], schema: row[COLUMNS[:schema]], type: row[COLUMNS[:type]], grant_option: row[COLUMNS[:grant_option]] == 'YES' ? true : false} }
      end
    end
  end
end
