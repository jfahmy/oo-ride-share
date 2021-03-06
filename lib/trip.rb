require 'csv'
require 'time'

module RideShare
  class Trip
    attr_reader :id, :passenger, :start_time, :end_time, :cost, :rating, :driver

    # initialize
    def initialize(input)
      @id = input[:id]
      @passenger = input[:passenger]
      @start_time = input[:start_time]
      @end_time = input[:end_time]
      @cost = input[:cost]
      @rating = input[:rating]
      @driver = input[:driver]

      if @end_time != nil
        if (@rating > 5 || @rating < 1)
          raise ArgumentError.new("Invalid rating #{@rating}")
        end

        if @start_time > @end_time
          raise ArgumentError.new("Start_time cannot be later than end_time")
        end

        if @start_time > Time.now || @end_time > Time.now
          raise ArgumentError.new("Time is in the future! That can't be right.")
        end
      end
    end

    def inspect
      "#<#{self.class.name}:0x#{self.object_id.to_s(16)} " +
      "ID=#{id.inspect} " +
      "PassengerID=#{passenger&.id.inspect}>"
    end
    # a method to calculate the time duration of each trip
    def duration
      return @end_time - @start_time
    end

  end
end
