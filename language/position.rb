require File.join(File.dirname(__FILE__), "base")

#List of possible positions
def positions
  @positions
end

#Set up possible positions
def with_range(start, stop)
  @positions = []
  start.upto(stop) {|position| @positions << position}
end

#Override base's setup_game to add position_specific rules
def setup_game(property, *entities)
  #Work witht the entity objects, from their names
  entities = entities.collect {|name| game.entities[name]}
  #General rules: 
  #Mutual exclusion
  LOGGER.info "Adding mutual exclusion rules"
  game.add_mutual_exclusion_rules(entities, property, positions)
  #Last available value
  LOGGER.info "Adding last available rules"
  game.add_last_available_value_rules(entities, property, positions)
  #One place at a time rule
  LOGGER.info "Adding one place at a time rules"
  game.add_one_place_at_a_time_rules(entities, property, positions)

end