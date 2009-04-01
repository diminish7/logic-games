require File.join(File.dirname(__FILE__), "spec_helper")

describe "ClauseCluster" do
  before(:all) do
    @required = [:operator, :lhs, :rhs]
    @typed = {:operator => String}
    @polymophic = {:lhs => [Clause, ClauseCluster], :rhs => [Clause, ClauseCluster]}
    @enumerated = {:operator => [ClauseCluster::AND, ClauseCluster::OR]}
    
    @readable = "Property1 of Entity1 DOES NOT EQUAL Value1 AND Property2 of Entity2 EQUALS Value2"
  end
  
  before(:each) do
    @obj = ClauseCluster.new
    @obj.operator = ClauseCluster::AND
    @obj.lhs = Clause.new
    @obj.rhs = Clause.new
    
    @obj.lhs.comparator = Clause::NOT_EQUAL
    @obj.lhs.property_value = "Value1"
    @obj.lhs.property = Property.new
    @obj.lhs.entity = Entity.new
    @obj.lhs.property.name = "Property1"
    @obj.lhs.entity.name = "Entity1"
    
    @obj.rhs.comparator = Clause::EQUAL
    @obj.rhs.property_value = "Value2"
    @obj.rhs.property = Property.new
    @obj.rhs.entity = Entity.new
    @obj.rhs.property.name = "Property2"
    @obj.rhs.entity.name = "Entity2"
  end
  
  it_should_behave_like "Validatable"
  it_should_behave_like "Readable"
  it_should_behave_like "Clonable"
  
  describe "evaluate(rule_base)" do
    before(:each) do
      @rule_base = RuleBase.new
      @fact1 = Fact.new
      @fact1.entity = @obj.lhs.entity
      @fact1.property = @obj.lhs.property
      @fact2 = Fact.new
      @fact2.entity = @obj.rhs.entity
      @fact2.property = @obj.rhs.property
      @rule_base.add_fact(@fact1)
      @rule_base.add_fact(@fact2)
    end
    
    it "should return UNKNOWN if lhs or rhs are UNKNOWN" do
      @obj.evaluate(@rule_base).should == Rule::UNKNOWN
    end
    describe "operator is OR" do
      before(:each) do
        @obj.operator = ClauseCluster::OR
      end
      it "should return TRUE if either lhs or rhs are TRUE" do
        @fact1.property_value = @obj.lhs.property_value
        @fact1.comparator = @obj.lhs.comparator
        @obj.evaluate(@rule_base).should == Rule::TRUE
      end
      it "should return FALSE if both lhs or rhs are FALSE" do
        @fact1.property_value = @obj.lhs.property_value
        @fact1.comparator = Clause::EQUAL
        @fact2.property_value = @obj.rhs.property_value
        @fact2.comparator = Clause::NOT_EQUAL
        @obj.evaluate(@rule_base).should == Rule::FALSE
      end
    end
    describe "operator is AND" do
      before(:each) do
        @obj.operator = ClauseCluster::AND
      end
      it "should return TRUE if both lhs and rhs are TRUE" do
        @fact1.property_value = @obj.lhs.property_value
        @fact1.comparator = Clause::NOT_EQUAL
        @fact2.property_value = @obj.rhs.property_value
        @fact2.comparator = Clause::EQUAL
        @obj.evaluate(@rule_base).should == Rule::TRUE
      end
      it "should return FALSE if either lhs or rhs are FALSE" do
        @fact1.property_value = @obj.lhs.property_value
        @fact1.comparator = Clause::EQUAL
        @fact2.property_value = @obj.rhs.property_value
        @fact2.comparator = Clause::EQUAL
        @obj.evaluate(@rule_base).should == Rule::FALSE
      end
    end
  end
  
  describe "entities()" do
    it "should contain the list of entities from the clauses" do
      entities = @obj.entities
      entities.length.should == 2
      entities.include?(@obj.lhs.entity).should == true
      entities.include?(@obj.rhs.entity).should == true
    end
    it "should not duplicate entities" do
      cc = ClauseCluster.new
      cc.operator = ClauseCluster::AND
      cc.lhs = @obj
      cc.rhs = Clause.new
      
      cc.rhs.comparator = Clause::EQUAL
      cc.rhs.property_value = "Value2"
      cc.rhs.property = Property.new
      cc.rhs.property.name = "Property3"
      cc.rhs.entity = cc.lhs.rhs.entity
      
      entities = cc.entities
      entities.length.should == 2
      entities.include?(@obj.lhs.entity).should == true
      entities.include?(@obj.rhs.entity).should == true
    end
  end
  
end