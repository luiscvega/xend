require 'ap'
require 'open3'
require 'xmlsimple'

class Xend
  TEMPLATES = File.expand_path("../templates", File.dirname(__FILE__))

  def self.post(file, soap)
    stdout, stderr, res = Open3.capture3('curl -H "Content-Type: text/xml" -d @%s %s' % [File.join(TEMPLATES, "%s.xml" % file), soap])

    return stdout
  end
  
  class Rate < Xend
    SOAP = "https://www.xend.com.ph/api/RateService.asmx"

    def self.calculate
      Response.new(post("rate-calculate", SOAP))
    end
  end

  class Shipment < Xend
    SOAP = "https://www.xend.com.ph/api/ShipmentService.asmx"

    def self.get
      Response.new(post("shipment-get", SOAP))
    end

  end

  class Response
    def initialize(xml)
      @data = XmlSimple.xml_in(xml)
    end

    def rate
      @data["Body"][0]["CalculateResponse"][0]["CalculateResult"][0]
    end

    def waybill
      @data["Body"][0]["GetResponse"][0]["GetResult"][0]["WayBillNo"][0]
    end
  end
end
