require 'sequel'
require_relative 'db_connection'


# Database schema:
#  scientists 
#   :id           <----\ 
#   :name               \
#   :madness             \        copyrights
#   :tries                \---- :scientist_id
#   :timestamp            /---- :device_id
#                        /
#  devices              /
#   :id           <----/
#   :name
#   :power
#   :timestamp

class Scientist < Sequel::Model
  many_to_many :devices, join_table: :copyrights
end

class Device < Sequel::Model
  many_to_many :scientists, join_table: :copyrights
end
