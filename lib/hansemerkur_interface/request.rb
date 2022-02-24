require "hansemerkur_interface/requests/plan_search"
require 'httparty'
module HansemerkurInterface
    class Request 
        attr_reader :options, :response
        attr_accessor :xml_body

        
        def defaults
            defaults ||= {
                username: 'RIPWIW',
                password: 'sjWr1%~sl3-x',
                api_endpoint: 'https://test.hmrv.de/rvm-web/services/HMRVSoap_Service',
                terminal_id: '7066335',
                requestor_id: 'WWDIGITAL'
              }
          end

        def initialize(params = {})
            @options = defaults.merge!(params)

            raise 'Options must contain params: <username>' unless @options.key?(:username)
            raise 'Options must contain params: <password>' unless @options.key?(:password)
            raise 'Options must contain params: <api_endpoint>' unless @options.key?(:api_endpoint)
            raise 'Options must contain params: <terminal_id>' unless @options.key?(:terminal_id)
            raise 'Options must contain params: <requestor_id>' unless @options.key?(:requestor_id)
            
        end

        def call(xml_body) 
            @response = HTTParty.post(@options[:api_endpoint],
                headers: {"Accept" => "application/xml", "Content-Type" =>"application/xml"},
                basic_auth: {username: @options[:username], password: @options[:password]},
                body: xml_body)
        end
     
    end
end