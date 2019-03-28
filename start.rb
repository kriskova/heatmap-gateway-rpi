require 'rubygems'
require 'serialport'
require 'unirest'

MAC_PATH = '/dev/cu.usbmodem1452401'.freeze
LINUX_PATH = '/dev/ttyACM0'.freeze
BAUD_RATE = 9600
DATA_BITS = 8
STOP_BITS = 1
PARITY = SerialPort::NONE

MESSAGE_REGEX = /nodeid: [0-9]{1,3} temp: [0-9]{1,2}.[0-9]{2} humidity: [0-9]{1,2}.[0-9]{2}/

def serial_path
  File.exists?(MAC_PATH) ? MAC_PATH : LINUX_PATH
end

serial = SerialPort.new(serial_path, BAUD_RATE, DATA_BITS, STOP_BITS, PARITY)

loop do
  puts 'Waiting for data...'
  line = serial.readline("\r")

  if MESSAGE_REGEX.match? line
    # nodeid: 100 temp: 25.60 humidity: 54.80
    # nodeid: 100 temp: nan humidity: nan
    parsed = line.split

    # node, temp, humidity
    puts parsed.inspect
    response = Unirest.post "http://httpbin.org/post",
      headers: { "Accept" => "application/json" },
      parameters: { humidity: parsed[3], temp: parsed[5] }
    puts response.code
  else
    puts 'Unrecognized message format'
  end

  sleep 1
end
