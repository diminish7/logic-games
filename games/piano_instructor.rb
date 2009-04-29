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
    
    #Janet's lesson is on the first day or else on the third day
    new_rule "Janet", :in_position, [1, 3]
    
    evaluate
    
  end
  
end

game = PianoInstructor.new
game.display_answers