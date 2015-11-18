require 'net/http'

module Vuelandia
	class Connection
		attr_accessor :user, :password, :xmlRQ, :endpoint, :request_timeout, :response_timeout,
    	        	  :p_addr, :p_port, :p_user, :p_password


		def initialize(configuration, xml)
			self.endpoint = configuration.endpoint
            self.user = configuration.user
            self.password = configuration.password
            self.request_timeout = configuration.request_timeout
            self.response_timeout = configuration.response_timeout
            self.xmlRQ = xml
            if configuration.proxy
            	self.p_addr = configuration.proxy[:address]
            	self.p_port = configuration.proxy[:port]
            	self.p_user = configuration.proxy[:user]
            	self.p_password = configuration.proxy[:password]
        	else
        		self.p_addr = self.p_port = self.p_user = self.p_password = nil
			end
		end

		def perform_request
			uri = URI(endpoint)
			req = Net::HTTP::Post.new(uri)
			req.set_form_data('user' => user, 'password' => password, 'xmlRQ' => xmlRQ)
			res = Net::HTTP.start(uri.hostname, uri.port, p_addr, 
								  p_port, p_user, p_password) do |http|
				http.open_timeout = request_timeout
				http.read_timeout = response_timeout
  				http.request(req)
			end
		end
	end
end