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
				cat = IDName.new
					css_cat = css_hd.at_css('Category')
					cat.ID = css_cat.at_css('ID').content
					cat.Name = css_cat.at_css('Name').content
				hd.Category = cat
				hd.Address = css_hd.at_css('Address').content
				hd.City = css_hd.at_css('City').content
				loc = Location.new
					css_loc = css_hd.at_css('Location')
					loc_country = IDName.new
						css_loc_country = css_loc.at_css('Country')
						loc_country.ID = css_loc_country.at_css('ID').content
						loc_country.Name = css_loc_country.at_css('Name').content
					loc.Country = loc_country
						
					loc_destination = IDName.new
						css_loc_destination = css_loc.at_css('Destination')
						loc_destination.ID = css_loc_destination.at_css('ID').content
						loc_destination.Name = css_loc_destination.at_css('Name').content
					loc.Destination = loc_destination
			
					loc_zone = IDName.new
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

		def parse_booking_confirmation(booking_confirmation, type: :string)
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

		def parse_hotel_availability_details(hotel_availability_details, type: :string)
			doc = to_nokogiri(hotel_availability_details, type)
			data = HotelAvailabilityDetailsParsed.new
			data.SessionID = doc.at_css('SessionID').content
			sap = SearchAvailabilityParameters.new
				css_sap = doc.at_css('SearchAvailabilityParameters')
				sap.Check_in_date = css_sap.at_css('Check_in_date').content
				sap.Check_out_date = css_sap.at_css('Check_out_date').content
				loc = IDName.new
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
								oc.Ages << a.content
							end
						end
					sap.Occupancies << oc					
				end
			data.SearchAvailabilityParameters = sap
			data.Hotel = parse_detailed_hotel(doc.at_css('Hotel'))
			data.SessionHotels = []
				unless doc.at_css('SessionHotels').at_css('Hotels').nil?
					doc.at_css('SessionHotels').at_css('Hotels').css('Hotel').each do |h|
						data.SessionHotels << parse_detailed_hotel(h)
					end
				end
			data
		end

		def parse_voucher(voucher, type: :string)
			doc = to_nokogiri(voucher, type)
			data = VoucherParsed.new
				css_doc = doc.at_css('Booking')
				data.id = css_doc['id']
				data.BookingStatus = css_doc.at_css('BookingStatus').content
				unless css_doc.at_css('BookingModificationStatus').nil?
					data.BookingModificationStatus = css_doc.at_css('BookingModificationStatus').content
				end
				unless css_doc.at_css('Locator').nil?
					data.Locator = css_doc.at_css('Locator').content
				end
				unless css_doc.at_css('AgencyReference').nil?
					data.AgencyReference = css_doc.at_css('AgencyReference').content
				end
				data.CreationDate = css_doc.at_css('CreationDate').content
				data.CheckInDate = css_doc.at_css('CheckInDate').content
				data.CheckOutDate = css_doc.at_css('CheckOutDate').content
				data.Price = css_doc.at_css('Price').content
				data.NetPrice = css_doc.at_css('NetPrice').content
				unless css_doc.at_css('CancellationFeeDate').nil?
					data.CancellationFeeDate = css_doc.at_css('CancellationFeeDate').content
				end
				unless css_doc.at_css('CancellationDate').nil?
					data.CancellationDate = css_doc.at_css('CancellationDate').content
				end
				unless css_doc.at_css('CancellationTime').nil?
					data.CancellationTime = css_doc.at_css('CancellationTime').content
				end
				unless css_doc.at_css('CancellationPrice').nil?
					data.CancellationPrice = css_doc.at_css('CancellationPrice').content
				end
				data.CustomerName = css_doc.at_css('CustomerName').content
				data.Hotel = IDName.new
					data.Hotel.ID = css_doc.at_css('Hotel')['id']
					data.Hotel.Name = css_doc.at_css('Hotel').content
				data.City = css_doc.at_css('City').content
				data.Zone = IDName.new
					data.Zone.ID = css_doc.at_css('Zone')['id']
					data.Zone.Name = css_doc.at_css('Zone').content
				data.Destination = IDName.new
					data.Destination.ID = css_doc.at_css('Destination')['id']
					data.Destination.Name = css_doc.at_css('Destination').content
				data.Country = IDName.new
					data.Country.ID = css_doc.at_css('Country')['id']
					data.Country.Name = css_doc.at_css('Country').content
				data.Comments = []
					css_doc.at_css('Comments').css('Comment').each do |c|
						com = Comment.new
						com.type = c['type']
						com.fromdate = c['fromdate']
						com.todate = c['todate']
						com.Text = c.content
						data.Comments << com
					end
				data.Payment = css_doc.at_css('Payment')['type']
				data.Rooms = []
					css_doc.at_css('Rooms').css('Room').each do |r|
						room = VoucherRoom.new
						room.roomsNumber = r['roomsNumber']
						room.CheckInDate = r.at_css('CheckInDate').content
						room.CheckOutDate = r.at_css('CheckOutDate').content
						room.Adults = r.at_css('Adults')['number']
						room.Children = r.at_css('Children')['number']
						room.ChildAges = []
							r.at_css('Children').css('Child').each do |ca|
								room.ChildAges << ca['Age']
							end
						unless r.at_css('Babies').nil?
							room.Babies = r.at_css('Babies')['number']
						end
						room.RoomType = IDName.new
							room.RoomType.ID = r.at_css('RoomType')['id']
							room.RoomType.Name = r.at_css('RoomType').content
						room.Amenities = []
							unless r.at_css('Amenities').nil?
								r.at_css('Amenities').css('Amenity').each do |a|
									am = IDName.new
										am.ID = a['id']
										am.Name = a.content
									room.Amenities << am
								end
							end
						room.CompleteRoomName = r.at_css('CompleteRoomName').content
						room.BoardType = IDName.new
							room.BoardType.ID = r.at_css('BoardType')['id']
							room.BoardType.Name = r.at_css('BoardType').content
						room.Price = r.at_css('Price')
						data.Rooms << room
					end
				data.Supplements = []
					unless css_doc.at_css('Supplements').nil?
						css_doc.at_css('Supplements').css('Supplement').each do |s|
							sup = SupplementOrDiscount.new
							sup.id = s['id']
							sup.Type = s['type']
							sup.paymenttype = s['paymenttype']
							sup.Obligatory = s['obligatory']
							sup.From = s.at_css('FromDate').content
							sup.To = s.at_css('ToDate').content
							sup.Description = s.at_css('Description').content
							sup.Price = s.at_css('Price').content
							data.Supplements << sup
						end
					end
				data.Offers = []
					unless css_doc.at_css('Offers').nil?
						css_doc.at_css('Offers').css('Offer').each do |o|
							off = SupplementOrDiscount.new
							off.id = o['id']
							off.From = o.at_css('FromDate').content
							off.To = o.at_css('ToDate').content
							off.Description = o.at_css('Description').content
							unless o.at_css('Price').nil?
								off.Price = o.at_css('Price').content
							end
							data.Offers << off
						end
					end
				data.CancellationPolicies = []
					css_doc.at_css('CancellationPolicies').css('CancellationPolicy').each do |cp|
						canc = CancellationPolicy.new
						canc.From = cp.at_css('FromDate').content		
						canc.To = cp.at_css('ToDate').content		
						canc.Time = cp.at_css('Time').content		
						canc.Price = cp.at_css('Price').content		
						data.CancellationPolicies << canc
					end
				data.HotelAddress = css_doc.at_css('HotelAddress').content
				data.HotelZipCode = css_doc.at_css('HotelZipCode').content
				data.HotelTelephoneNumber = css_doc.at_css('HotelTelephoneNumber').content
				unless css_doc.at_css('HotelMap').nil?
					data.HotelMap = css_doc.at_css('HotelMap').content
				end
				data.HotelCategory = IDName.new
					data.HotelCategory.ID = css_doc.at_css('HotelCategory')['id']
					data.HotelCategory.Name = css_doc.at_css('HotelCategory').content
				sp = ServiceProvider.new
					css_sp = css_doc.at_css('ServiceProvider')
					sp.ID = css_sp['id']
					sp.Name = css_sp.at_css('Name').content
					sp.FiscalIdentificationCode = css_sp.at_css('FiscalIdentificationCode').content
					sp.City = css_sp.at_css('City').content
					sp.Country = IDName.new
						sp.Country.ID = css_sp.at_css('Country')['id']
						sp.Country.Name = css_sp.at_css('Country').content
					unless css_sp.at_css('Address').nil?
						sp.Address = css_sp.at_css('Address').content
					end
					unless css_sp.at_css('ZipCode').nil?
						sp.ZipCode = css_sp.at_css('ZipCode').content
					end
					sp.Email = css_sp.at_css('Email').content
					sp.TelephoneNumbers = []
						css_sp.css('TelephoneNumber').each do |tn|
							tel = TelephoneOrFaxNumber.new
							tel.CountryCode = tn.at_css('CountryCode').content
							tel.Number = tn.at_css('Number').content
							sp.TelephoneNumbers << tel
						end
					sp.FaxNumbers = []
						css_sp.css('FaxNumber').each do |fn|
							fax = TelephoneOrFaxNumber.new
							fax.CountryCode = fn.at_css('CountryCode').content
							fax.Number = fn.at_css('Number').content
							sp.TelephoneNumbers << fax
						end
					unless css_sp.at_css('Logo').nil?
						sp.Logo = css_sp.at_css('Logo').content
					end
				data.ServiceProvider = sp
				ra = RetailAgency.new
					css_ra = css_doc.at_css('RetailAgency')
					ra.ID = css_ra['id']
					ra.Name = css_ra.at_css('Name').content
					ra.CustomerServiceTelephoneNumber = css_ra.at_css('CustomerServiceTelephoneNumber').content
					ra.CustomerServiceHours = css_ra.at_css('CustomerServiceHours').content
					ra.Logo = css_ra.at_css('Logo').content
					ra.VoucherStamp = css_ra.at_css('VoucherStamp').content
				data.RetailAgency = ra
				data.VoucherLogo = css_doc.at_css('VoucherLogo').content
				data.SecondVoucherLogo = css_doc.at_css('SecondVoucherLogo').content
				data.VoucherStamp = css_doc.at_css('VoucherStamp').content
				data.PayableBy = PayableBy.new
					data.PayableBy.Name = css_doc.at_css('PayableBy').at_css('Name').content
					data.PayableBy.FiscalIdentificationCode = css_doc.at_css('PayableBy').at_css('FiscalIdentificationCode').content
				data.OtherFields = []
					css_doc.at_css('OtherFields').css('Field').each do |f|
						field = OtherField.new
						field.Name = f.at_css('Name').content
						field.Value = f.at_css('Value').content
						data.OtherFields << field
					end
			data			
		end

		def parse_booking_cancellation(booking_cancellation, type: :string)
			doc = to_nokogiri(booking_cancellation, type)
			data = BookingCancelationParsed.new
				data.BookingStatus = doc.at_css('BookingStatus').content
				data.HotelName = doc.at_css('HotelName').content
				data.BookingPrice = doc.at_css('BookingPrice').content
				data.CheckInDate = doc.at_css('CheckInDate').content
				data.CheckOutDate = doc.at_css('CheckOutDate').content
				data.Rooms = []
					doc.at_css('Rooms').css('Room').each do |r|
						room = VoucherRoom.new
						room.roomsNumber = r['roomsNumber']
						room.CheckInDate = r.at_css('CheckInDate').content
						room.CheckOutDate = r.at_css('CheckOutDate').content
						room.Adults = r.at_css('Adults')['number']
						room.Children = r.at_css('Children')['number']
						room.ChildAges = []
							r.at_css('Children').css('Child').each do |ca|
								room.ChildAges << ca['Age']
							end
						unless r.at_css('Babies').nil?
							room.Babies = r.at_css('Babies')['number']
						end
						room.RoomType = IDName.new
							room.RoomType.ID = r.at_css('RoomType')['id']
							room.RoomType.Name = r.at_css('RoomType').content
						room.Amenities = []
							unless r.at_css('Amenities').nil?
								r.at_css('Amenities').css('Amenity').each do |a|
									am = IDName.new
										am.ID = a['id']
										am.Name = a.content
									room.Amenities << am
								end
							end
						room.CompleteRoomName = r.at_css('CompleteRoomName').content
						room.BoardType = IDName.new
							room.BoardType.ID = r.at_css('BoardType')['id']
							room.BoardType.Name = r.at_css('BoardType').content
						unless r.at_css('Offer').nil?
							room.Offer = IDName.new
							room.Offer.ID = r.at_css('Offer')['id']
							room.Offer.Name = r.at_css('Offer').content
						end
						room.Price = r.at_css('Price')
						data.Rooms << room
					end
				data.FechaAnulacionSinGastos = doc.at_css('FechaAnulacionSinGastos').content
				data.CancellationPolicies = []
					doc.at_css('CancellationPolicies').css('CancellationPolicy').each do |cp|
						canc = CancellationPolicy.new
						canc.From = cp.at_css('FromDate').content		
						canc.Time = cp.at_css('Time').content		
						canc.Price = cp.at_css('Price').content		
						data.CancellationPolicies << canc
					end
				unless doc.at_css('CancellationPrice')
					data.CurrentCancellationPrice = doc.at_css('CurrentCancellationPrice').content
				end
				unless doc.at_css('CancellationPrice')
					data.CancellationPrice = doc.at_css('CancellationPrice').content
				end
				doc.at_css('ERROR').nil? ? data.ERROR = 0 : data.ERROR = 1
				data.Errors = []
				unless doc.at_css('Errors').nil?
					doc.at_css('Errors').css('Error').each do |e|
						data.Errors << e.content
					end
				end
			data
		end

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
								zone = IDName.new
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
				File.open(document) { |f| Nokogiri::XML(f) }
			else
				Nokogiri::XML(document)
			end
		end

		def parse_detailed_hotel(css)
			hotel = DetailedHotel.new
				hd = DetailedHotelDetails.new
					css_hd = css.at_css('HotelDetails')
					hd.ID = css_hd.at_css('ID').content
					hd.Name = css_hd.at_css('Name').content
					hd.Category = IDName.new
					hd.Category.ID = css_hd.at_css('Category').at_css('ID').content
					hd.Category.Name = css_hd.at_css('Category').at_css('Name').content
					hd.Address = css_hd.at_css('Address').content
					hd.City = css_hd.at_css('City').content
					loc = Location.new
						loc.Country = IDName.new
						loc.Destination = IDName.new
						loc.Zone = IDName.new
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
					unless css_hd.at_css('Description').nil?
						hd.Description = css_hd.at_css('Description').content
					end
					hd.Photo = Photo.new
					hd.Photo.Width = css_hd.at_css('Photo').at_css('Width').content
					hd.Photo.Height = css_hd.at_css('Photo').at_css('Height').content
					hd.Photo.URL = css_hd.at_css('Photo').at_css('URL').content
					unless css_hd.at_css('Notes').nil? 
						hd.Notes = []
							css_hd.at_css('Notes').css('Note').each do |n|
								note = Note.new
								note.Type = n['type']
								note.Text = n.content
								hd.Notes << note
							end
					end
					unless css_hd.at_css('ImportantNote').nil?
						hd.ImportantNote = css_hd.at_css('ImportantNote').content
					end 
					unless css_hd.at_css('Photos').nil?
						hd.Photos = []
							css_hd.at_css('Photos').css('Photo').each do |p|
								photo = Photo.new
								photo.Width = p.at_css('Width').content
								photo.Height = p.at_css('Height').content
								photo.URL = p.at_css('URL').content
								hd.Photos << photo
							end
					end
					unless css_hd.at_css('ServicesFacilities').nil?
						hd.ServicesFacilities = []
							css_hd.at_css('ServicesFacilities').css('Service').each do |s|
								service = Service.new
								service.Type = s.at_css('Type').content
								service.Name = s.at_css('Name').content
								service.Value = s.at_css('Value').content
								service.AdditionalCharges = s.at_css('AdditionalCharges').content
								hd.ServicesFacilities << service
							end
					end
					unless css_hd.at_css('CharacteristicsFacilities').nil?
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
					end
				hotel.HotelDetails = hd
				unless css.at_css('obj').nil?
					hotel.obj = css.at_css('obj').content
				end
				unless css.at_css('Accomodations').nil?
					hotel.Accommodations = []
						css.at_css('Accomodations').css('Room').each do |r|
							room = DetailedRoom.new
								rt = RoomType.new
									css_rt = r.at_css('RoomType')
									rt.ID = css_rt.at_css('ID').content
									rt.Name = css_rt.at_css('Name').content
									rt.NumberRooms = css_rt.at_css('NumberRooms').content
									rt.Amenities = []
									unless r.at_css('RoomType').at_css('Amenities').nil?
										r.at_css('RoomType').at_css('Amenities').css('Amenity').each do |a|
											rt.Amenities << a.at_css('ID').content
										end
									end
								room.RoomType = rt
								room.Boards = []
									r.css('Board').each do |b|
										board = Board.new
											board.Board_type = IDName.new
											board.Board_type.ID = b.at_css('Board_type').at_css('ID').content
											board.Board_type.Name = b.at_css('Board_type').at_css('Name').content
											board.Currency = b.at_css('Currency').content
											board.Price = b.at_css('Price').content
											board.PriceAgency = b.at_css('PriceAgency').content
											board.DirectPayment = b.at_css('DirectPayment').content
											board.DATOS = b.at_css('DATOS').content
											board.StrokePrice = b.at_css('StrokePrice').content
											board.Offer = b.at_css('Offer').content
										room.Boards << board
									end
							hotel.Accomodations << room
						end
				end
			hotel
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
						category = IDName.new
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
									amenity = IDName.new
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