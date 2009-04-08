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
  typed_collection :rules => :Rule
  
  def initialize(name = nil)
    @name = name
    @facts = {}
    @rules = []
  end
  
  #Forward chains to generate as many facts as possible given the initial knowledge
  def evaluate
    made_discovery = true
    while made_discovery do
      made_discovery = self.rules.any? do |rule|
        if rule.fired?
          false
        else
          rule.evaluate
          rule.fired?
        end
      end
    end
  end
  
  #Adds a fact to this rule base's fact hash
  def add_fact(fact)
    @facts[fact.entity] = {} unless @facts.has_key?(fact.entity)
    @facts[fact.entity][fact.property] = [] unless @facts[fact.entity].has_key?(fact.property)
    @facts[fact.entity][fact.property].each do |existing|
      if (fact.comparator == Fact::EQUAL && existing.comparator == Fact::EQUAL && fact.property_value != existing.property_value) ||
            (existing.comparator != fact.comparator && existing.property_value == fact.property_value)
        raise "Adding a contradictory fact!"
      end
    end
    @facts[fact.entity][fact.property] << fact
    LOGGER.info "Adding fact: #{fact.readable}"
  end
  
  #Adds a rule to this rule_base
  def add_rule(rule)
    @rules << rule
    LOGGER.info "Adding rule: #{rule.readable}"
  end
  
  #Returns the facts from this rule base for a given object.
  # obj can be of type Entity or Property
  def facts_for(entity, property)
    return [] if @facts[entity].nil? || @facts[entity][property].nil?
    return @facts[entity][property]
  end
  
  #Get all facts as an array
  def all_facts
    @facts.values.collect { |property_facts| property_facts.values }.flatten
  end
  
  #Formatted, readable string representing the rule base
  def readable
    "Rules:\n#{rules.collect {|r| r.readable }.join('\n')}\nFacts:\n#{all_facts.collect {|f| f.readable }.join('\n')}"
  end
  
  #Create a new rule base with all the same rules and facts
  def clone
    rule_base = RuleBase.new(self.name)
    #Clone the facts
    self.facts.each do |entity, properties|
      rule_base.facts[entity] = {}
      properties.each do |property, value|
        rule_base.facts[entity][property] = value.collect {|fact| fact.clone(rule_base)}
      end
    end
    #Clone the rules
    self.rules.each do |rule|
      rule_base.rules << rule.clone(rule_base)
    end
    return rule_base
  end
  
end