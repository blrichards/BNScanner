require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist
Capybara.run_server = false
Capybara.default_driver = :poltergeist
Capybara.app_host = 'https://wigle.net'

class Sniffer
    include Capybara::DSL

    # makes sure all the proper interfaces are present
    def configInterfaces
        if not `iwconfig`.include? "wlan0mon"
            system("sudo iw dev wlan0 interface add wlan0mon type monitor")
            puts "wlan0mon was added to interfaces"
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
        system("kismet_server -p to_upload") # change location to 'to_upload' dir
    end

    def networkIsAvailable
        if not `iwconfig`.include? "Nanterre"
            system("sudo reboot")
        end
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
            sleep(5)
            attach_file('stumblefile', path)
            sleep(5)
            find('input[type="submit"]').click
            sleep(5)
            visit '/uploads'
        end
        system('rm to_upload/*')
    end
end

BNSniffer = Sniffer. new

BNSniffer.networkIsAvailable()
BNSniffer.upload()
BNSniffer.configInterfaces()
BNSniffer.monitor()
BNSniffer.startCollecting()
