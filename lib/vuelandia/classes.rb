#############################COMMON CLASSES###############################
class IdName
	attr_accessor :ID, :Name
end
##########################################################################

##################TO RETURN THE DATA FOR ALL DESTINATIONS LIST############
class Country < IdName
	attr_accessor :Destinations
end

class Destination < IdName
	attr_accessor :Zones
end
###########################################################################


##################TO RETURN THE DATA WHEN AVAILABILITY RETURNS MULTIPLE RESULTS############
class MultipleDataParsed
	attr_accessor :Type, :Name, :Destination, :Country, :AdditionalsParameters
end

class AdditionalsParameters
	attr_accessor :Destination, :DestinationID, :IDE
end
###########################################################################################


##################TO RETURN THE DATA WHEN AVAILABILITY RETURNS A UNIQUE RESULT#############
class UniqueDataParsed
	attr_accessor :obj, :TotalDestinationHotels, :AvailablesHotel, :SessionID, :Hotels
end

class Hotel
	#######Optional#######
	attr_accessor :Category, :City, :Latitud, :Longitud, :Photo, :ImportantNote
	#######Required#######
	attr_accessor :HotelDetails, :Rooms
end

class HotelDetails < IdName
	attr_accessor :NameOriginal
end

class Photo
	attr_accessor :Width, :Height, :URL
end

class Room
	attr_accessor :RoomType, :Boards
end

class RoomType < IdName
	attr_accessor :Amenities, :NumberRooms
end

class Board
	attr_accessor :IDItem, :Board_type, :Currency, :Price, :PriceAgency, :DirectPayment, :DATOS,
				  :StrokePrice, :Offer, :Refundable
end
###########################################################################################

################TO RETURN THE DATA FOR ADDITIONAL INFORMATION##############################
class AdditionalInformationParsed
	attr_accessor :HotelDetails, :SearchAvailabilityDetails, :AgencyBalance, :AdditionalInformation,
				  :PVP, :PriceAgency, :Rates	
end

class HotelDetails < IdName
	attr_accessor :Category, :Address, :City, :Location, :Photo
end

class Location
	attr_accessor :Country, :Destination, :Zone
end

class SearchAvailabilityDetails
	attr_accessor :Check_in_date, :Check_in_day_of_week, :Check_out_date, :Check_out_day_of_week,
				  :Days, :RoomID, :Occupancies, :RoomNames, :BoardID, :BoardName  
end

class Occupancy
	attr_accessor :Rooms, :Adults, :Children, :Ages
end

class RoomName
	attr_accessor :numberOfRooms, :RoomID, :Name
end

class AgencyBalance
	attr_accessor :Balance, :Credit, :AmountAvailable
end

class AdditionalInformation
	attr_accessor :status, :CommentsAllow, :onRequest, :Rooms, :CancellationPeriod, :Supplements, 
				  :Discounts, :Offers, :EssentialInformation, :fechaInicioCancelacion, :horaInicioCancelacion,
				  :fechaLimiteSinGastos, :horaLimiteSinGastos, :PaymentTypes 
end

class RoomAdditional
	attr_accessor :RoomID, :From, :To, :numberOfRooms, :Adults, :Children, :BoardID, :Price, :PriceAgency
end

class CancellationPeriod
	attr_accessor :From, :To, :Hour, :Amount, :PriceAgency
end

class SupplementOrDiscount
	attr_accessor :From, :To, :Obligatory, :Type, :Description, :Paxes_number, :Price, :PriceAgency
end

class Offer
	attr_accessor :Name, :Description
end

class Information
	attr_accessor :From, :To, :Description
end

class PaymentType
	attr_accessor :code, :Name
end

class Rate
	attr_accessor :DATOS, :IDHotel, :Price, :PriceAgency, :RefundableCode, :AdditionalInformation
end
###########################################################################################

##############TO PERFORM AND PARSE A BOOKING CONFIRMATION##################################
class Client
	attr_accessor :name, :surnames, :documentNumber, :country, :region, :EMail, :PostCode, :Phone
end

class Company
	attr_accessor :nameCompany, :cifCompany, :addressCompany, :postalCodeCompany,
				  :ProvinceCompany, :regionCompany
end

class BookingConfirmationParsed
	attr_accessor :ReservationStatus, :PaymentStatus, :ConfirmationStatus, :BookingID,
				  :SecurityCode, :ERROR, :Errors
end 

class Error
	attr_accessor :type, :message
end
###########################################################################################

##############TO PARSE HOTEL AVAILABILITY DETAILS##########################################
class HotelAvailabilityDetailsParsed
	attr_accessor :SessionID, :SearchAvailabilityParameters, :Hotel
end

class SearchAvailabilityParameters
	attr_accessor :Check_in_date, :Check_out_date, :Location, :Occupancies
end
###########################################################################################

