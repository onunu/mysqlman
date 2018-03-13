require 'thor'

module Mysqlman
  class CLI < Thor
    desc 'init', 'initialize settings'
    long_desc <<-LONGDESC
      Require: `config/manager.yml` : to connect MySQL.
      Create: `excludes.d/default.yml`, `roles.d/`,  `users.d/`
      When you want see how to write or roles some files, please confirm README on Github.
    LONGDESC
    def init
      Mysqlman::Initializer.new.init!
    end

    desc 'apply', 'apply settings'
    def apply
      Mysqlman::Runner.new.run!
    end
  end
end
