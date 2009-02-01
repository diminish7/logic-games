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
  
  #Formatted, readable string representing the clause cluster
  def readable
    "#{ lhs.readable } #{ operator } #{ rhs.readable }"
  end
end