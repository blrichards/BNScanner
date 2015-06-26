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
        puts "visiting wigle..."
        visit '/uploads'
        click_on 'topBarLogin'
        fill_in('cred0', :with => 'blrichards')
        fill_in('cred1', :with => 'Benton97')
        find('.regbutton').click
	while not page.has_css?('#topBarLogout') do
	    print "."
	end
	# find('.userText')
        puts "Logged in."
        unless (Dir.entries('/home/pi/BNScanner/to_upload') - %w{. ..}).empty?
        # unless (Dir.entries('/Users/benrichards/Projects/BNScanner/to_upload') - %w{. ..}).empty?
            Dir.foreach('/home/pi/BNScanner/to_upload') do |logfile|
            # Dir.foreach('/Users/benrichards/Projects/BNScanner/to_upload') do |logfile|
                next if logfile == '.' or logfile == '..'
                # path = "/home/pi/BNScanner/to_upload/#{logfile}"
                path = "/Users/benrichards/Projects/BNScanner/to_upload/#{logfile}"
                puts "Uploading...#{logfile}"
                find('#uploadButton').trigger('click')
                save_and_open_screenshot
                attach_file('stumblefile', path)
                # find('stumblefile').attach_file(path)
                find('input[name="Send"]').click
                sleep 3 # may need to be increased
                visit '/uploads'
            end
        end
        system('sudo rm /home/pi/BNScanner/to_upload/Kismet*')
    end
end

wigle = UploadWorker.new

wigle.upload
