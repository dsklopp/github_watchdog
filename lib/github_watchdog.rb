#require "github_watchdog/version"

#module GithubWatchdog
  # Your code goes here...
#end

# There is a cooler way to do this with: http://daemons.rubyforge.org/
# But this works for the trivial use case and the time constraints
options={}
File.open("/etc/github_watchdog.conf") do |f|
	f.each_line do |line|
		elements=line.split('=')
		options={elements[0] => elements[1]}
	end
end
loop do 
	options.each do |key, value|
		puts "#{key} - #{value}"
	end
	sleep(30)
end
