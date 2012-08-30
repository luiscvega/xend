module Settings
  USER_TOKEN = ENV["XEND_USER_TOKEN"]
  DEVELOPER_ID = ENV["XEND_DEVELOPER_ID"]

  module SOAP
    RATE = "https://www.xend.com.ph/api/RateService.asmx"
    SHIPMENT = "https://www.xend.com.ph/api/ShipmentService.asmx"
    BOOKING = "https://www.xend.com.ph/api/BookingService.asmx"
    TRACKING = "https://www.xend.com.ph/api/TrackingService.asmx"
  end
end