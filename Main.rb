require './Sniffer'
require './Upload'

networkIsAvailable()
configInterfaces()
# Upload if networkIsAvailable() end
monitor()
startCollecting()
