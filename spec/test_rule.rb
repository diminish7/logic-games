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
  
end