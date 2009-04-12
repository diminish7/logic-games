#Set up game description
game = Game.new("Piano Instructor")
game.rule_base = RuleBase.new
game.description = <<DESC
A piano instructor will schedule exactly one lesson for each of six students--Grace, Henry, Janet, Steve, Tom, and Una--one lesson per day for six consecutive days. The schedule must conform to the following conditions:

    * Henry's lesson is later in the schedule than Janet's
    * Una's lesson is later in the schedule than Steve's lesson
    * Steve's lesson is exactly three days after Grace's lesson
    * Janet's lesson is on the first day or else on the third day
DESC

#Set up the entities
position_property = Property.new
position_property.name = "Position"

["Grace", "Henry", "Janet", "Steve", "Tom", "Una"].each do |name|
  entity = Entity.new
  entity.name = name
  entity.properties = [position_property]
  game.entities[name] = entity
end

#Create the questions
game.questions = []
q = Question.new
q.text = "If Janet's lesson is scheduled for the first day, then the lesson for which one of the following students must be scheduled for the sixth day?"
q.rule_base = game.rule_base
q.type = Question::DETERMINE_TRUTH
#New facts
fact = Fact.new
fact.rule_base = game.rule_base
fact.comparator = Fact::EQUAL
fact.entity = game.entities["Janet"]
fact.property = position_property
fact.property_value = 1
q.new_facts = [fact]
q.options = []
#Options (L is the correct answer...)
["Grace", "Henry", "Steve", "Tom", "Una"].each do |name|
  option = Option.new
  fact = Fact.new
  fact.rule_base =game.rule_base
  fact.comparator = Fact::EQUAL
  fact.entity = game.entities[name]
  fact.property = position_property
  fact.property_value = 6
  option.facts = [fact]
  q.options << option
end
game.questions << q
#OTHER QUESTIONS TO ADD LATER
# 2. For which one of the following students is there an acceptable schedule in which the student's lesson is on the third day and another acceptable schedule in which the student's lesson is on the fifth day?
#    Grace, Henry, Steve, Tom, Una
# 3. Which one of the following is the complete and accurate list of the students any one of whom could be the student whose lesson is scheduled for the second day?
#    Grace
#    Tom
#    Grace, Tom
#    Henry, Tom 
#    Grace, Henry, Tom
# 4. If Henry's lesson is scheduled for a day either immediately before or immediately after Tom's lesson, then Grace's lesson must be scheduled for the:
#    first, second, third, fourth or fifth day?
# 5. If Janet's lesson is scheduled for the third day, which one of the following could be true?
#    Grace's lesson is scheduled for a later day than Henry's lesson
#    Grace's lesson is scheduled for a later day than Una's lesson
#    Henry's lesson is scheduled for a later day than Una's lesson
#    Tom's lesson is scheduled for a later day than Una's lesson
# 6. Which one of the following is a complete and accurate list of days any one of which could be the day for which Tom's lesson is scheduled?
#    first, second, third
#    second, third, fourth
#    second, fifth, sixth
#    first, second, third, fourth
#    second, third, fourth, sixth

#Display game
puts game.readable

#Create the rules and facts

#General rules: 
#Mutual exclusion
LOGGER.info "Adding mutual exclusion rules"
game.add_mutual_exclusion_rules(game.entities.values, position_property, [1, 2, 3, 4, 5, 6])
#Last available value
LOGGER.info "Adding last available rules"
game.add_last_available_value_rules(game.entities.values, position_property, [1, 2, 3, 4, 5, 6])
#One place at a time rule
LOGGER.info "Adding one place at a time rules"
game.add_one_place_at_a_time_rules(game.entities.values, position_property, [1, 2, 3, 4, 5, 6])

#Rules and facts for "Henry's lesson is later in the schedule than Janet's"
#Facts: 
# - Henry cannot be in position 1
# - Janet cannot be in position 6
LOGGER.info "Adding rules and facts for \"Henry's lesson is later in the schedule than Janet's\""
[["Henry", 1], ["Janet", 6]].each do |entity_name, position|
  game.create_fact(game.entities[entity_name], position_property, Fact::NOT_EQUAL, position)
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
game.create_rule(game.entities["Henry"], position_property, Clause::EQUAL, 2, game.entities["Janet"], position_property, Clause::EQUAL, 1)
game.create_rule(game.entities["Janet"], position_property, Clause::EQUAL, 5, game.entities["Henry"], position_property, Clause::EQUAL, 6)
#Rules for Henry
{3 => [4, 5, 6], 4 => [5, 6], 5 => [6]}.each do |antecedant_value, consequent_values|
  game.create_rule(game.entities["Henry"], position_property, Clause::EQUAL, antecedant_value, game.entities["Janet"], position_property, Clause::NOT_EQUAL, consequent_values)
end
#Rules for Janet
{2 => [1], 3 => [1, 2], 4 => [1, 2, 3]}.each do |antecedant_value, consequent_values|
  game.create_rule(game.entities["Janet"], position_property, Clause::EQUAL, antecedant_value, game.entities["Henry"], position_property, Clause::NOT_EQUAL, consequent_values)
end

  
#Rules and facts for "Una's lesson is later in the schedule than Steve's lesson"
#Facts: 
# - Una cannot be in position 1
# - Steve cannot be in position 6
LOGGER.info "Adding rules and facts for \"Una's lesson is later in the schedule than Steve's\""
[["Una", 1], ["Steve", 6]].each do |entity_name, position|
  game.create_fact(game.entities[entity_name], position_property, Fact::NOT_EQUAL, position)
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
game.create_rule(game.entities["Una"], position_property, Clause::EQUAL, 2, game.entities["Steve"], position_property, Clause::EQUAL, 1)
game.create_rule(game.entities["Steve"], position_property, Clause::EQUAL, 5, game.entities["Una"], position_property, Clause::EQUAL, 6)
#Rules for Una
{3 => [4, 5, 6], 4 => [5, 6], 5 => [6]}.each do |antecedant_value, consequent_values|
  game.create_rule(game.entities["Una"], position_property, Clause::EQUAL, antecedant_value, game.entities["Steve"], position_property, Clause::NOT_EQUAL, consequent_values)
end
#Complex rules for Una
[5, 6].each do |position|
  game.create_rule(game.entities["Una"], position_property, Clause::NOT_EQUAL, 6, game.entities["Steve"], position_property, Clause::NOT_EQUAL, position)
end
{[5, 6] => [4, 5, 6], [4, 5, 6] => [3, 4, 5, 6], [3, 4, 5, 6] => [2, 3, 4, 5, 6]}.each do |antecedent_values, consequent_values|
  consequent_values.each do |consequent_value|
    game.create_compound_rule(game.entities["Una"], position_property, Clause::NOT_EQUAL, antecedent_values, ClauseCluster::AND, game.entities["Steve"], position_property, Clause::NOT_EQUAL, consequent_value)
  end
end
#Rules for Steve
{2 => [1], 3 => [1, 2], 4 => [1, 2, 3]}.each do |antecedant_value, consequent_values|
  game.create_rule(game.entities["Steve"], position_property, Clause::EQUAL, antecedant_value, game.entities["Una"], position_property, Clause::NOT_EQUAL, consequent_values)
end
#Complex Rules for Steve
[1, 2].each do |position|
  game.create_rule(game.entities["Steve"], position_property, Clause::NOT_EQUAL, 1, game.entities["Una"], position_property, Clause::NOT_EQUAL, position)
end
{[1, 2] => [1, 2, 3], [1, 2, 3] => [1, 2, 3, 4], [1, 2, 3, 4] => [1, 2, 3, 4, 5]}.each do |antecedent_values, consequent_values|
  consequent_values.each do |consequent_value|
    game.create_compound_rule(game.entities["Steve"], position_property, Clause::NOT_EQUAL, antecedent_values, ClauseCluster::AND, game.entities["Una"], position_property, Clause::NOT_EQUAL, consequent_value)
  end
end

#Rules and Facts for "Steve's lesson is exactly three days after Grace's lesson"
#Fact:
# - Steve is not in position 1, 2 or 3
# - Grace is not in position 4, 5, or 6
LOGGER.info "Adding rules and facts for \"Steve's lesson is exactly three days after Grace's lesson\""
{"Steve" => [1, 2, 3], "Grace" => [4, 5, 6]}.each do |entity_name, positions|
  positions.each do |position|
    game.create_fact(game.entities[entity_name], position_property, Fact::NOT_EQUAL, position)
  end
end
#Rules:
# - if Steve is in position 4 then Grace is in position 1
# - if Steve is in position 5 then Grace is in position 2
# - if Steve is in position 6 then Grace is in position 3
# - if Steve is NOT in position 4 then Grace is NOT in position 1
# - if Steve is NOT in position 5 then Grace is NOT in position 2
# - if Steve is NOT in position 6 then Grace is NOT in position 3
# - if Grace is in position 1 then Steve is in position 4
# - if Grace is in position 2 then Steve is in position 5
# - if Grace is in position 3 then Steve is in position 6
# - if Grace is NOT in position 1 then Steve is NOT in position 4
# - if Grace is NOT in position 2 then Steve is NOT in position 5
# - if Grace is NOT in position 3 then Steve is NOT in position 6
#Rules for Steve
4.upto(6) do |position|
  game.create_rule(game.entities["Steve"], position_property, Clause::EQUAL, position, game.entities["Grace"], position_property, Clause::EQUAL, (position-3))
  game.create_rule(game.entities["Steve"], position_property, Clause::NOT_EQUAL, position, game.entities["Grace"], position_property, Clause::NOT_EQUAL, (position-3))
end
#Rules for Grace
1.upto(3) do |position|
  game.create_rule(game.entities["Grace"], position_property, Clause::EQUAL, position, game.entities["Steve"], position_property, Clause::EQUAL, (position+3))
  game.create_rule(game.entities["Grace"], position_property, Clause::NOT_EQUAL, position, game.entities["Steve"], position_property, Clause::NOT_EQUAL, (position+3))
end

#Rules and Facts for the combination of the two Steve rules above:
#Fact: 
# - Una is not in positions 1, 2, 3 or 4
# - Grace is NOT in position 3
LOGGER.info "Adding rules and facts for combination of rules"
[1, 2, 3, 4].each do |position|
  game.create_fact(game.entities["Una"], position_property, Fact::NOT_EQUAL, position)
end
game.create_fact(game.entities["Grace"], position_property, Fact::NOT_EQUAL, 3)
#Rules:
#(una is 4 or more positions after grace)
# - if Una is in position 4 then Grace is in position 1
# - if Una is in position 5 then Gace is NOT in positions 3, 4 or 6
# - if Una is in position 6 then Grace is NOT in positions 4 or 5
# - if Grace is in position 1 then Una is NOT in positions 2 or 3
# - if Grace is in position 2 then Una is NOT in positions 1, 3 or 4
# - if Grace is in positions 3 then Una is in position 6
game.create_rule(game.entities["Una"], position_property, Clause::EQUAL, 4, game.entities["Grace"], position_property, Clause::EQUAL, 1)
game.create_rule(game.entities["Grace"], position_property, Clause::EQUAL, 3, game.entities["Una"], position_property, Clause::EQUAL, 6)
#Rules for Una
{5 => [3, 4, 6], 6 => [4, 5]}.each do |antecedant_value, consequent_values|
  game.create_rule(game.entities["Una"], position_property, Clause::EQUAL, antecedant_value, game.entities["Grace"], position_property, Clause::NOT_EQUAL, consequent_values)
end
#Rules for Grace
{1 => [2, 3], 2 => [1, 3, 4]}.each do |antecedant_value, consequent_values|
  game.create_rule(game.entities["Grace"], position_property, Clause::EQUAL, antecedant_value, game.entities["Una"], position_property, Clause::NOT_EQUAL, consequent_values)
end

#Rules and Facts for "Janet's lesson is on the first day or else on the third day"
#Facts:
# - Janet is not in position 2
# - Janet is not in position 4
# - Janet is not in position 5
# - Janet is not in position 6
LOGGER.info "Adding rules and facts for \"Janet's lesson is on the first day or else on the third day\""
[2, 4, 5, 6].each do |position|
  game.create_fact(game.entities["Janet"], position_property, Fact::NOT_EQUAL, position)
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