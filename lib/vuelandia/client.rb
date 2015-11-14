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

    def perform_search_availability(destination:, check_in_date:, check_out_date:, occupancy:, **args)
      builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        language = args[:language] ? args[:language] : "ENG" 
        xml.SearchAvailabilityRQ(:version => "2.0", :language => language){
          xml.Request{
            xml.Destination{
              xml.cdata(destination)
            }
            xml.Check_in_date_ check_in_date
            xml.Check_out_date_ check_out_date
            occupancy.each do |room|
              xml.Occupancy{
                xml.Rooms_ 1
                xml.Adults_ room[:adult_count]
                xml.Children_ room[:child_count]
                if room[:child_count] > 0
                  xml.Ages{
                    room[:child_ages].each do |age|
                      xml.Age_ age
                    end
                  }
                end
              }
            end
            ######################end of required params#####################
            xml.HotelList_ args[:hotel_list] if args[:hotel_list]
            xml.DestinationID_ args[:destination_id] if args[:destination_id]
            xml.CountryCode_ args[:country_code] if args[:country_code]
            xml.HotelInformation_ 'Y' if args[:hotel_information]
            
            ###################filters description###########################
            #args[:filters] is a hash with the next structure where each key is optional
            #{categories:[x1,...,xn], prices:{price_from:x,price_to:y},
            # room_types:[x1,...,xn], amenities:[x1,...,xn], boards:[x1,...,xn]}
            filters = args[:filters]
            if filters
              xml.Filters{
                if filters[:categories]
                  xml.Categories{
                    filters[:categories].each do |category|
                      xml.Category_ category
                    end
                  }
                end
                if filters[:prices]
                  xml.Prices{
                    xml.PriceFrom_ filters[:prices][:price_from] if filters[:prices][:price_from] 
                    xml.PriceTo_ filters[:prices][:price_to] if filters[:prices][:price_to] 
                  }
                end
                if filters[:room_types]
                  xml.RoomTypes{
                    filters[:room_types].each do |room_type|
                      xml.RoomType_ room_type
                    end
                  }
                end
                if filters[:amenities]
                  xml.Amenities{
                    filters[:amenities].each do |amenity|
                      xml.Amenity_ amenity
                    end
                  }
                end
                if filters[:boards]
                  xml.Boards{
                    filters[:boards].each do |board|
                      xml.Board_ board
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
      puts 'Requesting'
      connection = Vuelandia::Connection.new(configuration, xml)  
      connection.perform_request
    end 

    def perform_additional_information(obj:, datos:, language: "ENG", **args)
      builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.AdditionalInformationRQ(:version => "2.0", :language => language){
          xml.Request{
            xml.obj_ obj
            xml.DATOS_ datos
            unless args[:ShowMoreRates].nil?
              xml.ShowMoreRates_ 'Y'
            end
          }
        }
      end
      xml = builder.to_xml
      puts xml
      connection = Vuelandia::Connection.new(configuration, xml)
      connection.perform_request
    end

    def perform_all_destinations_list(language: "ENG")
      builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.AllDestinationsListRQ(:version => "2.0", :language => language){
          xml.AllDestinations
        }
      end
      xml = builder.to_xml
      puts xml
      connection = Vuelandia::Connection.new(configuration, xml)
      connection.perform_request
    end
  end
end
