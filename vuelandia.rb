require_relative 'lib/vuelandia/client'

c = Vuelandia::Client.new(user: 'sibareumtest', password: 'sibareumtest', endpoint: :test)
occupancy = [{'adult_count' => 2, 'child_count' => 2, 'child_ages' => [2,3]}]
c.perform_search_availability(destination: 'Madrid', check_in_date: '2015-12-12',
							  check_out_date: '2015-12-20', occupancy: occupancy)