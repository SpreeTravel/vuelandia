The `vuelandia` gem interfaces with the [Vuelandia.com](http://www.vuelandia.com/) API to search for and book hotel rooms.

## Installation

I'm sure you know how to install Ruby gems by now...

In your Gemfile, before a `bundle install`, add:

    gem "vuelandia", "~> X.X.X"

**Note:** you'll need to replace `X.X.X` in the example above with the [latest gem version](https://rubygems.org/gems/vuelandia) visible in the badge above.

Manually, via command line:
	
    gem install vuelandia

## Available queries

- `perform_search_availability`
	- Parameters
		- Required
			- `:destination`
			- `:check\_in\_date` (format: 'YYYY-MM-DD')
			- `:check\_out\_date` (format: 'YYYY-MM-DD')
			- `:occupancies`
		- Optional
			- `:language`
			- `:hotel_list`
			- `:destination_id`
			- `:country_code`
			- `:hotel_information`
			- `:filters`
- `perform_additional_information`
	- Parameters
		- Required
			- `:obj`
			- `:datos`
		- Optional
			- `:language`
			- `:show_more_rates`
- `perform_booking_confirmation`
	- Parameters
		- Required
			- `:obj`
			- `:datos`
			- `:client`
		- Optional
			- `:language`
			- `:company`
			- `:comment`
			- `:reference`
- `perform_voucher`
	- Parameters
		- Required
			- `bookingID`
			- `seg`
		- Optional
			- `language`
- `perform_booking_cancellation`
	- Parameters
		- Required
			- `bookingID`
			- `securityCode`
		- Optional
			- `language`
			- `cancelConfirm`
- `perform_all_destinations_list`
	- Parameters
		- Optional
			- `:language`
- `perform_booking_list`
	- Parameters
		- Optional
			- `language`
			- `bookingID`
			- `locator`
			- `agencyReference`
			- `bookingDateRange`
			- `customerName`
			- `hotelID`
			- `hotelName`
			- `bookingStatus`
		- Info
			- Parameters are optional, but there must be at least one present.
- `perform_hotel_list`
	- Parameters
		- Required
			- `zoneID`
		- Optional
			- `:language`

## Usage
### Create the connection to Vuelandia
	client = Vuelandia::Client.new(user: "user", password: "pass"[, endpoint: :test, proxy: proxy])

- endpoint can be either `:test` or `:live` 
- proxy is a hash with keys `:address`, `:port`, `:user`, `:password`

### Perform the search
	search = client.perform_XXX(parameters)

- The reponse to a search is a `Net::HTTP` response and its body is the reponse XML to your query. You can use this XML however you want, but usually you would want to parse it

### Parse the XML
	parser = Vuelandia::Parser.new
	data = parser.parse_XXX(search.body, [type: type])

- `type` can be `:file` but it's `:string` by default
- `data` is an object which properties depends on the query made
- Format of parsed data depends on the type of query made.

**Note:** you'll need to replace `XXX` in the examples above with the name of the query you want to perform

## Examples
#### In this section I will demonstrate how to call the perform_XXX methods, but, in order to query the objects obtained from the parsing methods, you will need the documentation of the service and you will also need to take a look to the `classes.rb` file.

- To search for one room for 2 adults and a 5 year old kid and two other rooms, each with 3 adults in Madrid from 2016-1-5 to 2016-1-10 using a proxy to connect to internet
		
		proxy = { address: "proxy-address", port: 3128, user: "proxy-user", password: "proxy-password" }	
		client = Vuelandia::Client.new(user: "user", password: "pass", proxy: proxy) 
		
		occupancy1 = Occupancy.new
		occupancy1.Rooms = 1
		occupancy1.Adults = 2
		occupancy1.Children = 1
		occupancy1.ChildAges = [5]
		occupancy2 = Occupancy.new
		occupancy2.Rooms = 2
		occupancy2.Adults = 3
		occupancy2.Children = 0
		response = client.perform_search_availability(destination: "Madrid", check_in_date: "2016-1-5", check_out_date: "2016-1-10", occupancies: [occupancy1, occupancy2])

		#since the response is a Net::HTTPResponse instance, you could do something like
		if response.code == '200'
			parser = Vuelandia::Parser.new
			parsed_data = parser.parse_search_availability(response.body)
		end

- If we want to limit the previous search results to a price range, the previous query would be
	
		filters = { prices: { price_from: 100, price_to: 500 } }
		client.perform_search_availability(destination: "Madrid", check_in_date: "2016-1-5", check_out_date: "2016-1-10", occupancies: [occupancy1, occupancy2], filters: filters )

- To find out details about the previous search after parsing the data into parsed_data
	
		unless parsed_data[:multiple]
			parsed_data = parsed_data[:data]
			response = client.perform_hotel_details_availability(hotelID: parsed_data.Hotel.HotelDetails.ID, sessionID: parsed_data.SessionID)
			parsed_details = parser.parse_hotel_details_availability(response.body)
		else
			puts "Multiple Results"
		end

- To obtain additional information before booking

		response = client.perform_additional_information(obj: parsed_data.obj, datos: parsed_data.Hotels[0].Rooms[0].Boards[0].DATOS)

- To confirm a booking
		
		the_client = Client.new(name: "Client", surnames: "Sur Names")
		response = client.perform_booking_confirmation(obj: parsed_data.obj, datos: parsed_data.Hotels[0].Rooms[0].Boards[0].DATOS, client: the_client)
		parsed_booking = parser.parse_booking_confirmation(response.body)

- To get a voucher
		
		if parsed_booking.ERROR == 0
			client.perform_voucher(bookingID: parsed_booking.BookingID, seg: parsed_booking.SecurityCode)
		else
			puts "There was an error during the booking confirmation phase."
		end

- If we want to cancel our booking
	
		client.perform_booking_cancellation(bookingID: parsed_booking.BookingID, securityCode: parsed_booking.SecurityCode, cancelConfirm: true)

#### Other helpful methods are

- To know all possible destinations

		client.perform_all_destinations_list

- To search for bookings using parameters

		client.perform_booking_list(bookingDateRange: { type: 2, fromDate: 2016-1-5, toDate: 2016-1-10 })

- To find out what all possible hotels are given a zone id

		client.perform_hotel_list(zoneID: 10)

## Contributing

1. [Fork it](https://github.com/openjaf/vuelandia/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
