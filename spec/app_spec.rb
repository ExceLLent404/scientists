require_relative '../app/app'
require 'rack/test'
require 'database_cleaner'
require 'rspec/json_matcher'

describe 'REST API' do
  include Rack::Test::Methods
  include RSpec::JsonMatcher

  def app
    Sinatra::Application
  end

  DatabaseCleaner.strategy = :truncation

  before(:all) do
    DatabaseCleaner.clean
  end
  
  after(:all) do
    DatabaseCleaner.clean
  end

  describe 'GET /api/scientists' do
    context 'when scientists list is empty' do
      it 'returns an empty list of scientists' do
        get '/api/scientists'

        expect(last_response).to be_ok
        expect(last_response.headers).to include 'Content-Type'
        expect(last_response.headers['Content-Type']).to eql 'application/json'
        expect(last_response.body).to be_json_as('scientists' => [])
      end
    end

    context 'when at least one scientist exists' do
      it 'returns a non-empty list of scientists' do
        scientist = Scientist.create(name: 'Bob', madness: 5, tries: 0)

        get '/api/scientists'

        expect(last_response).to be_ok
        expect(last_response.headers).to include 'Content-Type'
        expect(last_response.headers['Content-Type']).to eql 'application/json'
        expect(last_response.body).to be_json_including('scientists' => [])
        expect(last_response.body).to include '"name": "Bob"'
        expect(last_response.body).to include '"madness": 5'
        expect(last_response.body).to include '"tries": 0'

        scientist.delete
      end
    end
  end

  describe 'GET /api/scientists/:id' do
    context 'when the record about the scientist does not exist' do
      it 'does not find the requested scientist' do
        get '/api/scientists/0'

        expect(Scientist[0]).to be_nil
        expect(last_response).to be_not_found
      end
    end

    context 'when the record about the scientist exists' do
      it 'returns a record with the requested scientist' do
        scientist = Scientist.create(name: 'Bob', madness: 5, tries: 0)

        get "/api/scientists/#{scientist.id}"

        expect(last_response).to be_ok
        expect(last_response.headers).to include 'Content-Type'
        expect(last_response.headers['Content-Type']).to eql 'application/json'
        expect(last_response.body).to be_json_including('name' => 'Bob',
          'madness' => 5, 'tries' => 0)

        scientist.delete
      end
    end
  end

  describe 'GET /api/scientists/:id/devices' do
    context 'when the record about the scientist does not exist' do
      it 'does not find the requested scientist' do
        get '/api/scientists/0/devices'

        expect(Scientist[0]).to be_nil
        expect(last_response).to be_not_found
      end
    end

    context 'when the record about the scientist exists' do
      context 'but the scientist has no devices' do
        it 'returns an empty list of devices' do
          scientist = Scientist.create(name: 'Bob', madness: 5, tries: 0)

          get "/api/scientists/#{scientist.id}/devices"

          expect(last_response).to be_ok
          expect(last_response.headers).to include 'Content-Type'
          expect(last_response.headers['Content-Type']).to eql 'application/json'
          expect(last_response.body).to be_json_as('devices' => [])

          scientist.delete
        end
      end

      context 'and the scientist has at least one device' do
        it 'returns a non-empty list of devices' do
          scientist = Scientist.create(name: 'Bob', madness: 5, tries: 0)
          device = Device.create(name: 'Bomb', power: 100)
          scientist.add_device(device)

          get "/api/scientists/#{scientist.id}/devices"

          expect(last_response).to be_ok
          expect(last_response.headers).to include 'Content-Type'
          expect(last_response.headers['Content-Type']).to eql 'application/json'
          expect(last_response.body).to be_json_including('devices' => [])
          expect(last_response.body).to include '"name": "Bomb"'
          expect(last_response.body).to include '"power": 100'

          scientist.remove_device(device)
          device.delete
          scientist.delete
        end
      end
    end
  end

  describe 'GET /api/devices' do
    context 'when devices list is empty' do
      it 'returns an empty list of devices' do
        get '/api/devices'

        expect(last_response).to be_ok
        expect(last_response.headers).to include 'Content-Type'
        expect(last_response.headers['Content-Type']).to eql 'application/json'
        expect(last_response.body).to be_json_as('devices' => [])
      end
    end

    context 'when at least one device exists' do
      it 'returns a non-empty list of devices' do
        device = Device.create(name: 'Bomb', power: 100)

        get '/api/devices'

        expect(last_response).to be_ok
        expect(last_response.headers).to include 'Content-Type'
        expect(last_response.headers['Content-Type']).to eql 'application/json'
        expect(last_response.body).to be_json_including('devices' => [])
        expect(last_response.body).to include '"name": "Bomb"'
        expect(last_response.body).to include '"power": 100'

        device.delete
      end
    end
  end

  describe 'GET /api/devices/:id' do
    context 'when the record about the device does not exist' do
      it 'does not find the requested device' do
        get '/api/devices/0'

        expect(Device[0]).to be_nil
        expect(last_response).to be_not_found
      end
    end

    context 'when the record about the device exists' do
      it 'returns a record with the requested device' do
        device = Device.create(name: 'Bomb', power: 100)

        get "/api/devices/#{device.id}"

        expect(last_response).to be_ok
        expect(last_response.headers).to include 'Content-Type'
        expect(last_response.headers['Content-Type']).to eql 'application/json'
        expect(last_response.body).to be_json_including('name' => 'Bomb',
          'power' => 100)

        device.delete
      end
    end
  end

  describe 'GET /api/devices/:id/scientists' do
    context 'when the record about the device does not exist' do
      it 'does not find the requested device' do
        get '/api/devices/0/scientists'

        expect(Device[0]).to be_nil
        expect(last_response).to be_not_found
      end
    end

    context 'when the record about the device exists' do
      context 'but the device has no scientists' do
        it 'returns an empty list of scientists' do
          device = Device.create(name: 'Bomb', power: 100)

          get "/api/devices/#{device.id}/scientists"

          expect(last_response).to be_ok
          expect(last_response.headers).to include 'Content-Type'
          expect(last_response.headers['Content-Type']).
            to eql 'application/json'
          expect(last_response.body).to be_json_as('scientists' => [])

          device.delete
        end
      end

      context 'and the device has at least one scientist' do
        it 'returns a non-empty list of scientists' do
          device = Device.create(name: 'Bomb', power: 100)
          scientist = Scientist.create(name: 'Bob', madness: 5, tries: 0)
          device.add_scientist(scientist)

          get "/api/devices/#{device.id}/scientists"

          expect(last_response).to be_ok
          expect(last_response.headers).to include 'Content-Type'
          expect(last_response.headers['Content-Type']).
            to eql 'application/json'
          expect(last_response.body).to be_json_including('scientists' => [])
          expect(last_response.body).to include '"name": "Bob"'
          expect(last_response.body).to include '"madness": 5'
          expect(last_response.body).to include '"tries": 0'

          device.remove_scientist(scientist)
          scientist.delete
          device.delete
        end
      end
    end
  end

  describe 'POST /api/scientists' do
    context 'when not all parameters are passed' do
      let(:request_body) { JSON.pretty_generate(
        {'name' => name, 'madness' => madness}) }
      let(:name) { 'James Watt' }
      let(:madness) { 50 }

      it 'does not create a new record about the scientist' do
        post '/api/scientists', request_body
        scientist = Scientist.first(name: name, madness: madness)

        expect(last_response).to be_unprocessable
        expect(scientist).to be_nil
      end
    end

    context 'when parameters are not correct' do
      let(:request_body) { JSON.pretty_generate(
        {'name' => name, 'madness' => madness, 'tries' => tries}) }

      context '(name is empty string)' do
        let(:name) { '' }
        let(:madness) { 50 }
        let(:tries) { 1 }

        it 'does not create a new record about the scientist' do
          post '/api/scientists', request_body
          scientist = Scientist.first(name: name,
            madness: madness, tries: tries)

          expect(last_response).to be_unprocessable
          expect(scientist).to be_nil
        end
      end

      context '(madness is negative)' do
        let(:name) { 'James Watt' }
        let(:madness) { -50 }
        let(:tries) { 1 }

        it 'does not create a new record about the scientist' do
          post '/api/scientists', request_body
          scientist = Scientist.first(name: name,
            madness: madness, tries: tries)

          expect(last_response).to be_unprocessable
          expect(scientist).to be_nil
        end
      end

      context '(tries is not integer)' do
        let(:name) { 'James Watt' }
        let(:madness) { 50 }
        let(:tries) { 'not integer' }

        it 'does not create a new record about the scientist' do
          post '/api/scientists', request_body
          scientist = Scientist.first(name: name, madness: madness)

          expect(last_response).to be_unprocessable
          expect(scientist).to be_nil
        end
      end
    end

    context 'when all parameters are passed and correct' do
      let(:request_body) { JSON.pretty_generate(
        {'name' => name, 'madness' => madness, 'tries' => tries}) }
      let(:name) { 'James Watt' }
      let(:madness) { 50 }
      let(:tries) { 1 }

      it 'creates a new record about the scientist' do
        post '/api/scientists', request_body
        scientist = Scientist.first(name: name, madness: madness, tries: tries)

        expect(last_response).to be_created
        expect(last_response.headers).to include 'Location'
        expect(last_response.headers['Location']).
          to eql "/api/scientists/#{scientist.id}"
        expect(scientist).not_to be_nil
      end
    end
  end

  describe 'POST /api/scientists/:id/devices' do
    context 'when the record about the scientist does not exist' do
      it 'does not find the requested scientist' do
        post '/api/scientists/0/devices'

        expect(Scientist[0]).to be_nil
        expect(last_response).to be_not_found
      end
    end

    context 'when the record about the scientist exists' do
      context 'but the device id is not passed' do
        let(:request_body) { JSON.pretty_generate({}) }

        it 'does not assign any device to the scientist' do
          scientist = Scientist.create(name: 'Amy', madness: 0, tries: 0)

          post "/api/scientists/#{scientist.id}/devices", request_body

          expect(last_response).to be_unprocessable
          expect(scientist.devices).to be_empty

          scientist.delete
        end
      end

      context 'but the device id is not correct' do
        let(:request_body) { JSON.pretty_generate({'id' => id}) }

        context '(id is a float)' do
          let(:id) { 5.7 }

          it 'does not assign any device to the scientist' do
            scientist = Scientist.create(name: 'Amy', madness: 0, tries: 0)

            post "/api/scientists/#{scientist.id}/devices", request_body

            expect(last_response).to be_unprocessable
            expect(scientist.devices).to be_empty

            scientist.delete
          end
        end

        context '(id is equal to 0)' do
          let(:id) { 0 }

          it 'does not assign any device to the scientist' do
            scientist = Scientist.create(name: 'Amy', madness: 0, tries: 0)

            post "/api/scientists/#{scientist.id}/devices", request_body

            expect(last_response).to be_unprocessable
            expect(scientist.devices).to be_empty

            scientist.delete
          end
        end
      end

      context 'and the device id is passed and correct' do
        context 'but there is no device with this id' do
          let(:request_body) { JSON.pretty_generate({'id' => id}) }
          let(:id) { 10 }

          it 'does not assign the device to the scientist' do
            scientist = Scientist.create(name: 'Amy', madness: 0, tries: 0)
            device = Device.first(id: id)

            post "/api/scientists/#{scientist.id}/devices", request_body

            expect(last_response).to be_not_found
            expect(device).to be_nil
            expect(scientist.devices).to be_empty

            scientist.delete
          end
        end

        context 'and there is a device with this id' do
          it 'assigns the device to the scientist' do
            scientist = Scientist.create(name: 'Amy', madness: 0, tries: 0)
            device = Device.create(name: 'Bomb', power: 100)
            request_body = JSON.pretty_generate({'id' => device.id})

            post "/api/scientists/#{scientist.id}/devices", request_body

            expect(last_response).to be_created  
            expect(scientist.devices[0]).to eql device

            scientist.delete
            device.delete
          end
        end
      end
    end
  end

  describe 'POST /api/devices' do
    context 'when not all parameters are passed' do
      let(:request_body) { JSON.pretty_generate({'name' => name}) }
      let(:name) { 'Lamp' }

      it 'does not create a new record about the device' do
        post '/api/devices', request_body
        device = Device.first(name: name)

        expect(last_response).to be_unprocessable
        expect(device).to be_nil
      end
    end

    context 'when parameters are not correct' do
      let(:request_body) { JSON.pretty_generate(
        {'name' => name, 'power' => power}) }

      context '(name is empty string)' do
        let(:name) { '' }
        let(:power) { 50 }

        it 'does not create a new record about the device' do
          post '/api/devices', request_body
          device = Device.first(name: name, power: power)

          expect(last_response).to be_unprocessable
          expect(device).to be_nil
        end
      end

      context '(power is negative)' do
        let(:name) { 'Lamp' }
        let(:power) { -50 }

        it 'does not create a new record about the device' do
          post '/api/devices', request_body
          device = Device.first(name: name, power: power)

          expect(last_response).to be_unprocessable
          expect(device).to be_nil
        end
      end

      context '(power is not integer)' do
        let(:name) { 'James Watt' }
        let(:power) { 'not integer' }

        it 'does not create a new record about the device' do
          post '/api/devices', request_body
          device = Device.first(name: name)

          expect(last_response).to be_unprocessable
          expect(device).to be_nil
        end
      end
    end

    context 'when all parameters are passed and correct' do
      let(:request_body) { JSON.pretty_generate(
        {'name' => name, 'power' => power}) }
      let(:name) { 'James Watt' }
      let(:power) { 50 }

      it 'creates a new record about the device' do
        post '/api/devices', request_body
        device = Device.first(name: name, power: power)

        expect(last_response).to be_created
        expect(last_response.headers).to include 'Location'
        expect(last_response.headers['Location']).
          to eql "/api/devices/#{device.id}"
        expect(device).not_to be_nil
      end
    end
  end

  describe 'POST /api/devices/:id/scientists' do
    context 'when the record about the device does not exist' do
      it 'does not find the requested device' do
        post '/api/devices/0/scientists'

        expect(Device[0]).to be_nil
        expect(last_response).to be_not_found
      end
    end

    context 'when the record about the device exists' do
      context 'but the scientist id is not passed' do
        let(:request_body) { JSON.pretty_generate({}) }

        it 'does not assign any scientist to the device' do
          device = Device.create(name: 'Lamp', power: 50)

          post "/api/devices/#{device.id}/scientists", request_body

          expect(last_response).to be_unprocessable
          expect(device.scientists).to be_empty

          device.delete
        end
      end

      context 'but the scientist id is not correct' do
        let(:request_body) { JSON.pretty_generate({'id' => id}) }

        context '(id is a float)' do
          let(:id) { 5.7 }

          it 'does not assign any scientist to the device' do
            device = Device.create(name: 'Lamp', power: 50)

            post "/api/devices/#{device.id}/scientists", request_body

            expect(last_response).to be_unprocessable
            expect(device.scientists).to be_empty

            device.delete
          end
        end

        context '(id is equal to 0)' do
          let(:id) { 0 }

          it 'does not assign any scientist to the device' do
            device = Device.create(name: 'Lamp', power: 50)

            post "/api/devices/#{device.id}/scientists", request_body

            expect(last_response).to be_unprocessable
            expect(device.scientists).to be_empty

            device.delete
          end
        end
      end

      context 'and the scientist id is passed and correct' do
        context 'but there is no scientist with this id' do
          let(:request_body) { JSON.pretty_generate({'id' => id}) }
          let(:id) { 10 }

          it 'does not assign the scientist to the device' do
            device = Device.create(name: 'Lamp', power: 50)
            scientist = Scientist.first(id: id)

            post "/api/devices/#{device.id}/scientists", request_body

            expect(last_response).to be_not_found
            expect(scientist).to be_nil
            expect(device.scientists).to be_empty

            device.delete
          end
        end

        context 'and there is a scientist with this id' do
          it 'assigns the scientist to the device' do
            device = Device.create(name: 'Lamp', power: 50)
            scientist = Scientist.create(name: 'Bob', madness: 0, tries: 0)
            request_body = JSON.pretty_generate({'id' => scientist.id})

            post "/api/devices/#{device.id}/scientists", request_body

            expect(last_response).to be_created  
            expect(device.scientists[0]).to eql scientist

            device.delete
            scientist.delete
          end
        end
      end
    end
  end

  describe 'PUT /api/scientist/:id' do
    context 'when the record about the scientist does not exist' do
      it 'does not find the requested scientist' do
        put '/api/scientists/0'

        expect(Scientist[0]).to be_nil
        expect(last_response).to be_not_found
      end
    end

    context 'when the record about the scientist exists' do
      context 'but not all parameters are passed' do
        let(:request_body) { JSON.pretty_generate(
          {'name' => name, 'madness' => madness}) }
        let(:name) { 'Carl' }
        let(:madness) { 37 }

        it 'does not update the record about the scientist' do
          scientist = Scientist.create(name: 'Bob', madness: 10, tries: 5)

          put "/api/scientists/#{scientist.id}", request_body

          expect(last_response).to be_unprocessable
          expect(scientist.name).to eql 'Bob'
          expect(scientist.madness).to eql 10
          expect(scientist.tries).to eql 5

          scientist.delete
        end
      end

      context 'when parameters are not correct' do
        let(:request_body) { JSON.pretty_generate(
          {'name' => name, 'madness' => madness, 'tries' => tries}) }

        context '(name is empty string)' do
          let(:name) { '' }
          let(:madness) { 50 }
          let(:tries) { 1 }

          it 'does not update the record about the scientist' do
            scientist = Scientist.create(name: 'Bob', madness: 10, tries: 5)

            put "/api/scientists/#{scientist.id}", request_body

            expect(last_response).to be_unprocessable
            expect(scientist.name).to eql 'Bob'
            expect(scientist.madness).to eql 10
            expect(scientist.tries).to eql 5

            scientist.delete
          end
        end

        context '(madness is negative)' do
          let(:name) { 'Carl' }
          let(:madness) { -50 }
          let(:tries) { 1 }

          it 'does not update the record about the scientist' do
            scientist = Scientist.create(name: 'Bob', madness: 10, tries: 5)

            put "/api/scientists/#{scientist.id}", request_body

            expect(last_response).to be_unprocessable
            expect(scientist.name).to eql 'Bob'
            expect(scientist.madness).to eql 10
            expect(scientist.tries).to eql 5

            scientist.delete
          end
        end

        context '(tries is not integer)' do
          let(:name) { 'Carl' }
          let(:madness) { 50 }
          let(:tries) { 'not integer' }

          it 'does not update the record about the scientist' do
            scientist = Scientist.create(name: 'Bob', madness: 10, tries: 5)

            put "/api/scientists/#{scientist.id}", request_body

            expect(last_response).to be_unprocessable
            expect(scientist.name).to eql 'Bob'
            expect(scientist.madness).to eql 10
            expect(scientist.tries).to eql 5

            scientist.delete
          end
        end
      end

      context 'when all parameters are passed and correct' do
        let(:request_body) { JSON.pretty_generate(
          {'name' => name, 'madness' => madness, 'tries' => tries}) }
        let(:name) { 'Carl' }
        let(:madness) { 50 }
        let(:tries) { 1 }

        it 'updates the record about the scientist' do
          scientist = Scientist.create(name: 'Bob', madness: 10, tries: 5)

          put "/api/scientists/#{scientist.id}", request_body
          scientist = Scientist[scientist.id]

          expect(last_response).to be_no_content
          expect(scientist.name).to eql name
          expect(scientist.madness).to eql madness
          expect(scientist.tries).to eql tries

          scientist.delete
        end
      end
    end
  end

  describe 'PUT /api/device/:id' do
    context 'when the record about the device does not exist' do
      it 'does not find the requested device' do
        put '/api/devices/0'

        expect(Device[0]).to be_nil
        expect(last_response).to be_not_found
      end
    end

    context 'when the record about the device exists' do
      context 'but not all parameters are passed' do
        let(:request_body) { JSON.pretty_generate({'name' => name}) }
        let(:name) { 'Grenade' }

        it 'does not update the record about the device' do
          device = Device.create(name: 'Bomb', power: 100)

          put "/api/devices/#{device.id}", request_body

          expect(last_response).to be_unprocessable
          expect(device.name).to eql 'Bomb'
          expect(device.power).to eql 100

          device.delete
        end
      end

      context 'when parameters are not correct' do
        let(:request_body) { JSON.pretty_generate(
          {'name' => name, 'power' => power}) }

        context '(name is empty string)' do
          let(:name) { '' }
          let(:power) { 50 }

          it 'does not update the record about the device' do
            device = Device.create(name: 'Bomb', power: 100)

            put "/api/devices/#{device.id}", request_body

            expect(last_response).to be_unprocessable
            expect(device.name).to eql 'Bomb'
            expect(device.power).to eql 100

            device.delete
          end
        end

        context '(power is negative)' do
          let(:name) { 'Grenade' }
          let(:power) { -50 }

          it 'does not update the record about the device' do
            device = Device.create(name: 'Bomb', power: 100)

            put "/api/devices/#{device.id}", request_body

            expect(last_response).to be_unprocessable
            expect(device.name).to eql 'Bomb'
            expect(device.power).to eql 100

            device.delete
          end
        end

        context '(power is not integer)' do
          let(:name) { 'Grenade' }
          let(:power) { 'not integer' }

          it 'does not update the record about the device' do
            device = Device.create(name: 'Bomb', power: 100)

            put "/api/devices/#{device.id}", request_body

            expect(last_response).to be_unprocessable
            expect(device.name).to eql 'Bomb'
            expect(device.power).to eql 100

            device.delete
          end
        end
      end

      context 'when all parameters are passed and correct' do
        let(:request_body) { JSON.pretty_generate(
          {'name' => name, 'power' => power}) }
        let(:name) { 'Grenade' }
        let(:power) { 89 }

        it 'updates the record about the device' do
          device = Device.create(name: 'Bomb', power: 100)

          put "/api/devices/#{device.id}", request_body
          device = Device[device.id]

          expect(last_response).to be_no_content
          expect(device.name).to eql name
          expect(device.power).to eql power

          device.delete
        end
      end
    end
  end

  describe 'DELETE /api/scientists/:id' do
    context 'when the record about the scientist does not exist' do
      it 'returns successful delete result' do
        delete '/api/scientists/0'

        expect(Scientist[0]).to be_nil
        expect(last_response).to be_no_content
      end
    end

    context 'when the record about the scientist exists' do
      it 'deletes the record about the scientist' do
        scientist = Scientist.create(name: 'Carl', madness: 5, tries: 0)

        delete "/api/scientists/#{scientist.id}"
        scientist = Scientist[scientist.id]

        expect(last_response).to be_no_content
        expect(scientist).to be_nil
      end
    end
  end

  describe 'DELETE /api/devices/:id' do
    context 'when the record about the device does not exist' do
      it 'returns successful delete result' do
        delete '/api/devices/0'

        expect(Device[0]).to be_nil
        expect(last_response).to be_no_content
      end
    end

    context 'when the record about the device exists' do
      it 'deletes the record about the device' do
        device = Device.create(name: 'Bomb', power: 100)

        delete "/api/devices/#{device.id}"
        device = Device[device.id]

        expect(last_response).to be_no_content
        expect(device).to be_nil
      end
    end
  end

  describe 'DELETE /api/scientists/:scientist_id/devices/:device_id' do
    context 'when the record about the scientist does not exist' do
      it 'returns successful delete result' do
        delete '/api/scientists/0/devices/0'

        expect(Scientist[0]).to be_nil
        expect(last_response).to be_no_content
      end
    end

    context 'when the record about the scientist exists' do
      context 'but the device is not related with the scientist' do
        it 'returns successful delete result' do
          scientist = Scientist.create(name: 'Carl', madness: 5, tries: 0)
          device = Device.create(name: 'Bomb', power: 100)

          delete "/api/scientists/#{scientist.id}/devices/#{device.id}"

          expect(scientist.devices).not_to include device
          expect(last_response).to be_no_content

          device.delete
          scientist.delete
        end
      end

      context 'and the device is related with the scientist' do
        it 'breaks the relation between the scientist and the device' do
          scientist = Scientist.create(name: 'Carl', madness: 5, tries: 0)
          device = Device.create(name: 'Bomb', power: 100)
          scientist.add_device(device)

          delete "/api/scientists/#{scientist.id}/devices/#{device.id}"

          expect(scientist.devices).not_to include device
          expect(last_response).to be_no_content

          scientist.remove_device(device)
          device.delete
          scientist.delete
        end
      end
    end
  end

  describe 'DELETE /api/devices/:device_id/scientists/:scientist_id' do
    context 'when the record about the device does not exist' do
      it 'returns successful delete result' do
        delete '/api/devices/0/scientists/0'

        expect(Device[0]).to be_nil
        expect(last_response).to be_no_content
      end
    end

    context 'when the record about the device exists' do
      context 'but the scientist is not related with the device' do
        it 'returns successful delete result' do
          device = Device.create(name: 'Bomb', power: 100)
          scientist = Scientist.create(name: 'Carl', madness: 5, tries: 0)

          delete "/api/devices/#{device.id}/scientists/#{scientist.id}"

          expect(device.scientists).not_to include scientist
          expect(last_response).to be_no_content

          scientist.delete
          device.delete
        end
      end

      context 'and the scientist is related with the device' do
        it 'breaks the relation between the device and the scientist' do
          device = Device.create(name: 'Bomb', power: 100)
          scientist = Scientist.create(name: 'Carl', madness: 5, tries: 0)
          device.add_scientist(scientist)

          delete "/api/devices/#{device.id}/scientists/#{scientist.id}"

          expect(device.scientists).not_to include scientist
          expect(last_response).to be_no_content

          device.remove_scientist(scientist)
          scientist.delete
          device.delete
        end
      end
    end
  end
end
