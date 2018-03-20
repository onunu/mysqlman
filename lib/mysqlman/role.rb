require 'yaml'

module Mysqlman
  class Role
    class << self
      def all
        files = Dir.glob("#{ROLE_DIR}/*.yml")
        files.map do |file|
          YAML.load_file(file).map do |name, config|
            new(name, config)
          end
        end.flatten
      end

      def find(name)
        roles = all
        roles.select { |role| role.name == name }.first
      end
    end

    attr_reader :name

    def initialize(name, config)
      @name = name
      @config = config
    end

    def privs
      [global_privs, schema_privs, table_privs].compact.flatten
    end

    def global_privs
      return if @config['global'].nil?
      parse_privs(@config['global'])
    end

    def schema_privs
      return if @config['schema'].nil?
      @config['schema'].map do |schema_name, privs|
        parse_privs(privs, schema_name)
      end
    end

    def table_privs
      return if @config['table'].nil?
      @config['table'].map do |schema_name, table_config|
        table_config.map do |table_name, privs|
          parse_privs(privs, schema_name, table_name)
        end
      end
    end

    def parse_privs(privs, schema = nil, table = nil)
      return Privs.all(schema, table, grantable?(privs)) if all_priv?(privs)
      privs.map do |priv|
        {
          schema: schema,
          table: table,
          type: priv.upcase.tr('_', ' ')
        }
      end
    end

    def grantable?(privs)
      privs.map(&:upcase).any? do |priv|
        priv.tr('_', ' ') == 'GRANT OPTION'
      end
    end

    def all_priv?(privs)
      privs.map(&:upcase).include?('ALL')
    end
  end
end
