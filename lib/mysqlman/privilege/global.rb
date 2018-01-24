require 'mysqlman/connection'

module Mysqlman
  module Privilege
    class Global

      TABLE = 'information_schema.USER_PRIVILEGES'

      def initialize(user:, host:)
        @user = user
        @host = host
      end

      def all_privileges
        conn = Connection.new
        privileges = conn.query("SELECT PRIVILEGE_TYPE FROM #{TABLE} WHERE GRANTEE = '\\\'#{@user}\\\'@\\\'#{@host}\\\''")
        privileges.to_a.map(&:values).flatten
      end
    end
  end
end
