require File.join(File.dirname(__FILE__), "spec_helper")

describe "Options" do
  before(:all) do
    @required = [:facts]
    @typed_collection = {:facts => Fact}
    
    @readable = "Property of Entity EQUALS Value"
  end
  
  before(:each) do
    @obj = Option.new
    fact = Fact.new
    fact.comparator = Clause::EQUAL
    fact.property_value = "Value"
    fact.property = Property.new
    fact.entity = Entity.new
    fact.rule_base = RuleBase.new
    fact.property.name = "Property"
    fact.entity.name = "Entity"
    @obj.facts = [fact]
  end
  
  it_should_behave_like "Validatable"
  it_should_behave_like "Readable"
  it_should_behave_like "Clonable"
  
end