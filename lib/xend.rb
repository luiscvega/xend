require 'ap'
require 'open3'
require 'xmlsimple'

# This works
stdout, stderr, res = Open3.capture3('curl -H "Content-Type: text/xml" -d @calculate.xml https://www.xend.com.ph/api/RateService.asmx')

# This doesn't (unauthorized caller, might be wrong sandbox user token?)
stdout, stderr, res = Open3.capture3('curl -H "Content-Type: text/xml" -d @schedule.xml https://www.xend.com.ph/apitest/BookingService.asmx')

ap XmlSimple.xml_in(stdout)