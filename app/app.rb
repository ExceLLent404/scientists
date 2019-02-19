require 'sinatra'
require 'sequel'
require 'json'
require_relative 'models'
require_relative 'db_connection'
require_relative 'checking_methods'

configure do
  set :bind, '0.0.0.0'
end

get '/api/scientists' do
  scientists = Scientist.all
  scientists_list = []
  scientists.each { |s| scientists_list << s.values}
  response_body = JSON.pretty_generate({scientists: scientists_list})
  return 200, {'Content-Type' => 'application/json'}, response_body
end

get '/api/scientists/:id' do
  scientist = Scientist[params[:id]]
  halt 404 if scientist.nil?

  response_body = JSON.pretty_generate(scientist.values)
  return 200, {'Content-Type' => 'application/json'}, response_body
end

get '/api/scientists/:id/devices' do
  scientist = Scientist[params[:id]]
  halt 404 if scientist.nil?

  devices = scientist.devices
  devices_list = []
  devices.each { |d| devices_list << d.values}
  response_body = JSON.pretty_generate({devices: devices_list})
  return 200, {'Content-Type' => 'application/json'}, response_body
end

get '/api/devices' do
  devices = Device.all
  devices_list = []
  devices.each { |d| devices_list << d.values}
  response_body = JSON.pretty_generate({devices: devices_list})
  return 200, {'Content-Type' => 'application/json'}, response_body
end

get '/api/devices/:id' do
  device = Device[params[:id]]
  halt 404 if device.nil?

  response_body = JSON.pretty_generate(device.values)
  return 200, {'Content-Type' => 'application/json'}, response_body
end

get '/api/devices/:id/scientists' do
  device = Device[params[:id]]
  halt 404 if device.nil?

  scientists = device.scientists
  scientists_list = []
  scientists.each { |s| scientists_list << s.values}
  response_body = JSON.pretty_generate({scientists: scientists_list})
  return 200, {'Content-Type' => 'application/json'}, response_body
end

post '/api/scientists' do
  data = JSON.parse(request.body.read)
  halt 422 until is_correct_data?(data, 'name', 'madness', 'tries')

  scientist = Scientist.create(name: data['name'],
                               madness: data['madness'], tries: data['tries'])
  return 201, {'Location' => "/api/scientists/#{scientist.id}"}, ''
end

post '/api/scientists/:id/devices' do
  scientist = Scientist[params[:id]]
  halt 404 if scientist.nil?

  data = JSON.parse(request.body.read)
  halt 422 until is_correct_data?(data, 'id')

  device = Device[data['id']]
  halt 404 if device.nil?

  scientist.add_device(device)
  return 201
end

post '/api/devices' do
  data = JSON.parse(request.body.read)
  halt 422 until is_correct_data?(data, 'name', 'power')

  device = Device.create(name: data['name'], power: data['power'])
  return 201, {'Location' => "/api/devices/#{device.id}"}, ''
end

post '/api/devices/:id/scientists' do
  device = Device[params[:id]]
  halt 404 if device.nil?

  data = JSON.parse(request.body.read)
  halt 422 until is_correct_data?(data, 'id')

  scientist = Scientist[data['id']]
  halt 404 if scientist.nil?

  device.add_scientist(scientist)
  return 201
end

put '/api/scientists/:id' do
  scientist = Scientist[params[:id]]
  halt 404 if scientist.nil?

  data = JSON.parse(request.body.read)
  halt 422 until is_correct_data?(data, 'name', 'madness', 'tries')

  scientist.update(name: data['name'],
    madness: data['madness'], tries: data['tries'])
  return 204
end

put '/api/devices/:id' do
  device = Device[params[:id]]
  halt 404 if device.nil?

  data = JSON.parse(request.body.read)
  halt 422 until is_correct_data?(data, 'name', 'power')

  device.update(name: data['name'], power: data['power'])
  return 204
end

delete '/api/scientists/:id' do
  scientist = Scientist[params[:id]]
  scientist.delete if !scientist.nil?
  return 204
end

delete '/api/devices/:id' do
  device = Device[params[:id]]
  device.delete if !device.nil?
  return 204
end

delete '/api/scientists/:scientist_id/devices/:device_id' do
  scientist = Scientist[params[:scientist_id]]
  return 204 if scientist.nil?

  device = scientist.devices_dataset.first(id: params[:device_id])
  scientist.remove_device(device) if !device.nil?
  return 204
end

delete '/api/devices/:device_id/scientists/:scientist_id' do
  device = Device[params[:device_id]]
  return 204 if device.nil?

  scientist = device.scientists_dataset.first(id: params[:scientist_id])
  device.remove_scientist(scientist) if !scientist.nil?
  return 204
end
