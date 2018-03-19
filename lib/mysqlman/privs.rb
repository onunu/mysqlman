require 'logger'
require 'mysqlman/privs_util'
require 'mysqlman/privs_grant'

module Mysqlman
  class Privs
    extend PrivsUtil
    include PrivsGrant

    def initialize(user)
      @user = user
      @conn = Connection.instance
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
      privs = fetch_privs(
        'information_schema.USER_PRIVILEGES',
        %w[PRIVILEGE_TYPE IS_GRANTABLE]
      )
      format_privs(add_grantable(privs))
    end

    def schema_privs
      privs = fetch_privs(
        'information_schema.SCHEMA_PRIVILEGES',
        %w[TABLE_SCHEMA PRIVILEGE_TYPE IS_GRANTABLE]
      )
      format_privs(add_grantable(privs))
    end

    def table_privs
      privs = fetch_privs(
        'information_schema.TABLE_PRIVILEGES',
        %w[TABLE_NAME TABLE_SCHEMA PRIVILEGE_TYPE IS_GRANTABLE]
      )
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
        next unless is_grant
        privs.push(
          schema: names[:schema], table: names[:table], type: 'GRANT OPTION'
        )
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
      privs.reject { |p| p[:type] == 'USAGE' }.map do |priv|
        priv.delete(:grant)
        priv
      end
    end
  end
end
