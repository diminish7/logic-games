require File.join(File.dirname(__FILE__), "spec_helper")

describe "Game" do
  before(:all) do
    @required = [:rule_base, :name, :description, :questions]
    @typed = {:rule_base => RuleBase, :name => String, :description => String}
    @typed_collections = {:questions => Question}    
    @readable = "\nTest Game:\n\nTest Description\n\nQuestions:\nTest Question\n\nProperty0 of Entity0 EQUALS Value0\nProperty1 of Entity1 EQUALS Value1"
  end
  
  before(:each) do
    #Create a rule base
    rule_base = RuleBase.new
    rule_base.name = "Test Rule Base"
    
    rule = Rule.new
    rule.rule_base = rule_base
    rule.consequent = Clause.new
    rule.antecedent = ClauseCluster.new
    
    lhs = Clause.new
    rhs = Clause.new
    
    lhs.comparator = Clause::NOT_EQUAL
    lhs.property_value = "Value1"
    lhs.property = Property.new
    lhs.entity = Entity.new
    lhs.property.name = "Property1"
    lhs.entity.name = "Entity1"
    
    rhs.comparator = Clause::EQUAL
    rhs.property_value = "Value2"
    rhs.property = Property.new
    rhs.entity = Entity.new
    rhs.property.name = "Property2"
    rhs.entity.name = "Entity2"
    
    rule.antecedent.lhs = lhs
    rule.antecedent.rhs = rhs
    rule.antecedent.operator = ClauseCluster::AND
    
    rule.consequent.comparator = Clause::EQUAL
    rule.consequent.property_value = "Value3"
    rule.consequent.property = Property.new
    rule.consequent.entity = Entity.new
    rule.consequent.property.name = "Property3"
    rule.consequent.entity.name = "Entity3"
    
    rule_base.rules = [rule]
    
    fact = Fact.new
    fact.comparator = Clause::EQUAL
    fact.property_value = "Value4"
    fact.property = Property.new
    fact.entity = Entity.new
    fact.rule_base = RuleBase.new
    fact.property.name = "Property4"
    fact.entity.name = "Entity4"
    
    rule_base.add_fact(fact)
    
    question = Question.new
    question.text = "Test Question"
    question.type = Question::DETERMINE_TRUTH
    question.rule_base = RuleBase.new
    question.options = []
    2.times do |i|
      option = Option.new
      fact = Fact.new
      fact.comparator = Clause::EQUAL
      fact.property_value = "Value#{i}"
      fact.property = Property.new
      fact.entity = Entity.new
      fact.rule_base = RuleBase.new
      fact.property.name = "Property#{i}"
      fact.entity.name = "Entity#{i}"
      option.facts = [fact]
      question.options << option
    end
    #Now create a game from the rule base
    @obj = Game.new("Test Game", "Test Description", [question], rule_base)
  end
  
  it_should_behave_like "Validatable"
  it_should_behave_like "Readable"
  
  describe "entities()" do
    it "should contain a hash of all the unique entities from the rule base" do
      @obj.entities.keys.length.should == 4
      ["Entity1", "Entity2", "Entity3", "Entity4"].each do |name|
        @obj.entities.keys.include?(name).should == true
      end
    end
  end
  
  describe "add_rule(rule)" do
    before(:each) do
      @new_rule = Rule.new
      @new_rule.rule_base = RuleBase.new
      @new_rule.consequent = Clause.new
      @new_rule.antecedent = ClauseCluster.new
      
      lhs = Clause.new
      rhs = Clause.new
      
      lhs.comparator = Clause::NOT_EQUAL
      lhs.property_value = "Value1"
      lhs.property = Property.new
      lhs.entity = Entity.new
      lhs.property.name = "Property1"
      lhs.entity.name = "Entity4"
      
      rhs.comparator = Clause::EQUAL
      rhs.property_value = "Value2"
      rhs.property = Property.new
      rhs.entity = Entity.new
      rhs.property.name = "Property2"
      rhs.entity.name = "Entity5"
      
      @new_rule.antecedent.lhs = lhs
      @new_rule.antecedent.rhs = rhs
      @new_rule.antecedent.operator = ClauseCluster::AND
      
      @new_rule.consequent.comparator = Clause::EQUAL
      @new_rule.consequent.property_value = "Value3"
      @new_rule.consequent.property = Property.new
      @new_rule.consequent.entity = Entity.new
      @new_rule.consequent.property.name = "Property3"
      @new_rule.consequent.entity.name = "Entity6"
      #Add the rule
      @obj.add_rule(@new_rule)
    end
    it "should add the rule to the rule_base" do
      @obj.rule_base.rules.include?(@new_rule).should == true
    end
    it "should add the rule's entities to the entities hash" do
      ["Entity4", "Entity5", "Entity6"].each do |name|
        @obj.entities.keys.include?(name).should == true
      end
    end
  end
  
  describe "add_fact(fact)" do
    before(:each) do
      @new_fact = Fact.new
      @new_fact.comparator = Clause::EQUAL
      @new_fact.property_value = "Value"
      @new_fact.property = Property.new
      @new_fact.entity = Entity.new
      @new_fact.rule_base = @obj.rule_base
      @new_fact.property.name = "Property"
      @new_fact.entity.name = "Entity7"
      #Add the fact
      @obj.add_fact(@new_fact)
    end
    
    it "should add the fact to the rule_base" do
      @obj.rule_base.all_facts.include?(@new_fact).should == true
    end
    it "should add the fact's entity to the entities hash" do
      @obj.entities.keys.include?("Entity7").should == true
    end
  end
  
  describe "create_rule(antecedent_entity, antecedent_property, antecedent_comparator, antecedent_value, consequent_entity, consequent_property, consequent_comparator, consequent_value)" do
    before(:each) do
      @new_rule = Rule.new
      @entity1 = Entity.new
      @entity1.name = "Entity8"
      @comparator1 = Clause::EQUAL
      @property1 = Property.new
      @property1.name = "Property8"
      @value1 = "Value8"
      @entity2 = Entity.new
      @entity2.name = "Entity9"
      @comparator2 = Clause::NOT_EQUAL
      @property2 = Property.new
      @property2.name = "Property9"
      @value2 = "Value9"
      @value3 = "Value10"
      @value4 = "Value11"
      @obj.create_rule(@entity1, @property1, @comparator1, @value1, @entity2, @property2, @comparator2, @value2)
      @obj.create_rule(@entity1, @property1, @comparator1, @value1, @entity2, @property2, @comparator2, [@value3, @value4])
    end
    
    it "should create a new rule with the given entities" do
      found = false
      @obj.rule_base.rules.each do |rule|
        found = rule.antecedent.kind_of?(Clause) && rule.antecedent.entity == @entity1 &&
                  rule.antecedent.property = @property1 && rule.antecedent.comparator == @comparator1 && 
                  rule.antecedent.property_value == @value1 && rule.consequent.entity == @entity2 && 
                  rule.consequent.property == @property2 && rule.consequent.comparator == @comparator2 && 
                  rule.consequent.property_value == @value2
        break if found
      end
      found.should == true
    end
    
    it "should create a new rule for each of the set of consequent values" do
      found1 = false
      found2 = false
      @obj.rule_base.rules.each do |rule|
        found1 ||= rule.antecedent.kind_of?(Clause) && rule.antecedent.entity == @entity1 &&
                  rule.antecedent.property = @property1 && rule.antecedent.comparator == @comparator1 && 
                  rule.antecedent.property_value == @value1 && rule.consequent.entity == @entity2 && 
                  rule.consequent.property == @property2 && rule.consequent.comparator == @comparator2 && 
                  rule.consequent.property_value == @value3
        found2 ||= rule.antecedent.kind_of?(Clause) && rule.antecedent.entity == @entity1 &&
                  rule.antecedent.property = @property1 && rule.antecedent.comparator == @comparator1 && 
                  rule.antecedent.property_value == @value1 && rule.consequent.entity == @entity2 && 
                  rule.consequent.property == @property2 && rule.consequent.comparator == @comparator2 && 
                  rule.consequent.property_value == @value4
      end
      (found1 && found2).should == true
    end
  end
  
  describe "add_mutual_exclusion_rules(entities, property, values)" do
    before(:each) do
      @property = Property.new
      @property.name = "Property10"
      @entity1 = Entity.new
      @entity1.name = "Entity 9"
      @entity2 = Entity.new
      @entity2.name = "Entity 10"
      @value1 = "Value1"
      @value2 = "Value2"
      @obj.add_mutual_exclusion_rules([@entity1, @entity2], @property, [@value1, @value2])
    end
    it "should create a mutual exclusion rule for each entity, with each value" do
      found1 = false
      found2 = false
      found3 = false
      found4 = false
      @obj.rule_base.rules.each do |rule|
        next unless rule.antecedent.kind_of?(Clause)
        found1 ||= rule.antecedent.entity == @entity1 && rule.antecedent.property == @property && rule.antecedent.comparator == Clause::EQUAL && 
                    rule.antecedent.property_value == @value1 && rule.consequent.entity == @entity2 && rule.consequent.property == @property &&
                    rule.consequent.comparator == Clause::NOT_EQUAL && rule.consequent.property_value == @value1
        found2 ||= rule.antecedent.entity == @entity1 && rule.antecedent.property == @property && rule.antecedent.comparator == Clause::EQUAL && 
                    rule.antecedent.property_value == @value2 && rule.consequent.entity == @entity2 && rule.consequent.property == @property &&
                    rule.consequent.comparator == Clause::NOT_EQUAL && rule.consequent.property_value == @value2
        found3 ||= rule.antecedent.entity == @entity2 && rule.antecedent.property == @property && rule.antecedent.comparator == Clause::EQUAL && 
                    rule.antecedent.property_value == @value1 && rule.consequent.entity == @entity1 && rule.consequent.property == @property &&
                    rule.consequent.comparator == Clause::NOT_EQUAL && rule.consequent.property_value == @value1
        found4 ||= rule.antecedent.entity == @entity2 && rule.antecedent.property == @property && rule.antecedent.comparator == Clause::EQUAL && 
                    rule.antecedent.property_value == @value2 && rule.consequent.entity == @entity1 && rule.consequent.property == @property &&
                    rule.consequent.comparator == Clause::NOT_EQUAL && rule.consequent.property_value == @value2
      end
      (found1 && found2 && found3 && found4).should == true
    end
  end
end