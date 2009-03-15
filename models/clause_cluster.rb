#Collection of clauses, joined by a Boolean operator
# ClauseClusters are recursive.
# Properties:
#   - lhs - The left hand side of the clause, can either be a clause or another clause cluster
#   - rhs - The right hand side of the clause, can either be a clause or another clause cluster
#   - operator - AND or OR
class ClauseCluster
  include Validatable
  
  #Constants
  AND = "AND"
  OR = "OR"
  
  #Fields
  attr_accessor :operator, :lhs, :rhs
  
  #Validations
  required :operator, :lhs, :rhs
  typed :operator => :String
  polymorphic :lhs => [:Clause, :ClauseCluster], :rhs => [:Clause, :ClauseCluster]
  enumerated :operator => [AND, OR]
  
  #Evaluate the truth of a clause cluster within a rule base
  def evaluate(rule_base)
    left_side = lhs.evaluate(rule_base)
    right_side = rhs.evaluate(rule_base)
    if self.operator == AND
      #Return true if both lhs and rhs are true
      return Rule::TRUE if left_side == Rule::TRUE && right_side == Rule::TRUE
      return Rule::FALSE if left_side == Rule::FALSE || right_side == Rule::FALSE
      return Rule::UNKNOWN
    else  #OR
      #Return true if either lhs or rhs are true
      return Rule::TRUE if left_side == Rule::TRUE || right_side == Rule::TRUE
      return Rule::FALSE if left_side == Rule::FALSE && right_side == Rule::FALSE
      return Rule::UNKNOWN
    end
  end
  
  #Get a list of all entities from all clauses
  def entities
    left_entities = lhs.kind_of?(Clause) ? [lhs.entity] : lhs.entities
    right_entities = rhs.kind_of?(Clause) ? [rhs.entity] : rhs.entities
    (left_entities + right_entities).uniq
  end
  
  #Formatted, readable string representing the clause cluster
  def readable
    "#{ lhs.readable } #{ operator } #{ rhs.readable }"
  end
end