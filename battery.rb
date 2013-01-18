#!/usr/bin/ruby 
def getFileValue(filename)
  file = File.new(filename,"r")
  content = file.gets
  file.close
  content = content.delete "\n"
end

def addLeadingZero(value)
  "%02d" % value
end

def getStatus(installed)
	installed.each do |bat|
		state = getFileValue("/sys/devices/platform/smapi/#{bat}/state")
		if state == "charging" 
			remaning_time = getFileValue("/sys/devices/platform/smapi/#{bat}/remaining_charging_time").to_i
			symbol = "[+]"
			descriptingword = "Charging"
		elsif state == "discharging"
			remaning_time = getFileValue("/sys/devices/platform/smapi/#{bat}/remaining_running_time").to_i
			symbol = "[-]"
			descriptingword = "Running"
		elsif state == "idle"
			remaning_time = 0
			symbol = "[ ]"
			descriptingword = "Idle"
		else
			puts "Unknown value: '"+state+"'"
		end
		percent = getFileValue("/sys/devices/platform/smapi/#{bat}/remaining_percent").to_i
		batterybar = (percent.to_f / 10).round
		hours = remaning_time / 60
		minutes = remaning_time % 60

		if ARGV[0] == "-v"
		 
			puts "The battery is " + state
			#getting some information about the current capacity
			design_capacity = getFileValue("/sys/devices/platform/smapi/#{bat}/design_capacity").to_i
			last_full_capacity = getFileValue("/sys/devices/platform/smapi/#{bat}/last_full_capacity").to_i
			capacity = last_full_capacity * 100 / design_capacity

			cycles = getFileValue("/sys/devices/platform/smapi/#{bat}/cycle_count")

			d = Time::now()
			d += remaning_time * 60
			puts "Current Status\t\t#{percent}%"
			puts "Remaining " + descriptingword + " Time\t" +   addLeadingZero(hours) + "h" + addLeadingZero(minutes) + "m"
			if state != "idle"
				puts descriptingword + " Till\t\t" + addLeadingZero(d.hour()) + ":" + addLeadingZero(d.min())
			end
			puts ""
			puts "After #{cycles} cycles the battery has #{capacity}% of its design capacity"
		elsif ARGV[0] == "-b"
			battery = ""
			batterybar.downto(1) { battery += "#" }
			batterybar.upto(9) { battery += " " }
			if(installed.length > 1) 
				print "[" + battery + "]"
			else
				puts "[" + battery + "]"
			end
		elsif ARGV[0] == "-h"
			puts "This is a very small script for getting some useful information about your battery"
			puts "Please notice that this script requires tp_smapi which is only available on ThinkPads"
			puts
			puts "Version 0.1 written by futejia during the 24C3 in Berlin"
			puts "Version 0.2 tweaks by ngharo during the haxor time on couch"
			puts "The script is published under the 'Beer License' which means you can do whatever you want, and when you like the script you buy futejia a beer"
			puts 
			puts "Command line options:"
			puts "    All information you usually need in one single line"
			puts "-h  Prints this help"
			puts "-b  Prints a nice ascii battery (Single line)"
			puts "-v  Gives some more information about the battery"
		else
			puts symbol + " " + addLeadingZero(hours) + ":" + addLeadingZero(minutes) + " (#{percent}%)"
		end
	end
	puts
end

begin
	installed = []
	['BAT0', 'BAT1'].each do |battery|
		if getFileValue("/sys/devices/platform/smapi/#{battery}/installed") == '1'
			installed.push(battery) 
		end
	end

	getStatus(installed)
end
