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
    end

    attr_reader :name, :config

    def initialize(config)
      @name = config.keys.first
      @config = config.values.first
    end

    def build_grants_statements(user:, host:)
      [
        build_global_grants_statements(user, host),
        build_schema_grants_statements(user, host),
        build_table_grants_statements(user, host)
      ]
    end

    private

    def build_global_grants_statements(user:, host:)
    end

    def build_schema_grants_statements(user:, host:)
    end

    def build_table_grants_statements(user:, host:)
    end
  end
end
