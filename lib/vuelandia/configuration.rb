module Vuelandia
  class Configuration
    def self.endpoints
      {
        test: "http://testxml.veturis.com/xmlWebServices.php".freeze,
        live: "https://xmlservices.veturis.com/xmlWebServices.php".freeze 
      }      
    end
    
    attr_accessor :endpoint, :user, :password, :proxy, :request_timeout,
      :response_timeout, :enable_logging, :language

    def initialize(endpoint: :test, user:, password:, proxy: nil, request_timeout: 5, response_timeout: 30, language: "ENG")
      self.endpoint = self.class.endpoints.fetch(endpoint, endpoint)
      self.user = user
      self.password = password
      self.proxy = proxy
      self.request_timeout = Integer(request_timeout)
      self.response_timeout = Integer(response_timeout)
      self.language = language
      freeze
    end
    
    def proxy?
      !!(proxy && !proxy.empty?)
    end
  end
end
