require File.join(File.dirname(__FILE__), "spec_helper")

describe "RuleBase" do
  before(:all) do
    @required = [:name]
    @typed = {:name => String}
    @typed_collections = {:rules => Rule}
    
    @readable = "Rules:\nIF Property1 of Entity1 DOES NOT EQUAL Value1 AND Property2 of Entity2 EQUALS Value2 THEN Property3 of Entity3 EQUALS Value3\nFacts:\nProperty4 of Entity4 EQUALS Value4"
  end
  
  before(:each) do
    @obj = RuleBase.new
    @obj.name = "Test Rule Base"
    
    rule = Rule.new
    rule.rule_base = @obj
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
    
    @obj.rules = [rule]
    
    fact = Fact.new
    fact.comparator = Clause::EQUAL
    fact.property_value = "Value4"
    fact.property = Property.new
    fact.entity = Entity.new
    fact.rule_base = RuleBase.new
    fact.property.name = "Property4"
    fact.entity.name = "Entity4"
    
    @obj.add_fact(fact)
  end
  
  it_should_behave_like "Validatable"
  it_should_behave_like "Readable"
  it_should_behave_like "Clonable"
  
  describe "facts_for(entity, property)" do
    before(:each) do
      @fact = @obj.all_facts.first
      @entity = @fact.entity
      @property = @fact.property
    end
    
    it "should return empty if their are no rules for the entity" do
      @obj.facts_for(Entity.new, @property).should == []
    end
    
    it "should return empty if their are no rules for the property" do
      @obj.facts_for(@entity, Property.new).should == []
    end
    
    it "should return a fact if one exists" do
      facts = @obj.facts_for(@entity, @property)
      facts.should be_a_kind_of Array
      facts.length.should == 1
      facts.first.should == @fact
    end
  end
  
  describe "evaluate()" do
    before(:each) do
      rule = @obj.rules.first
      @fact1 = Fact.new
      @fact1.comparator = Clause::NOT_EQUAL
      @fact1.property_value = "Value1"
      @fact1.property = rule.antecedent.lhs.property
      @fact1.entity = rule.antecedent.lhs.entity
      @fact2 = Fact.new
      @fact2.comparator = Clause::EQUAL
      @fact2.property_value = "Value2"
      @fact2.property = rule.antecedent.rhs.property
      @fact2.entity = rule.antecedent.rhs.entity
    end
    it "should not generate any facts if no rules can be fired" do
      @obj.rules.each {|rule| rule.fired?.should == false}
      @obj.facts.length.should == 1
      @obj.evaluate
      @obj.rules.each {|rule| rule.fired?.should == false}
      @obj.facts.length.should == 1
    end
    it "should generate facts from other facts" do
      @obj.add_fact(@fact1)
      @obj.add_fact(@fact2)
      @obj.rules.each {|rule| rule.fired?.should == false}
      @obj.facts.length.should == 3
      @obj.evaluate
      @obj.facts.length.should == 4
    end
    it "should fire all possible rules" do
      @obj.add_fact(@fact1)
      @obj.add_fact(@fact2)
      @obj.rules.each {|rule| rule.fired?.should == false}
      @obj.facts.length.should == 3
      @obj.evaluate
      @obj.rules.each {|rule| rule.fired?.should == true}
    end
  end
  
end