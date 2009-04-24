require File.join(File.dirname(__FILE__), "../language/position")
require File.join(File.dirname(__FILE__), "game_helpers")

class Broadcast
  include Language::Position
  include Helpers
  
  def initialize
    #Set up game description
    new_game
    called "Broadcast"
    described_as(
      "Seven consecutive time slots for a broadcast, numbered in chronological order 1 through 7, will be filled by six song tapes - G, H, L, O, P, S - and exactly one news tape. Each tape is to be assigned to a different time slot, and no tape is longer than any other tape. The broadcast is subject to the following restrictions:
        * L must be played immediately before O
        * The news tape must be played at some time after L
        * There must be exactly two time slots between G and P, regardless of whether G comes before P or whether G comes after P"
      )
        
    with_property "Position"
    with_range 1, 7
    for_entities "G", "H", "L", "O", "P", "S", "News"
    
    #Create the questions
    new_question
    described_as "If G is played second, which one of the following tapes must be played third?"
    with_fact "G", "Position", :is, 2
    determines ["News", "H", "L", "O", "S"], "Position", :is, 3
    
    #Display game
    puts game.readable
    
    #Create the rules and facts
    
    #L must be played immediately before O
    new_rule "L", :before, "O", 1
    #The news tape must be played at some time after L
    new_rule "News", :after, "L"
    
    #Additional implied rules (TODO)
    #Fact: 
    # - News cannot be in position 2 (because of the relationship of L and O)
    # - L cannot be in position 6 (because of the relationship of L and O)
    game.create_fact(game.entities["News"], property_called("Position"), Fact::NOT_EQUAL, 2)
    game.create_fact(game.entities["L"], property_called("Position"), Fact::NOT_EQUAL, 6)
    #Rules: 
    # - if News is in position 3 then L is in position 1
    # - if L is in position 5 then News is in position 7
    game.create_rule(game.entities["News"], property_called("Position"), Clause::EQUAL, 3, game.entities["L"], property_called("Position"), Clause::EQUAL, 1)
    game.create_rule(game.entities["L"], property_called("Position"), Clause::EQUAL, 5, game.entities["News"], property_called("Position"), Clause::EQUAL, 7)
    
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
        game.create_rule(entity1, property_called("Position"), Clause::EQUAL, antecedent_value, entity2, property_called("Position"), Clause::EQUAL, consequent_value)
        game.create_rule(entity1, property_called("Position"), Clause::NOT_EQUAL, antecedent_value, entity2, property_called("Position"), Clause::NOT_EQUAL, consequent_value)
      end
      #Add the NOT_EQUALS rules
      [2, 3, 5, 6].each do |consequent_value|
        game.create_rule(entity1, property_called("Position"), Clause::EQUAL, 4, entity2, property_called("Position"), Clause::NOT_EQUAL, consequent_value)
      end
      [1, 7].each do |consequent_value|
        game.create_rule(entity1, property_called("Position"), Clause::NOT_EQUAL, 4, entity2, property_called("Position"), Clause::NOT_EQUAL, consequent_value)
      end
      
    end
    
    #Generate whatever facts we can
    game.rule_base.evaluate
    
    #Now evaluate the questions
    game.questions.each do |question|
      LOGGER.info "Evaluating question #{question.readable}"
      answers[question] = question.evaluate
    end
    
  end
  
  
end

game = Broadcast.new
game.display_answers