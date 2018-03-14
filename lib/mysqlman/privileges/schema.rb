require 'mysqlman/connection'
require 'yaml'
require 'logger'

module Mysqlman
  module Privileges
    class Schema
      TABLE = 'information_schema.SCHEMA_PRIVILEGES'
      COLUMNS = {schema: 'TABLE_SCHEMA', type: 'PRIVILEGE_TYPE', grant_option: 'IS_GRANTABLE'}

      def self.all_privileges(schema_name, grant_option: false)
        privs = YAML.load_file(File.join(__dir__, 'all_privileges.yml'))['schema_privileges'].keys.map do |priv|
          { schema: schema_name, type: priv }
        end
        grant_option ? privs.push(schema: schema_name, type: 'GRANT OPTION') : privs
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
        query = "REVOKE #{priv[:type]} ON #{priv[:schema]}.* FROM '#{@user.user}'@'#{@user.host}'"
        @conn.query(query)
        @logger.info(query)
        reload_privileges
      end

      def grant(priv)
        query = "GRANT #{priv[:type]} ON #{priv[:schema]}.* TO '#{@user.user}'@'#{@user.host}'"
        @conn.query(query)
        @logger.info(query)
        reload_privileges
      end

      private

      def reload_privileges
        privs = @conn.query("SELECT #{COLUMNS.values.join(',')} FROM #{TABLE} WHERE GRANTEE = '\\\'#{@user.user}\\\'@\\\'#{@user.host}\\\''").to_a
        format(privs)
      end

      def format(privs)
        preformated_privs = privs.map do |row|
          {
            schema: row[COLUMNS[:schema]],
            type: row[COLUMNS[:type]],
            grant_option: row[COLUMNS[:grant_option]] == 'YES' ? true : false
          }
        end
        schemas = preformated_privs.map { |privs| privs[:schema] }.uniq
        schemas.each do |schema|
          is_grant = preformated_privs.select { |privs| privs[:schema] == schema }.map { |priv| priv[:grant_option] }.uniq.first
          preformated_privs.push(schema: schema, type: 'GRANT OPTION') if is_grant
        end
        preformated_privs.map do |priv|
          priv.delete(:grant_option)
          priv
        end
      end
    end
  end
end
