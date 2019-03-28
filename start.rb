require 'rubygems'
require 'serialport'
require 'unirest'

PORT_PATH = '/dev/cu.usbmodem1452401'
BAUD_RATE = 9600
DATA_BITS = 8
STOP_BITS = 1
PARITY = SerialPort::NONE

serial = SerialPort.new(PORT_PATH, BAUD_RATE, DATA_BITS, STOP_BITS, PARITY)

loop do
  puts 'Waiting for data...'
  line = serial.readline("\r")
  parsed = line.scan(/([0-9]{1,2}.[0-9]{2})/)

  # [Humidity, Temp]
  puts parsed.flatten.inspect
  response = Unirest.post "http://httpbin.org/post",
                        headers: { "Accept" => "application/json" },
                        parameters: { humidity: parsed.first, temp: parsed.last }
  puts response.code
  sleep 1
end
