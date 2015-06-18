require_relative 'Uploader'

wigle = UploadWorker.new

if `iwconfig`.include? "Nanterre"
    wigle.upload
end

if not `iwconfig`.include? "wlan0mon"
    system("sudo iw dev wlan0 interface add wlan0mon type monitor")
end

system "sudo iwconfig wlan0 txpower off"
sleep 1
system "sudo iwconfig wlan0 mode monitor"
sleep 5
system "sudo iwconfig wlan0 txpower on"

system "kismet_server -p to_upload"
