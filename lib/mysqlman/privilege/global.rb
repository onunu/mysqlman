require 'mysqlman/connection'

module Mysqlman
  module Privilege
    class Global

      TABLE = 'information_schema.USER_PRIVILEGES'

      def initialize(user:)
        @user = user
      end

      def all_privileges
        conn = Connection.new
        privileges = conn.query("SELECT PRIVILEGE_TYPE, IS_GRANTABLE FROM #{TABLE} WHERE GRANTEE = '\\\'#{@user.user}\\\'@\\\'#{@user.host}\\\''")
        privileges.to_a.map { |row| {type: row['PRIVILEGE_TYPE'], grant_option: row['IS_GRANTABLE'] == 'YES' ? true : false} }
      end
    end
  end
end
