require './Sniffer'
require 'capybara'
require 'bundler'
Bundler.require

networkIsAvailable()
configInterfaces()
upload()
monitor()
startCollecting()
