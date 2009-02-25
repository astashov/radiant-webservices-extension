module WebservicesSpecHelpers
   
  def login_as(user)
    controller.stub!(:authenticate).and_return(true)
    controller.stub!(:logged_in?).and_return(true)
    controller.stub!(:current_user).and_return(user)
    @current_user = user
  end
  
    
  # You may avoid to specify date, it will be constructed automatically
  # (for today, tomorrow, yesterday, lastweek, nextweek, thisweek or YYYYMMDD)
  def rules
<<END
content_type:
  -
    if:
      name: cosmic-calendar
      frequency: daily
    value: ":name"
  -
    if:
      name: "_any_"
    value: ":frequency_:name"

sign: ":sign"
END
  end
  
  def unsuccess_remote_expectations
    http = mock("http")
    Net::HTTP.should_receive(:new).and_return(http)
    http.should_receive(:use_ssl=).and_return(false)
    http.should_receive(:request_get).and_raise(SocketError)
  end
  
  def success_remote_expectations
    http = mock("http")
    response = mock("response")
    Net::HTTP.should_receive(:new).with('maps.google.com', 80).and_return(http)
    http.should_receive(:use_ssl=).and_return(false)
    http.should_receive(:request_get).with(/\/maps\/geo\?/).and_return(response)
    response.should_receive(:body).and_return(remote_success_answer) 
  end
  
  def remote_success_answer
    <<EOM
<?xml version="1.0" encoding="UTF-8" ?>
<kml xmlns="http://earth.google.com/kml/2.0"><Response>
  <name>boguchany</name>
  <Status>
    <code>200</code>
    <request>geocode</request>
  </Status>
  <Placemark id="p1">

    <address>Russian Federation, Region of Krasnoyarsk, село Богучаны</address>
    <AddressDetails Accuracy="4" xmlns="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0"><Country><CountryNameCode>RU</CountryNameCode><CountryName>Russian Federation</CountryName><AdministrativeArea><AdministrativeAreaName>Region of Krasnoyarsk</AdministrativeAreaName><SubAdministrativeArea><SubAdministrativeAreaName>Богучанский район</SubAdministrativeAreaName><Locality><LocalityName>село Богучаны</LocalityName></Locality></SubAdministrativeArea></AdministrativeArea></Country></AddressDetails>
    <ExtendedData>
      <LatLonBox north="58.3829695" south="58.3766743" east="97.4629864" west="97.4566912" />
    </ExtendedData>
    <Point><coordinates>97.4598388,58.3798219,0</coordinates></Point>

  </Placemark>
</Response></kml>
')
EOM
  end
  
end