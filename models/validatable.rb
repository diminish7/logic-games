#Model base class, provides validation methods
module Validatable
  attr_accessor :errors
  
  @@required_fields = {}
  @@typed_fields = {}
  @@typed_collections = {}
  @@enumerated_fields = {}
  @@polymorphic_fields = {}
  
  def self.included(base)
    base.class_eval do
      @@required_fields[base] = []
      @@typed_fields[base] = {}
      @@typed_collections[base] = {}
      @@enumerated_fields[base] = {}
      @@polymorphic_fields[base] = {}
      
      #Class variable setters
      def self.required(*fields)
        fields.each { |field| @@required_fields[self] << field }
      end
      def self.typed(fields)
        fields.each { |field, klazz| @@typed_fields[self][field] = klazz }
      end
      def self.typed_collection(fields)
        fields.each { |field, klazz| @@typed_collections[self][field] = klazz}
      end
      def self.enumerated(fields)
        fields.each { |field, values| @@enumerated_fields[self][field] = values }
      end
      def self.polymorphic(fields)
        fields.each { |field, types| @@polymorphic_fields[self][field] = types }
      end
      
      #Class variable getters
      def self.get_required
        @@required_fields[self]
      end
      def self.get_typed
        @@typed_fields[self]
      end
      def self.get_typed_collections
        @@typed_collections[self]
      end
      def self.get_enumerated
        @@enumerated_fields[self]
      end
      def self.get_polymorphic
        @@polymorphic_fields[self]
      end
    end
  end
  
  def initialize
    @errors = {}
  end
  
  #Basic validations
  def validate
    clear_errors
    #Check required fields
    self.class.get_required.each do |field|
      if self.send(field).nil?
        add_error(field, "can't be blank")
      end
    end
    #Check typed fields
    self.class.get_typed.each do |field, klazz|
      val = self.send(field)
      unless val.nil? || val.kind_of?(self.class.const_get(klazz))
        add_error(field, "must be a #{klazz}")
      end
    end
    #Check typed collections
    self.class.get_typed_collections.each do |field, klazz|
      arr = self.send(field)
      unless arr.nil?
        if arr.kind_of?(Array)
          arr.each do |item|
            unless item.kind_of?(self.class.const_get(klazz))
              add_error(field, "must be a collection of type #{klazz}")
              break
            end
          end
        else
          add_error(field, "must be a collection of type #{klazz}")
        end
      end
    end
    #Check polymorphic typings
    self.class.get_polymorphic.each do |field, types|
      val = self.send(field)
      unless val.nil? || types.include?(val.class.to_s.to_sym)
        add_error(field, "must be one of the following classes: #{types.join(', ')}")
      end
    end
    #Check enumerated values
    self.class.get_enumerated.each do |field, values|
      val = self.send(field)
      if val
        #Don't add the error if the value is the wrong class, assume that a typed validation will catch it
        unless values.first.class != val.class || values.include?(val)
          add_error(field, "must have one of the following values: #{values.join(', ')}")
        end
      end
    end
    
    return !has_errors?
  end
  
  def add_error(field, message)
    @errors[field] = [] unless @errors[field]
    @errors[field] << message
  end
  
  def clear_errors(field = nil)
    if field
      @errors[field].delete
    else
      @errors = {}
    end
  end
  
  def has_errors?
    !@errors.empty?
  end
  
end