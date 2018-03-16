module Mysqlman
  module PrivsGrant
    def revoke(priv, debug = false)
      query = "REVOKE #{priv[:type]} ON #{target_lebel(priv)} FROM #{user_info}"
      @conn.query(query) unless debug
      @logger.info(query)
    end

    def grant(priv, debug = false)
      query = "GRANT #{priv[:type]} ON #{target_lebel(priv)} TO #{user_info}"
      @conn.query(query) unless debug
      @logger.info(query)
    end

    private

    def user_info
      "'#{@user.user}'@'#{@user.host}'"
    end

    def target_lebel(priv)
      "#{priv[:schema] || '*'}.#{priv[:table] || '*'}"
    end
  end
end
