require 'ap'
require 'open3'
require 'xmlsimple'

class Xend
  def self.request(file, soap)
    Open3.capture3('curl -H "Content-Type: text/xml" -d @../templates/%s.xml %s' % [file, soap])
  end

  class Rate < Xend
    SOAP = "https://www.xend.com.ph/api/RateService.asmx"

    def self.calculate
      stdout, stderr, res = request("rate-calculate", SOAP)
      XmlSimple.xml_in(stdout)["Body"][0]["CalculateResponse"][0]["CalculateResult"][0]
    end
  end

  class Shipment < Xend
    SOAP = "https://www.xend.com.ph/api/ShipmentService.asmx"

    def self.get
      stdout, stderr, res = request("shipment-get", SOAP)

      XmlSimple.xml_in(stdout)
    end

  end

end