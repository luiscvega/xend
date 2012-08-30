require_relative "helper"

# RateService
test "calculate small" do
  rate = Xend::Rate.calculate(type: Xend::MetroManila,
                              weight: 1, length: 10, width: 10, height: 10)
  assert_equal "64.960000", rate
end

test "calculate medium" do
  rate = Xend::Rate.calculate(type: Xend::MetroManila,
                              weight: 1, length: 50, width: 50, height: 50)
  assert_equal "928.480000", rate
end

test "calculate big" do
  rate = Xend::Rate.calculate(type: Xend::MetroManila,
                              weight: 1, length: 1000, width: 1000, height: 1000)
  assert_equal nil, rate
end

# ShipmentService
test "create" do
  info = { type: Xend::MetroManila, weight: 1, length: 10, width: 10, height: 10,
           name: "Miguel Cacnio", address1: "123 Testing Street", city: "Quezon City", 
           province: "Metro Manila", zip: "1103" }
  waybillno = Xend::Shipment.create(info)
  shipment = Xend::Shipment.get(waybillno: waybillno)
  assert_equal waybillno, shipment["WayBillNo"]
  assert_equal "Miguel Cacnio", shipment["RecipientName"]
end