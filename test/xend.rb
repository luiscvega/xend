require_relative "helper"

# RateService
test "calculate" do
  response = Xend::Rate.calculate
  rate = response.rate
  assert_equal "64.960000", rate
end

# ShipmentService
test "get" do
  response = Xend::Shipment.get
  waybill = response.waybill
  assert_equal "733603482", waybill["WayBillNo"][0]
end
