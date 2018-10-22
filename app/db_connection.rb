require 'sequel'

DB = Sequel.connect(adapter: :postgres,
                    user: 'app',  password: 'p@ssw0rd',
                    host: 'localhost', port: 5432,
                    database: 'scientists')
