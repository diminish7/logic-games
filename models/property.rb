#A variable property for an entity
# Properties:
#   - name
class Property
  include Validatable

  #Fields
  attr_accessor :name
  
  #Validations
  required :name
  typed :name => :String
  
  #Alias name as readable to conform to readable interface
  alias :readable :name
end