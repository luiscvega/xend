require "mote"
require "open3"
require "xmlsimple"

module Xend
  USER_TOKEN   = ENV["XEND_USER_TOKEN"]
  DEVELOPER_ID = ENV["XEND_DEVELOPER_ID"]

  RATE_URL     = "https://www.xend.com.ph/api/RateService.asmx"
  SHIPMENT_URL = "https://www.xend.com.ph/api/ShipmentService.asmx"
  BOOKING_URL  = "https://www.xend.com.ph/api/BookingService.asmx"
  TRACKING_URL = "https://www.xend.com.ph/api/TrackingService.asmx"

  TEMPLATES = File.expand_path("../templates", File.dirname(__FILE__))

  METRO_MANILA          = "MetroManilaExpress"
  RIZAL                 = "RizalMetroManilaExpress"
  PROVINCIAL            = "ProvincialExpress"
  INTERNATIONAL_POSTAL  = "InternationalPostal"
  INTERNATIONAL_EMS     = "InternationalEMS"
  INTERNATIONAL_EXPRESS = "InternationalExpress"

  METRO_MANILA_RATES = {
    (0.01..0.50) => 44.00,
    (0.51..1.00) => 58.00,
    (1.01..1.50) => 75.00,
    (1.51..2.00) => 81.00,
    (2.01..2.50) => 99.00,
    (2.51..3.00) => 103.00,
  }

  Error = Class.new(StandardError)

  module Client
    extend Mote::Helpers

    def self.post(url, payload)
      Curl.post(url, payload, "-H 'Content-Type: text/xml; charset=utf-8'")
    end

    def self.payload(file, params)
      mote(path(file), params)
    end

    def self.path(file)
      File.join(TEMPLATES, "%s.xml" % file)
    end

    def self.rate_calculate(params)
      post(RATE_URL, payload("rate-calculate", params))
    end

    def self.shipment_get(params)
      post(SHIPMENT_URL, payload("shipment-get", params))
    end

    def self.shipment_create(params)
      post(SHIPMENT_URL, payload("shipment-create", params))
    end
  end

  class Rate
    def self.calculate(params)
      response = RateResponse.new(Client.rate_calculate(params))
      response.rate
    end
  end

  class Shipment
    def self.get(params)
      response = ShipmentResponse.new(Client.shipment_get(params))
      response.shipment
    end

    def self.create(params)
      response = ShipmentResponse.new(Client.shipment_create(params))
      response.result
    end
  end

  class Response
    def initialize(xml)
      @data = XmlSimple.xml_in(xml, forcearray: false)["Body"]
    end
  end

  class RateResponse < Response
    def rate
      @data["CalculateResponse"] &&
        @data["CalculateResponse"]["CalculateResult"]
    end
  end

  class ShipmentResponse < Response
    def shipment
      @data["GetResponse"] && @data["GetResponse"]["GetResult"]
    end

    def result
      @data["CreateResponse"] && @data["CreateResponse"]["CreateResult"]
    end
  end

  module Formula
    # Use this if you want to calculate using weight only
    #
    # Usage: Xend::Formulat.calculate(Xend::METRO_MANILA_RATES, 10)
    #
    def self.calculate(rates, weight)
      # Check first if it's heavy. If so, don't check Rates anymore.
      if weight > 3.0
        base_price = 103.00
        overweight = (weight - 3.0).round
        price = base_price + (overweight * 22.00)
        return add_tax price
      end

      # Loop through Rates hash
      rates.each do |range, price|
        return add_tax price if range.include? weight
      end
    end

    # Use this if you want to calculate final price given all details
    #
    # Usage: Xend::Formulat.calculate_complete(Xend::METRO_MANILA_RATES,
    # weight: 10, length: 10, width: 10, height: 10)
    #
    def self.calculate_complete(rates, params)
      weight_rate = calculate(rates, params[:weight])
      volume_rate = calculate(rates, volume_weight(params[:length], params[:width], params[:height]))

      return [weight_rate, volume_rate].max
    end

    # Use this if you want to calculate volumetric weight from
    # dimensions only
    #
    # Usage: Xend::Formulat.volume_weight(10, 10, 10)
    #
    def self.volume_weight(l,w,h)
      volume_weight = roundup([l,w,h].inject(&:*)/3500.0)
    end

  private

    # Round up to the nearest tenths
    def self.roundup(number)
      (number * 100).ceil/100.0
    end

    def self.add_tax(price_before_tax)
      (price_before_tax * 1.12).round(2)
    end

  end

  module Curl
    Error = Class.new(Xend::Error)

    class << self
      attr_accessor :cacert
    end

    def self.post(url, data, options = "")
      options << " --cacert '%s'" % cacert if cacert

      exec("curl -X POST --data @- #{options} #{url}", data)
    end

    def self.exec(cmd, data)
      stdout, stderr, res = Open3.capture3(cmd, stdin_data: data)

      if res.success?
        return stdout
      else
        raise Error, errors(stderr)
      end
    end

    def self.errors(stderr)
      stderr.scan(/^curl: .*$/).join("\n")
    end
  end
end
