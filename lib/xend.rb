require "mote"
require 'open3'
require 'xmlsimple'
require_relative 'settings'

class Xend
  include Settings
  extend Mote::Helpers
  MetroManila = "MetroManilaExpress"

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