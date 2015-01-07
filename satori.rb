require "rb-inotify"

require_relative "config.rb"

def move(filename, ext)
  puts "move called"
  namestr = `#{NAMECMD}`.chomp
  to = namestr + "." + ext
  path = MOVETO + to
  puts "target to #{to}"
  if File.exist?(MOVETO + to)
    puts "target exist! retry!"
    sleep(1)
    move(filename, ext)
  end
  cmdstr = "#{MOVECMD} \"#{WATCHPATH + filename}\" \"#{path}\""
  puts cmdstr
  `#{cmdstr}`
end

notifier = INotify::Notifier.new

notifier.watch(WATCHPATH, :moved_to, :create) do |event|
  puts "#{event.name} is now in image!"
  if /^(.*)\.(png|gif|jpg|jpeg)$/ =~ event.name
    puts "move #{event.name} to #{MOVETO}"
    puts "extension is #{$2}"
    move(event.name, $2)
  end
end

notifier.run

