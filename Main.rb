require './Sniffer'
Bundler.require

networkIsAvailable()
configInterfaces()
upload()
monitor()
startCollecting()
