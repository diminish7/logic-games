#Common helpers for games
module Helpers
  
  def answers
    @answers ||= {}
  end
  
  def display_answers
    answers.each do |question, answer|
      puts "Question:"
      puts "#{question.readable}"
      puts "Answer"
      puts answer ? answer.readable : "Unknown"
    end
  end
  
  def display_game
    puts game.readable
  end
  
  def evaluate
    game.rule_base.evaluate
    
    #Now evaluate the questions
    game.questions.each do |question|
      LOGGER.info "Evaluating question #{question.readable}"
      answers[question] = question.evaluate
    end
  end
end