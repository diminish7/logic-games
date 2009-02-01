#See Clause, only difference here is semantic - a fact is assumed to be true, and fact belongs to a rule base
class Fact < Clause
  include Validatable
  
  #Fields
  attr_accessor :rule_base
  
  #Validations
  required :comparator, :property_value, :property, :entity, :rule_base
  typed :property => :Property, :entity => :Entity, :rule_base => :RuleBase
  enumerated :comparator => [EQUAL, NOT_EQUAL]
  
end