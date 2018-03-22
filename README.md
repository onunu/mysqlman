# Mysqlman
Mysqlman is a tool manage users for MySQL.
You can start management with writing some yaml files and executing some commands.
And mysqlman provide feature to manage privileges(global, schema, table, but column)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mysqlman'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install mysqlman
```

## Usage
### 1. Setup
Firstly, please create file for connecting MySQL.
Please set the file in executing dir `config/manager.yml`

```yml
---
host: 127.0.0.1
username: root
password: passw0rd
```

#### Caution
The manager needs some privileges.
The read privileges to manage other users are following.

|schema|table|columns|
|:-----|:----|:------|
|mysql | user|User, Host|
|information_schema|USER_PRIVILEGES|PRIVILEGE_TYPE, IS_GRANTABLE|
|information_schema|SCHEMA_PRIVILEGES|TABLE_SCHEMA, PRIVILEGE_TYPE, IS_GRANTABLE|
|information_schema|TABLE_PRIVILEGES|TABLE_SCHEMA, TABLE_NAME, PRIVILEGE_TYPE, IS_GRANTABLE|

And ofcourse, the manager needs privileges that you want to manage with grant option.

### 2. Initialize
Second, initialize the config.
In initializing, mysqlman do followings.

- Create each directories(roles.d, users.d, excludes.d)
- Create exclude users config

Execute:

```
$ mysqlman init
```

Exclude users (=Unmanaged users) are that users are already exist in MySQL.
Exclude users are written in `excludes.d/default.yml` by default.
If you want to add unmanaged user, or to manage user written in excludes config, please edit the file by yourself.

### 3. Write config
Write user, role settings.
please confirm how to write them.

#### 3-1 Role
Role is config of database privileges.
All users are belong to one of roles.

In `roles.d/engineer.yml` as example:

```yml
---
engineer: # require: as a role name
  global: # optional: global privileges
    - select
  schema: # optional: schema privileges
    example_schema1: # requrie: schema name
      - update
      - insert
    example_schema2:
      - update
  table: # optional: table privileges
    example_schema1: # require: schema name
      example_table: # require: table name
        - delete:
```

You can write privilege type in format of followings.

- OK:
  - CREATE USER
  - create user
  - CREATE_USER
  - create_user
- NG:
  - CREATEUSER
  - createuser

##### Special privileges
###### ALL
`ALL` type privileges alias of some some privileges of the target level.
Please confirm following.

(WIP)
[All privileges](https://github.com/onunu/mysqlman/blob/master/lib/mysqlman/all_privileges.yml)

###### GRANT OPTION
`GRANT OPTION` is not included in `ALL` privileges.
If you want add the privileges, please set bot of them.

#### 3-2 User
User is config of information to connect Mysql.
All users are belong one of roles.

In `users.d/engineers.yml`:

```yml
---
engineer: # require: the role name
  - onunu: # require: user name
  - application_user:
    host: 10.0.0.1 # optional: connectable host(default '%')
```

### 4. Apply settings
After writing settings, please apply them.

#### dry-run
You can confirm changes witout appling settings.

```
$ mysqlman dryrun
```

#### apply
If the changes are same as your plan, please execute apply command.

```
$ mysqlman apply
```

Changes are put in STDOUT.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/onunu/mysqlman.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
