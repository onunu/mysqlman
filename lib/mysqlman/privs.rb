require 'mysqlman/connection'
require 'yaml'
require 'logger'

module Mysqlman
  class Privs
    class << self
      def all(schema, table, grantable)
        privs = all_privs(schema, table, lebel(schema, table))
        grantable ? privs.push(grant_option(schema, table)) : privs
      end

      private

      def all_privs(schema, table, key)
        load_privs(key).map do |priv|
          { schema: schema, table: table, type: priv }
        end
      end

      def lebel(schema, table)
        if schema && table
          'table'
        elsif schema
          'schema'
        else
          'global'
        end
      end

      def load_privs(key)
        YAML.load_file(File.join(__dir__, 'all_privileges.yml'))[key].keys
      end

      def grant_option(schema = nil, table = nil)
        { schema: schema, table: table, type: 'GRANT OPTION' }
      end
    end

    def initialize(user)
      @user = user
      @conn = Connection.new
      @logger = Logger.new(STDOUT)
    end

    def fetch
      reload_privs
    end

    private

    def reload_privs
      [global_privs, schema_privs, table_privs].compact.flatten
    end

    def global_privs
      privs = fetch_privs('information_schema.USER_PRIVILEGES', %w[PRIVILEGE_TYPE IS_GRANTABLE])
      format_privs(add_grantable(privs))
    end

    def schema_privs
      privs = fetch_privs('information_schema.SCHEMA_PRIVILEGES', %w[TABLE_SCHEMA PRIVILEGE_TYPE IS_GRANTABLE])
      format_privs(add_grantable(privs))
    end

    def table_privs
      privs = fetch_privs('information_schema.TABLE_PRIVILEGES', %w[TABLE_NAME TABLE_SCHEMA PRIVILEGE_TYPE IS_GRANTABLE])
      format_privs(add_grantable(privs))
    end

    def fetch_privs(table, columns)
      @conn.query(fetch_query(table, columns)).map do |row|
        {
          schema: row['TABLE_SCHEMA'],
          table: row['TABLE_NAME'],
          type: row['PRIVILEGE_TYPE'],
          grant: row['IS_GRANTABLE'] == 'YES'
        }
      end
    end

    def fetch_query(table, columns)
      <<-SQL
        SELECT #{columns.join(',')}
        FROM #{table}
        WHERE
          GRANTEE = '\\\'#{@user.user}\\\'@\\\'#{@user.host}\\\''
      SQL
    end

    def add_grantable(privs)
      privs.uniq { |priv| [priv[:schema], priv[:table]] }.each do |names|
        is_grant = grantable_collection?(privs, names)
        privs.push(schema: names[:schema], table: names[:table], type: 'GRANT OPTION') if is_grant
      end
      privs
    end

    def grantable_collection?(privs, names)
      collection = privs.select do |priv|
        priv[:schema] == names[:schema] && priv[:table] == names[:table]
      end
      collection.all? { |priv| priv[:grant] }
    end

    def format_privs(privs)
      privs.map do |priv|
        priv.delete(:grant)
        priv
      end
    end
  end
end
