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
	sleep 5
        puts "visiting wigle..."
        visit '/uploads'
        click_link 'topBarLogin'
        fill_in('cred0', :with => 'blrichards')
        fill_in('cred1', :with => 'Benton97')
        click_button 'Login'
        puts "Logged in."
        unless (Dir.entries('/home/pi/BNScanner/to_upload') - %w{. ..}).empty?
            Dir.foreach('/home/pi/BNScanner/to_upload') do |logfile|
                next if logfile == '.' or logfile == '..'
                path = "/home/pi/BNScanner/to_upload/#{logfile}"
                # find '#topBarLogout'
                sleep(8)
                puts "Uploading...#{logfile}"
                click_on 'uploadButton'
                sleep(8)
                attach_file('stumblefile', path)
                sleep(8)
                find('input[type="submit"]').click
                sleep(8)
                visit '/uploads'
            end
        end
        system('sudo rm /home/pi/BNScanner/to_upload/Kismet*')
    end
end
