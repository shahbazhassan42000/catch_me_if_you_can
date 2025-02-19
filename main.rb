require_relative 'calendar'
require 'io/console'

dummy_data_loaded = false
calender = Calendar.new

def display_menu
  print "

  ██████╗ █████╗ ██╗     ███████╗███╗   ██╗██████╗  █████╗ ██████╗
 ██╔════╝██╔══██╗██║     ██╔════╝████╗  ██║██╔══██╗██╔══██╗██╔══██╗
 ██║     ███████║██║     █████╗  ██╔██╗ ██║██║  ██║███████║██████╔╝
 ██║     ██╔══██║██║     ██╔══╝  ██║╚██╗██║██║  ██║██╔══██║██╔══██╗
 ╚██████╗██║  ██║███████╗███████╗██║ ╚████║██████╔╝██║  ██║██║  ██║
  ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝

0. Load dummy data
1. Add event
2. Delete event
3. Edit event
4. View event
5. View all events of a month
6. Calendar style month view
7. View all events
8. Exit

Enter your choice: "
end

def pause
  print "\nEnter any key to continue... "
  $stdin.getch
end

def validate_date(date, complete_date)
  begin
    if complete_date # if complete_date is true then date must be in YYYY-MM-DD format
      raise ArgumentError unless date.match(/^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$/)
    else # else date must be in YYYY-MM format
      raise ArgumentError unless date.match(/^[0-9]{4}-(0[1-9]|1[0-2])$/)

      date += '-01' # add day to the date in order to parse it by DateTime.parse
    end
    date = DateTime.parse(date)
    if date < Calendar::MIN_YEAR || date > Calendar::MAX_YEAR
      if complete_date
        puts "Out of range date, date must be between #{Calendar::MIN_YEAR.to_date} and #{Calendar::MAX_YEAR.to_date}, please try again later"
      else
        puts "Out of range date, date must be between #{Calendar::MIN_YEAR.strftime('%Y-%M')} and #{Calendar::MAX_YEAR.strftime('%Y-%M')}, please try again"
      end
    else
      date
    end
  rescue ArgumentError
    if complete_date
      puts 'Invalid date, date must be in YYYY-MM-DD format, please try again'
    else
      puts 'Invalid date, date must be in YYYY-MM format, please try again'
    end
  end
end

def validate_time(time)
  Event::TIME_REGEX.match(time) ? time : puts('Invalid time format, it should be in HH:MM AM/PM format')
end

def validate_participants(participants)
  participants = participants.empty? ? [] : participants.split(',').map(&:strip)
  participants.delete('') # delete empty strings from the array
  participants
end

def take_input(name, mandatory, complete_date = true)
  puts "\t\t\tNOTE: Enter exit to return to back menu"
  loop do
    print "Enter #{name}", mandatory ? '*: ' : ': '
    input = gets.chomp
    return if input.downcase == 'exit'

    if input.empty? and mandatory
      puts "#{name.capitalize} can't be empty"
      next
    end
    case name
    when 'date'
      input = validate_date(input, complete_date)
      next unless input
    when 'time'
      input = validate_time(input)
      next unless input
    when 'participants (comma separated i.e., a,b,c)' then input = validate_participants(input)
    when "place or left empty if it's a remote event"
      input = 'Remote' if input.empty?
    end
    return input
  end
end

def add_event(calender)
  name = take_input('name', true)
  return unless name # return to back menu if user enters exit

  date = take_input('date', true)
  return unless date

  time = take_input('time', true)
  return unless time

  place = take_input("place or left empty if it's a remote event", false)
  return unless place

  participants = take_input('participants (comma separated i.e., a,b,c)', false)
  return unless participants

  if calender.add_event(name: name, date: date, time: time, place: place, participants: participants)
    puts 'Event added successfully'
  else
    puts 'Event not added, please try again'
  end
end

def take_seach_key(operation)
  loop do
    print "
    1. #{operation} event by date
    2. #{operation} event by name
    3. Return to main menu

Enter your choice: "
    choice = gets.chomp
    case choice
    when '1'
      input = take_input('date', true)
      return unless input
    when '2'
      input = take_input('name', true)
      return unless input
    when '3'
      puts 'Returning to main menu...'
      sleep 1
      return
    else
      puts 'Invalid choice, please try again'
      pause
      next
    end
    return input
  end
end

def view_event(calender)
  key = take_seach_key('View')
  return unless key

  calender.view_event(key)
end

def edit_event(calender)
  key = take_seach_key('Edit')
  return unless key

  calender.edit_events(key)
end

def delete_event(calender)
  key = take_seach_key('Delete')
  return unless key

  calender.delete_events(key)
end

def view_month_events(calender, list_view)
  date = take_input('date', true, false)
  return unless date

  calender.view_month_events(date, list_view)
end

def load_dummy_date(calender)
  calender.add_event(name: 'Independence Day', date: DateTime.parse('2023-08-14'), time: '10:00 AM', place: 'Amal Academy', participants: ['Shahbaz', 'Shumaim'])
  calender.add_event(name: 'Birthday Party', date: DateTime.parse('2023-08-14'), time: '07:00 PM', place: 'Pizza Hut', participants: ['Ali', 'Sara', 'Zain', 'Hira'])
  calender.add_event(name: 'Meeting', date: DateTime.parse('2023-08-14'), time: '02:00 PM', place: 'Zoom', participants: [])
  calender.add_event(name: 'Movie Night', date: DateTime.parse('2023-08-18'), time: '09:00 PM', place: 'Cinepax', participants: ['Nadia', 'Raima', 'Zara'])
  calender.add_event(name: 'Scrum Meet', date: DateTime.parse('2023-08-14'), time: '10:00 AM', place: '7Vals', participants: ['Shahbaz', 'Nouman'])
  calender.add_event(name: 'Scrum Meet', date: DateTime.parse('2023-08-11'), time: '10:00 AM', place: '7Vals', participants: ['Shahbaz', 'Nouman'])
  calender.add_event(name: 'Scrum Meet', date: DateTime.parse('2023-08-12'), time: '10:00 AM', place: '7Vals', participants: ['Shahbaz', 'Nouman'])
  calender.add_event(name: 'Scrum Meet', date: DateTime.parse('2023-08-13'), time: '10:00 AM', place: '7Vals', participants: ['Shahbaz', 'Nouman'])
  calender.add_event(name: 'Scrum Meet', date: DateTime.parse('2023-08-21'), time: '10:00 AM', place: '7Vals', participants: ['Shahbaz', 'Nouman'])
  calender.add_event(name: 'Scrum Meet', date: DateTime.parse('2023-08-18'), time: '10:00 AM', place: '7Vals', participants: ['Shahbaz', 'Nouman'])
  calender.add_event(name: 'XOXO', date: DateTime.parse('2020-07-10'), time: '01:00 AM', place: 'Haily Tower', participants: ['Shahbaz','Nouman'])
  calender.add_event(name: 'ABC', date: DateTime.parse('2020-07-20'), time: '02:00 AM', place: 'Haily Tower', participants: ['Shahbaz','Nouman'])
  calender.add_event(name: 'XYZ', date: DateTime.parse('2020-07-25'), time: '03:00 AM', place: 'Haily Tower', participants: ['Shahbaz','Nouman'])
  calender.add_event(name: 'Apocalypse', date: DateTime.parse('2018-12-02'), time: '04:00 AM', place: 'NY', participants: ['Shahbaz', 'Jarvis', 'Hulk'])
  calender.add_event(name: 'Apocalypse-II', date: DateTime.parse('2018-12-12'), time: '05:00 AM', place:  'NY', participants: ['Shahbaz', 'Jarvis', 'Hulk'])
  calender.add_event(name: 'Apocalypse-III', date: DateTime.parse('2018-12-22'), time: '06:00 AM', place: 'NY', participants: ['Shahbaz', 'Jarvis', 'Hulk'])
  calender.add_event(name: 'To be deleted', date: DateTime.parse('2023-08-30'), time: '09:30 AM',  participants:[])
  calender.add_event(name: 'To be deleted', date: DateTime.parse('2023-07-10'), time: '03:30 AM', participants:[])
  calender.add_event(name: 'To be deleted', date: DateTime.parse('2020-02-20'), time: '05:30 AM',  participants: ['Shahbaz', 'Jarvis', 'Hulk'])
  calender.add_event(name: 'To be edit', date: DateTime.parse('2023-08-14'), time: '09:30 AM', place: '7Vals', participants: ['Shahbaz','Nouman'])
  calender.add_event(name: 'To be edit-II', date: DateTime.parse('2023-08-14'), time: '09:30 AM', place: '7Vals', participants: ['Shahbaz','Nouman'])
  calender.add_event(name: 'To be edit-III', date: DateTime.parse('2023-08-14'), time: '09:30 AM', place: '7Vals', participants: ['Shahbaz','Nouman'])
  calender.add_event(name: 'To be edit-IV', date: DateTime.parse('2019-08-22'), time: '09:30 AM', place: '7Vals', participants: ['Shahbaz','Nouman'])
end

loop do
  display_menu
  choice = gets.chomp
  case choice
  when '0'
    if dummy_data_loaded
      puts 'Dummy data already loaded'
    else
      load_dummy_date(calender)
      dummy_data_loaded = true
      puts 'Dummy data loaded successfully'
    end
    pause
  when '1'
    add_event(calender)
    pause
  when '2'
    delete_event(calender)
    pause
  when '3'
    edit_event(calender)
    pause
  when '4'
    view_event(calender)
    pause
  when '5' # view month events in list view
    view_month_events(calender, true)
    pause
  when '6' # view month events in calendar view
    view_month_events(calender, false)
    pause
  when '7'
    calender.view_all_events
    pause
  when '8'
    puts 'Exiting...'
    sleep(1)
    break
  else
    puts 'Invalid choice, please try again'
    pause
  end
end
