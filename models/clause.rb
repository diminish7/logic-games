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
  
  #Evaluates this clause's truth within a rule base
  def evaluate(rule_base)
    rule_base.facts_for(self.entity, self.property).each do |fact|
      if self.applies(fact)
        return Rule::TRUE if self.comparator == fact.comparator
        return Rule::FALSE
      end
    end
    return Rule::UNKNOWN
  end
  
  #Determines if a fact applies to the truth of this clause
  def applies(fact)
    self.entity == fact.entity &&
      self.property == fact.property &&
      self.property_value == fact.property_value
  end
  
  #Formatted, readable string representing the clause
  def readable
    "#{ property.readable } of #{ entity.readable } #{ comparator } #{ property_value }"
  end
  
  #Return a new clause that is a clone of the current clause
  def clone
    clause = Clause.new
    clause.comparator = self.comparator
    clause.property_value = self.property_value
    clause.property = self.property
    clause.entity = self.entity
    return clause
  end
  
end