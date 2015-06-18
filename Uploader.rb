require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist
Capybara.run_server = false
Capybara.default_driver = :poltergeist
Capybara.app_host = 'https://wigle.net'

class UploadWorker
    include Capybara::DSL

    def upload
        puts "visiting wigle..."
        visit '/uploads'
        click_link 'topBarLogin'
        fill_in('cred0', :with => 'blrichards')
        fill_in('cred1', :with => 'Benton97')
        click_button 'Login'
        puts "Logged in."
        Dir.foreach('/root/BNScanner/to_upload') do |logfile|
            next if logfile == '.' or logfile == '..'
            path = "/root/BNScanner/to_upload/#{logfile}"
            sleep(3)
            puts "Uploading...#{logfile}"
            click_on 'uploadButton'
            sleep(2)
            attach_file('stumblefile', path)
            sleep(2)
            find('input[type="submit"]').click
            sleep(2)
            visit '/uploads'
        end
        system('sudo rm /home/pi/BNScanner/to_upload/*')
    end
end
