require 'csv'
require 'time'
require 'pry'

require_relative 'user'
require_relative 'trip'
require_relative 'driver'

module RideShare
  class TripDispatcher
    attr_reader :drivers, :passengers, :trips
    # load CSV data, and create three arrays , passengers, drivers and trips array
    def initialize(user_file = 'support/users.csv',
                   trip_file = 'support/trips.csv',
                    driver_file = 'support/drivers.csv')
      @passengers = load_users(user_file)
      @drivers = load_drivers(driver_file)
      @trips = load_trips(trip_file)
    end

    # create user objects
    def load_users(filename)
      users = []

      CSV.read(filename, headers: true).each do |line|
        input_data = {}
        input_data[:id] = line[0].to_i
        input_data[:name] = line[1]
        input_data[:phone] = line[2]

        users << User.new(input_data)
      end

      return users
    end

    # create trips
    def load_trips(filename)
      trips = []
      trip_data = CSV.open(filename, 'r', headers: true,
                                          header_converters: :symbol)

      trip_data.each do |raw_trip|
        passenger_num = raw_trip[:passenger_id].to_i
        passenger = find_passenger(passenger_num)
        driver_number = raw_trip[:driver_id].to_i
        #binding.pry
        driver = find_driver(driver_number)
        parsed_trip = {
          id: raw_trip[:id].to_i,
          passenger: passenger,
          start_time: Time.parse(raw_trip[:start_time]),
          end_time: Time.parse(raw_trip[:end_time]),
          cost: raw_trip[:cost].to_f,
          rating: raw_trip[:rating].to_i,
          driver: driver
        }

        trip = Trip.new(parsed_trip)
        passenger.add_trip(trip)
        driver.add_driven_trip(trip)
        trips << trip

      end

      return trips
    end

    # create drivers
    def load_drivers(filename)
      drivers = []
      CSV.read(filename, headers: true).each do |line|
        input_data = {}
        input_data[:id] = line[0].to_i
        input_data[:vin] = line[1]
        input_data[:status] = line[2].to_sym

        if find_passenger(input_data[:id]) != nil
          passenger = find_passenger(input_data[:id])
          input_data[:name] = passenger.name
          input_data[:phone_num] = passenger.phone_number
        end

        driver = Driver.new(input_data)
        @passengers = @passengers.map do |user|

          if user.id == driver.id
            driver
          else
            user
          end

        end
        drivers << driver
      end
      drivers
    end

    # find passenger bu id
    def find_passenger(id)
      check_id(id)
      return @passengers.find { |passenger| passenger.id == id }
    end

    # find driver by id
    def find_driver(id)
      check_id(id)
      return @drivers.find { |driver| driver.id == id }
    end

    # find availabe driver by rules
    def available_driver
       # pull all available drivers
       available_drivers = @drivers.find_all {|driver| driver.status == :AVAILABLE}

       # pull first driver from the drivers without any trips
       driver_without_trips = available_drivers.find {|driver| driver.driven_trips == []}

       if !driver_without_trips.nil?
         return driver_without_trips
       else
         return available_drivers.min_by do |driver|    # select the driver with the earliest ( last trip end time)
           driver.last_trip_end_time
         end
       end

    end

    # create new in-progress trip by using user_id
    def request_trip(user_id)
      driver = available_driver
      if driver == nil
        return "No driver available at this time."
      end
      start_time = Time.now
      end_time = nil
      trip_id = @trips.length + 1
      passenger = find_passenger(user_id)
      new_trip = Trip.new({
        driver: driver, start_time: start_time, end_time: end_time, passenger: passenger, id: trip_id
        })

      driver.add_driven_trip(new_trip)
      passenger.add_trip(new_trip)
      @trips << new_trip

      driver.status = :UNAVAILABLE

      return new_trip

    end

    def inspect
      return "#<#{self.class.name}:0x#{self.object_id.to_s(16)} \
              #{trips.count} trips, \
              #{drivers.count} drivers, \
              #{passengers.count} passengers>"
    end

    private

    def check_id(id)
      raise ArgumentError, "ID cannot be blank or less than zero. (got #{id})" if id.nil? || id <= 0
    end
  end
end
