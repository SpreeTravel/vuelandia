require 'nokogiri'
require_relative 'classes'

module Vuelandia
	class Parser
		def parse_search_availability(search_availability, type: :string)
			if type == :file
				doc = File.open(search_availability) { |f| Nokogiri::XML(f) }
			else
				doc = Nokogiri::XML(search_availability)
			end
			if doc.at_css('MultiplesResults')
				data = parse_search_availability_multiple(doc)	
				return { multiple: true, data: data }
			else
				data = parse_search_availability_unique(doc)	
				return { multiple: false, data: data }
			end
		end

		private
		def parse_search_availability_multiple(doc)
			data = []
			doc.css('Result').each do |res|
				result = MultipleData.new
				result.Type = res.at_css('Type').content
				result.Name = res.at_css('Name').content
				unless res.at_css('Destination').nil?
					result.Destination = res.at_css('Destination').content
				end
				result.Country = res.at_css('Country').content
				additional = AdditionalsParameters.new
				res.at_css('AdditionalsParameters') do |ap|
					additional.Destination = ap.at_css('Destination').content
					additional.DestinationID = ap.at_css('DestinationID').content
					additional.IDE = ap.at_css('IDE').content
				end
				result.AdditionalsParameters = additional
				data << result
			end
		end

		def parse_search_availability_unique(doc)
			doc = doc.at_css('Response')
			data = UniqueData.new
			data.obj = doc.at_css('obj').content
			data.TotalDestinationHotels = doc.at_css('TotalDestinationHotels').content
			data.AvailablesHotel = doc.at_css('AvailablesHotel').content
			data.SessionID = doc.at_css('SessionID').content
			if data.AvailablesHotel.to_i > 0
				data.Hotels = []
				#######Iterating over the hotels########
				doc = doc.at_css('Hotels')
				doc.css('Hotel').each do |h|
					hotel = Hotel.new
					######Setting HotelDetails######
					hd = h.at_css('HotelDetails') 
					hotel_details = HotelDetails.new 
					hotel_details.ID = hd.at_css('ID').content
					hotel_details.Name = hd.at_css('Name').content
					unless hd.at_css('NameOriginal').nil?
						hotel_details.NameOriginal = hd.at_css('NameOriginal').content 
					end
					hotel.HotelDetails = hotel_details

					#####Setting optional parameters that only appear when information was requested######
					cat = h.at_css('Category')
					unless cat.nil?
						category = Category.new
						category.ID = cat.at_css('ID').content
						category.Name = cat.at_css('Name').content
						hotel.Category = category
					end
					unless h.at_css('City').nil?
						hotel.City = h.at_css('City').content
					end
					unless h.at_css('Latitud').nil?
						hotel.Latitud = h.at_css('Latitud').content
					end
					unless h.at_css('Longitud').nil?
						hotel.Longitud = h.at_css('Longitud').content
					end
					photo = h.at_css('Photo')
					unless photo.nil?
						photog = Photo.new
						photog.Width = photo.at_css('Width').content
						photog.Height = photo.at_css('Height').content
						photog.URL = photo.at_css('URL').content
						hotel.Photo = photog
					end
					unless h.at_css('ImportantNote').nil?
						hotel.ImportantNote = h.at_css('ImportantNote').content
					end

					a = h.at_css('Accommodations')
					a.css('Room').each do |r|
						
					end					
					
					data.Hotels << hotel
				end
			end
			data
		end	
		
		public
		def parse_all_destinations_list(all_destinations_list, type: :string)
			if type == :file
				doc = File.open(all_destinations_list) { |f| Nokogiri::XML(f) }
			elsif type == :string
				doc = Nokogiri::XML(all_destinations_list)
			end
			#######data is an array of Country#########
			#each Country has an ID, a Name and Destinations, where Destinations is a Destination array
			#each Destination has an ID, a Name and Zones, where Zones is a Zone array
			#each Zone has an ID and a Name 
			data = []
			doc.css('Country').each do |c|
				country = Country.new
				country.ID = c.at_css('ID').content
				country.Name = c.at_css('Name').content
				country.Destinations = []				
				dest = c.at_css('Destinations')
				unless dest.nil? || dest.children.empty?
					dest.css('Destination').each do |d|
						destination = Destination.new
						destination.ID = d.at_css('ID').content
						destination.Name = d.at_css('Name').content
						destination.Zones = []
						zon = d.at_css('Zones')
						unless zon.nil? || zon.children.empty? 
							zon.css('Zone').each do |z|
								zone = Zone.new
								zone.ID = z.at_css('ID').content
								zone.Name = z.at_css('Name').content
								destination.Zones << zone
							end
						end
						country.Destinations << destination
					end
				end
				data << country
			end
			data
		end
	end
end