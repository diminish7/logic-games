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
  
end