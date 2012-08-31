require_relative "helper"

# Formula
test "formula with weight with tax" do
  rate = Xend::Formula.calculate(Xend::MetroManila_RATES, 1)
  api_rate = Xend::Rate.calculate(type: Xend::MetroManila,
                                  weight: 1, length: 10, width: 10, height: 10)
  assert_equal api_rate.to_f, rate
end

test "formula via dimensions" do
  weight = Xend::Formula.get_volume_weight(12, 12, 10)
  assert_equal 0.42, weight
end

test "formula with heavy shipment" do
  rate = Xend::Formula.calculate(Xend::MetroManila_RATES, 4)
  api_rate = Xend::Rate.calculate(type: Xend::MetroManila,
                                  weight: 4, length: 10, width: 10, height: 10)
  assert_equal api_rate.to_f, rate
end

test "formula with complete information (Weight & Dimensions)" do
  params = { weight: 1, length: 12, width: 10, height: 10 }
  rate = Xend::Formula.calculate_complete(Xend::MetroManila_RATES, params)
  api_rate = Xend::Rate.calculate({ type: Xend::MetroManila }.merge!(params))
  
  assert_equal api_rate.to_f, rate
end

test "formula with complete information (Weight & Dimensions) but volume weight is followed" do
  params = { weight: 100, length: 100, width: 100, height: 100 }
  rate = Xend::Formula.calculate_complete(Xend::MetroManila_RATES, params)
  api_rate = Xend::Rate.calculate({ type: Xend::MetroManila }.merge!(params))

  assert_equal api_rate.to_f, rate
end

# RateService
test "calculate small Metro Manila" do
  rate = Xend::Rate.calculate(type: Xend::MetroManila,
                              weight: 1, length: 10, width: 10, height: 10)
  assert_equal "64.960000", rate
end

test "calculate medium Metro Manila" do
  rate = Xend::Rate.calculate(type: Xend::MetroManila,
                              weight: 1, length: 50, width: 50, height: 50)
  assert_equal "928.480000", rate
end

test "calculate big Metro Manila" do
  rate = Xend::Rate.calculate(type: Xend::MetroManila,
                              weight: 1, length: 1000, width: 1000, height: 1000)
  assert_equal nil, rate
end

# test "calculate small Rizal" do
#   rate = Xend::Rate.calculate(type: Xend::Rizal,
#                               weight: 1.0, length: 0, width: 0, height: 0)
#   assert_equal "77.280000", rate
# end

test "calculate small Province" do
  rate = Xend::Rate.calculate(type: Xend::Provincial, province: "Abra",
                              weight: 1, length: 10, width: 10, height: 10)
  assert_equal "79.520000", rate
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