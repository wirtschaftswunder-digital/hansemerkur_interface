module HansemerkurInterface 
    module Requests 
        class ReadInsurance
          attr_accessor :request, :options, :cancel_information, :response 
            #read_information ruby hash: 
            # policy_number = Polciy number of insurance to read
            # offer_id = the offer id, which was submitted by BookRQ
            # additional_email = Email where the policy will be send to
            # agent_code = The employee canceled the insurance for example BT
            # Example Hash for testing purpose
            # ci = {policy_number:"500458123", additional_email:"benjamin.tzschoppe@gmx.de", agent_duty_code:"BT"}
          

            def initialize(read_information = {}, params = {})
              @read_information = read_information
              #Check for the right information
              raise 'Read Information are required' if read_information.nil?
              raise 'You need at least a policy number' if read_information[:policy_number].nil?
              raise 'You need a agent duty code' if read_information[:agent_duty_code].nil?

              
              @options = {}
              @options.merge!(params)

              @request = HansemerkurInterface::Request.new(@options)
            end

            def call 
             @response = @request.call(generate_xml)
             #puts response.parsed_response
             if @response.parsed_response.nil? || @response.parsed_response["Envelope"]["Body"]["HMR_InsuranceReadRS"].key?('Errors')
              #puts  @response.parsed_response["Envelope"]["Body"]["HMR_InsuranceCancelRS"]
              raise HanseMerkurException.new(@response.parsed_response["Envelope"]["Body"]["HMR_InsuranceReadRS"]["Errors"]["Error"].kind_of?(Array) ? @response.parsed_response["Envelope"]["Body"]["HMR_InsuranceReadRS"]["Errors"]["Error"].first["__content__"] : @response.parsed_response["Envelope"]["Body"]["HMR_InsuranceReadRS"]["Errors"]["Error"]["__content__"])
             else 
              return @response.parsed_response["Envelope"]["Body"]["HMR_InsuranceReadRS"]
             end
            end
           

            def generate_xml 
              %(<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                <soapenv:Header xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"/>
                <soapenv:Body xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
                  <HMR_InsuranceReadRQ xmlns="http://hansemerkur.de/rvm/ota/ws/types" PrimaryLangID="de" Target="Production" TimeStamp="#{DateTime.now}" Version="2020.1">
                    <POS>
                      <Source ISOCountry="#{@request.options[:anbieter_iso_code].upcase}" ISOCurrency="EUR" TerminalID="#{@request.options[:terminal_id]}" AgentDutyCode="#{@read_information[:agent_duty_code]}">
                        <RequestorID ID="#{@request.options[:requestor_id]}" Type="5"/>
                      </Source>
                    </POS>
                    <PlanForReadRQ InsuranceCompany="HMR">
                        <PolicyNumber>#{@read_information[:policy_number]}</PolicyNumber>
                        <EmailPolicy> 
                          <AdditionalEmail>#{@read_information[:additional_email]}</AdditionalEmail>
                        </EmailPolicy>
                    </PlanForReadRQ>
                  </HMR_InsuranceReadRQ>
                </soapenv:Body>
              </soapenv:Envelope>)
            end
        end
    end
end
