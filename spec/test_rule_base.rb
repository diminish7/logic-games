require File.join(File.dirname(__FILE__), "spec_helper")

describe "RuleBase" do
  before(:all) do
    @required = [:name]
    @typed = {:name => String}
    @typed_collections = {:facts => Fact, :rules => Rule}
    
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
    
    @obj.facts = [fact]
  end
  
  it_should_behave_like "Validatable"
  it_should_behave_like "Readable"
  
end