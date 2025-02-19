require 'date'

class Event
  # regex for validating time, invalid time formats are 00:00 AM, 1:30 PM, 12:30 CM, 12:30 AMM
  # valid time examples: 12:59 AM, 01:00 PM, 10:00 pm, 11:00 Am, 06:00 Pm
  TIME_REGEX = /^(0[1-9]|1[0-2]):[0-5][0-9] (AM|PM|am|pm|Am|Pm)$/.freeze
  @@id = 0 # global ID counter for auto incrmenting ID

  attr_accessor :name, :place, :participants, :date, :time
  attr_reader :id

  # receives a hash of event attributes
  def initialize(event)
    @@id += 1
    @id = @@id
    @name = event[:name]
    @date = event[:date]
    @time = validate_time(event[:time])
    @place = event[:place]
    @participants = event[:participants]
  end

  def display
    print '%-5s | %-20s | %-8s | %-10s | %-20s | ' % [id, name, time, date.to_date, place]
    print participants.join(', ')
    print "\n"
  end

  def self.display_header
    puts '  ID  | %12s %-7s |   %-6s |    %-7s |        %-13s |     %s' % ['Name', '', 'Time', 'Date', 'Place', 'Participants']
    puts '-' * 100
  end
end
