require 'spec'
require File.join(File.dirname(__FILE__), '../startup')

#Shared Specs
describe "Validatable", :shared => true do
  it "should validate" do
    @obj.validate.should == true
  end
  it "should validate required fields" do
    unless @required.nil?
      @required.each do |field|
        getter, setter, orig = get_accessors_and_value(field, @obj)
        @obj.send(setter, nil)
        @obj.validate.should == false
        @obj.errors[field].length.should == 1
        @obj.errors[field].first.should == "can't be blank"
        @obj.send(setter, orig) #Reset it
      end
    end
  end
  it "should validate typed fields" do
    unless @typed.nil?
      @typed.each do |field, type|
        getter, setter, orig = get_accessors_and_value(field, @obj)
        @obj.send(setter, Object.new)
        @obj.validate.should == false
        @obj.errors[field].length.should == 1
        @obj.errors[field].first.should == "must be a #{type}"
        @obj.send(setter, orig)
      end
    end
  end
  it "should validate typed collections are collections" do
    unless @typed_collections.nil?
      @typed_collections.each do |field, type|
        getter, setter, orig = get_accessors_and_value(field, @obj)
        @obj.send(setter, orig.first)
        @obj.validate.should == false
        @obj.errors[field].length.should == 1
        @obj.errors[field].first.should == "must be a collection of type #{type}"
        @obj.send(setter, orig)
      end
    end
  end
  it "should validate typed collections types" do
    unless @typed_collections.nil?
      @typed_collections.each do |field, type|
        getter, setter, orig = get_accessors_and_value(field, @obj)
        @obj.send(setter, [Object.new])
        @obj.validate.should == false
        @obj.errors[field].length.should == 1
        @obj.errors[field].first.should == "must be a collection of type #{type}"
        @obj.send(setter, orig)
      end
    end
  end
  it "should validate polymorphic types" do
    unless @polymorphic.nil?
      @polymorphic.each do |field, types|
        getter, setter, orig = get_accessors_and_value(field, @obj)
        @obj.send(setter, Object.new)
        @obj.validate.should == false
        @obj.errors[field].length.should == 1
        @obj.errors[field].first.should == "must be one of the following classes: #{types.join(', ')}"
        #Now make sure it works for all types
        types.each do |type|
          @obj.send(setter, type.new)
          @obj.validate.should == true
        end
        @obj.send(setter, orig)
      end
    end
  end
  it "should validate enumerated fields" do
    unless @enumerated.nil?
      @enumerated.each do |field, values|
        getter, setter, orig = get_accessors_and_value(field, @obj)
        @obj.send(setter, "INVALID")
        @obj.validate.should == false
        @obj.errors[field].length.should == 1
        @obj.errors[field].first.should == "must have one of the following values: #{values.join(', ')}"
        #Now make sure it works for all legit values
        values.each do |value|
          @obj.send(setter, value)
          @obj.validate.should == true
        end
        @obj.send(setter, orig)
      end
    end
  end
end

describe "Readable", :shared => true do
  it "should return the correct value from readable()" do
    @obj.readable.should == @readable
  end
end

#Helpers
def get_accessors_and_value(field, obj)
  #Return getter and setter
  getter, setter = field, "#{field}=".to_sym
  orig = obj.send(getter)
  return getter, setter, orig
end