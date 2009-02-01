#Top-level entity, the rule base represents the collection
# of rules and facts for a scenario
# Properties:
#   - name
#   - facts
#   - rules
class RuleBase
  include Validatable
  
  #Fields
  attr_accessor :name, :facts, :rules
  
  #Validations
  required :name
  typed :name => :String
  typed_collection :facts => :Fact, :rules => :Rule
  
  #Returns the facts from this rule base for a given object.
  # obj can be of type Entity, Property or EntityProperty
  def facts_for(obj)
    #TODO
  end
  
  #Returns the rules from this rule base for a given object.
  # obj can be of type Entity, Property or EntityProperty
  def rules_for(obj)
    #TODO
  end
  
  #Formatted, readable string representing the rule base
  def readable
    "Rules:\n#{rules.collect {|r| r.readable }.join('\n')}\nFacts:\n#{facts.collect {|f| f.readable }.join('\n')}"
  end
  
end