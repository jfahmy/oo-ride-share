require_relative 'spec_helper'
require 'time'
require 'pry'


describe "TripDispatcher class" do
  describe "Initializer" do
    it "is an instance of TripDispatcher" do
      dispatcher = RideShare::TripDispatcher.new(USER_TEST_FILE,
                                                 TRIP_TEST_FILE,
                                                  DRIVER_TEST_FILE)
      expect(dispatcher).must_be_kind_of RideShare::TripDispatcher
    end

    it "establishes the base data structures when instantiated" do
      dispatcher = RideShare::TripDispatcher.new
      [:trips, :passengers].each do |prop|
        expect(dispatcher).must_respond_to prop
      end

      expect(dispatcher.trips).must_be_kind_of Array
      expect(dispatcher.passengers).must_be_kind_of Array
      # expect(dispatcher.drivers).must_be_kind_of Array
    end
  end

  describe "find_user method" do
    before do
      @dispatcher = RideShare::TripDispatcher.new(USER_TEST_FILE,
                                                 TRIP_TEST_FILE,
                                                  DRIVER_TEST_FILE)
    end

    it "throws an argument error for a bad ID" do
      expect{ @dispatcher.find_passenger(0) }.must_raise ArgumentError
    end

    it "finds a user instance" do
      passenger = @dispatcher.find_passenger(2)
      expect(passenger).must_be_kind_of RideShare::User
    end
  end


  # Uncomment for Wave 2
  describe "find_driver method" do
    before do
      @dispatcher = RideShare::TripDispatcher.new(USER_TEST_FILE,
                                                 TRIP_TEST_FILE,
                                                  DRIVER_TEST_FILE)
    end

    it "throws an argument error for a bad ID" do
      expect { @dispatcher.find_driver(0) }.must_raise ArgumentError
    end

    it "finds a driver instance" do
      driver = @dispatcher.find_driver(2)
      expect(driver).must_be_kind_of RideShare::Driver
    end
  end

  describe "Driver & Trip loader methods" do
    before do
      @dispatcher = RideShare::TripDispatcher.new(USER_TEST_FILE,
                                                 TRIP_TEST_FILE,
                                                  DRIVER_TEST_FILE)
    end

    it "accurately loads driver information into drivers array" do
      first_driver = @dispatcher.drivers.first
      last_driver = @dispatcher.drivers.last

      expect(first_driver.name).must_equal "Driver2"
      expect(first_driver.id).must_equal 2
      expect(first_driver.status).must_equal :UNAVAILABLE
      expect(last_driver.name).must_equal "Driver8"
      expect(last_driver.id).must_equal 8
      expect(last_driver.status).must_equal :AVAILABLE
    end

    it "Connects drivers with driven trips" do
      trips = @dispatcher.trips

      [trips.first, trips.last].each do |trip|
        driver = trip.driver

        expect(driver).must_be_instance_of RideShare::Driver
        expect(driver.driven_trips).must_include trip

      end
    end
  end

  describe "User & Trip loader methods" do
    before do
      @dispatcher = RideShare::TripDispatcher.new(USER_TEST_FILE,
                                                  TRIP_TEST_FILE,
                                                  DRIVER_TEST_FILE)
    end

    it "accurately loads passenger information into passengers array" do
      first_passenger = @dispatcher.passengers.first
      last_passenger = @dispatcher.passengers.last

      expect(first_passenger.name).must_equal "User1"
      expect(first_passenger.id).must_equal 1
      expect(last_passenger.name).must_equal "Driver8"
      expect(last_passenger.id).must_equal 8
    end

    it "accurately loads trip info and associates trips with passengers" do
      trip = @dispatcher.trips.first
      passenger = trip.passenger

      expect(passenger).must_be_instance_of RideShare::User
      expect(passenger.trips).must_include trip
    end

    it "loads trip start and end time as a Time" do
      trip = @dispatcher.trips.first
      passenger = trip.passenger

      expect(passenger.trips[0].start_time).must_be_instance_of Time
      expect(passenger.trips[0].end_time).must_be_instance_of Time
    end

    it "loads an accurate Time stamp" do
      trip = @dispatcher.trips.first
      passenger = trip.passenger

      test_start_time = Time.parse("2018-05-25 11:52:40 -0700")
      test_end_time = Time.parse("2018-05-25 12:25:00 -0700")

      expect(passenger.trips[0].start_time).must_equal test_start_time
      expect(passenger.trips[0].end_time).must_equal test_end_time
     end
  end

  describe "TripDispatcher#available_driver" do
    before do
      @dispatcher = RideShare::TripDispatcher.new(USER_TEST_FILE,
                                                  TRIP_TEST_FILE,
                                                  DRIVER_TEST_FILE)
    end

    it "return a driver who is available" do

      expect(@dispatcher.available_driver).must_be_instance_of RideShare::Driver
      expect(@dispatcher.available_driver.status).must_equal :AVAILABLE
    end

    it "returns a driver that had not driven a trip for the longest time" do
      expect(@dispatcher.available_driver.id).must_equal 8
    end

    it "returns the first driver without any driven_trips" do
      dispatcher2 = RideShare::TripDispatcher.new(USER_TEST_FILE,
                                                  TRIP_TEST_FILE,
                                                  DRIVER_TEST_FILE)
      driver_x = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV",
                                     vin: "1C9EVBRM0YBC564DZ")
      driver_y = RideShare::Driver.new(id: 100, name: "Jenny", vin: "1C9EVBRM0YBC564DZ")
      dispatcher2.drivers << driver_x
      dispatcher2.drivers << driver_y

      expect(dispatcher2.available_driver).must_equal driver_x
    end


  end

  describe "request trip by a user" do
    before do
      @dispatcher = RideShare::TripDispatcher.new(USER_TEST_FILE,
                                                  TRIP_TEST_FILE,
                                                  DRIVER_TEST_FILE)
    end


    it "will add the trip object to driver's driven_trips array" do
        trip_generated = @dispatcher.request_trip(1)
        driven_trips = trip_generated.driver.driven_trips

        expect(driven_trips).must_include trip_generated
    end


    it "will add the trip object to passenger's trips array" do
      trip_generated = @dispatcher.request_trip(1)
      trips = trip_generated.passenger.trips

      expect(trips).must_include trip_generated
    end

    it "will add the trip object to the collection of all trips in trip dispatcher" do
      all_trips = @dispatcher.trips
      trip_count = all_trips.length
      trip_generated = @dispatcher.request_trip(1)

      expect(all_trips).must_include trip_generated
      expect(all_trips.length).must_equal trip_count + 1

    end

    it "will change the driver status to unavailabe" do
      trip_generated = @dispatcher.request_trip(1)
      status = trip_generated.driver.status

      expect(status).must_equal :UNAVAILABLE

    end

    it "will return the trip" do
      trip_generated = @dispatcher.request_trip(1)

      expect(trip_generated).must_be_kind_of RideShare::Trip

    end

    it "will return a message when no driver is available for trip" do
      @dispatcher.drivers.each do |driver|
        driver.status = :UNAVAILABLE
      end

      expect(@dispatcher.request_trip(6)).must_equal "No driver available at this time."
    end

    it "will not create a trip if no driver is available" do
      @dispatcher.drivers.each do |driver|
        driver.status = :UNAVAILABLE
      end
      trip_count = @dispatcher.trips.length
      @dispatcher.request_trip(6)

      expect(@dispatcher.trips.length).must_equal trip_count

    end

  end

end
