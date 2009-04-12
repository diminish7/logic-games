#Class representing a particular logic game
class Game
  include Validatable
  
  attr_accessor :name, :description, :questions, :rule_base, :entities
  
  required :rule_base, :name, :description, :questions
  typed :rule_base => :RuleBase, :description => :String, :name => :String
  typed_collection :questions => :Question
  
  def initialize(name = nil, description = nil, questions = nil, rule_base = nil)
    @name = name
    @description = description
    @questions = questions
    @rule_base = rule_base
    initialize_entities(@rule_base)
  end
  
  #Add a rule to the rulebase, and add it's entity to the entities hash
  def add_rule(rule)
    @rule_base.add_rule(rule)
    rule.entities.each do |entity|
      @entities[entity.name] ||= entity
    end
  end
  
  #Add a fact to the rulebase, and add it's entity to the entities hash
  def add_fact(fact)
    @rule_base.add_fact(fact)
    @entities[fact.entity.name] ||= fact.entity
  end
  
  #Create a rule and add it to the rule_base
  # Note that consequent value can be a simple value or an array of values to create a set of similar rules
  def create_rule(antecedent_entity, antecedent_property, antecedent_comparator, antecedent_value, consequent_entity, consequent_property, consequent_comparator, consequent_value)
    consequent_values = consequent_value.kind_of?(Array) ? consequent_value : [consequent_value]
    consequent_values.each do |c_value|
      rule = Rule.new
      rule.rule_base = self.rule_base
      rule.antecedent = Clause.new
      rule.consequent = Clause.new
      #Antecedent
      rule.antecedent.entity = antecedent_entity
      rule.antecedent.property = antecedent_property
      rule.antecedent.comparator = antecedent_comparator
      rule.antecedent.property_value = antecedent_value
      #Consequent
      rule.consequent.entity = consequent_entity
      rule.consequent.property = consequent_property
      rule.consequent.comparator = consequent_comparator
      rule.consequent.property_value = c_value
      #Add to the game (and rule_base)
      self.add_rule(rule)
    end
  end
  
  #Create a compound rule
  def create_compound_rule(antecedent_entity, antecedent_property, antecedent_comparator, antecedent_values, boolean_operator, consequent_entity, consequent_property, consequent_comparator, consequent_value)
    clauses = []
    antecedent_values.each do |antecedent_value|
      clause = Clause.new
      clause.entity = antecedent_entity
      clause.property = antecedent_property
      clause.property_value = antecedent_value
      clause.comparator = antecedent_comparator
      clauses << clause
    end
    antecedent = create_cluster_from_clauses(clauses, boolean_operator)
    consequent = Clause.new
    consequent.entity = consequent_entity
    consequent.property = consequent_property
    consequent.property_value = consequent_value
    consequent.comparator = consequent_comparator
    #Create and add the rule
    rule = Rule.new
    rule.rule_base = self.rule_base
    rule.antecedent = antecedent
    rule.consequent = consequent
    #Add to the game (and rule_base)
    self.add_rule(rule)
  end
  
  #Create a fact and add it to the rule base
  def create_fact(entity, property, comparator, value)
    fact = Fact.new
    fact.rule_base = self.rule_base
    fact.entity = entity
    fact.property = property
    fact.comparator = comparator
    fact.property_value = value
    self.add_fact(fact)
  end
  
  ##### Common rule type additions:
  #Add mutual exclusion rules to either the specified entities
  def add_mutual_exclusion_rules(entities, property, values)
    #Iterate through all entities, and for each, iterate through all values and create a rule
    # that if property == value for that entity, then property != value for any other entity
    entities.each do |entity|
      values.each do |value|
        entities.each do |other|
          next if other == entity
          self.create_rule(entity, property, Clause::EQUAL, value, other, property, Clause::NOT_EQUAL, value)
        end
      end
    end
  end
  #Add one place at a time rules
  def add_one_place_at_a_time_rules(entities, property, values)
    #For an entity, if property == value, then property != any other value
    entities.each do |entity|
      values.each do |value|
        values.each do |other|
          next if other == value
          self.create_rule(entity, property, Clause::EQUAL, value, entity, property, Clause::NOT_EQUAL, other)
        end
      end
    end
  end
  #Add last available value rules
  #TODO: refactor this to use create_compound_rule()
  def add_last_available_value_rules(entities, property, values)
    entities.each do |entity|
      values.each do |value|
        clauses = []
        values.each do |other|
          unless value == other
            clause = Clause.new
            clause.entity = entity
            clause.property = property
            clause.property_value = other
            clause.comparator = Clause::NOT_EQUAL
            clauses << clause
          end
        end
        #Create an AND'd clause cluster
        antecedent = create_cluster_from_clauses(clauses, ClauseCluster::AND)
        #Create the consequent
        consequent = Clause.new
        consequent.entity = entity
        consequent.property = property
        consequent.property_value = value
        consequent.comparator = Clause::EQUAL
        #Create and add the rule
        rule = Rule.new
        rule.rule_base = self.rule_base
        rule.antecedent = antecedent
        rule.consequent = consequent
        #Add to the game (and rule_base)
        self.add_rule(rule)
      end
    end
  end
  
  #Return the name, description and questions
  def readable
    "\n#{self.name}:\n\n#{self.description}\n\nQuestions:\n#{self.questions.collect {|q| q.readable}.join("\n\n")}"
  end
  
protected
  #Create a hash of entities by name
  def initialize_entities(rule_base)
    @entities ||= {}
    return if rule_base.nil? || rule_base.rules.empty?
    @rule_base.rules.each do |rule|
      rule.entities.each do |entity|
        @entities[entity.name] ||= entity
      end
    end
    @rule_base.facts.keys.each do |entity|
      @entities[entity.name] ||= entity
    end
  end
  
  #Create a clause cluster from a set of clauses
  def create_cluster_from_clauses(clauses, operator)
    return nil if clauses.empty?  #This shouldn't happen...
    return clauses.first if clauses.length == 1 #Recursion stop case
    lhs = clauses.shift   #Pop the first clause
    cluster = ClauseCluster.new
    cluster.lhs = lhs
    cluster.operator = operator
    cluster.rhs = create_cluster_from_clauses(clauses, operator)
    return cluster
  end
end