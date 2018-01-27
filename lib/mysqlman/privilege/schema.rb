require 'mysqlman/connection'

module Mysqlman
  module Privilege
    class Schema
      TABLE = 'information_schema.SCHEMA_PRIVILEGES'
      COLUMNS = {schema: 'TABLE_SCHEMA', type: 'PRIVILEGE_TYPE', grant_option: 'IS_GRANTABLE'}

      def initialize(user:)
        @user = user
      end

      def all_privileges
        conn = Connection.new
        privileges = conn.query("SELECT #{COLUMNS.values.join(',')} FROM #{TABLE} WHERE GRANTEE = '\\\'#{@user.user}\\\'@\\\'#{@user.host}\\\''")
        privileges.to_a.map { |row| {schema: row[COLUMNS[:schema]], type: row[COLUMNS[:type]], grant_option: row[COLUMNS[:grant_option]] == 'YES' ? true : false} }
      end
    end
  end
end
