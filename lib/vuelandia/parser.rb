require 'nokogiri'
require_relative 'classes'

module Vuelandia
	class Parser
		def parse_all_destinations_list(all_destinations_list, type: :string)
			doc = to_nokogiri(all_destinations_list, type)
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

		def parse_search_availability(search_availability, type: :string)
			doc = to_nokogiri(search_availability, type)
			if doc.at_css('MultiplesResults')
				data = parse_search_availability_multiple(doc)	
				return { multiple: true, data: data }
			else
				data = parse_search_availability_unique(doc)	
				return { multiple: false, data: data }
			end
		end

		def parse_additional_information(additional_information, type: :string)
			doc = to_nokogiri(additional_information, type)
			data = AdditionalInformationParsed.new
			hd = HotelDetails.new
				css_hd = doc.at_css('HotelDetails')
				hd.ID = css_hd.at_css('ID').content
				hd.Name = css_hd.at_css('Name').content
				cat = Category.new
					css_cat = css_hd.at_css('Category')
					cat.ID = css_cat.at_css('ID').content
					cat.Name = css_cat.at_css('Name').content
				hd.Category = cat
				hd.Address = css_hd.at_css('Address').content
				hd.City = css_hd.at_css('City').content
				loc = Location.new
					css_loc = css_hd.at_css('Location')
					loc_country = CountryDestinationZone.new
						css_loc_country = css_loc.at_css('Country')
						loc_country.ID = css_loc_country.at_css('ID').content
						loc_country.Name = css_loc_country.at_css('Name').content
					loc.Country = loc_country
						
					loc_destination = CountryDestinationZone.new
						css_loc_destination = css_loc.at_css('Destination')
						loc_destination.ID = css_loc_destination.at_css('ID').content
						loc_destination.Name = css_loc_destination.at_css('Name').content
					loc.Destination = loc_destination
			
					loc_zone = CountryDestinationZone.new
						css_loc_zone = css_loc.at_css('Zone')
						loc_zone.ID = css_loc_zone.at_css('ID').content
						loc_zone.Name = css_loc_zone.at_css('Name').content
					loc.Zone = loc_zone
				hd.Location = loc
				photo = Photo.new
					css_photo = css_hd.at_css('Photo')
					photo.Width = css_photo.at_css('Width').content
					photo.Height = css_photo.at_css('Height').content
					photo.URL = css_photo.at_css('URL').content
				hd.Photo = photo
			data.HotelDetails = hd
			sad = SearchAvailabilityDetails.new
				css_sad = doc.at_css('SearchAvailabilityDetails')
				sad.Check_in_date = css_sad.at_css('Check_in_date').content
				sad.Check_in_day_of_week = css_sad.at_css('Check_in_day_of_week').content
				sad.Check_out_date = css_sad.at_css('Check_out_date').content
				sad.Check_out_day_of_week = css_sad.at_css('Check_out_day_of_week').content
				sad.Days = css_sad.at_css('Days').content
				sad.RoomID = css_sad.at_css('RoomID').content
				oc = Occupancy.new
					css_oc = css_sad.at_css('Occupancy')
					oc.Rooms = css_oc.at_css('Rooms').content
					oc.Adults = css_oc.at_css('Adults').content
					oc.Children = css_oc.at_css('Children').content
				sad.Occupancy = oc
				rn = RoomName.new
					rn.numberOfRooms = css_sad.at_css('RoomName')['numberOfRooms']
					rn.RoomID = css_sad.at_css('RoomName')['RoomID']
					rn.Name = css_sad.at_css('RoomName').content
				sad.RoomName = rn
				sad.BoardID = css_sad.at_css('BoardID').content
				sad.BoardName = css_sad.at_css('BoardName').content
			data.SearchAvailabilityDetails = sad			
			css_ab = doc.at_css('AgencyBalance')
			unless css_ab.nil? #because is in the sample response but not in the specification
				ab = AgencyBalance.new
				ab.Balance = css_ab.at_css('Balance').content			
				ab.Credit = css_ab.at_css('Credit').content			
				ab.AmountAvailable = css_ab.at_css('AmountAvailablee').content			
			end
			data.AgencyBalance = ab
			ai = AdditionalInformation.new
				css_ai = doc.at_css('AdditionalInformation')
				ai.status = css_ai.at_css('status').content
				ai.CommentsAllow = css_ai.at_css('status').content
				unless css_ai.at_css('onRequest').nil? #in the sample but not in the specification
					ai.onRequest = css_ai.at_css('onRequest').content
				end
				ai.Rooms = []
				css_ai.at_css('Rooms').css('Room').each do |r|
					ra = RoomAdditional.new
					ra.RoomID = r.at_css('RoomID').content				
					ra.From = r.at_css('From').content				
					ra.To = r.at_css('To').content				
					ra.numberOfRooms = r.at_css('numberOfRooms').content				
					ra.Adults = r.at_css('Adults').content				
					ra.numberOfRooms = r.at_css('numberOfRooms').content				
					ra.Children = r.at_css('Children').content				
					ra.BoardID = r.at_css('BoardID').content				
					ra.Price = r.at_css('Price').content				
					ra.PriceAgency = r.at_css('PriceAgency').content				
					ai.Rooms << ra
				end
				cp = CancellationPeriod.new
					css_cp = css_ai.at_css('Cancellation').at_css('Period')
					cp.From = css_cp.at_css('From').content
					cp.To = css_cp.at_css('To').content
					cp.Hour = css_cp.at_css('Hour').content
					cp.Amount = css_cp.at_css('Amount').content
					cp.PriceAgency = css_cp.at_css('PriceAgency').content
				ai.CancellationPeriod = cp
				ai.Supplements = []
					css_ai.at_css('Supplements').css('Supplement').each do |s|
						sup = SupplementOrDiscount.new
						sup.From = s.at_css('From').content
						sup.To = s.at_css('To').content
						sup.Obligatory = s.at_css('Obligatory').content
						sup.Type = s.at_css('Type').content
						sup.Description = s.at_css('Description').content
						sup.Paxes_number = s.at_css('Paxes_number').content
						sup.Price = s.at_css('Price').content
						sup.PriceAgency = s.at_css('PriceAgency').content
						ai.Supplements << sup
					end
				ai.Discounts = []
					css_ai.at_css('Discounts').css('Discount').each do |d|
						disc = SupplementOrDiscount.new
						disc.From = d.at_css('From').content
						disc.To = d.at_css('To').content
						disc.Obligatory = d.at_css('Obligatory').content
						disc.Type = d.at_css('Type').content
						disc.Description = d.at_css('Description').content
						disc.Paxes_number = d.at_css('Paxes_number').content
						disc.Price = d.at_css('Price').content
						disc.PriceAgency = d.at_css('PriceAgency').content
						ai.Discounts << disc
					end
				ai.Offers = []
					css_ai.at_css('Offers').css('Offer').each do |o|
						offer = Offer.new
						offer.Name = o.at_css('Name').content
						offer.Description = o.at_css('Description').content
						ai.Offers << offer
					end
				ai.EssentialInformation = []
					css_ai.at_css('EssentialInformation').css('Information').each do |i|
						info = Information.new
						info.From = i.at_css('From').content
						info.To = i.at_css('To').content
						info.Description = i.at_css('Description').content
						ai.EssentialInformation << info
					end
				ai.fechaInicioCancelacion = css_ai.at_css('fechaInicioCancelacion').content
				ai.horaInicioCancelacion = css_ai.at_css('horaInicioCancelacion').content
				ai.fechaLimiteSinGastos = css_ai.at_css('fechaLimiteSinGastos').content
				ai.horaLimiteSinGastos = css_ai.at_css('horaLimiteSinGastos').content
				ai.PaymentTypes = []
				css_ai.at_css('PaymentTypes').css('Type').each do |t|
						type = PaymentType.new
						type.code = t['code']
						type.Name = t.content
						ai.PaymentTypes << type
					end
			data.AdditionalInformation = ai
			data.PVP = doc.at_css('PVP').content
			data.PriceAgency = doc.at_css('PriceAgency').content
			###TODO Rates###
			data
		end

		private
		def to_nokogiri(document, type)
			if type == :file
				File.open(additional_information) { |f| Nokogiri::XML(f) }
			else
				Nokogiri::XML(additional_information)
			end
		end

		def parse_search_availability_multiple(doc)
			data = []
			doc.css('Result').each do |res|
				result = MultipleDataParsed.new
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
			data = UniqueDataParsed.new
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

					######Setting Rooms########
					a = h.at_css('Accommodations')
					hotel.Rooms = []
					a.css('Room').each do |r|
						room = Room.new

						######Setting RoomType#######
						rt = r.at_css('RoomType')
						room_type = RoomType.new
						room_type.ID = rt.at_css('ID').content
						room_type.Name = rt.at_css('Name').content
						room_type.NumberRooms = rt.at_css('NumberRooms').content
						am = rt.at_css('Amenities')
						unless am.nil?
							room_type.Amenities = []
							am = am.css('Amenity')
							unless am.nil?
								am.each do |a|
									amenity = Amenity.new
									amenity.ID = a.at_css('ID').content
									unless a.at_css('Name').nil?
										amenity.Name = a.at_css('Name').content
									end
									room_type.Amenities << amenity
								end
							end							
						end
						room.RoomType = room_type
						###############################

						#######Setting Boards##########
						room.Boards = []
						r.css('Board').each do |b|
							board = Board.new
							unless b.at_css('IDItem').nil?
								board.IDItem = b.at_css('IDItem').content
							end
							board.Board_type = b.at_css('Board_type').at_css('ID').content
							board.Currency = b.at_css('Currency').content
							board.Price = b.at_css('Price').content
							board.PriceAgency = b.at_css('PriceAgency').content
							board.DirectPayment = b.at_css('DirectPayment').content
							board.DATOS = b.at_css('DATOS').content
							unless b.at_css('StrokePrice').nil?
								board.StrokePrice = b.at_css('StrokePrice').content
							end
							board.Offer = b.at_css('Offer').content
							board.Refundable = b.at_css('Refundable').content
							room.Boards << board
						end
						###############################

						hotel.Rooms << room
					end					
					
					data.Hotels << hotel
				end
			end
			data
		end	
	end
end