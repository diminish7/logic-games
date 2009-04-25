require File.join(File.dirname(__FILE__), "../language/position")
require File.join(File.dirname(__FILE__), "game_helpers")

class PianoInstructor
  include Language::Position
  include Helpers
  
  def initialize
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
    display_game
    
    #Create the rules and facts
    
    #Henry's lesson is later in the schedule than Janet's
    new_rule "Henry", :after, "Janet"
      
    #Una's lesson is later in the schedule than Steve's lesson
    new_rule "Una", :after, "Steve"
    
    #Steve's lesson is exactly three days after Grace's lesson
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
    
    #Janet's lesson is on the first day or else on the third day
    new_rule "Janet", :in_position, [1, 3]
    
    evaluate
    
  end
  
end

game = PianoInstructor.new
game.display_answers