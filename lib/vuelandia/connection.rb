require 'net/http'

module Vuelandia
	class Connection
		attr_accessor :user, :password, :xmlRQ, :endpoint 

		def initialize(user:, password:, xmlRQ:, endpoint:)
			self.user = user
			self.password = password
			self.xmlRQ = xmlRQ
			self.endpoint = endpoint
		end

		def perform_request
			uri = URI(endpoint)
			req = Net::HTTP::Post.new(uri)
			req.set_form_data('user' => user, 'password' => password, 'xmlRQ' => xmlRQ)
			puts req.body
			res = Net::HTTP.start(uri.hostname, uri.port) do |http|
  				http.request(req)
			end
		end
	end
end