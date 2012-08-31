require "mote"
require 'open3'
require 'xmlsimple'
require_relative 'settings'

class Xend
  include Settings
  extend Mote::Helpers

  MetroManila           = "MetroManilaExpress"
  Rizal                 = "RizalMetroManilaExpress"
  Provincial            = "ProvincialExpress"
  InternationalPostal   = "InternationalPostal"
  InternationalEMS      = "InternationalEMS"
  InternationalExpress  = "InternationalExpress"

  MetroManila_RATES = {
    (0.01..0.50) => 44.00,
    (0.51..1.00) => 58.00,
    (1.01..1.50) => 75.00,
    (1.51..2.00) => 81.00,
    (2.01..2.50) => 99.00,
    (2.51..3.00) => 103.00,
  }

  Error = Class.new(StandardError)
  TEMPLATES = File.expand_path("../templates", File.dirname(__FILE__))

private

  def self.payload(soap, file, params)
    Curl.post(soap, 
              mote(File.join(TEMPLATES, "#{file}.xml"), params),
              "-H 'Content-Type: text/xml; charset=utf-8'")
  end

  class Rate < Xend
    def self.calculate(params)
      response = RateResponse.new(payload(Settings::SOAP::RATE, "rate-calculate", params))
      response.rate
    end
  end

  class Shipment < Xend
    def self.get(params)
      response = ShipmentResponse.new(payload(Settings::SOAP::SHIPMENT, "shipment-get", params))
      response.shipment
    end

    def self.create(params)
      response = ShipmentResponse.new(payload(Settings::SOAP::SHIPMENT, "shipment-create", params))
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
      @data["CalculateResponse"] && @data["CalculateResponse"]["CalculateResult"]
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
    # Usage: Xend::Formulat.calculate(Xend::MetroManila_RATES, 10)
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
    # Usage: Xend::Formulat.calculate_complete(Xend::MetroManila_RATES, weight: 10, length: 10, width: 10, height: 10)
    #
    def self.calculate_complete(rates, params)
      weight_rate = calculate(rates, params[:weight])
      volume_rate = calculate(rates, get_volume_weight(params[:length], params[:width], params[:height]))

      return [weight_rate, volume_rate].max
    end

    # Use this if you want to calculate volumetric weight from dimensions only
    #
    # Usage: Xend::Formulat.get_volume_weight(10, 10, 10)
    #
    def self.get_volume_weight(l,w,h)
      volume_weight = round_up([l,w,h].inject(&:*)/3500.0)
    end

  private

    # Round up to the nearest tenths
    def self.round_up(number)
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