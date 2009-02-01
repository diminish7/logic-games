#A rule within a rule base.
# Properties are:
#   - rule_base
#   - antecedent (polymorphic, either a clause or a clause cluster,
#                 represents the "if" portion of the rule)
#   - consequent - a clause, representing the "then" portion of the rule
class Rule
  include Validatable
  
  #Fields
  attr_accessor :rule_base, :consequent, :antecedent
  
  #Validations
  required :rule_base, :consequent, :antecedent
  typed :rule_base => :RuleBase, :consequent => :Clause
  polymorphic :antecedent => [:Clause, :ClauseCluster]
  
  #Formatted, readable string representing the clause cluster
  def readable
    "IF #{ antecedent.readable } THEN #{ consequent.readable }"
  end
end