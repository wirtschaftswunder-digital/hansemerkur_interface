module HansemerkurInterface 
    module Requests 
        class CancelInsurance
          attr_accessor :request, :options, :cancel_information, :response 
            #cancel_information ruby hash: 
            # policy_number = Polciy number of insurance to cancel
            # cancel_reason = One out of insolvency, customer_cancellation, operator_cancellation, goodwill
            # agent_code = The employee canceled the insurance for example BT
            # Example Hash for testing purpose
            # ci = {policy_number:"500414958", cancel_reason:"customer_cancellation", agent_duty_code:"BT"}
          

            def initialize(cancel_information = {}, params = {})
              @cancel_information = cancel_information
              #Check for the right information
              raise 'Cancel Information are required' if cancel_information.nil?
              raise 'You need a policy number' if cancel_information[:policy_number].nil?
              raise 'You need a cancel reason' if cancel_information[:cancel_reason].nil? 
              raise 'You need an agent code' if cancel_information[:agent_duty_code].nil?
              raise 'The cancel reason must be: insolvency, customer_cancellation, operator_cancellation, goodwill' if !["INSOLVENCY","CUSTOMER_CANCELLATION", "OPERATOR_CANCELLATION", "GOODWILL"].include?(cancel_information[:cancel_reason].upcase)
              

              
              @options = {}
              @options.merge!(params)

              @request = HansemerkurInterface::Request.new(@options)
            end

            def call 
             @response = @request.call(generate_xml)
             #puts response.parsed_response
             if @response.parsed_response.nil? || @response.parsed_response["Envelope"]["Body"]["HMR_InsuranceCancelRS"].key?('Errors')
              puts  @response.parsed_response["Envelope"]["Body"]["HMR_InsuranceCancelRS"]
              raise HanseMerkurException.new(@response.parsed_response["Envelope"]["Body"]["HMR_InsuranceCancelRS"]["Errors"]["Error"].kind_of?(Array) ? @response.parsed_response["Envelope"]["Body"]["HMR_InsuranceCancelRS"]["Errors"]["Error"].first["__content__"] : @response.parsed_response["Envelope"]["Body"]["HMR_InsuranceCancelRS"]["Errors"]["Error"]["__content__"])
             else 
              return @response.parsed_response["Envelope"]["Body"]["HMR_InsuranceCancelRS"]
             end
            end

            

            def generate_xml 
              %(<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                <soapenv:Header xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"/>
                <soapenv:Body xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
                  <HMR_InsuranceCancelRQ xmlns="http://hansemerkur.de/rvm/ota/ws/types" PrimaryLangID="de" Target="Production" TimeStamp="2022-02-11T15:07:34.801+02:00" Version="2020.1">
                    <POS>
                      <Source ISOCountry="DE" ISOCurrency="EUR" TerminalID="#{@request.options[:terminal_id]}" AgentDutyCode="#{cancel_information[:agent_duty_code]}">
                        <RequestorID ID="#{@request.options[:requestor_id]}" Type="5"/>
                      </Source>
                    </POS>
                    <PlanForCancelRQ InsuranceCompany="HMR">
                        <PolicyNumber>#{cancel_information[:policy_number]}</PolicyNumber>
                        <CancelReason>#{cancel_information[:cancel_reason].upcase}</CancelReason>
                    </PlanForCancelRQ>
                  </HMR_InsuranceCancelRQ>
                </soapenv:Body>
              </soapenv:Envelope>)
            end
        end
    end
end
