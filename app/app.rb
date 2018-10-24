require 'sinatra'
require 'sequel'
require 'json'
require_relative 'models'
require_relative 'db_connection'

get '/api/scientists' do
  scientists = Scientist.all
  halt 204 if scientists.empty?
  scientists_list = []
  scientists.each { |s| scientists_list << s.values}
  response_body = JSON.pretty_generate({scientists: scientists_list})
  return 200, {'Content-Type' => 'application/json'}, response_body
end

get '/api/scientists/:id' do
  scientist = Scientist.first(id: params[:id])
  halt 404 if scientist.nil?
  response_body = JSON.pretty_generate(scientist.values)
  return 200, {'Content-Type' => 'application/json'}, response_body
end

get '/api/scientists/:id/devices' do
  scientist = Scientist.first(id: params[:id])
  halt 404 if scientist.nil?
  devices = scientist.devices
  halt 204 if devices.empty?
  devices_list = []
  devices.each { |d| devices_list << d.values}
  response_body = JSON.pretty_generate({devices: devices_list})
  return 200, {'Content-Type' => 'application/json'}, response_body
end

get '/api/scientists/:s_id/devices/:d_id' do
  redirect to("/api/devices/#{params[:d_id]}")
end

get '/api/devices' do
  devices = Device.all
  halt 204 if devices.empty?
  devices_list = []
  devices.each { |d| devices_list << d.values}
  response_body = JSON.pretty_generate({devices: devices_list})
  return 200, {'Content-Type' => 'application/json'}, response_body
end

get '/api/devices/:id' do
  device = Device.first(id: params[:id])
  halt 404 if device.nil?
  response_body = JSON.pretty_generate(device.values)
  return 200, {'Content-Type' => 'application/json'}, response_body
end

get '/api/devices/:id/scientists' do
  device = Device.first(id: params[:id])
  halt 404 if device.nil?
  scientists = device.scientists
  halt 204 if scientists.empty?
  scientists_list = []
  scientists.each { |s| scientists_list << s.values}
  response_body = JSON.pretty_generate({scientists: scientists_list})
  return 200, {'Content-Type' => 'application/json'}, response_body
end

get '/api/devices/:d_id/scientists/:s_id' do
  redirect to("/api/scientists/#{params[:d_id]}")
end
