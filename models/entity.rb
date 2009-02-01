#Representation of an entity/object with variable properties
# Properties:
#   - name
#   - entity_properties (join table for n:m)
#   - properties
class Entity
  include Validatable
  
  #Fields
  attr_accessor :name, :properties
  
  #Validations
  required :name, :properties
  typed :name => :String
  typed_collection :properties => :Property
    
  #Alias name as readable to conform to readable interface
  alias :readable :name
end