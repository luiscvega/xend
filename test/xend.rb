require_relative "helper"

# RateService
test "calculate" do
  rate = Xend::Rate.calculate(weight: 1, length: 10, width: 10, height: 10)
  assert_equal "64.960000", rate
end

test "calculate" do
  rate = Xend::Rate.calculate(weight: 1, length: 50, width: 50, height: 50)
  assert_equal "928.480000", rate
end

test "calculate big" do
  rate = Xend::Rate.calculate(weight: 1, length: 1000, width: 1000, height: 1000)
  assert_equal nil, rate
end

# ShipmentService
test "get" do
  shipment = Xend::Shipment.get(waybillno: "733603482")
  assert_equal "733603482", shipment["WayBillNo"]
  assert_equal "Jon Bon Jovi", shipment["RecipientName"]
end
