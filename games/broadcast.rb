#Set up game description
game = Game.new("Broadcast")
game.rule_base = RuleBase.new
game.description = <<DESC
Seven consecutive time slots for a broadcast, numbered in chronological order 1 through 7, will be filled by six song tapes - G, H, L, O, P, S - and exactly one news tape. Each tape is to be assigned to a different time slot, and no tape is longer than any other tape. The broadcast is subject to the following restrictions:

    * L must be played immediately before O
    * The news tape must be played at some time after L
    * There must be exactly two time slots between G and P, regardless of whether G comes before P or whether G comes after P
DESC

#Set up the entities
position_property = Property.new
position_property.name = "Position"

["G", "H", "L", "O", "P", "S", "News"].each do |name|
  entity = Entity.new
  entity.name = name
  entity.properties = [position_property]
  game.entities[name] = entity
end

#Create the questions
game.questions = []
q = Question.new
q.text = "If G is played second, which one of the following tapes must be played third?"
q.rule_base = game.rule_base
q.type = Question::DETERMINE_TRUTH
#New facts
fact = Fact.new
fact.rule_base = game.rule_base
fact.comparator = Fact::EQUAL
fact.entity = game.entities["G"]
fact.property = position_property
fact.property_value = 2
q.new_facts = [fact]
q.options = []
#Options (L is the correct answer...)
["News", "H", "L", "O", "S"].each do |name|
  option = Option.new
  fact = Fact.new
  fact.rule_base =game.rule_base
  fact.comparator = Fact::EQUAL
  fact.entity = game.entities[name]
  fact.property = position_property
  fact.property_value = 3
  option.facts = [fact]
  q.options << option
end
game.questions << q

#Display game
puts game.readable

#Create the rules and facts

#General rules: 
#Mutual exclusion
# - If G is in position 1, then H, L, O, P, S and News are NOT in position 1
# - etc...
LOGGER.info "Adding mutual exclusion rules"
game.add_mutual_exclusion_rules(game.entities.values, position_property, [1, 2, 3, 4, 5, 6, 7])
#Last available value
# - If G is not in positions 1, 2, 3, 4, 5, or 6, then it must be in position 7
LOGGER.info "Adding last available rules"
game.add_last_available_value_rules(game.entities.values, position_property, [1, 2, 3, 4, 5, 6, 7])
#One place at a time rule
# - If G is in position 1, then G is not in positions 2, 3, 4, 5, 6, or 7
LOGGER.info "Adding one place at a time rules"
game.add_one_place_at_a_time_rules(game.entities.values, position_property, [1, 2, 3, 4, 5, 6, 7])

#Rules and facts for "L must be played immediately before O"
#Facts: 
# - O cannot be in position 1
# - L cannot be in position 7
LOGGER.info "Adding rules and facts for 'L must be played immediately before O"
[["O", 1], ["L", 7]].each do |entity_name, position|
  game.create_fact(game.entities[entity_name], position_property, Fact::NOT_EQUAL, position)
end

#Rules:
# - if O is in position 2 then L is in position 1
# - if O is in position 3 then L is in position 2
# - if O is in position 4 then L is in position 3
# - if O is in position 5 then L is in position 4
# - if O is in position 6 then L is in position 5
# - if O is in position 7 then L is in position 6
# - if L is in position 1 then O is in position 2
# - if L is in position 2 then O is in position 3
# - if L is in position 3 then O is in position 4
# - if L is in position 4 then O is in position 5
# - if L is in position 5 then O is in position 6
# - if L is in position 6 then O is in position 7
# - if L is not in position 1 then O is not in position 2
# - if L is not in position 2 then O is not in position 3
# - if L is not in position 3 then O is not in position 4
# - if L is not in position 4 then O is not in position 5
# - if L is not in position 5 then O is not in position 6
# - if L is not in position 6 then O is not in position 7
# - if O is not in position 2 then L is not in position 1
# - if O is not in position 3 then L is not in position 2
# - if O is not in position 4 then L is not in position 3
# - if O is not in position 5 then L is not in position 4
# - if O is not in position 6 then L is not in position 5
# - if O is not in position 7 then L is not in position 6
6.times do |i|
  game.create_rule(game.entities["O"], position_property, Clause::EQUAL, (i+2), game.entities["L"], position_property, Clause::EQUAL, (i+1))
  game.create_rule(game.entities["O"], position_property, Clause::NOT_EQUAL, (i+2), game.entities["L"], position_property, Clause::NOT_EQUAL, (i+1))
  game.create_rule(game.entities["L"], position_property, Clause::EQUAL, (i+1), game.entities["O"], position_property, Clause::EQUAL, (i+2))
  game.create_rule(game.entities["L"], position_property, Clause::NOT_EQUAL, (i+1), game.entities["O"], position_property, Clause::NOT_EQUAL, (i+2))
end

  
#Rules and facts for "The news tape must be played at some time after L"
#Fact: 
# - News cannot be in position 1
# - News cannot be in position 2 (because of the relationship of L and O)
# - L cannot be in position 7 (which we already know from above...)
# - L cannot be in position 6 (because of the relationship of L and O)
LOGGER.info "Adding rules and facts for 'The news tape must be played at some time after L"
game.create_fact(game.entities["News"], position_property, Fact::NOT_EQUAL, 1)
game.create_fact(game.entities["News"], position_property, Fact::NOT_EQUAL, 2)
game.create_fact(game.entities["L"], position_property, Fact::NOT_EQUAL, 6)

#Rules: 
# - if News is in position 3 then L is in position 1
# - if News is in position 4 then L is NOT in positions 3, 5, 6, or 7
# - if News is in position 5 then L is NOT in positions 4, 6 or 7
# - if News is in position 6 then L is NOT in position 5, or 7
# - if L is in position 2 then News is NOT in position 1 or 3
# - if L is in position 3 then News is NOT in position 1, 2 or 4
# - if L is in position 4 then News is NOT in position 1, 2, 3, or 5
# - if L is in position 5 then News is in position 7
#Note: these rules will be tricky to automate: because News is after L, but O is immediately after L, News must be at least two after L
# - if News is in 
news = game.entities["News"]
l = game.entities["L"]
#Simple rules
game.create_rule(news, position_property, Clause::EQUAL, 3, l, position_property, Clause::EQUAL, 1)
game.create_rule(l, position_property, Clause::EQUAL, 5, news, position_property, Clause::EQUAL, 7)
#Rules for News
{4 => [3, 5, 6, 7], 5 => [4, 6, 7], 6 => [5, 7]}.each do |antecedant_value, consequent_values|
  game.create_rule(news, position_property, Clause::EQUAL, antecedant_value, l, position_property, Clause::NOT_EQUAL, consequent_values)
end
#Rules for L
{2 => [1, 3], 3 => [1, 2, 4], 4 => [1, 2, 3, 5]}.each do |antecedant_value, consequent_values|
  game.create_rule(l, position_property, Clause::EQUAL, antecedant_value, news, position_property, Clause::NOT_EQUAL, consequent_values)
end

#Rules and facts for "There must be exactly two time slots between G and P, regardless of whether G comes before P or whether G comes after P
#Facts: None
#Rules:
# - if G is in position 1 then P is in position 4
# - if G is in position 2 then P is in position 5
# - if G is in position 3 then P is in position 6
# - if G is in position 4 then P is NOT in positions 2, 3, 5, or 6
# - if G is in position 5 then P is in position 2
# - if G is in position 6 then P is in position 3
# - if G is in position 7 then P is in position 4
# - if P is in position 1 then G is in position 4
# - if P is in position 2 then G is in position 5
# - if P is in position 3 then G is in position 6
# - if P is in position 4 then G is NOT in positions 2, 3, 5, or 6
# - if P is in position 5 then G is in position 2
# - if P is in position 6 then G is in position 3
# - if P is in position 7 then G is in position 4
# - if G is not in position 1 then P is not in position 4
# - if G is not in position 2 then P is not in position 5
# - if G is not in position 3 then P is not in position 6
# - if G is not in position 4 then P is not in positions 1 or 7
# - if G is not in position 5 then P is not in position 2
# - if G is not in position 6 then P is not in position 3
# - if G is not in position 7 then P is not in position 4
# - if P is not in position 1 then G is not in position 4
# - if P is not in position 2 then G is not in position 5
# - if P is not in position 3 then G is not in position 6
# - if P is not in position 4 then G is not in positions 1 or 7
# - if P is not in position 5 then G is not in position 2
# - if P is not in position 6 then G is not in position 3
# - if P is not in position 7 then G is not in position 4

LOGGER.info "Adding rules and facts for 'There must be exactly two time slots between G and P, regardless of whether G comes before P or whether G comes after P'"
{"G" => "P", "P" => "G"}.each do |name1, name2|
  entity1 = game.entities[name1]
  entity2 = game.entities[name2]
  #Add the EQUALS rules
  {1 => 4, 2 => 5, 3 => 6, 5 => 2, 6 => 3, 7 => 4}.each do |antecedent_value, consequent_value|
    game.create_rule(entity1, position_property, Clause::EQUAL, antecedent_value, entity2, position_property, Clause::EQUAL, consequent_value)
    game.create_rule(entity1, position_property, Clause::NOT_EQUAL, antecedent_value, entity2, position_property, Clause::NOT_EQUAL, consequent_value)
  end
  #Add the NOT_EQUALS rules
  [2, 3, 5, 6].each do |consequent_value|
    game.create_rule(entity1, position_property, Clause::EQUAL, 4, entity2, position_property, Clause::NOT_EQUAL, consequent_value)
  end
  [1, 7].each do |consequent_value|
    game.create_rule(entity1, position_property, Clause::NOT_EQUAL, 4, entity2, position_property, Clause::NOT_EQUAL, consequent_value)
  end
  
end

#Generate whatever facts we can
game.rule_base.evaluate
#Now evaluate the questions
game.questions.each do |question|
  LOGGER.info "Evaluating question #{question.readable}"
  answer = question.evaluate
  if answer
    LOGGER.info "Answer: #{answer.readable}"
  else
    LOGGER.info "Could not answer the question..."
  end
end