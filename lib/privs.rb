require 'mysqlman/connection'
require 'yaml'
require 'logger'

module Mysqlman
  class Privs
    class << self
      def all(schema, table, grant_option)
        return table_all_privs(schema, table, grant_option) if schema && table
        return schema_all_privs(schema, grant_option) if schema
        global_all_privs(grant_option)
      end

      private

      def table_all_privs(schema, table, grant_option)
        binding.pry
      end

      def schema_all_privs(schema, grant_option)
        binding.pry
      end

      def global_all_privs(grant_option)
        binding.pry
      end

      def grant_option(schema = nil, table = nil)
        { schema: schema, table: table, type: 'GRANT_OPTION' }
      end
    end
  end
end
