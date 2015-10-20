#require "github_watchdog/version"
require 'octokit'
require 'logger'


logger = Logger.new File.new('/var/log/github_watchdog.log', 'a+')
logger.info "Started github_watchdog"



options={}
File.open("/etc/github_watchdog.conf") do |f|
	f.each_line do |line|
		elements=line.split('=')
		options[elements[0]] = elements[1].strip()
	end
end

# I had to look up octokit's documentation
# https://github.com/octokit/octokit.rb
# which wasn't as helpful as I had hoped, but...
# http://octokit.github.io/octokit.rb/Octokit/Client/Repositories.html#contributors-instance_method
# was really helpful
# I had to look up the Github API call
# https://developer.github.com/v3/repos/#list-contributors
# Please note that the contributor list is cached, so the data
# can be hours old.  See above link for details.
filecache = File.open("/var/dump.txt", 'r+')
count = 0
File.open(filecache) {|f| count = f.read.count("\n")}
if count == 0
	contributors_prior = []
else
	contributors_prior = filecache.readline.split().sort!
end
filecache.close()
# https://github.com/octokit/octokit.rb
contributors = Octokit.contributors("#{options['organization']}/#{options['repo']}")

# There is a cooler way to do this with: http://daemons.rubyforge.org/
# But this works for the trivial use case and the time constraints
loop do
	contributors_url = Octokit.contributors("#{options['organization']}/#{options['repo']}")
	contributors = []
	contributors_url.each do |contrib|
		contributors << contrib[:login]
	end
	contributors.sort!
	if contributors_prior != contributors
		new_contributors = contributors - contributors_prior
		logger.info "Contributors are not the same"
		logger.info "Contributors added: " + new_contributors.join(', ')
		File.write("/var/dump.txt", contributors.join(' '))
	else
		logger.info "Contributors are the same"
	end
	contributors_prior = contributors
	sleep(options['interval'].to_i)
end

