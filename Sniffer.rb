require_relative 'Uploader'

wigle = UploadWorker.new

# try to upload if connected to the network
puts "Checking for networks..."
wigle.upload if `iwconfig`.include? "Nanterre"

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
puts "Sniffing..."
system "kismet_server -p to_upload"

# cut power to wlan0 (aka the wifi module)
system "sudo iwconfig wlan0 txpower off"
sleep 1

# switch wlan0 to managed mode
system "sudo iwconfig wlan0 mode managed"
sleep 5

# reinitiate power to wlan0
system "sudo iwconfig wlan0 txpower on"
