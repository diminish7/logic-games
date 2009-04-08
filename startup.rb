BASE_DIR = File.dirname(__FILE__)

require 'logger'
LOGGER = Logger.new($stdout)

require "#{BASE_DIR}/models/validatable"

Dir["#{BASE_DIR}/models/*"].each do |file|
  require file
end
