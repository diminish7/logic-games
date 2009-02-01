require File.join(File.dirname(__FILE__), "spec_helper")

describe "Entity" do
  before(:all) do
    @required = [:name, :properties]
    @typed = {:name => String}
    @typed_collections = {:properties => Property}
    
    @readable = "Test Entity"
  end
  
  before(:each) do
    @obj = Entity.new
    @obj.name = "Test Entity"
    @obj.properties = [Property.new]
  end
  
  it_should_behave_like "Validatable"
  it_should_behave_like "Readable"
  
end