require File.join(File.dirname(__FILE__), "spec_helper")

describe "Rule" do
  before(:all) do
    @required = [:rule_base, :consequent, :antecedent]
    @typed = {:rule_base => RuleBase, :consequent => Clause}
    @polymorphic = {:antecedent => [Clause, ClauseCluster]}
    
    @readable = "IF Property1 of Entity1 DOES NOT EQUAL Value1 AND Property2 of Entity2 EQUALS Value2 THEN Property3 of Entity3 EQUALS Value3"
  end
  
  before(:each) do
    @obj = Rule.new
    @obj.rule_base = RuleBase.new
    @obj.consequent = Clause.new
    @obj.antecedent = ClauseCluster.new
    
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
    
    @obj.antecedent.lhs = lhs
    @obj.antecedent.rhs = rhs
    @obj.antecedent.operator = ClauseCluster::AND
    
    @obj.consequent.comparator = Clause::EQUAL
    @obj.consequent.property_value = "Value3"
    @obj.consequent.property = Property.new
    @obj.consequent.entity = Entity.new
    @obj.consequent.property.name = "Property3"
    @obj.consequent.entity.name = "Entity3"
  end
  
  it_should_behave_like "Validatable"
  it_should_behave_like "Readable"
  it_should_behave_like "Clonable"
  
  describe "entities" do
    it "should return a list of unique entities from all clauses" do
      entities = @obj.entities
      entities.length.should == 3
      [@obj.antecedent.lhs.entity, @obj.antecedent.rhs.entity, @obj.consequent.entity].each do |entity|
        entities.include?(entity).should == true
      end
    end
  end
  
  describe "fired?()" do
    it "should initialize to false" do
      rule = Rule.new
      rule.fired?.should == false
    end
  end
  
  describe "generate_fact()" do
    it "should add the consequent to the rule base as a fact" do
      @obj.rule_base.facts_for(@obj.consequent.entity, @obj.consequent.property).empty?.should == true
      @obj.generate_fact
      @obj.rule_base.facts_for(@obj.consequent.entity, @obj.consequent.property).length.should == 1
      fact = @obj.rule_base.facts_for(@obj.consequent.entity, @obj.consequent.property).first
      fact.entity.should == @obj.consequent.entity
      fact.property.should == @obj.consequent.property
      fact.property_value.should == @obj.consequent.property_value
      fact.comparator.should == @obj.consequent.comparator
    end
  end
  
  describe "evaluate()" do
    describe "Antecedent is TRUE" do
      before(:each) do
        @obj.antecedent.evaluate(@obj.rule_base).should == Rule::UNKNOWN
        fact1 = Fact.new
        fact1.comparator = Clause::NOT_EQUAL
        fact1.property_value = @obj.antecedent.lhs.property_value
        fact1.property = @obj.antecedent.lhs.property
        fact1.entity = @obj.antecedent.lhs.entity
        @obj.rule_base.add_fact(fact1)
        fact2 = Fact.new
        fact2.comparator = Clause::EQUAL
        fact2.property_value = @obj.antecedent.rhs.property_value
        fact2.property = @obj.antecedent.rhs.property
        fact2.entity = @obj.antecedent.rhs.entity
        @obj.rule_base.add_fact(fact2)
        @obj.antecedent.evaluate(@obj.rule_base).should == Rule::TRUE
      end
      
      it "should set fired to true" do
        @obj.fired?.should == false
        @obj.evaluate
        @obj.fired?.should == true
      end
      it "should generate a fact in the rule base" do
        @obj.rule_base.facts.length.should == 2
        @obj.evaluate
        @obj.rule_base.facts.length.should == 3
      end
    end
    describe "Antecedent is FALSE" do
      before(:each) do
        @obj.antecedent.evaluate(@obj.rule_base).should == Rule::UNKNOWN
        fact = Fact.new
        fact.comparator = Clause::EQUAL
        fact.property_value = @obj.antecedent.lhs.property_value
        fact.property = @obj.antecedent.lhs.property
        fact.entity = @obj.antecedent.lhs.entity
        @obj.rule_base.add_fact(fact)
        @obj.antecedent.evaluate(@obj.rule_base).should == Rule::FALSE
      end
      
      it "should set fired to true" do
        @obj.fired?.should == false
        @obj.evaluate
        @obj.fired?.should == true
      end
      it "should not generate a fact in the rule base" do
        @obj.rule_base.facts.length.should == 1
        @obj.evaluate
        @obj.rule_base.facts.length.should == 1
      end
    end
    describe "Antecedent is UNKNOWN" do
      it "should not set fired to true" do
        @obj.antecedent.evaluate(@obj.rule_base).should == Rule::UNKNOWN
        @obj.fired?.should == false
        @obj.evaluate
        @obj.fired?.should == false
      end
      it "should not generate a fact in the rule base" do
        @obj.antecedent.evaluate(@obj.rule_base).should == Rule::UNKNOWN
        @obj.rule_base.facts.empty?.should == true
        @obj.evaluate
        @obj.rule_base.facts.empty?.should == true
      end
    end
  end
end