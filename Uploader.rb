require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'logger'

Capybara.javascript_driver = :poltergeist
Capybara.run_server = true
Capybara.default_driver = :poltergeist
Capybara.current_session.driver.headers = {"User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.124 Safari/537.36"}
Capybara.app_host = 'https://wigle.net'

class UploadWorker
    include Capybara::DSL

    def upload(path)
        # start error logs
        conLogger = Logger.new('log_files/connection_error.log')
        upLogger = Logger.new('log_files/upload_error.log')

        # check if upload folder is empty
        unless (Dir.entries(path) - %w{. ..}).empty?

            #connects to wigle
            begin
                print "\nvisiting wigle..."
                visit '/uploads'
                click_on 'topBarLogin'
                fill_in('cred0', :with => 'bastille')
                fill_in('cred1', :with => 'SDRsrock')
                find('.regbutton').click
                print "." until page.has_css?('#topBarLogout')
                puts "Logged in."
            rescue Exception => e
                conLogger.error e.message
                puts "\nConnection error occured. \nRebooting network"
                system("sudo /etc/init.d/networking restart")
                print "." until `iwconfig`.include? "Nanterre"
                retry
            end

            # starts uploading files one by one
            Dir.foreach(path) do |captureFile|
                tries = 0
                begin
                    throw :moveOn if tries == 3
                    uploadFile = "#{path}/#{captureFile}"
                    next if captureFile == '.' or captureFile == '..' or File.zero?(uploadFile)
                    print "Uploading #{captureFile}..."
                    find('#uploadButton').click
        		    find('input[name="stumblefile"]')
        		    attach_file("stumblefile", uploadFile)
        		    find('input[name="Send"]').click
                    print "." until page.has_css?('.statsSection')
                rescue Exception => e
                    tries += 1
                    upLogger.error e.message
                    puts "\nProblem occured uploading file. #{x} more tries"
                    retry
                end
                puts "success"

                catch :moveOn do
                    puts "\nFile could not be uploaded. Moving on..."
                    next
                end
            end
        end

        upLogger.close
        conLogger.close

        # deletes uploaded files
        system 'sudo rm /home/pi/BNScanner/to_upload/*'
    end
end
