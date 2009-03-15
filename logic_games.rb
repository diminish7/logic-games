home = File.dirname(__FILE__)

if ARGV[0] == "spec"
  #Run the specs
  system("ruby -S spec #{home}/spec/test_*.rb")
elsif ARGV[0] == "games"
  #Run all games under the 'games' folder
  require "#{home}/startup"
  Dir["#{home}/games/*"].each do |game|
    require game
  end
elsif ARGV[0] == "game"
  if ARGV[1]
    require "#{home}/startup"
    require "#{home}/games/#{ARGV[1]}"
  else
    puts "Usage:"
    puts "  <game>: run specified game"
  end
else
  puts "Usage:"
  puts "  spec: run the specs"
  puts "  games: run all logic games"
  puts "  game: run the specified logic game"
end