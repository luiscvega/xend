require_relative "helper"

# RateService
test "calculate" do
  response = Xend::Rate.calculate(weight: 1)
  rate = response.rate
  assert_equal "64.960000", rate
end

# ShipmentService
test "get" do
  response = Xend::Shipment.get(waybillno: "733603482")
  waybill = response.waybill
  assert_equal "733603482", waybill["WayBillNo"][0]
end
