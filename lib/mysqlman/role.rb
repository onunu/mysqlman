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
      return [] if @config['global'].nil?
      is_grant = @config['global'].map(&:keys).flatten.include?('grant')
      return Privileges::Global.all_privileges(grant_option: is_grant) if @config['global'].map(&:keys).flatten.include?('all')
      @config['global'].map(&:keys).flatten.map { |priv| { type: priv.upcase.gsub('_', ' ') } }
    end

    def schema_privileges
      return [] if @config['schema'].nil?
      @config['schema'].map do |schemas|
        schemas.map do |schema_name, privs|
          is_grant = privs.map(&:keys).flatten.include?('grant')
          next Privileges::Schema.all_privileges(schema_name, grant_option: is_grant) if privs.map(&:keys).flatten.include?('all')
          privs.map(&:keys).flatten.map do |priv|
            {
              schema: schema_name,
              type: priv.upcase.gsub('_', ' ')
            }
          end
        end
      end.flatten
    end

    def table_privileges
      return [] if @config['table'].nil?
      @config['table'].map do |schemas|
        schemas.map do |schema_name, tables|
          tables.map do |table|
            table.map do |table_name, privs|
              is_grant = privs.map(&:keys).flatten.include?('grant')
              next Privileges::Table.all_privileges(schema_name, table_name, grant_option: is_grant) if privs.map(&:keys).flatten.include?('all')
              privs.map(&:keys).flatten.map do |priv|
                {
                  schema: schema_name,
                  table: table_name,
                  type: priv.upcase.gsub('_', ' ')
                }
              end
            end
          end
        end
      end.flatten
    end
  end
end
