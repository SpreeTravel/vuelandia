require 'nokogiri'
require_relative 'classes'

module Vuelandia
	class Parser
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
				cat = IdName.new
					css_cat = css_hd.at_css('Category')
					cat.ID = css_cat.at_css('ID').content
					cat.Name = css_cat.at_css('Name').content
				hd.Category = cat
				hd.Address = css_hd.at_css('Address').content
				hd.City = css_hd.at_css('City').content
				loc = Location.new
					css_loc = css_hd.at_css('Location')
					loc_country = IdName.new
						css_loc_country = css_loc.at_css('Country')
						loc_country.ID = css_loc_country.at_css('ID').content
						loc_country.Name = css_loc_country.at_css('Name').content
					loc.Country = loc_country
						
					loc_destination = IdName.new
						css_loc_destination = css_loc.at_css('Destination')
						loc_destination.ID = css_loc_destination.at_css('ID').content
						loc_destination.Name = css_loc_destination.at_css('Name').content
					loc.Destination = loc_destination
			
					loc_zone = IdName.new
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
				sad.Occupancies = []
				css_sad.css('Occupancy').each do |o|
					oc = Occupancy.new
						oc.Rooms = o.at_css('Rooms').content
						oc.Adults = o.at_css('Adults').content
						oc.Children = o.at_css('Children').content
						oc.Ages = []
						unless o.at_css('Ages').nil?
							o.at_css('Ages').css('Age').each do |a|
								o.Ages << a.content
							end
						end
					sad.Occupancies << oc					
				end
				sad.RoomNames = []
				css_sad.css('RoomName').each do |r|
					rn = RoomName.new
						rn.numberOfRooms = r['numberOfRooms']
						rn.RoomID = r['RoomID']
						rn.Name = r.content
					sad.RoomNames << rn
				end
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
			data.AdditionalInformation = parse_additional_information_attribute(doc.at_css('AdditionalInformation'))
			data.PVP = doc.at_css('PVP').content
			data.PriceAgency = doc.at_css('PriceAgency').content
			css_rates = doc.at_css('Rates')
			unless css_rate.nil?
				data.Rates = []
				css_rates.css('Rate').each do |r|
					rate = Rate.new
						rate.DATOS = css_rate.at_css('DATOS').content
						rate.IDHotel = css_rate.at_css('IDHotel').content
						rate.Price = css_rate.at_css('Price').content
						rate.PriceAgency = css_rate.at_css('PriceAgency').content
						rate.RefundableCode = css_rate.at_css('RefundableCode').content
						rate.AdditionalInformation = parse_additional_information_attribute(css_rate.at_css('AdditionalInformation'))
					data.Rates << rate
				end
			end
			data
		end

		def parse_booking_confirmation(booking_confirmation, type)
			doc = to_nokogiri(booking_confirmation, type)
			data = BookingConfirmationParsed.new
			data.ReservationStatus = doc.at_css('ReservationStatus').content
			data.PaymentStatus = doc.at_css('PaymentStatus').content
			data.ConfirmationStatus = doc.at_css('ConfirmationStatus').content
			data.BookingID = doc.at_css('BookingID').content
			data.SecurityCode = doc.at_css('SecurityCode').content
			data.ERROR = doc.at_css('ERROR').nil? ? 0 : 1
			data.Errors = []
			unless doc.at_css('Errors').nil?
				doc.at_css('Errors').css('Error').each do |e|
					error = Error.new
					error.type = e['type']
					error.message = e.content
					data.Errors << error
				end
			end
			data
		end

		def parse_hotel_availability_details(hotel_availability_details, type)
			doc = to_nokogiri(hotel_availability_details, type)
			data = HotelAvailabilityDetailsParsed.new
			data.SessionID = doc.at_css('SessionID').content
			sap = SearchAvailabilityParameters.new
				css_sap = doc.at_css('SearchAvailabilityParameters')
				sap.Check_in_date = css_sap.at_css('Check_in_date').content
				sap.Check_out_date = css_sap.at_css('Check_out_date').content
				loc = IdName.new
					loc.ID = css_sap.at_css('Location').at_css('DestinationID').content
					loc.Name = css_sap.at_css('Location').at_css('DestinationID').content
				sap.Location = loc
				sap.Occupancies = []
				css_sap.css('Occupancy').each do |o|
					oc = Occupancy.new
						oc.Rooms = o.at_css('Rooms').content
						oc.Adults = o.at_css('Adults').content
						oc.Children = o.at_css('Children').content
						oc.Ages = []
						unless o.at_css('Ages').nil?
							o.at_css('Ages').css('Age').each do |a|
								o.Ages << a.content
							end
						end
					sap.Occupancies << oc					
				end
			data.SearchAvailabilityParameters = sap
			hotel = DetailedHotel.new
				css_hotel = doc.at_css('Hotel')
				hd = DetailedHotelDetails.new
					css_hd = css_hotel.at_css('HotelDetails')
					hd.ID = css_hd.at_css('ID').content
					hd.Name = css_hd.at_css('Name').content
					hd.Category = IdName.new
					hd.Category.ID = css_hd.at_css('Category').at_css('ID').content
					hd.Category.Name = css_hd.at_css('Category').at_css('Name').content
					hd.Address = css_hd.at_css('Address').content
					hd.City = css_hd.at_css('City').content
					loc = Location.new
						loc.Country = IdName.new
						loc.Destination = IdName.new
						loc.Zone = IdName.new
						css_loc = css_hd.at_css('Location')
						loc.Country.ID = css_loc.at_css('Country').at_css('ID').content	
						loc.Country.Name = css_loc.at_css('Country').at_css('Name').content	
						loc.Destination.ID = css_loc.at_css('Destination').at_css('ID').content	
						loc.Destination.Name = css_loc.at_css('Destination').at_css('Name').content	
						loc.Zone.ID = css_loc.at_css('Zone').at_css('ID').content	
						loc.Zone.Name = css_loc.at_css('Zone').at_css('Name').content	
					hd.Location = loc
					hd.Latitud = css_hd.at_css('Latitud').content
					hd.Longitud = css_hd.at_css('Longitud').content
					hd.Description = css_hd.at_css('Description').content
					hd.Photo = Photo.new
					hd.Photo.Width = css_hd.at_css('Photo').at_css('Width').content
					hd.Photo.Height = css_hd.at_css('Photo').at_css('Height').content
					hd.Photo.URL = css_hd.at_css('Photo').at_css('URL').content
					hd.Notes = []
						css_hd.at_css('Notes').css('Note').each do |n|
							note = Note.new
							note.Type = n['type']
							note.Text = n.content
							hd.Notes << note
						end
					hd.Photos = []
						css_hd.at_css('Photos').css('Photo').each do |p|
							photo = Photo.new
							photo.Width = p.at_css('Width').content
							photo.Height = p.at_css('Height').content
							photo.URL = p.at_css('URL').content
							hd.Photos << photo
						end
					hd.ServicesFacilities = []
						css_hd.at_css('ServicesFacilities').css('Service').each do |s|
							service = Service.new
							service.Type = s.at_css('Type').content
							service.Name = s.at_css('Name').content
							service.Value = s.at_css('Value').content
							service.AdditionalCharges = s.at_css('AdditionalCharges').content
							hd.ServicesFacilities << service
						end
					hd.CharacteristicsFacilities = []
						css_hd.at_css('CharacteristicsFacilities').css('Characteristic').each do |c|
							characteristic = Characteristic.new
							characteristic.ID = c.at_css('ID').content
							characteristic.Type = c.at_css('Type').content
							characteristic.TypeID = c.at_css('TypeID').content
							characteristic.Name = c.at_css('Name').content
							characteristic.Value = c.at_css('Value').content
							characteristic.AdditionalCharges = c.at_css('AdditionalCharges').content
							hd.CharacteristicsFacilities << characteristic
						end
				hotel.HotelDetails = hd
				
			data.Hotel = hotel
			
			data
		end

		def parse_all_destinations_list(all_destinations_list, type: :string)
			doc = to_nokogiri(all_destinations_list, type)
			data = []
			doc.css('Country').each do |c|
				country = IdName.new
				country.ID = c.at_css('ID').content
				country.Name = c.at_css('Name').content
				country.Destinations = []				
				dest = c.at_css('Destinations')
				unless dest.nil? || dest.children.empty?
					dest.css('Destination').each do |d|
						destination = IdName.new
						destination.ID = d.at_css('ID').content
						destination.Name = d.at_css('Name').content
						destination.Zones = []
						zon = d.at_css('Zones')
						unless zon.nil? || zon.children.empty? 
							zon.css('Zone').each do |z|
								zone = IdName.new
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
						category = IdName.new
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
									amenity = IdName.new
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

		#this method parses the AdditionalInformation of AdditionalInformationParsed
		#is a separate method because Rates attribute also needs it and we like to follow
		#the DRY principle
		def parse_additional_information_attribute(css_ai)	
			ai = AdditionalInformation.new
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
			ai
		end
	end
end