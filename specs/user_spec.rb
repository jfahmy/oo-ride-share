require_relative 'spec_helper'

describe "User class" do

  describe "User instantiation" do
    before do
      @user = RideShare::User.new(id: 1, name: "Smithy", phone: "353-533-5334")
    end

    it "is an instance of User" do
      expect(@user).must_be_kind_of RideShare::User
    end

    it "throws an argument error with a bad ID value" do
      expect do
        RideShare::User.new(id: 0, name: "Smithy")
      end.must_raise ArgumentError
    end

    it "sets trips to an empty array if not provided" do
      expect(@user.trips).must_be_kind_of Array
      expect(@user.trips.length).must_equal 0
    end

    it "is set up for specific attributes and data types" do
      [:id, :name, :phone_number, :trips].each do |prop|
        expect(@user).must_respond_to prop
      end

      expect(@user.id).must_be_kind_of Integer
      expect(@user.name).must_be_kind_of String
      expect(@user.phone_number).must_be_kind_of String
      expect(@user.trips).must_be_kind_of Array
    end
  end


  describe "trips property" do
    before do
      @user = RideShare::User.new(id: 9, name: "Merl Glover III",
                                  phone: "1-602-620-2330 x3723", trips: [])
      trip = RideShare::Trip.new(id: 8, driver: nil, passenger: @user,
                                 start_time: Time.parse("2016-08-08"),
                                 end_time: Time.parse("2016-08-09"),
                                 rating: 5)

      @user.add_trip(trip)
    end

    it "each item in array is a Trip instance" do
      @user.trips.each do |trip|
        expect(trip).must_be_kind_of RideShare::Trip
      end
    end

    it "all Trips must have the same passenger's user id" do
      @user.trips.each do |trip|
        expect(trip.passenger.id).must_equal 9
      end
    end
  end


  describe "Trip's net_expenditures" do
    before do
      @user = RideShare::User.new(id: 9, name: "Merl Glover III",
                                  phone: "1-602-620-2330 x3723", trips: [])

      trip = RideShare::Trip.new({id: 8,  passenger: @user,
                                 start_time: Time.parse("2016-08-08"),
                                 end_time: Time.parse("2016-08-09"),
                                 rating: 5, cost:10.11})

      @user.add_trip(trip)

      trip = RideShare::Trip.new({id: 8,  passenger: @user,
                                 start_time: Time.parse("2016-09-08"),
                                 end_time: Time.parse("2016-09-08"),
                                 rating: 4, cost:20})

      @user.add_trip(trip)
    end

    it "net_expenditures should be return a number for total amount of money" do
      expect(@user.net_expenditures).must_equal 30.11
      expect(@user.net_expenditures).must_be_instance_of Float

    end
  end

  describe "User#total_time_spent" do
    before do
      @user = RideShare::User.new(id: 9, name: "Merl Glover III",
                                  phone: "1-602-620-2330 x3723", trips: [])

      trip = RideShare::Trip.new({id: 8,  passenger: @user,
                                 start_time: Time.parse("2018-05-25 11:52:00 -0700"),
                                 end_time: Time.parse("2018-05-25 12:51:00 -0700"),
                                 rating: 5, cost:10.11})

      @user.add_trip(trip)

      trip = RideShare::Trip.new({id: 8,  passenger: @user,
                                 start_time: Time.parse("2018-07-23 04:39:00 -0700"),
                                 end_time: Time.parse("2018-07-23 05:38:00 -0700"),
                                 rating: 4, cost:20})

      @user.add_trip(trip)
    end
    it "returns the total amount of time that the user spent on trips" do
        expect(@user.total_time_spent).must_equal 7080.0
        expect(@user.total_time_spent).must_be_instance_of Numeric
    end
  end

end
