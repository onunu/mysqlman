require 'mysqlman/connection'

module Mysqlman
  module Privilege
    class Global

      TABLE = 'information_schema.USER_PRIVILEGES'

      # @params user: User
      def initialize(user:)
        @user = user
      end

      def all_privileges
        conn = Connection.new
        privileges = conn.query("SELECT PRIVILEGE_TYPE FROM #{TABLE} WHERE GRANTEE = '\\\'#{@user.user}\\\'@\\\'#{@user.host}\\\''")
        privileges.to_a.map(&:values).flatten
      end
    end
  end
end
