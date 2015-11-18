module Vuelandia
  class Configuration
    def self.endpoints
      {
        test: "http://testxml.veturis.com/xmlWebServices.php".freeze,
        live: "https://xmlservices.veturis.com/xmlWebServices.php".freeze 
      }      
    end
    
    attr_accessor :endpoint, :user, :password, :request_timeout, :response_timeout, :proxy

    def initialize(endpoint: :test, user:, password:, request_timeout: 5, response_timeout: 30, proxy: nil)
      self.endpoint = self.class.endpoints.fetch(endpoint, endpoint)
      self.user = user
      self.password = password
      self.request_timeout = Integer(request_timeout)
      self.response_timeout = Integer(response_timeout)
      self.proxy = proxy
      freeze
    end
  end
end
