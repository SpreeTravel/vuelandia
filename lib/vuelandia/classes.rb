##################TO RETURN THE DATA FOR ALL DESTINATIONS LIST############
class Country
	attr_accessor :ID, :Name, :Destinations
end

class Destination
	attr_accessor :ID, :Name, :Zones
end

class Zone
	attr_accessor :ID, :Name
end
###########################################################################


##################TO RETURN THE DATA WHEN AVAILABILITY RETURNS MULTIPLE RESULTS############
class MultipleData
	attr_accessor :Type, :Name, :Destination, :Country, :AdditionalsParameters
end

class AdditionalsParameters
	attr_accessor :Destination, :DestinationID, :IDE
end
###########################################################################################


##################TO RETURN THE DATA WHEN AVAILABILITY RETURNS A UNIQUE RESULT#############
class UniqueData
	attr_accessor :obj, :TotalDestinationHotels, :AvailablesHotel, :SessionID, :Hotels
end

class Hotel
	#######Optional#######
	attr_accessor :Category, :City, :Latitud, :Longitud, :Photo, :ImportantNote
	#######Required#######
	attr_accessor :HotelDetails
end

class HotelDetails
	attr_accessor :ID, :Name, :NameOriginal
end

class Category
	attr_accessor :ID, :Name
end

class Photo
	attr_accessor :Width, :Height, :URL
end

class Accommodations
	attr_accessor :Room
end
###########################################################################################
