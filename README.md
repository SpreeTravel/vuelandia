The `vuelandia` gem interfaces with the [Vuelandia.com](http://www.vuelandia.com/) API to search for and book hotel rooms.

## Installation

I'm sure you know how to install Ruby gems by now...

In your Gemfile, before a `bundle install`, add:

    gem "vuelandia", "~> X.X.X"

**Note:** you'll need to replace `X.X.X` in the example above with the [latest gem version](https://rubygems.org/gems/vuelandia) visible in the badge above.

Manually, via command line:
	
    gem install vuelandia

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
- `perform_booking_cancellation`
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
- `all_destinations_list`
	- Parameters
		- Optional
			- `:language`

## Contributing

1. [Fork it](https://github.com/mariomuniz/vuelandia/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
