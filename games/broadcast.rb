#Set up game description
game = Game.new("Broadcast")
game.description = <<DESC
Seven consecutive time slots for a broadcast, numbered in chronological order 1 through 7, will be filled by six song tapes - G, H, L, O, P, S - and exactly one news tape. Each tape is to be assigned to a different time slot, and no tape is longer than any other tape. The broadcast is subject to the following restrictions:

    * L must be played immediately before O
    * The news tape must be played at some time after L
    * There must be exactly two time slots between G and P, regardless of whether G comes before P or whether G comes after P
DESC
game.questions = []
game.questions << <<QUESTIONS
If G is played second, which one of the following tapes must be played third?

    * The news
    * H
    * L
    * O
    * S
QUESTIONS
#Display game
puts game.readable

#Set up the entities
position_property = Property.new
position_property.name = "Position"

["G", "H", "L", "O", "P", "S", "News"].each do |name|
  entity = Entity.new
  entity.name = name
  entity.properties = [position_property]
  game.entities[name] = entity
end

#Create the rules and facts
game.rule_base = RuleBase.new

#General rules: mutual exclusion
# - If G is in position 1, then H, L, O, P, S and News are NOT in position 1
# - etc...
game.add_mutual_exclusion_rules(game.entities.values, position_property, [1, 2, 3, 4, 5, 6, 7])

#Rules and facts for "L must be played immediately before O"
#Facts: 
# - O cannot be in position 1
# - L cannot be in position 7
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
6.times do |i|
  game.create_rule(game.entities["O"], position_property, Clause::EQUAL, (i+2), game.entities["L"], position_property, Clause::EQUAL, (i+1))
end
  
#Rules and facts for "The news tape must be played at some time after L"
#Fact: 
# - News cannot be in position 1
# - L cannot be in position 7 (which we already know from above...)
game.create_fact(game.entities["News"], position_property, Fact::NOT_EQUAL, 1)

#Rules: 
# - if News is in position 2 then L is in position 1
# - if News is in position 3 then L is NOT in positions 4, 5, 6 or 7
# - if News is in position 4 then L is NOT in positions 5, 6, or 7
# - if News is in position 5 then L is NOT in positions 6 or 7
# - if News is in position 6 then L is NOT in position 7
# - if L is in position 2 then News is NOT in position 1
# - if L is in position 3 then News is NOT in position 1 or 2
# - if L is in position 4 then News is NOT in position 1, 2 or 3
# - if L is in position 5 then News is NOT in position 1, 2, 3 or 4
# - if L is in position 6 then News is NOT in position 1, 2, 3, 4 or 5
{"News" => "L", "L" => "News"}.each do |name1, name2|
  entity1 = game.entities[name1]
  entity2 = game.entities[name2]
  #Add the one EQUAL rule
  game.create_rule(entity1, position_property, Clause::EQUAL, 2, entity2, position_property, Clause::EQUAL, 1)
  #Add all the NOT EQUAL rules
  {3 => [4, 5, 6, 7], 4 => [5, 6, 7], 5 => [6, 7], 6 => 7}.each do |antecedent_value, consequent_values|
    game.create_rule(entity1, position_property, Clause::EQUAL, antecedent_value, entity2, position_property, Clause::NOT_EQUAL, consequent_values)
  end
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
{"G" => "P", "P" => "G"}.each do |name1, name2|
  entity1 = game.entities[name1]
  entity2 = game.entities[name2]
  #Add the EQUALS rules
  {1 => 4, 2 => 5, 3 => 6, 5 => 2, 6 => 3, 7 => 4}.each do |antecedent_value, consequent_value|
    game.create_rule(entity1, position_property, Clause::EQUAL, antecedent_value, entity2, position_property, Clause::EQUAL, consequent_value)
  end
  #Add the NOT_EQUALS rules
  [2, 3, 5, 6].each do |consequent_value|
    game.create_rule(entity1, position_property, Clause::EQUAL, 4, entity2, position_property, Clause::NOT_EQUAL, consequent_value)
  end
end

#Generate whatever facts we can
game.rule_base.evaluate

#TODO: solve for questions (NOTE: need a new class to represent question with new facts and possible answers.  Adding facts shouldn't change the main rulebase)