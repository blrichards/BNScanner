require 'capybara'
require 'capybara/dsl'
require 'capybara-webkit'
require 'capybara/poltergeist'

include Capybara::DSL

Capybara.javascript_driver = :webkit
Capybara.run_server = true
Capybara.default_driver = :webkit
Capybara.app_host = 'https://wigle.net'

# makes sure all the proper interfaces are present
def configInterfaces
    if not `iwconfig`.include? "wlan0mon"
        system("sudo iw dev wlan0 interface add wlan0mon type monitor")
        system("echo 'wlan0mon was added to interfaces'")
    end
    puts "wireless interfaces have been configured"
end

# puts all wifi interfaces into monitor mode
def monitor
    if not `iwconfig wlan0`.include? "Monitor"
        system("sudo iwconfig wlan0 txpower off")
        sleep(1)
        system("sudo iwconfig wlan0 mode monitor")
        sleep(1)
        system("sudo iwconfig wlan0")
        sleep(5)
        system("sudo iwconfig wlan0 txpower on")
    end

    if not `iwconfig wlan0mon`.include? "Monitor"
        system("sudo iwconfig wlan0mon txpower off")
        sleep(1)
        system("sudo iwconfig wlan0mon mode monitor")
        sleep(1)
        system("sudo iwconfig wlan0mon")
        sleep(5)
        system("sudo iwconfig wlan0mon txpower on")
    end
    puts "wlan0 and wlan0mon are now in monitor mode"
end

# puts all wifi interfaces into managed mode
def managed
    if not `iwconfig wlan0`.include? "Managed"
        system("sudo iwconfig wlan0 txpower off")
        sleep(1)
        system("sudo iwconfig wlan0 mode managed")
        sleep(1)
        system("sudo iwconfig wlan0")
        sleep(5)
        system("sudo iwconfig wlan0 txpower on")
    end

    if not `iwconfig wlan0mon`.include? "Managed"
        system("sudo iwconfig wlan0mon txpower off")
        sleep(1)
        system("sudo iwconfig wlan0mon mode managed")
        sleep(1)
        system("sudo iwconfig wlan0mon")
        sleep(5);
        system("sudo iwconfig wlan0mon txpower on")
    end
    puts "wlan0 and wlan0mon are now being managed"
end

# starts collection
def startCollecting
    system("sudo kismet_server -p to_upload") # change location to 'to_upload' dir
end

def networkIsAvailable
    if not `iwconfig wlan0`.include? "Managed"
        managed()
    end

    wifi = true
    i = 0

    while wifi and i < 4 do
        if `iwconfig`.include? "Nanterre"
            wifi = false
        else
            sleep(3)
        end
    	i += 1
    end

    # if wifi
    # 	system("sudo reboot")
    # end

    sleep(3)

    return wifi
end

def upload
    puts "visiting wigle..."
    visit '/uploads'
    click_link 'topBarLogin'
    fill_in('cred0', :with => 'blrichards')
    fill_in('cred1', :with => 'Benton97')
    click_button 'Login'
    puts "Logged in."
    Dir.foreach('/ruby-sniffer/to_upload') do |logfile|
        path = "/ruby-sniffer/to_upload/#{logfile}"
        find("#topBarLogout")
        puts "Uploading..."
        click_on 'uploadButton'
        sleep(2)
        attach_file('stumblefile', path)
        sleep(2)
        find('input[type="submit"]').click
        sleep(2)
        visit '/uploads'
    end
    system('rm to_upload/*')
end

networkIsAvailable()
configInterfaces()
upload()
monitor()
startCollecting()
