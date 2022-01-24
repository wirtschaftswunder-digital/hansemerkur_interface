module HansemerkurInterface 
    module Requests 
        class PlanSearch < ::HansemerkurInterface::Base
          attr_accessor :base

            def initialize 
              super
              @xml_body = self.generate_xml
            end

            def generate_xml 
                '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:axis2="http://hansemerkur.de/rvm/ota/ws" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:http="http://schemas.xmlsoap.org/wsdl/http/" xmlns:mime="http://schemas.xmlsoap.org/wsdl/mime/" xmlns:ns0="http://hansemerkur.de/rvm/ota/ws/types" xmlns:ns1="http://org.apache.axis2/xsd" xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns:soap12="http://schemas.xmlsoap.org/wsdl/soap12/" xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" targetNamespace="http://hansemerkur.de/rvm/ota/ws">
                <SOAP-ENV:Header/>
                <SOAP-ENV:Body>
                    <HMR_InsurancePlanSearchRQ xmlns="http://hansemerkur.de/rvm/ota/ws/types" PrimaryLangID="de" DetailResponse="false" Target="Test" TimeStamp="2022-01-24T10:42:42.366+02:00" Version="2021.1">
                      <POS>
                        <Source ISOCountry="DE" ISOCurrency="EUR" TerminalID="7066335">
                          <RequestorID ID="WWDIGITAL" Type="5"/>
                        </Source>
                      </POS>
                      <CoveragePreferences>
                        <CoveragePreference CoverageType="1" InsuranceCompany="HMR" PreferLevel="Preferred"/>
                      </CoveragePreferences>
                      <SearchTripInfo>
                        <CoveredTrips>
                          <CoveredTrip BookingConfirmation="2021-10-09T12:00:00.000+02:00" End="2022-09-15T12:00:00.000+02:00" Start="2022-09-01T12:00:00.000+02:00">
                            <Destinations>
                              <Destination ArrivalDate="2022-09-01">
                                <DestinationCategory>
                                  <Region IncludeExtendedRegions="true">w</Region>
                                </DestinationCategory>
                              </Destination>
                            </Destinations>
                            <Operators>
                              <Operator CompanyShortName="BLA"/>
                            </Operators>
                          </CoveredTrip>
                        </CoveredTrips>
                      </SearchTripInfo>
                      <SearchTravInfo MaxTravelers="4" MinTravelers="4">
                        <SearchTravelers>
                          <SearchTraveler ID="1" NamePrefix="H">
                            <Age>45</Age>
                            <CitizenCountryName Code="DE" DefaultInd="false"/>
                            <IndCoverageReqs>
                              <IndTripCost Amount="800" CurrencyCode="EUR" DecimalPlaces="0"/>
                            </IndCoverageReqs>
                          </SearchTraveler>
                          <SearchTraveler ID="2" NamePrefix="D">
                            <Age>45</Age>
                            <CitizenCountryName Code="DE" DefaultInd="false"/>
                            <IndCoverageReqs>
                              <IndTripCost Amount="800" CurrencyCode="EUR" DecimalPlaces="0"/>
                            </IndCoverageReqs>
                          </SearchTraveler>
                          <SearchTraveler ID="3" NamePrefix="K">
                            <Age>12</Age>
                            <IndCoverageReqs>
                              <IndTripCost Amount="200" CurrencyCode="EUR" DecimalPlaces="0"/>
                            </IndCoverageReqs>
                          </SearchTraveler>
                          <SearchTraveler ID="4" NamePrefix="K">
                            <BirthDate>2005-10-10</BirthDate>
                            <CitizenCountryName Code="DE" DefaultInd="false"/>
                            <IndCoverageReqs>
                              <IndTripCost Amount="200" CurrencyCode="EUR" DecimalPlaces="0"/>
                            </IndCoverageReqs>
                          </SearchTraveler>
                        </SearchTravelers>
                      </SearchTravInfo>
                    </HMR_InsurancePlanSearchRQ>
                </SOAP-ENV:Body>
              </SOAP-ENV:Envelope>'
            end
        end
    end
end