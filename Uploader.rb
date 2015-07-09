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

    def upload(path)
        puts "Commencing upload..."
        # check if upload folder is empty
        puts "No files to upload " if (Dir.entries(path) - %w{. ..}).empty?
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
            rescue
                puts "\nConnection error occured. \nRebooting network"
                system("sudo /etc/init.d/networking restart")
                retry
            end

            # starts uploading files one by one
            Dir.foreach(path) do |captureFile|
                begin
                    uploadFile = "#{path}/#{captureFile}"
                    next if captureFile == '.' or captureFile == '..' or File.zero?(uploadFile)
                    print "Uploading #{captureFile}..."
                    find('#uploadButton').click
                    find('input[name="stumblefile"]')
                    attach_file("stumblefile", uploadFile)
                    find('input[name="Send"]').click
                    print "." until page.has_css?('.statsSection')
                    click_on "Return to your uploads page"
                rescue
                    puts "failed"
                    next
                end
                puts "success"
            end
            # deletes uploaded files
            system 'sudo rm /home/pi/BNScanner/to_upload/*'
        end
        puts "Upload complete."
    end
end
