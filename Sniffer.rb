#!/usr/bin/env ruby
require_relative 'Uploader'

if `iwconfig wlan0`.include? "Nanterre"
    puts "\n\n\n\nConventional WiFi dongle detected."
    wigle = UploadWorker.new
    wigle.upload("/home/pi/BNScanner/to_upload")
elsif `ifconfig eth0`.include? "inet addr:192.168.1"
    puts "\n\n\n\nEthernet connection detected."
    wigle = UploadWorker.new
    wigle.upload("/home/pi/BNScanner/to_upload")
elsif `iwconfig`.include? "wlan8"
    puts "\n\n\n\nWardriving dongle detected.\nCommencing data collection..."
    system "timeout 120 kismet_server -p /home/pi/BNScanner/to_upload" until false
else
    puts "No data collection tools detected. Please connect to internet or insert wardriving dongle, then reboot."
end
