require 'ap'
require 'open3'
require 'xmlsimple'

class Xend
  def self.curl(soap)
    Open3.capture3('curl -H "Content-Type: text/xml" -d @../templates/rate-calculate.xml %s' % soap)
  end

  def self.xml(raw_xml)
    XmlSimple.xml_in(raw_xml)
  end

  class Rate < Xend
    SOAP = "https://www.xend.com.ph/api/RateService.asmx"

    def self.calculate
      stdout, stderr, res = curl(SOAP)

      response = xml stdout

      rate = response["Body"][0]["CalculateResponse"][0]["CalculateResult"][0]

    end
  end

end