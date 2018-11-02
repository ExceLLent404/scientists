require 'sequel'
require_relative 'db_connection'

DB.drop_table?(:copyrights, :scientists, :devices)

DB.create_table(:scientists) do
  primary_key :id
  String :name, size: 40, null: false, unique: true
  Integer :madness, null: false         # measure of madness
  Integer :tries, null: false           # number of tries to destroy the galaxy
  DateTime :created_at, null: false, default: Time.now # date and time of
                                                       # adding information
  constraint(:not_negative_madness) { madness >= 0 }
  constraint(:not_negative_tries) { tries >= 0 }
end

DB.create_table(:devices) do
  primary_key :id
  String :name, size: 40, null: false, unique: true
  Integer :power, null: false           # measure of destructive power
  DateTime :created_at, null: false, default: Time.now # date and time of
                                                       # adding information
  constraint(:not_negative_power) { power >= 0 }
end

DB.create_table(:copyrights) do
  foreign_key :scientist_id, :scientists, on_delete: :cascade
  foreign_key :device_id, :devices, on_delete: :cascade
  primary_key [:scientist_id, :device_id]
end
