require_relative "helper"

# RateService
test "calculate" do
  rate = Xend::Rate.calculate
  assert_equal "64.960000", rate
end

# ShipmentService
test "get" do
  waybill = Xend::Shipment.get
  assert_equal "733603482", waybill["Body"][0]["GetResponse"][0]["GetResult"][0]["WayBillNo"][0]
end
