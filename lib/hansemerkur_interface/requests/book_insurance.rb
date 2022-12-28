module HansemerkurInterface 
    module Requests 
        class BookInsurance
          attr_accessor :request, :options, :booking_information, :response 
            #booking_information ruby hash: 
            # destination_country_code:string   
            # booking_region:string
            # trip_start:datetime 
            # trip_end:datetime  
            # insurance_customer:Hash
            #   birthdate:date, given_name:string, surname:string, phone_number:string, email:string, street:string, city:string, postal_code:string, country_name:string
            # booked_services:Array
            #   booked_service:Hash 
            #     tarif_code:string, 
            #     traveler_allocations:Array 
            #       traveler_allocation:Hash traveler_id:integer
            # covered_persons:Hash 
            #   id:string, country_code:string given_name:string surname:string birthdate:date, amount:BigDecimal
            # Example Hash for testing purpose
            # bc = {booking_confirmation_date:DateTime.now, 
            #       booking_region:"DE", 
            #       trip_start: DateTime.parse('2023-7-1'), 
            #       trip_end: DateTime.parse('2023-7-14'),
            #       destination_country_code: "de",
            #       covered_persons: [{id:4711, surname:"Schocke",given_name:"Jona",birthdate:Date.parse('2014-7-4'),amount:BigDecimal('200.0'),country_code:"de"},
            #                         {id:4712, surname:"Tzschoppe",given_name:"Linus",birthdate:Date.parse('2016-4-11'),amount:BigDecimal('200.0'),country_code:"de"}],
            #       insurance_customer: {given_name:"Britta",surname:"Tzschoppe", birthdate:Date.parse('1983-12-2'),email:"britta.tzschoppe@gmx.de", phone_number:"123456789", street:"Im Handbachtal 65", city:"Oberhausen", postal_code:"46147", country_name:"de"},
            #       booked_services: [{tarif_code:"912668",traveler_allocations:[4711,4712]}]}
          

            def initialize(booking_information = {}, params = {})
              @booking_information = booking_information
              #Check for the right information
              raise 'Booking Information are required' if booking_information.nil?
              raise 'You need a booking confirmation date' if booking_information[:booking_confirmation_date].nil? 
              raise 'You need a trip start date' if booking_information[:trip_start].nil? 
              raise 'You need a trip end date' if booking_information[:trip_end].nil?
              raise 'You need a destination country code' if booking_information[:destination_country_code].nil?
            
              raise 'You need at least one covered person' if booking_information[:covered_persons].empty? 

              booking_information[:covered_persons].each do |person|
                raise 'Each traveler has to have a birthdate' if person[:birthdate].nil? 
                raise 'Each traveler has to have a unique id' if person[:id].nil? 
                raise 'Each traveler has to have a given name' if person[:given_name].nil? || person[:given_name].empty?
                raise 'Each traveler has to have a surname' if person[:surname].nil? || person[:surname].empty?
                raise 'Each traveler has to have an amount' if person[:amount].nil? || person[:amount] == 0 
                raise 'Each traveler has to have a country code' if person[:country_code].nil? || person[:country_code].empty? 
              end

              raise 'You need at an insurance customer' if  booking_information[:insurance_customer].nil? ||  booking_information[:insurance_customer].empty? 
              raise 'The insurance customer needs a given name' if booking_information[:insurance_customer][:given_name].nil? || booking_information[:insurance_customer][:given_name].empty? 
              raise 'The insurance customer needs a surname' if booking_information[:insurance_customer][:surname].nil? || booking_information[:insurance_customer][:surname].empty? 
              raise 'The insurance customer needs a birthdate' if booking_information[:insurance_customer][:birthdate].nil?
              raise 'The insurance customer needs a email' if booking_information[:insurance_customer][:email].nil? || booking_information[:insurance_customer][:email].empty? 
              raise 'The insurance customer needs a phone number' if booking_information[:insurance_customer][:phone_number].nil? || booking_information[:insurance_customer][:phone_number].empty? 
              raise 'The insurance customer needs a street' if booking_information[:insurance_customer][:street].nil? || booking_information[:insurance_customer][:street].empty? 
              raise 'The insurance customer needs a city' if booking_information[:insurance_customer][:city].nil? || booking_information[:insurance_customer][:city].empty? 
              raise 'The insurance customer needs a postal code' if booking_information[:insurance_customer][:postal_code].nil? || booking_information[:insurance_customer][:postal_code].empty? 
              raise 'The insurance customer needs a country name' if booking_information[:insurance_customer][:country_name].nil? || booking_information[:insurance_customer][:country_name].empty? 
              
              raise 'You need at least one booked service' if booking_information[:booked_services].empty? 
              booking_information[:booked_services].each do |service|
                raise 'Each service has to have a tarif code' if service[:tarif_code].nil? 
                raise 'Each service has to have traveler allocations' if service[:traveler_allocations].empty?
                service[:traveler_allocations].each do |ta|
                  raise 'Each traveler allocation has to have one traveler id' if ta.nil?
                end 
                
              end

              
              @options = {}
              @options.merge!(params)

              @request = HansemerkurInterface::Request.new(@options)
            end

            def call 
             @response = @request.call(generate_xml)
             #puts response.parsed_response
             if @response.parsed_response.nil? || @response.parsed_response["Envelope"]["Body"]["HMR_InsuranceBookRS"].key?('Errors')
              #puts  response.parsed_response["Envelope"]["Body"]["HMR_InsuranceBookRS"]["Errors"]
              raise HanseMerkurException.new(@response.parsed_response["Envelope"]["Body"]["HMR_InsuranceBookRS"]["Errors"]["Error"].kind_of?(Array) ? @response.parsed_response["Envelope"]["Body"]["HMR_InsuranceBookRS"]["Errors"]["Error"].first["__content__"] :  @response.parsed_response["Envelope"]["Body"]["HMR_InsuranceBookRS"]["Errors"]["Error"]["__content__"])
             else 
              return @response.parsed_response["Envelope"]["Body"]["HMR_InsuranceBookRS"]
             end
            end

            def insurance_book_rs 
              @response.parsed_response["Envelope"]["Body"]["HMR_InsuranceBookRS"]
            end

            def get_services
              insurance_book_rs["PlanForBookRS"]["Services"]["Service"].is_a?(Array) ? insurance_book_rs["PlanForBookRS"]["Services"]["Service"] : [insurance_book_rs["PlanForBookRS"]["Services"]["Service"]]
            end

            def generate_xml 
              %(<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                <soapenv:Header xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"/>
                <soapenv:Body xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
                  <HMR_InsuranceBookRQ xmlns="http://hansemerkur.de/rvm/ota/ws/types" PrimaryLangID="de" Target="Production" TimeStamp="2022-02-11T15:07:34.801+02:00" Version="2021.1">
                    <POS>
                      <Source ISOCountry="DE" ISOCurrency="EUR" TerminalID="#{@request.options[:terminal_id]}">
                        <RequestorID ID="#{@request.options[:requestor_id]}" Type="5"/>
                      </Source>
                    </POS>
                    <PlanForBookRQ>
                      <CoveredTravelers>
                      #{
                        booking_information[:covered_persons].each.map do |person|
                        %(<CoveredTraveler ID="#{person[:id]}">
                          <CoveredPerson>
                            <NamePrefix>#{person[:gender]}</NamePrefix>
                            <GivenName>#{person[:given_name]}</GivenName>
                            <Surname>#{person[:surname]}</Surname>
                            <BirthDate>#{person[:birthdate].strftime('%Y-%m-%d')}</BirthDate>
                          </CoveredPerson>
                          <CitizenCountryName Code="#{person[:country_code].upcase}" DefaultInd="false"/>
                          <IndCoverageReqs>
                            <IndTripCost Amount="#{"%.2f" % person[:amount]}" CurrencyCode="EUR"/>
                          </IndCoverageReqs>
                        </CoveredTraveler>)
                        end.join('')
                      }
                      </CoveredTravelers>
                      <InsCoverageDetail Type="SingleTrip">
                        <CoverageRequirements>
                          <CoverageRequirement CoverageType="1"/>
                        </CoverageRequirements>
                        <CoveredTrips>
                          <CoveredTrip BookingConfirmation="#{booking_information[:booking_confirmation_date].to_s}" End="#{booking_information[:trip_end].to_s}" PeriodType="TRAVEL_PERIOD" Start="#{booking_information[:trip_start].to_s}">
                            <Destinations>
                              <Destination ArrivalDate="#{booking_information[:trip_start].strftime('%Y-%m-%d')}">
                                <DestinationCategory>
                                  <Country>#{booking_information[:destination_country_code].upcase}</Country>
                                </DestinationCategory>
                              </Destination>
                            </Destinations>
                          </CoveredTrip>
                        </CoveredTrips>
                      </InsCoverageDetail>
                      <QuoteIDRef>1000</QuoteIDRef>
                      <InsuranceCustomer BirthDate="#{booking_information[:insurance_customer][:birthdate]}" CurrencyCode="EUR">
                        <PersonName>
                          <NamePrefix>#{booking_information[:insurance_customer][:gender]}</NamePrefix>
                          <GivenName>#{booking_information[:insurance_customer][:given_name]}</GivenName>
                          <Surname>#{booking_information[:insurance_customer][:surname]}</Surname>
                        </PersonName>
                        <Telephone PhoneNumber="#{booking_information[:insurance_customer][:phone_number]}" PhoneTechType="5"/>
                        <Email>#{booking_information[:insurance_customer][:email]}</Email>
                        <Address>
                          <StreetNmbr>#{booking_information[:insurance_customer][:street]}</StreetNmbr>
                          <CityName>#{booking_information[:insurance_customer][:city]}</CityName>
                          <PostalCode>#{booking_information[:insurance_customer][:postal_code]}</PostalCode>
                          <CountryName>#{booking_information[:insurance_customer][:country_name].upcase}</CountryName>
                        </Address>
                      </InsuranceCustomer>
                      <BookServices>
                      #{
                        booking_information[:booked_services].each_with_index.map do |service, index|
                        %(<Service ID="#{index+1}">
                            <QuotedTariff>
                              <TariffCode>#{service[:tarif_code]}</TariffCode>
                            </QuotedTariff>
                            <TravelerAllocations>
                            #{
                            service[:traveler_allocations].each.map do |ta|
                              %(<TravelerAllocation ID="5" TravelerIDRef="#{ta}"/>) 
                              end.join('')
                             }
                           </TravelerAllocations>
                          </Service>)
                        end.join('')
                      }
                      </BookServices>
                      <EmailPolicy>
                        <AdditionalEmail>#{booking_information[:insurance_customer][:email]}</AdditionalEmail>
                      </EmailPolicy>
                    </PlanForBookRQ>
                  </HMR_InsuranceBookRQ>
                </soapenv:Body>
              </soapenv:Envelope>)
            end
        end
    end
end
