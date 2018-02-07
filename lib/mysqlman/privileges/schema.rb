require 'mysqlman/connection'
require 'yaml'

module Mysqlman
  module Privileges
    class Schema
      TABLE = 'information_schema.SCHEMA_PRIVILEGES'
      COLUMNS = {schema: 'TABLE_SCHEMA', type: 'PRIVILEGE_TYPE', grant_option: 'IS_GRANTABLE'}

      def self.all_privileges(schema_name, grant_option: false)
        YAML.load_file(File.join(__dir__, 'all_privileges.yml'))['schema_privileges'].keys.map do |priv|
          {
            schema: schema_name,
            type: priv,
            grant_option: grant_option
          }
        end
      end

      def initialize(user:)
        @user = user
        @conn = Connection.new
        reload_privileges
      end

      def fetch
        reload_privileges
      end

      def revoke(priv)
        @conn.query("REVOKE #{priv[:type]} ON #{priv[:schema]}.* FROM '#{@user.user}'@'#{@user.host}'")
        reload_privileges
      end

      private

      def reload_privileges
        privileges = @conn.query("SELECT #{COLUMNS.values.join(',')} FROM #{TABLE} WHERE GRANTEE = '\\\'#{@user.user}\\\'@\\\'#{@user.host}\\\''")
        @privileges = privileges.to_a.map { |row| {schema: row[COLUMNS[:schema]], type: row[COLUMNS[:type]], grant_option: row[COLUMNS[:grant_option]] == 'YES' ? true : false} }
      end
    end
  end
end
