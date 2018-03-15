require 'yaml'

module Mysqlman
  class Role
    class << self
      def all
        files = Dir.glob("#{ROLE_DIR}/*.yml")
        files.map do |file|
          new(YAML.load_file(file))
        end
      end

      def find(name)
        roles = all
        roles.select { |role| role.name == name }.first
      end
    end

    attr_reader :name, :config

    def initialize(config)
      @name = config.keys.first
      @config = config.values.first
    end

    def privs
      [
        global_privs,
        schema_privs,
        table_privs
      ].compact.flatten
    end

    def global_privs
      parse_privs(@config['global'])
    end

    def schema_privs
      @config['schema'].map do |schema_name, privs|
        parse_privs(privs, schema_name)
      end
    end

    def table_privs
      @config['table'].map do |schema_name, table_config|
        table_config.map do |table_name, privs|
          parse_privs(privs, schema_name, table_name)
        end
      end
    end

    def parse_privs(privs, schema = nil, table = nil)
      return Privs.all(schema, table, grantable?(privs)) if all_priv?(privs)
      privs.map(&:keys).flatten.map do |priv|
        {
          schema: schema,
          table: table,
          type: priv.upcase.tr('_', ' ')
        }
      end
    end

    def grantable?(privs)
      privs.map(&:keys).flatten.include?('grant_option')
    end

    def all_priv?(privs)
      privs.map(&:keys).flatten.include?('all')
    end
  end
end
