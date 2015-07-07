require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist
Capybara.run_server = true
Capybara.default_driver = :poltergeist
Capybara.current_session.driver.headers = {"User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.124 Safari/537.36"}
Capybara.app_host = 'https://wigle.net'

class UploadWorker
    include Capybara::DSL

    def upload
        begin
            print "visiting wigle..."
            visit '/uploads'
            click_on 'topBarLogin'
            fill_in('cred0', :with => 'bastille')
            fill_in('cred1', :with => 'SDRsrock')
            find('.regbutton').click
            while not page.has_css?('#topBarLogout') do
        	print "."
            end
            puts "Logged in."
            unless (Dir.entries('/home/pi/BNScanner/to_upload') - %w{. ..}).empty?
                Dir.foreach('/home/pi/BNScanner/to_upload') do |logfile|
                    begin
                        path = "/home/pi/BNScanner/to_upload/#{logfile}"
                        next if logfile == '.' or logfile == '..' or File.zero?(path)
                        print "Uploading #{logfile}..."
                        find('#uploadButton').click
            		    find('input[name="stumblefile"]')
            		    attach_file("stumblefile", path)
            		    find('input[name="Send"]').click
                        while not page.has_css?('.statsSection') do
                            print "."
                        end
    		            puts "done"
                        click_on "Return to your uploads page"
                    rescue
                        next
                    end
                end
            end
            system('sudo rm /home/pi/BNScanner/to_upload/*')
        rescue
            puts "Error occured. Rebooting..."
            system("sudo reboot")
        end
    end
end
