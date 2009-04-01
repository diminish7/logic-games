require File.join(File.dirname(__FILE__), "spec_helper")

describe "Question" do
  before(:all) do
    @required = [:text, :options, :type, :rule_base]
    @typed = {:rule_base => RuleBase, :text => String}
    @typed_collection = {:new_facts => Fact, :options => Option}
    @enumerated = {:type => [Question::DETERMINE_TRUTH, Question::DETERMINE_POSSIBLE]}
    
    @readable = "Test Question\n\nProperty0 of Entity0 EQUALS Value0\nProperty1 of Entity1 EQUALS Value1"
  end
  
  before(:each) do
    @obj = Question.new
    @obj.text = "Test Question"
    @obj.type = Question::DETERMINE_TRUTH
    @obj.rule_base = RuleBase.new
    @obj.options = []
    @option1 = Option.new
    fact = Fact.new
    fact.comparator = Clause::EQUAL
    fact.property_value = "Value0"
    fact.property = Property.new
    fact.entity = Entity.new
    fact.rule_base = RuleBase.new
    fact.property.name = "Property0"
    fact.entity.name = "Entity0"
    @option1.facts = [fact]
    @obj.options << @option1
    @option2 = Option.new
    fact = Fact.new
    fact.comparator = Clause::EQUAL
    fact.property_value = "Value1"
    fact.property = Property.new
    fact.entity = Entity.new
    fact.rule_base = RuleBase.new
    fact.property.name = "Property1"
    fact.entity.name = "Entity1"
    @option2.facts = [fact]
    @obj.options << @option2
  end
  
  it_should_behave_like "Validatable"
  it_should_behave_like "Readable"
  it_should_behave_like "Clonable"
  
  describe "evaluate()" do
    it "should return the first option with all true facts if the type is DETERMINE_TRUTH" do
      @obj.evaluate.should be_nil
      @obj.rule_base.add_fact(@option2.facts.first)
      @obj.evaluate.should == @option2
    end
    it "should return the first option with all possible facts if the type is DETERMINE_POSSIBLE"
  end
  
end