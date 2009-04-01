#See Clause, only difference here is semantic - a fact is assumed to be true, and fact belongs to a rule base
class Fact < Clause
  include Validatable
  
  #Fields
  attr_accessor :rule_base
  
  #Validations
  required :comparator, :property_value, :property, :entity, :rule_base
  typed :property => :Property, :entity => :Entity, :rule_base => :RuleBase
  enumerated :comparator => [EQUAL, NOT_EQUAL]
  
  #Return a new fact that is a clone of the current fact
  def clone(rule_base = nil)
    fact = Fact.new
    fact.rule_base = rule_base || self.rule_base
    fact.comparator = self.comparator
    fact.property_value = self.property_value
    fact.property = self.property
    fact.entity = self.entity
    return fact
  end
  
  #Compare with another fact, return true if this is a match
  def compare(other)
    self.comparator == other.comparator &&
      self.property_value == other.property_value &&
      self.property == other.property &&
      self.entity == other.entity
  end
end