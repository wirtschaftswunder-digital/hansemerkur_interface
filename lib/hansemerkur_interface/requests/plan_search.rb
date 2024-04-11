module HansemerkurInterface 
    module Requests 
        class PlanSearch
          attr_accessor :request, :options, :booking_information 
            #booking_information ruby hash: 
            # booking_confirmation_date:datetime   
            # booking_region:string
            # trip_start:datetime 
            # trip_end:datetime  
            # persons array of persons 
            # person:OpenStruct 
            #   country_code:string last_name:string birthdate:date, amount:integer 
            # bc = {booking_confirmation_date:DateTime.now, booking_region:"AT", trip_start: DateTime.parse('2023-7-1'), trip_end: DateTime.parse('2023-7-14'),persons: [{surname:"Tzschoppe",birthdate:Date.parse('2009-12-11'),amount:200.0,country_code:"de"}]}
            def initialize(booking_information = {}, params = {})
              @booking_information = booking_information
              #Check for the right information
              raise 'Booking Information are required' if booking_information.nil?
              raise 'You need a booking confirmation date' if booking_information[:booking_confirmation_date].nil? 
              raise 'You need a trip start date' if booking_information[:trip_start].nil? 
              raise 'You need a trip end date' if booking_information[:trip_end].nil?
              raise 'You need at least one traveler' if booking_information[:persons].empty? 
              booking_information[:persons] do |person|
                raise 'Each traveller has to have a birthdate' if person[:birthdate].nil? 
                raise 'Each traveler has to have a lastname' if person[:surname].blank? 
                raise 'Each traveler has to have an amount' if person[:amount].nil? || person.amount == 0 
                raise 'Each traveler has to have a country code' if person[:country_code].blank? 
              end
              
              @options = {}
              @options.merge!(params)

              @request = HansemerkurInterface::Request.new(@options)
            end

            def call 
             response = @request.call(generate_xml)
             if response.parsed_response["Envelope"]["Body"]["HMR_InsurancePlanSearchRS"].key?('Errors')
              raise HanseMerkurException.new(response.parsed_response["Envelope"]["Body"]["HMR_InsurancePlanSearchRS"]["Errors"]["Error"]["__content__"])
             else 
              return response.parsed_response["Envelope"]["Body"]["HMR_InsurancePlanSearchRS"]["AvailablePlans"]
             end
            end

            def generate_xml 
              %(<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:axis2="http://hansemerkur.de/rvm/ota/ws" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:http="http://schemas.xmlsoap.org/wsdl/http/" xmlns:mime="http://schemas.xmlsoap.org/wsdl/mime/" xmlns:ns0="http://hansemerkur.de/rvm/ota/ws/types" xmlns:ns1="http://org.apache.axis2/xsd" xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns:soap12="http://schemas.xmlsoap.org/wsdl/soap12/" xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" targetNamespace="http://hansemerkur.de/rvm/ota/ws">
                <SOAP-ENV:Header/>
                <SOAP-ENV:Body>
                    <HMR_InsurancePlanSearchRQ xmlns="http://hansemerkur.de/rvm/ota/ws/types" PrimaryLangID="de" DetailResponse="true" Target="Production" TimeStamp="#{DateTime.now}" Version="2021.1">
                      <POS>
                        <Source ISOCountry="#{@request.options[:anbieter_iso_code].upcase}" ISOCurrency="EUR" TerminalID="#{@request.options[:terminal_id]}">
                          <RequestorID ID="#{@request.options[:requestor_id]}" Type="5"/>
                        </Source>
                      </POS>
                      <CoveragePreferences>
                        <CoveragePreference CoverageType="1" InsuranceCompany="HMR" PreferLevel="Preferred"/>
                      </CoveragePreferences>
                      <SearchTripInfo>
                        <CoveredTrips>
                          <CoveredTrip BookingConfirmation="#{booking_information[:booking_confirmation_date].to_s}" End="#{booking_information[:trip_end].to_s}" Start="#{booking_information[:trip_start].to_s}">
                            <Destinations>
                              <Destination ArrivalDate="#{booking_information[:trip_start].strftime('%Y-%m-%d')}">
                                <DestinationCategory>
                                  <Country >#{booking_information[:booking_region].nil? ? 'DE' : booking_information[:booking_region].upcase}</Country>
                                </DestinationCategory>
                              </Destination>
                            </Destinations>
                          </CoveredTrip>
                        </CoveredTrips>
                      </SearchTripInfo>
                      <SearchTravInfo MaxTravelers="#{booking_information[:persons].count}" MinTravelers="#{booking_information[:persons].count}">
                        <SearchTravelers>
                        #{ 
                          booking_information[:persons].each_with_index.map do |person, index|
                            %(<SearchTraveler ID="#{index+1}" NamePrefix="#{person[:surname].chars.first.upcase}">
                              <BirthDate>#{person[:birthdate].strftime('%Y-%m-%d')}</BirthDate>
                                <CitizenCountryName Code="#{person[:country_code].upcase}" DefaultInd="false"/>
                                <IndCoverageReqs>
                                  <IndTripCost Amount="#{person[:amount].to_i}" CurrencyCode="EUR" DecimalPlaces="0"/>
                                </IndCoverageReqs>
                              </SearchTraveler>)
                          end.join('')
                         }
                        </SearchTravelers>
                      </SearchTravInfo>
                    </HMR_InsurancePlanSearchRQ>
                </SOAP-ENV:Body>
              </SOAP-ENV:Envelope>)
            end
        end
    end
end

#Umbuchung relativ einfach 
#Emailadresse kommt mit...
#Reservierung möglich soll nach X Tagen automatisch gebucht oder storniert werden?  