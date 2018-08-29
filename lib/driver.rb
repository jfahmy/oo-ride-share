module RideShare
  class Driver < User
    attr_reader :vehicle_id, :driven_trips, :status

    def initialize(input)
      super(input)
      @vehicle_id = input[:vin]
      @status = input[:status]
      @driven_trips = input[:driven_trips].nil? ? [] : input[:driven_trips]

      raise ArgumentError, "No VIN number provided" if @vehicle_id == nil || @vehicle_id.length != 17
      raise ArgumentError, "No id number provided" if @id <= 0
      raise ArgumentError, "Invalid status, must be either :AVAILABLE or :UNAVAILABLE" if @status != :AVAILABLE && @status != :UNAVAILABLE
    end

    def add_driven_trip(trip)
      @driven_trips << trip
    end

    def average_rating
      total_rate = @driven_trips.sum do |trip|
        trip.rating
      end
      return total_rate / @driven_trips.length
    end

    def total_revenue
      revenue = @driven_trips.sum do |trip|
        (trip.cost - 1.65) * 0.8.round(2)
      end
      return revenue
    end

    def net_expenditures
      return super - total_revenue
    end
  end

end
