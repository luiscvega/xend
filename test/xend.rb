require_relative "helper"

# RateCalculator
test "calculate" do
  rate = Xend::Rate.calculate
  assert_equal "64.960000", rate
end
