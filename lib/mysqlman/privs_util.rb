require 'mysqlman/connection'
require 'yaml'

module Mysqlman
  module PrivsUtil
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
end
