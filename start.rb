require 'rubygems'
require 'serialport'
require 'unirest'

MAC_PATH = '/dev/cu.usbmodem1452401'.freeze
LINUX_PATH = '/dev/ttyACM0'.freeze
BAUD_RATE = 9600
DATA_BITS = 8
STOP_BITS = 1
PARITY = SerialPort::NONE
HOST = 'https://creative-capital-2019.herokuapp.com'.freeze

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
    _, node_id, _, temp, _, hum = line.chomp.split

    post_url = "#{HOST}/nodes/#{node_id}/data"

    puts "Posting to #{post_url}"
    puts "Data: #{[node_id, temp, hum]}"

    response = Unirest.post post_url,
      headers: { "Accept" => "application/json" },
      parameters: { humidity: hum, temperature: temp }
    puts response.code
  else
    puts 'Unrecognized message format'
  end

  sleep 1
end
