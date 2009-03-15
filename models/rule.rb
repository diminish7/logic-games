#A rule within a rule base.
# Properties are:
#   - rule_base
#   - antecedent (polymorphic, either a clause or a clause cluster,
#                 represents the "if" portion of the rule)
#   - consequent - a clause, representing the "then" portion of the rule
class Rule
  include Validatable
  
  #Constants
  TRUE = "TRUE"
  FALSE = "FALSE"
  UNKNOWN = "UNKNOWN"
  
  #Fields
  attr_accessor :rule_base, :consequent, :antecedent
  
  #Validations
  required :rule_base, :consequent, :antecedent
  typed :rule_base => :RuleBase, :consequent => :Clause
  polymorphic :antecedent => [:Clause, :ClauseCluster]
  
  def initialize
    @fired = false
  end
  
  #Evaluate this rule
  def evaluate
    truth = self.antecedent.evaluate(self.rule_base)
    if truth == TRUE
      #The consequent is true, generate a fact and set this rule to fired
      generate_fact
      @fired = true
    elsif truth == FALSE
      #The consequent is not true, set this rule to fired (no facts have been generated)
      @fired = true
    end
  end
  
  #Returns true if the rule has been fired and a truth value has been determined
  def fired?
    @fired
  end
  
  #Add the consequent as a fact to the rule base
  def generate_fact
    fact = Fact.new
    fact.entity = self.consequent.entity
    fact.property = self.consequent.property
    fact.property_value = self.consequent.property_value
    fact.comparator = self.consequent.comparator
    self.rule_base.add_fact(fact)
  end
  
  #Get a collection of all unique entities from all clauses in this rule
  def entities
    if antecedent.kind_of?(Clause)
      [antecedent.entity, consequent.entity].uniq
    else
      #Antecedent is a clause cluster
      (antecedent.entities + [consequent.entity]).uniq
    end
  end
  
  #Formatted, readable string representing the clause cluster
  def readable
    "IF #{ antecedent.readable } THEN #{ consequent.readable }"
  end
end