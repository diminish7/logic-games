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
    display_game
    
    #Create the rules and facts:
    
    #L must be played immediately before O
    new_rule "L", :before, "O", 1
    #The news tape must be played at some time after L
    new_rule "News", :after, "L"
    
    #There must be exactly two time slots between G and P, regardless of whether G comes before P or whether G comes after P
    new_rule "G", :separated_by, "P", 2
    
    #Generate whatever facts we can
    evaluate
    
  end
  
  
end

game = Broadcast.new
game.display_answers