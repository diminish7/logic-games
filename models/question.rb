class Question
  include Validatable
  
  DETERMINE_TRUTH = "DETERMINE TRUTH"
  DETERMINE_POSSIBLE = "DETERMINE POSSIBLE"
  
  attr_accessor :text, :options, :type, :rule_base, :new_facts
  
  required :text, :options, :type, :rule_base
  typed :rule_base => :RuleBase, :text => :String
  typed_collection :new_facts => :Fact, :options => :Option
  enumerated :type => [DETERMINE_TRUTH, DETERMINE_POSSIBLE]
  
  #Evaluates each option based on the facts from the rule base on the new facts from this question
  # Returns the option that solves this question, or nil if it is not solvable yet
  def evaluate
    #Clone the rule base so we aren't adding new facts to the actual rule base
    rb = self.rule_base.clone
    #Add new facts and evaluate
    new_facts.each {|fact| rb.add_fact(fact)} unless new_facts.nil?
    rb.evaluate
    if type == DETERMINE_TRUTH
      return nil if rb.facts.nil? #No facts, we can't determine the truth of anything
      #Iterate through each option and evaluate the truth of it
      # Short-circuit: return the first option that is true
      options.each do |option|
        return option if option.facts.all? do |fact|
          matchers = rb.facts[fact.entity] ? rb.facts[fact.entity][fact.property] : nil
          matchers && matchers.all? {|matcher| fact.compare(matcher)}
        end
      end
    elsif type == DETERMINE_POSSIBLE
      #TODO - iterate through each option -
      # 1. clone the rule base
      # 2. iterate through each fact and
      #   a. make sure that the fact isn't impossible (doesn't contradict existing fact)
      #   b. add the fact to the rule base
      # 3. return the first option where you can do this to all facts from the option
      #    i.e. there was never an impossible fact
    end
    return nil  #No matches found
  end
  
  #Human readable output
  def readable
    "#{text}\n\n#{options.collect {|opt| opt.readable}.join("\n")}"
  end
  
end