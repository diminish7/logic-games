#Base DSL syntax

###### Accessors ######
def game
  @game
end
#Keep track of the last referenced class for ambiguous verbs
def last_referenced
  @last_referenced || @game
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
  @last_referenced = @game
end

#Define new question
def new_question
  q = Question.new
  q.rule_base = game.rule_base
  game.questions ||= []
  game.questions << q
  @last_referenced = q
end

#Abstract - Implement this in the more specific language files
def setup_game(*args)
  nil
end

###### Functions that operate on the last referenced object #######

#Give @last_referenced a name
def called(name)
  last_referenced.name = name
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
end

#Add a property to the game
def with_property(name)
  @properties ||= {}
  @last_referenced = @properties[name] = Property.new(name)
end

#Add a fact to a question
def with_fact(entity_name, property_name, comparator_symbol, property_value)
  raise "I can't add a fact to a #{@last_referenced.class}" unless @last_referenced.kind_of?(Question)
  comparator = comparator_from_symbol(comparator_symbol)
  fact = Fact.new
  fact.rule_base = game.rule_base
  fact.comparator = comparator
  fact.entity = entity_called(entity_name)
  fact.property = property_called(property_name)
  fact.property_value = property_value
  @last_referenced.new_facts ||= []
  @last_referenced.new_facts << fact
end

#Add options to the question
def determines(entity_names, property_name, comparator_symbol, property_value)
  raise "I can't set determination on a #{@last_referenced.class}" unless @last_referenced.kind_of?(Question)
  #Set the type of the question
  @last_referenced.type = Question::DETERMINE_TRUTH
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
    @last_referenced.options ||= []
    @last_referenced.options << option
  end
end

#Set up entities with the last referenced property
def for_entities(*entities)
  if (property = @last_referenced).kind_of?(Property)
    entities.each do |name|
      entity = game.entities[name] || Entity.new
      entity.name = name
      entity.properties ||= []
      entity.properties << property
      game.entities[name] = entity
    end
    setup_game(property, *entities)
  else
    raise "Can't set entities for a #{@last_referenced.class}"
  end
end

#Helpers
def comparator_from_symbol(symbol)
  clause_class = (@last_referenced.kind_of?(Fact) || @last_referenced.kind_of?(Question)) ? Fact : Clause
  if [:is, :are].include? symbol
    clause_class::EQUAL
  elsif [:is_not, :are_not].include? symbol
    clause_class::NOT_EQUAL
  else
    raise "I don't understand #{comparator} in this context..."
  end
end