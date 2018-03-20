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

    $ bundle

Or install it yourself as:

    $ gem install mysqlman

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
The manager needs some privileges. Read privileges to manage other users are following.

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

- Create each directory(roles.d, users.d, excludes.d)
- Create exclude users config

Execute:

    $ mysqlman init

Exclude users (=Unmanaged users) are that users are already exist in MySQL.
Exclide users are written in `excludes.d/default.yml` by default.
If you want to add unmanaged user, or to manage user written in excludes config, please edit the file by yourself.

### 3. Write config


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/onunu/mysqlman.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
