module Mysqlman
  class Processor
    def initialize
      @current_users = current_users
      @managed_users = managed_users
    end

    def apply(debug = false)
      delete_unknown_user(debug)
      create_shortage_user(debug)
      revoke_extra_privileges(debug)
      grant_shortage_privileges(debug)
    end

    private

    def current_users
      User.all.map do |user|
        exclude_users.include?(user: user.user, host: user.host) ? nil : user
      end.compact
    end

    def exclude_users
      @exclude_users ||= Dir.glob("#{EXCLUDE_DIR}/*.yml").map do |file|
        YAML.load_file(file).map do |u|
          { user: u['user'], host: u['host'] || '%' }
        end
      end.flatten
    end

    # rubocop:disable Metrics/MethodLength
    def managed_users
      Dir.glob("#{USER_DIR}/*.yml").map do |file|
        YAML.load_file(file).map do |role, users|
          users.map do |user|
            User.new(
              role: role,
              user: user.keys.first,
              host: user['host'] || HOST_ALL
            )
          end
        end
      end.flatten
    end
    # rubocop:enable Metrics/MethodLength

    def delete_unknown_user(_debug)
      @current_users.each do |cu|
        cu.drop unless @managed_users.any? do |mu|
          cu.user == mu.user && cu.host == mu.host
        end
      end
    end

    def create_shortage_user(_debug)
      @managed_users.each do |user|
        user.create unless user.exists?
      end
    end

    def revoke_extra_privileges(debug)
      @managed_users.each do |user|
        (user.privs.fetch - user.role.privs).each do |priv|
          user.privs.revoke(priv, debug)
        end
      end
    end

    def grant_shortage_privileges(debug)
      @managed_users.each do |user|
        (user.role.privs - user.privs.fetch).each do |priv|
          user.privs.grant(priv, debug)
        end
      end
    end
  end
end
