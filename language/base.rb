#Base DSL syntax
module Language
  module Base
    ###### Accessors ######
    def game
      @game
    end
    #Keep track of the last referenced class for ambiguous verbs
    def last_referenced
      @last_referenced || @game
    end
    #Keep track of the last context-sensitive method called
    def last_called
      @last_called
    end
    #Get a property by name
    def property_called(name)
      @properties[name]
    end
    #Get an entity by name
    def entity_called(name)
      game.entities[name]
    end
    
    ####### Initializers ######
    #Define a new game
    def new_game
      @game = Game.new
    end
    
    #Define new question
    def new_question
      q = Question.new
      q.rule_base = game.rule_base
      game.questions ||= []
      game.questions << q
      q
    end
    
    #Abstract - Implement this in the more specific language files
    def setup_game(*args)
      nil
    end
    
    ###### Functions that operate on the last referenced object #######
    
    #Give @last_referenced a name
    def called(name)
      last_referenced.name = name
      last_referenced
    end
    
    #Give @last_referenced a description
    def described_as(description)
      if last_referenced.respond_to?(:description)
        last_referenced.description = description
      elsif last_referenced.respond_to?(:text)
        last_referenced.text = description
      else
        raise "I don't know how to describe #{last_referenced}"
      end
      last_referenced
    end
    
    #Add a property to the game
    def with_property(name)
      @properties ||= {}
      @properties[name] = Property.new(name)
    end
    
    #Add a fact to a question
    def with_fact(entity_name, property_name, comparator_symbol, property_value)
      raise "I can't add a fact to a #{@last_referenced.class}" unless last_referenced.kind_of?(Question)
      question = last_referenced
      comparator = comparator_from_symbol(comparator_symbol)
      fact = Fact.new
      fact.rule_base = game.rule_base
      fact.comparator = comparator
      fact.entity = entity_called(entity_name)
      fact.property = property_called(property_name)
      fact.property_value = property_value
      question.new_facts ||= []
      question.new_facts << fact
      question
    end
    
    #Add options to the question
    def determines(entity_names, property_name, comparator_symbol, property_value)
      raise "I can't set determination on a #{@last_referenced.class}" unless last_referenced.kind_of?(Question)
      question = last_referenced
      #Set the type of the question
      question.type = Question::DETERMINE_TRUTH
      #Add options
      comparator = comparator_from_symbol(comparator_symbol)
      entities = entity_names.collect {|name| entity_called(name)}
      property = property_called(property_name)
      entities.each do |entity|
        option = Option.new
        fact = Fact.new
        fact.rule_base = game.rule_base
        fact.comparator = comparator
        fact.entity = entity
        fact.property = property
        fact.property_value = property_value
        option.facts = [fact]
        question.options ||= []
        question.options << option
      end
      question
    end
    
    #Set up entities with the last referenced property
    def for_entities(*entities)
      if (property = last_referenced).kind_of?(Property)
        entities.each do |name|
          entity = game.entities[name] || Entity.new
          entity.name = name
          entity.properties ||= []
          entity.properties << property
          game.entities[name] = entity
        end
        setup_game(property, *entities)
      else
        raise "Can't set entities for a #{last_referenced.class}"
      end
      property
    end
    
    #Helpers
    def comparator_from_symbol(symbol)
      clause_class = (last_referenced.kind_of?(Fact) || last_referenced.kind_of?(Question)) ? Fact : Clause
      if [:is, :are].include? symbol
        clause_class::EQUAL
      elsif [:is_not, :are_not].include? symbol
        clause_class::NOT_EQUAL
      else
        raise "I don't understand #{comparator} in this context..."
      end
    end
    
    [:with_property, :with_fact, :determines, :property_called, :entity_called, :new_game, :new_question, :called, :described_as, :for_entities].each do |method|
      new_name = "_#{method}".to_sym
      alias_method new_name, method
      define_method(method) do |*args|
        @last_called = method
        @last_referenced = self.send(new_name, *args)
      end
    end
  end
end