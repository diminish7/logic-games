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
  
end