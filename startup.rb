BASE_DIR = File.dirname(__FILE__)

require "#{BASE_DIR}/models/validatable"

Dir["#{BASE_DIR}/models/*"].each do |file|
  require file
end
