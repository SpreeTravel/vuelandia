require 'nokogiri'
require_relative 'classes'

module Vuelandia
	class Parser
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