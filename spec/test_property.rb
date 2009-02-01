require File.join(File.dirname(__FILE__), "spec_helper")

describe "Property" do
  
  before(:all) do
    @required = [:name]
    @typed = {:name => String}
    
    @readable = "Test Property"
  end
  
  before(:each) do
    @obj = Property.new
    @obj.name = "Test Property"
  end
  
  it_should_behave_like "Validatable"
  it_should_behave_like "Readable"
  
end