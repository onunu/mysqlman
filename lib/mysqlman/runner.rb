module Mysqlman
  class Runner
    def initialize
      @current_users = current_users
      @managed_users = managed_users
    end

    def run
      delete_unknown_user
      create_shortage_user
      revoke_extra_privileges
    end

    private

    def current_users
      User.all.map { |u| exclude_users.include?({user: u.user, host: u.host}) ? nil : u }.compact
    end

    def exclude_users
      @exclude_users ||= Dir.glob("#{EXCLUDE_DIR}/*.yml").map do |file|
        YAML.load_file(file).map do |u|
          { user: u['user'], host: u['host'] || '%'}
        end
      end.flatten
    end

    def managed_users
      Dir.glob("#{USER_DIR}/*.yml").map do |file|
        difinitions = YAML.load_file(file)
        difinitions.map do |role, users|
          users.map do |user|
            User.new({ role: role, user: user.keys.first, host: user['host'] || HOST_ALL })
          end
        end
      end.flatten
    end

    def delete_unknown_user
      @current_users.each do |cu|
        cu.drop unless @managed_users.any? { |mu| cu.user == mu.user && cu.host == mu.host }
      end
    end

    def create_shortage_user
      @managed_users.each do |user|
        user.create unless user.exists?
      end
    end

    def revoke_extra_privileges
      @managed_users.each do |user|
        revoke_global_extra_privileges(user)
        revoke_schema_extra_privileges(user)
        revoke_table_extra_privileges(user)
      end
    end

    def revoke_global_extra_privileges(user)
      current = user.global_privileges.fetch
      current.delete(Privileges::Global::USAGE_PRIV)
      (current - user.role.global_privileges).each do |priv|
        user.global_privileges.revoke(priv)
      end
    end

    def revoke_schema_extra_privileges(user)
      current = user.schema_privileges.fetch
      (current - user.role.schema_privileges).each do |priv|
        user.schema_privileges.revoke(priv)
      end
    end

    def revoke_table_extra_privileges(user)
      current = user.table_privileges.fetch
      (current - user.role.table_privileges).each do |priv|
        user.table_privileges.revoke(priv)
      end
    end
  end
end
