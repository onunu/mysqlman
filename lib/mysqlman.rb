require "mysqlman/version"
require 'mysqlman/user'
require 'mysqlman/role'
require 'mysqlman/initializer'
require 'mysqlman/privilege/global'
require 'mysqlman/privilege/schema'
require 'mysqlman/privilege/table'
require 'mysqlman/runner'

module Mysqlman
  EXE_DIR = Dir.pwd
  EXCLUDE_DIR = File.join(EXE_DIR, 'excludes.d')
  EXCLUDE_FILE = File.join(EXCLUDE_DIR, 'default.yml')

  ROLE_DIR = File.join(EXE_DIR, 'roles.d')
  USER_DIR = File.join(EXE_DIR, 'users.d')

  MANAGER_CONFIG = File.join(EXE_DIR, 'config', 'manager.yml')

  HOST_ALL = '%'
end
