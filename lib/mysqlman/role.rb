require 'yaml'

module Mysqlman
  class Role
    class << self
      def all
        files = Dir.glob("#{ROLE_DIR}/*.yml")
        files.map do |file|
          self.new(YAML.load_file(file))
        end
      end

      def find(name)
        roles = self.all
        roles.select { |role| role.name == name }.first
      end
    end

    attr_reader :name, :config

    def initialize(config)
      @name = config.keys.first
      @config = config.values.first
    end

    def global_privileges
      @config['global'].map do |config|
        {
          type: config.keys.first.upcase.gsub('_', ' '),
          grant_option: !!config.dig(:grant)
        }
      end
    end

    def schema_privileges
      @config['schema'].map do |config|
        config.map do |schema, privs|
          privs.map do |priv|
            {
              schema: schema,
              type: priv.keys.first,
              grant_option: !!priv.dig(:grant)
            }
          end
        end
      end.flatten
    end

    def table_privileges
      @config['table'].map do |schema_privs|
        schema_privs.map do |schema_name, table_privs|
          table_privs.map do |table_priv|
            table_priv.map do |table_name, privs|
              privs.map do |priv|
                {
                  schema: schema_name,
                  table: table_name,
                  type: priv.keys.first,
                  grant_option: !!priv.dig(:grant)
                }
              end
            end
          end
        end
      end.flatten
    end
  end
end
