require File.join(File.dirname(__FILE__), "spec_helper")

describe "Clause" do
  before(:all) do
    @required = [:comparator, :property_value, :property, :entity]
    @typed = {:property => Property, :entity => Entity}
    @enumerated = {:comparator => [Clause::EQUAL, Clause::NOT_EQUAL]}
    
    @readable = "Property of Entity EQUALS Value"
  end
  
  before(:each) do
    @obj = Clause.new
    @obj.comparator = Clause::EQUAL
    @obj.property_value = "Value"
    @obj.property = Property.new
    @obj.entity = Entity.new
    @obj.property.name = "Property"
    @obj.entity.name = "Entity"
  end
  
  it_should_behave_like "Validatable"
  it_should_behave_like "Readable"
  
  describe "applies(fact)" do
    it "should return true if the fact matches the clause" do
      fact = Fact.new
      fact.comparator = @obj.comparator
      fact.property = @obj.property
      fact.entity = @obj.entity
      fact.property_value = @obj.property_value
      @obj.applies(fact).should == true
    end
    it "should return false if the any element of the fact does not match the clause" do
      fact = Fact.new
      fact.comparator = @obj.comparator
      fact.property = Property.new
      fact.entity = @obj.entity
      fact.property_value = @obj.property_value
      @obj.applies(fact).should == false
      fact.property = @obj.property
      fact.entity = Entity.new
      @obj.applies(fact).should == false
      fact.entity = @obj.entity
      fact.property_value = "Non-Matching Value"
      @obj.applies(fact).should == false
      fact.property_value = @obj.property_value
      @obj.applies(fact).should == true
    end
  end
  
  describe "evaluate(rule_base)" do
    before(:each) do
      @rule_base = RuleBase.new
      @fact1 = Fact.new
      @fact1.entity = @obj.entity
      @fact1.property = @obj.property
      @fact2 = Fact.new
      @fact2.entity = Entity.new
      @fact2.property = Property.new
    end
    
    it "should return UNKNOWN if none of the facts applies" do
      @rule_base.add_fact(@fact1)
      @rule_base.add_fact(@fact2)
      @obj.evaluate(@rule_base).should == Rule::UNKNOWN
    end
    it "should return TRUE if any of the facts applies and are equal" do
      @fact1.comparator = @obj.comparator
      @fact1.property_value = @obj.property_value
      @rule_base.add_fact(@fact1)
      @rule_base.add_fact(@fact2)
      @obj.evaluate(@rule_base).should == Rule::TRUE
    end
    it "should return FALSE if any of the facts applies and are not equal" do
      @fact1.comparator = Clause::NOT_EQUAL
      @fact1.property_value = @obj.property_value
      @rule_base.add_fact(@fact1)
      @rule_base.add_fact(@fact2)
      @obj.evaluate(@rule_base).should == Rule::FALSE
    end
  end
end