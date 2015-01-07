require "rb-inotify"

require_relative "config.rb"

def move(filename, ext)
  sleep(10) # ダウンロード中に移動とか起きるとめんどくさそう
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
  if /^(.*)\.(png|png-large|gif|jpg|jpeg|jpg-large|JPG|bmp)$/ =~ event.name
    puts "move #{event.name} to #{MOVETO}"
    puts "extension is #{$2}"
    ext = $2
    ext = "jpg" if ext == "jpg-large"
    ext = "png" if ext == "png-large"
    move(event.name, ext)
  end
end

notifier.run

