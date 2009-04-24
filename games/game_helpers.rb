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
end