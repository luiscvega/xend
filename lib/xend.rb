require 'ap'
require 'open3'
require 'xmlsimple'

stdout, stderr, res = Open3.capture3('curl -H "Content-Type: text/xml" -v -d @schedule.xml https://www.xend.com.ph/apitest/BookingService.asmx')


ap XmlSimple.xml_in(stdout)