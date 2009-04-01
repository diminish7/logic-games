require File.join(File.dirname(__FILE__), "spec_helper")

describe "Fact" do
  before(:all) do
    @required = [:comparator, :property_value, :property, :entity, :rule_base]
    @typed = {:property => Property, :entity => Entity, :rule_base => RuleBase}
    @enumerated = {:comparator => [Clause::EQUAL, Clause::NOT_EQUAL]}
    
    @readable = "Property of Entity EQUALS Value"
  end
  
  before(:each) do
    @obj = Fact.new
    @obj.comparator = Clause::EQUAL
    @obj.property_value = "Value"
    @obj.property = Property.new
    @obj.entity = Entity.new
    @obj.rule_base = RuleBase.new
    @obj.property.name = "Property"
    @obj.entity.name = "Entity"
  end
  
  it_should_behave_like "Validatable"
  it_should_behave_like "Readable"
  it_should_behave_like "Clonable"
  
  describe "compare(other)" do
    it "should return true iff the other fact is a match" do
      other = Fact.new
      other.comparator = Clause::NOT_EQUAL
      other.property_value = @obj.property_value
      other.property = @obj.property
      other.entity = @obj.entity
      @obj.compare(other).should == false
      other.comparator = Clause::EQUAL
      @obj.compare(other).should == true
    end
  end
  
end