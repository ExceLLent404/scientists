require 'sequel'
require_relative 'db_connection'

file = File.open("app/init_db.sql", "r")
query = file.read

DB.run(query)

file.close
