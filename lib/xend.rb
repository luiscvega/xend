require 'ap'
require 'open3'
require 'xmlsimple'

# SANDBOX
  # RateService
# stdout, stderr, res = Open3.capture3('curl -H "Content-Type: text/xml" -d @rate-calculate-sandbox.xml https://www.xend.com.ph/api/RateService.asmx')

  # BookingService
# stdout, stderr, res = Open3.capture3('curl -H "Content-Type: text/xml" -d @booking-schedule-sandbox.xml https://www.xend.com.ph/apitest/BookingService.asmx')

  # ShipmentService

    # Create
# stdout, stderr, res = Open3.capture3('curl -H "Content-Type: text/xml" -d @shipment-create-sandbox.xml https://www.xend.com.ph/apitest/ShipmentService.asmx')

  # Get
# stdout, stderr, res = Open3.capture3('curl -H "Content-Type: text/xml" -d @shipment-get-sandbox.xml https://www.xend.com.ph/apitest/ShipmentService.asmx')



# LIVE

  # ShipmentService
    # Create
# stdout, stderr, res = Open3.capture3('curl -H "Content-Type: text/xml" -d @shipment-create.xml https://www.xend.com.ph/api/ShipmentService.asmx')

    # Get
stdout, stderr, res = Open3.capture3('curl -H "Content-Type: text/xml" -d @shipment-get.xml https://www.xend.com.ph/api/ShipmentService.asmx')

ap XmlSimple.xml_in(stdout)