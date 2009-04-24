require File.join(File.dirname(__FILE__), "base")

module Language
  module Position
    include Language::Base
    
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
    
    #Position-specific rules
    def new_rule(entity1, description, entity2, modifier = nil)
      if description == :before
        position_rule(entity1, entity2, modifier)
      elsif description == :after
        position_rule(entity2, entity1, modifier)
      end
    end
    
    def position_rule(first_entity, second_entity, distance = nil)
      first_entity = entity_called(first_entity) if first_entity.kind_of?(String)
      second_entity = entity_called(second_entity) if second_entity.kind_of?(String)
      if distance.nil?
        # Facts
        #   - first entity can't be in the last position
        #   - second_entity can't be in the first position
        game.create_fact(first_entity, property_called("Position"), Fact::NOT_EQUAL, positions.length)
        game.create_fact(second_entity, property_called("Position"), Fact::NOT_EQUAL, 1)
        # Rules
        #   - If first entity is in the second to last position, second entity is in the last position
        #   - If second entity is in position 2, first entity is in position 1
        #   - For positions 2 up to the third to last position, if first entity is in that position, then second entity is NOT in position 1 up to position-1
        #   - For positions 3 up to the second to last position, if second entity is in that position, the first entity is NOT in position+1 up to last position
        game.create_rule(first_entity, property_called("Position"), Clause::EQUAL, (positions.length-1), second_entity, property_called("Position"), Clause::EQUAL, positions.length)
        game.create_rule(second_entity, property_called("Position"), Clause::EQUAL, 2, first_entity, property_called("Position"), Clause::EQUAL, 1)
        2.upto(positions.length-2) do |first_position|
          1.upto(first_position-1) do |second_position|
            game.create_rule(first_entity, property_called("Position"), Clause::EQUAL, first_position, second_entity, property_called("Position"), Clause::NOT_EQUAL, second_position)
          end
        end
        3.upto(positions.length-1) do |second_position|
          (second_position+1).upto(positions.length) do |first_position|
            game.create_rule(second_entity, property_called("Position"), Clause::EQUAL, second_position, first_entity, property_called("Position"), Clause::NOT_EQUAL, first_position)
          end
        end
      else
        # Facts:
        #   - second entity can't be in positions 1 through distance
        #   - first entity can't be in positions last down to last - distance
        1.upto(distance) do |position|
          game.create_fact(second_entity, property_called("Position"), Fact::NOT_EQUAL, position)
          game.create_fact(first_entity, property_called("Position"), Fact::NOT_EQUAL, positions.length-position+1)
        end
        # Rules:
        #   - for positions 1 through size-distance, if first entity is in position, then second entity is in position + distance
        #     and if first entity is NOT in position, then second entity is NOT in position + distance
        #   - for positions distance through size, if second entity is in position, then first entity is in position - distance
        #     and if second entity is NOT in position then first entity is NOT in position - distance
        (positions.length - distance).times do |i|
          first_position = i+1
          second_position = first_position + distance
          game.create_rule(second_entity, property_called("Position"), Clause::EQUAL, second_position, first_entity, property_called("Position"), Clause::EQUAL, first_position)
          game.create_rule(second_entity, property_called("Position"), Clause::NOT_EQUAL, second_position, first_entity, property_called("Position"), Clause::NOT_EQUAL, first_position)
          game.create_rule(first_entity, property_called("Position"), Clause::EQUAL, first_position, second_entity, property_called("Position"), Clause::EQUAL, second_position)
          game.create_rule(first_entity, property_called("Position"), Clause::NOT_EQUAL, first_position, second_entity, property_called("Position"), Clause::NOT_EQUAL, second_position)
        end
      end
    end
    
  end
end