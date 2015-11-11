require_relative 'configuration'
require_relative 'connection'
require 'nokogiri'

module Vuelandia
  class Client
    attr_accessor :configuration, :connection
    private :configuration=, :connection, :connection=

    def initialize(**config)
      self.configuration = Configuration.new(**config)
      freeze
    end

    # each method returns an operation object which contains both the
    # request and response objects.

    def perform_search_availability(destination:, check_in_date:, check_out_date:, occupancy:, **args)
      builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.SearchAvailabilityRQ(:version => "2.0", :language => "ENG"){
          xml.Request{
            xml.Destination{
              xml.cdata(destination)
            }
            xml.Check_in_date_ check_in_date
            xml.Check_out_date_ check_out_date
            occupancy.each do |room|
              xml.Occupancy{
                xml.Rooms_ 1
                xml.Adults_ room['adult_count']
                xml.Children_ room['child_count']
                if room['child_count'] > 0
                  xml.Ages{
                    room['child_ages'].each do |age|
                      xml.Age_ age
                    end
                  }
                end
              }
            end
          }        
        }
    end
    xml = builder.to_xml
    puts xml
    puts 'requesting'
    connection = Vuelandia::Connection.new(endpoint: configuration.endpoint, 
                                           user: configuration.user, 
                                           password: configuration.password, xmlRQ: xml)  
    connection.perform_request 
    end
  end
end
