require File.join(File.dirname(__FILE__), "../language/position")
include Language::Position

#Set up game description
new_game
called "Piano Instructor"
described_as(
  "A piano instructor will schedule exactly one lesson for each of six students--Grace, Henry, Janet, Steve, Tom, and Una--one lesson per day for six consecutive days. The schedule must conform to the following conditions:
    * Henry's lesson is later in the schedule than Janet's
    * Una's lesson is later in the schedule than Steve's lesson
    * Steve's lesson is exactly three days after Grace's lesson
    * Janet's lesson is on the first day or else on the third day"
  )
    
with_property "Position"
with_range 1, 6
for_entities "Grace", "Henry", "Janet", "Steve", "Tom", "Una"

#Create the questions
new_question
described_as "If Janet's lesson is scheduled for the first day, then the lesson for which one of the following students must be scheduled for the sixth day?"
with_fact "Janet", "Position", :is, 1
determines ["Grace", "Henry", "Steve", "Tom", "Una"], "Position", :is, 6

#Display game
puts game.readable

#Create the rules and facts

#Rules and facts for "Henry's lesson is later in the schedule than Janet's"
#Facts: 
# - Henry cannot be in position 1
# - Janet cannot be in position 6
LOGGER.info "Adding rules and facts for \"Henry's lesson is later in the schedule than Janet's\""
[["Henry", 1], ["Janet", 6]].each do |entity_name, position|
  game.create_fact(game.entities[entity_name], property_called("Position"), Fact::NOT_EQUAL, position)
end

#Rules:
# - if Henry is in position 2 then Janet is in position 1
# - if Henry is in position 3 then Janet is NOT in positions 4, 5, or 6
# - if Henry is in position 4 then Janet is NOT in positions 5 or 6
# - if Henry is in position 5 then Janet is NOT in position 6
# - if Janet is in position 2 then Henry is NOT in position 1
# - if Janet is in position 3 then Henry is NOT in positions 1 or 2
# - if Janet is in position 4 then Henry is NOT in positions 1, 2 or 3
# - if Janet is in position 5 then Henry is in position 6
#Simple rules
game.create_rule(game.entities["Henry"], property_called("Position"), Clause::EQUAL, 2, game.entities["Janet"], property_called("Position"), Clause::EQUAL, 1)
game.create_rule(game.entities["Janet"], property_called("Position"), Clause::EQUAL, 5, game.entities["Henry"], property_called("Position"), Clause::EQUAL, 6)
#Rules for Henry
{3 => [4, 5, 6], 4 => [5, 6], 5 => [6]}.each do |antecedant_value, consequent_values|
  game.create_rule(game.entities["Henry"], property_called("Position"), Clause::EQUAL, antecedant_value, game.entities["Janet"], property_called("Position"), Clause::NOT_EQUAL, consequent_values)
end
#Rules for Janet
{2 => [1], 3 => [1, 2], 4 => [1, 2, 3]}.each do |antecedant_value, consequent_values|
  game.create_rule(game.entities["Janet"], property_called("Position"), Clause::EQUAL, antecedant_value, game.entities["Henry"], property_called("Position"), Clause::NOT_EQUAL, consequent_values)
end

  
#Rules and facts for "Una's lesson is later in the schedule than Steve's lesson"
#Facts: 
# - Una cannot be in position 1
# - Steve cannot be in position 6
LOGGER.info "Adding rules and facts for \"Una's lesson is later in the schedule than Steve's\""
[["Una", 1], ["Steve", 6]].each do |entity_name, position|
  game.create_fact(game.entities[entity_name], property_called("Position"), Fact::NOT_EQUAL, position)
end

#Rules:
# - if Una is in position 2 then Steve is in position 1
# - if Una is in position 3 then Steve is NOT in positions 4, 5, or 6
# - if Una is in position 4 then Steve is NOT in positions 5 or 6
# - if Una is in position 5 then Steve is NOT in position 6
# - If Una is NOT in position 6 the Steve is NOT in positions 5 or 6
# - if Una is NOT in positions 5 or 6 then Steve is NOT in positions 4, 5, or 6
# - if Una is NOT in positions 4, 5 or 6, then Steve is NOT in positions 3, 4, 5 or 6
# - if Una is NOT in positions 3, 4, 5 or 6 then Steve is NOT in positions 2, 3, 4, 5 or 6
# - if Steve is in position 2 then Una is NOT in position 1
# - if Steve is in position 3 then Una is NOT in positions 1 or 2
# - if Steve is in position 4 then Una is NOT in positions 1, 2 or 3
# - if Steve is in position 5 then Una is in position 6
# - if Steve is NOT in positions 1, then Una is NOT in position 1 or 2
# - if Steve is NOT in positions 1 or 2, then Una is NOT in positions 1, 2, or 3
# - if Steve is NOT in positions 1, 2 or 3, then Una is NOT in positions 1, 2, 3 or 4
# - if Steve is NOT in positions 1, 2, 3, or 4, then Una is NOT in positions 1, 2, 3, 4 or 5
#####
#Simple rules
game.create_rule(game.entities["Una"], property_called("Position"), Clause::EQUAL, 2, game.entities["Steve"], property_called("Position"), Clause::EQUAL, 1)
game.create_rule(game.entities["Steve"], property_called("Position"), Clause::EQUAL, 5, game.entities["Una"], property_called("Position"), Clause::EQUAL, 6)
#Rules for Una
{3 => [4, 5, 6], 4 => [5, 6], 5 => [6]}.each do |antecedant_value, consequent_values|
  game.create_rule(game.entities["Una"], property_called("Position"), Clause::EQUAL, antecedant_value, game.entities["Steve"], property_called("Position"), Clause::NOT_EQUAL, consequent_values)
end
#Complex rules for Una
[5, 6].each do |position|
  game.create_rule(game.entities["Una"], property_called("Position"), Clause::NOT_EQUAL, 6, game.entities["Steve"], property_called("Position"), Clause::NOT_EQUAL, position)
end
{[5, 6] => [4, 5, 6], [4, 5, 6] => [3, 4, 5, 6], [3, 4, 5, 6] => [2, 3, 4, 5, 6]}.each do |antecedent_values, consequent_values|
  consequent_values.each do |consequent_value|
    game.create_compound_rule(game.entities["Una"], property_called("Position"), Clause::NOT_EQUAL, antecedent_values, ClauseCluster::AND, game.entities["Steve"], property_called("Position"), Clause::NOT_EQUAL, consequent_value)
  end
end
#Rules for Steve
{2 => [1], 3 => [1, 2], 4 => [1, 2, 3]}.each do |antecedant_value, consequent_values|
  game.create_rule(game.entities["Steve"], property_called("Position"), Clause::EQUAL, antecedant_value, game.entities["Una"], property_called("Position"), Clause::NOT_EQUAL, consequent_values)
end
#Complex Rules for Steve
[1, 2].each do |position|
  game.create_rule(game.entities["Steve"], property_called("Position"), Clause::NOT_EQUAL, 1, game.entities["Una"], property_called("Position"), Clause::NOT_EQUAL, position)
end
{[1, 2] => [1, 2, 3], [1, 2, 3] => [1, 2, 3, 4], [1, 2, 3, 4] => [1, 2, 3, 4, 5]}.each do |antecedent_values, consequent_values|
  consequent_values.each do |consequent_value|
    game.create_compound_rule(game.entities["Steve"], property_called("Position"), Clause::NOT_EQUAL, antecedent_values, ClauseCluster::AND, game.entities["Una"], property_called("Position"), Clause::NOT_EQUAL, consequent_value)
  end
end

#Rules and Facts for "Steve's lesson is exactly three days after Grace's lesson"
new_rule "Steve", :after, "Grace", 3

#Rules and Facts for the combination of the two Steve rules above:
#Fact: 
# - Una is not in positions 1, 2, 3 or 4
# - Grace is NOT in position 3
LOGGER.info "Adding rules and facts for combination of rules"
[1, 2, 3, 4].each do |position|
  game.create_fact(game.entities["Una"], property_called("Position"), Fact::NOT_EQUAL, position)
end
game.create_fact(game.entities["Grace"], property_called("Position"), Fact::NOT_EQUAL, 3)
#Rules:
#(una is 4 or more positions after grace)
# - if Una is in position 4 then Grace is in position 1
# - if Una is in position 5 then Gace is NOT in positions 3, 4 or 6
# - if Una is in position 6 then Grace is NOT in positions 4 or 5
# - if Grace is in position 1 then Una is NOT in positions 2 or 3
# - if Grace is in position 2 then Una is NOT in positions 1, 3 or 4
# - if Grace is in positions 3 then Una is in position 6
game.create_rule(game.entities["Una"], property_called("Position"), Clause::EQUAL, 4, game.entities["Grace"], property_called("Position"), Clause::EQUAL, 1)
game.create_rule(game.entities["Grace"], property_called("Position"), Clause::EQUAL, 3, game.entities["Una"], property_called("Position"), Clause::EQUAL, 6)
#Rules for Una
{5 => [3, 4, 6], 6 => [4, 5]}.each do |antecedant_value, consequent_values|
  game.create_rule(game.entities["Una"], property_called("Position"), Clause::EQUAL, antecedant_value, game.entities["Grace"], property_called("Position"), Clause::NOT_EQUAL, consequent_values)
end
#Rules for Grace
{1 => [2, 3], 2 => [1, 3, 4]}.each do |antecedant_value, consequent_values|
  game.create_rule(game.entities["Grace"], property_called("Position"), Clause::EQUAL, antecedant_value, game.entities["Una"], property_called("Position"), Clause::NOT_EQUAL, consequent_values)
end

#Rules and Facts for "Janet's lesson is on the first day or else on the third day"
#Facts:
# - Janet is not in position 2
# - Janet is not in position 4
# - Janet is not in position 5
# - Janet is not in position 6
LOGGER.info "Adding rules and facts for \"Janet's lesson is on the first day or else on the third day\""
[2, 4, 5, 6].each do |position|
  game.create_fact(game.entities["Janet"], property_called("Position"), Fact::NOT_EQUAL, position)
end
#Rules: None

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