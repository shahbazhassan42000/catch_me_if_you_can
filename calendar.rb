require_relative 'event'

class Calendar
  MAX_YEAR = DateTime.new(2025, 1, 1)
  MIN_YEAR = DateTime.new(2015, 1, 1)

  def initialize
    @events = {}
  end

  def view_event(key)
    events = search_events(key)
    if events&.size&.positive?
      if events.count.eql?(1) # if only one event exists
        Event.display_header
        events.first.display
      else
        loop do
          choice = event_selection(events)
          if choice.downcase.eql?('q')
            puts 'Returning to back menu...'
            sleep(1)
            break
          elsif choice.to_i.between?(1, events.count) # if choice is valid
            Event.display_header
            events[choice.to_i - 1].display
          else
            puts 'Invalid choice, please try again'
          end
          pause
        end
      end
    else
      puts 'No events found.'
    end
  end

  def delete_events(key)
    events = search_events(key)
    if events&.size&.positive?
      if events.count.eql?(1) # if only one event exists
        delete_event(events.first)
      else
        loop do
          choice = event_selection(events)
          if choice.downcase.eql?('q')
            puts 'Returning to back menu...'
            sleep(1)
            break
          elsif choice.to_i.between?(1, events.count) # if choice is valid
            delete_event(events[choice.to_i - 1])
            events = search_events(key) # update events after deletion
          else
            puts 'Invalid choice, please try again'
          end
          break unless events # return to main menu if all events deleted

          pause
        end
      end
    else
      puts 'No events found.'
    end
  end

  def view_month_events(date, list_view)
    events = @events["#{date.year}-#{date.month}"]
    if events&.size&.positive?
      puts "Events for #{date.strftime('%B %Y')}: "
      if list_view
        events.sort.each do |day, events|
          puts "\nEvents for #{events.first.date.to_date}: "
          Event.display_header
          events.each(&:display)
        end
      else # calendar view
        days = get_month_days(date)
        puts "Sun\t\tMon\t\tTue\t\tWed\t\tThu\t\tFri\t\tSat\n\n" # Calender view header
        puts '-' * 100 # separator line
        counter = 0 # used for display days in a row week wise
        date.wday.times do # indentaiton for first day of the month
          print "\t\t"
          counter += 1
        end
        (1..days).each do |day|
          print day
          counter += 1
          print "[#{events[day].count}]" if events[day] # printing events count in square brackets
          print "\t\t"
          print "\n\n" if (counter % 7).zero? # new line after 7 days
        end
      end
    else
      puts "No events found against #{date.strftime('%B %Y')}"
    end
  end

  def edit_events(key)
    events = search_events(key)
    if events&.size&.positive?
      if events.count.eql?(1) # if only one event exists
        edit_event(events.first)
      else
        loop do
          choice = event_selection(events)
          if choice.downcase.eql?('q')
            puts 'Returning to back menu...'
            sleep(1)
            break
          elsif choice.to_i.between?(1, events.count) # if choice is valid
            edit_event(events[choice.to_i - 1])
          else
            puts 'Invalid choice, please try again'
          end
          pause
        end
      end
    else
      puts 'No events found.'
    end
  end

  def view_all_events
    puts 'No events found' if @events.empty?
    @events.sort.each do |key, days|
      days.sort.each do |day, events|
        puts "\nEvents for #{events.first.date.to_date}: "
        Event.display_header
        events.each(&:display)
      end
    end
  end

  def add_event(event) # event is a hash
    date = event[:date]
    key = "#{date.year}-#{date.month}"
    event = Event.new(event)
    if @events[key] # check if year and month exits
      if @events[key][date.day] # check if day exits
        @events[key][date.day] << event
      else # day not exits
        @events[key][date.day] = [event]
      end
    else # year and month not exits
      @events[key] = { date.day => [event] }
    end
  end

  private

  def get_month_days(date)
    if date.month.eql?(2)
      date.leap? ? 29 : 28
    else
      [4, 6, 9, 11].include?(date.month) ? 30 : 31
    end
  end

  def event_selection(events)
    puts "\n#{events.count} events found\n"
    events.each.with_index(1) do |event, index|
      puts "#{index}. #{event.name} on #{event.date.to_date} at #{event.time}"
    end
    puts 'q. Return to back menu'
    print 'Select any event: '
    gets.chomp
  end

  def search_events(key)
    filtered_events = []
    if key.is_a?(String) # search by name
      @events.each_value do |days|
        days.each_value do |events|
          events.each do |event|
            filtered_events << event if event.name.eql?(key)
          end
        end
      end
    else # search by date
      date = "#{key.year}-#{key.month}"
      filtered_events = @events.dig(date, key.day)
    end
    filtered_events
  end

  def delete_event(event)
    key = "#{event.date.year}-#{event.date.month}"
    day = event.date.day
    deleted_event = @events[key][day].delete(event)
    if deleted_event # if event deleted
      if @events[key][day].empty? # if all events deleted for a day then delete that day
        @events[key].delete(day)
        @events.delete(key) if @events[key].empty? # if all days deleted for a month then delete that month
      end
      puts 'Event deleted successfully'
    else
      puts 'Event not deleted, please try again'
    end
  end

  def add_participants(event)
    loop do
      puts "\t\t\tNOTE: Enter exit to return to back menu"
      print 'Add new participants (comma separated i.e., a,b,c): '
      participants = gets.chomp
      break if participants.downcase.eql?('exit')

      if participants.empty?
        puts 'Participants can not be empty, please try again'
        next
      end
      participants = participants.split(',').map(&:strip)
      participants.delete('') # delete empty strings from the array
      break if event.participants += participants
    end
  end

  def remove_participant(event)
    if event.participants.empty?
      puts 'No participants found, please add participants first'
      pause
    elsif event.participants.count.eql?(1) # if only one participant exists
      event.participants = []
      puts 'Participant removed successfully'
    else # multiple participants exists
      loop do
        event.participants.each.with_index(1) do |participant, index|
          puts "\t\t\t\t#{index}. #{participant}"
        end
        puts "\t\t\t\t#{event.participants.size + 1}. Remove all participants"
        puts "\t\t\t\t#{event.participants.size + 2}. Return to back menu"
        print "\nSelect participants to remove: "
        index = gets.chomp.to_i
        if index.eql?(event.participants.size + 1)
          event.participants = []
          puts 'All participants removed successfully'
          break
        elsif index.eql?(event.participants.size + 2)
          puts 'Returning to back menu...'
          sleep(1)
          break
        elsif index.between?(1, event.participants.count)
          event.participants.delete_at(index - 1)
          break if event.participants.empty?
        else
          puts 'Invalid selection, please try again'
          pause
        end
        puts "\n"
      end
    end
  end

  def edit_participants(event)
    if event.participants.empty?
      participants = take_input('participants (comma separated i.e., a,b,c)', false)
      return unless participants

      event.participants = participants
    else # participants found
      loop do
        print "
participants: [#{event.participants.join(', ')}]

            1. Add new participants
            2. Remove participant
            3. Return to back menu

Enter your choice: "
        choice = gets.chomp
        case choice
        when '1' then add_participants(event) # add new participants
        when '2' then remove_participant(event) # remove participant
        when '3'
          puts 'Returning to back menu...'
          sleep(1)
          break
        else
          puts 'Invalid choice, please try again'
          pause
        end
      end
    end
  end

  def edit_event(event)
    loop do
      Event.display_header
      event.display
      print "

        1. Edit event name
        2. Edit event time
        3. Edit event place
        4. Edit event participants
        5. Return to back menu

Enter your choice: "
      choice = gets.chomp
      case choice
      when '1' # edit name
        name = take_input('name', true)
        break unless name # return to back menu if user enters exit

        event.name = name
      when '2' # edit time
        time = take_input('time', true)
        break unless time

        event.time = time
      when '3' # edit place
        place = take_input('place', false)
        break unless place

        event.place = place
      when '4'
        break unless edit_participants(event)
      when '5'
        puts 'Returning to back menu...'
        sleep(1)
        break
      else
        puts 'Invalid choice, please try again'
        pause
      end
    end
  end
end
