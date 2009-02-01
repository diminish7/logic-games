#Clause, representing the state of a particular property for a particular entity
# Properties:
#   - entity (through entity_property)
#   - property (through entity_property)
#   - comparitor (EQUAL, NOT_EQUAL)
#   - value (the value assigned to the given property, can be integer, float, string, or boolean)
class Clause
  include Validatable
  
  #CONSTANTS
  EQUAL = "EQUALS"
  NOT_EQUAL = "DOES NOT EQUAL"
  
  #Fields
  attr_accessor :comparator, :property_value, :property, :entity
  
  #Validations
  required :comparator, :property_value, :property, :entity
  typed :property => :Property, :entity => :Entity
  enumerated :comparator => [EQUAL, NOT_EQUAL]
  
  #Formatted, readable string representing the clause
  def readable
    "#{ property.readable } of #{ entity.readable } #{ comparator } #{ property_value }"
  end
  
end