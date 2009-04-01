class Option
  include Validatable
  
  attr_accessor :facts
  
  required :facts
  typed_collection :facts => :Fact
  
  #Human readable version of this option
  def readable
    facts.collect {|fact| fact.readable}.join(",")
  end
end