#!/usr/bin/env ruby

require_relative 'Uploader'

puts "Checking for networks"

wigle = UploadWorker.new
wigle.upload("/home/pi/BNScanner/to_upload") if `iwconfig`.include? "Nanterre"

# add a wlan0 subinterface to allow channel hopping
unless `iwconfig`.include? "wlan0mon"
    system("sudo iw dev wlan0 interface add wlan0mon type monitor")
end

# cut power to wlan0 (aka the wifi module)
system "sudo iwconfig wlan0 txpower off"
sleep 1

# switch wlan0 to monitor mode
system "sudo iwconfig wlan0 mode monitor"
sleep 5

# reinitiate power to wlan0
system "sudo iwconfig wlan0 txpower on"

# trigger kismet_server and place logfiles in to_upload directory
while true
    puts "Sniffing..."
    system "timeout 120 kismet_server -p /home/pi/BNScanner/to_upload"
end
