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
    
    #Keep track of rules for inferred rules
    def known_rules
      @known_rules ||= {}
    end
    
    #Add rule to known_rules
    def track_rule(type, params)
      #TODO: Are there other types of rules that can be used inferring?
      known_rules[type] ||= {}
      if params[:first_entity]
        known_rules[type][params[:first_entity]] ||= []
        known_rules[type][params[:first_entity]] << params
      end
      if params[:second_entity]
        known_rules[type][params[:second_entity]] ||= []
        known_rules[type][params[:second_entity]] << params
      end
    end
    
    #Try to infer new rules from existing rules
    def infer_rules
      #Try to infer ordering rules (TODO: are there other types of rules that can be used to infer?)
      order_rules = known_rules[:ordered]
      #First entity is the same on two rules, and one of the rules has a specific distance
      order_rules.each do |entity, rules|
        next unless rules.length > 1  #Only checking combinations of rules
        if (specific_rule = rules.find { |r| r[:distance] != nil }) && (general_rule = rules.find { |r| r[:distance] == nil })
          if specific_rule[:first_entity] == general_rule[:first_entity]
            if specific_rule[:distance] == 1
              #Facts:
              # specific_rule[:first_entity] can't be in the second-to-last position
              # general_rule[:second_entity] can't be in second position
              first = entity_called(specific_rule[:first_entity])
              second = entity_called(general_rule[:second_entity])
              game.create_fact(first, position_property, Fact::NOT_EQUAL, positions.length-1)
              game.create_fact(second, position_property, Fact::NOT_EQUAL, 2)
              #Rules:
              # If specific_rule[:first_entity] is in the 3rd-to-last position, general_rule[:second_entity] is in the last position
              # If general_rule[:second_entity] is in the 3rd position, specific_rule[:first_entity] is in the first positions
              game.create_rule(first, position_property, Clause::EQUAL, positions.length-2, second, position_property, Clause::EQUAL, positions.length)
              game.create_rule(second, position_property, Clause::EQUAL, 3, first, position_property, Clause::EQUAL, 1)
            else
              #TODO: Can we infer anything?
            end
          elsif specific_rule[:first_entity] == general_rule[:second_entity]
            #TODO
          elsif specific_rule[:second_entity] == general_rule[:first_entity]
            #TODO: this applies to Grace, Steve and Una
          end
        end
      end
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
    
    #Helper - returns the property called 'Position'
    def position_property
      property_called("Position")
    end
    
    #Position-specific rules
    def new_rule(entity1, description, entity2, modifier = nil)
      case description
      when :before
        ordered_position_rule(entity1, entity2, modifier)
      when :after
        ordered_position_rule(entity2, entity1, modifier)
      when :separated_by
        #e.g. entity1 and entity2 have 2 slots between them, so entity2 is 3 ahead or behind entity1
        unordered_position_rule(entity1, entity2, modifier+1)
      when :distance_from
        unordered_positions_rule(entity1, entity2, modifier)
      when :in_position
        #TODO: entity2 is a number of array of numbers in this case.  Should refactor to be named something more generic...
        if entity2.respond_to?(:each)
          #Collection of possible positions
          specific_positions(entity1, entity2)
        else
          #One specific position
          specific_position(entity1, entity2)
        end
      end
    end
    
    #Rules where one entity is before the other
    def ordered_position_rule(first_entity, second_entity, distance = nil)
      first_entity = entity_called(first_entity) if first_entity.kind_of?(String)
      second_entity = entity_called(second_entity) if second_entity.kind_of?(String)
      #Keep track of rules so we can infer new rules from the combination of rules
      track_rule(:ordered, {:first_entity => first_entity.name, :second_entity => second_entity.name, :distance => distance})
      if distance.nil?
        general_ordered_position_rule(first_entity, second_entity)
      else
        specific_ordered_position_rule(first_entity, second_entity, distance)
      end
      #Try to infer new rules from the combinations of rules
      infer_rules
    end
    
    #Rules where one entity is before another by an unspecified distance
    def general_ordered_position_rule(first_entity, second_entity)
      # Facts
        #   - first entity can't be in the last position
        #   - second_entity can't be in the first position
        game.create_fact(first_entity, position_property, Fact::NOT_EQUAL, positions.length)
        game.create_fact(second_entity, position_property, Fact::NOT_EQUAL, 1)
        # Rules
        #   - If first entity is in the second to last position, second entity is in the last position
        #   - If second entity is in position 2, first entity is in position 1
        #   - For positions 2 up to the third to last position, if first entity is in that position, then second entity is NOT in position 1 up to position-1
        #   - For positions 3 up to the second to last position, if second entity is in that position, the first entity is NOT in position+1 up to last position
        game.create_rule(first_entity, position_property, Clause::EQUAL, (positions.length-1), second_entity, position_property, Clause::EQUAL, positions.length)
        game.create_rule(second_entity, position_property, Clause::EQUAL, 2, first_entity, position_property, Clause::EQUAL, 1)
        2.upto(positions.length-2) do |first_position|
          1.upto(first_position-1) do |second_position|
            game.create_rule(first_entity, position_property, Clause::EQUAL, first_position, second_entity, position_property, Clause::NOT_EQUAL, second_position)
          end
        end
        3.upto(positions.length-1) do |second_position|
          (second_position+1).upto(positions.length) do |first_position|
            game.create_rule(second_entity, position_property, Clause::EQUAL, second_position, first_entity, position_property, Clause::NOT_EQUAL, first_position)
          end
        end
    end
    
    #Rules where one entity is before another by an unspecified amount
    def specific_ordered_position_rule(first_entity, second_entity, distance)
      # Facts:
        #   - second entity can't be in positions 1 through distance
        #   - first entity can't be in positions last down to last - distance
        1.upto(distance) do |position|
          game.create_fact(second_entity, position_property, Fact::NOT_EQUAL, position)
          game.create_fact(first_entity, position_property, Fact::NOT_EQUAL, positions.length-position+1)
        end
        # Rules:
        #   - for positions 1 through size-distance, if first entity is in position, then second entity is in position + distance
        #     and if first entity is NOT in position, then second entity is NOT in position + distance
        #   - for positions distance through size, if second entity is in position, then first entity is in position - distance
        #     and if second entity is NOT in position then first entity is NOT in position - distance
        (positions.length - distance).times do |i|
          first_position = i+1
          second_position = first_position + distance
          game.create_rule(second_entity, position_property, Clause::EQUAL, second_position, first_entity, position_property, Clause::EQUAL, first_position)
          game.create_rule(second_entity, position_property, Clause::NOT_EQUAL, second_position, first_entity, position_property, Clause::NOT_EQUAL, first_position)
          game.create_rule(first_entity, position_property, Clause::EQUAL, first_position, second_entity, position_property, Clause::EQUAL, second_position)
          game.create_rule(first_entity, position_property, Clause::NOT_EQUAL, first_position, second_entity, position_property, Clause::NOT_EQUAL, second_position)
        end
    end
    
    #Rules where two entities are a certain distance apart, but order is not specified
    def unordered_position_rule(entity1, entity2, distance)
      entity1 = entity_called(entity1) if entity1.kind_of?(String)
      entity2 = entity_called(entity2) if entity2.kind_of?(String)
      # Facts: None
      # Rules:
      #   - for positions 1 through distance, if one of the entities is in that slot, the other must be distance slots ahead of it
      #   - for positions 1 through distance, if one of the entities is NOT in that slot, the other must NOT be distance slots ahead of it
      #   - for positions last down to last-distance, if one of the entities is in that slot, the other must be distance slots behind it
      #   - for positions last down to last-distance, if one of the entities is NOT in that slot, the other must NOT be distance slots behind it
      #   - for positions distance+1 through last-(distance+1), if one of the entities is in that position, then the other entity cannot equal any
      #     position other than position+distance and position-distance
      #   - for positions distance+1 through last-(distance+1), if one of the entities is NOT in that position, then the other entity cannot be in
      #     position-distance or position+distance
      1.upto(distance) do |position|
        game.create_rule(entity1, position_property, Clause::EQUAL, position, entity2, position_property, Clause::EQUAL, position+distance)
        game.create_rule(entity2, position_property, Clause::EQUAL, position, entity1, position_property, Clause::EQUAL, position+distance)
        game.create_rule(entity1, position_property, Clause::NOT_EQUAL, position, entity2, position_property, Clause::NOT_EQUAL, position+distance)
        game.create_rule(entity2, position_property, Clause::NOT_EQUAL, position, entity1, position_property, Clause::NOT_EQUAL, position+distance)
      end
      positions.length.downto(positions.length-distance) do |position|
        game.create_rule(entity1, position_property, Clause::EQUAL, position, entity2, position_property, Clause::EQUAL, position-distance)
        game.create_rule(entity2, position_property, Clause::EQUAL, position, entity1, position_property, Clause::EQUAL, position-distance)
        game.create_rule(entity1, position_property, Clause::NOT_EQUAL, position, entity2, position_property, Clause::NOT_EQUAL, position-distance)
        game.create_rule(entity2, position_property, Clause::NOT_EQUAL, position, entity1, position_property, Clause::NOT_EQUAL, position-distance)
      end
      (distance+1).upto(positions.length-(distance+1)) do |position1|
        1.upto(positions.length) do |position2|
          unless position1-distance == position2 || position1+distance == position2
            game.create_rule(entity1, position_property, Clause::EQUAL, position1, entity2, position_property, Clause::NOT_EQUAL, position2)
            game.create_rule(entity2, position_property, Clause::EQUAL, position1, entity1, position_property, Clause::NOT_EQUAL, position2)
          end
        end
        game.create_rule(entity1, position_property, Clause::NOT_EQUAL, position1, entity2, position_property, Clause::NOT_EQUAL, position1-distance)
        game.create_rule(entity1, position_property, Clause::NOT_EQUAL, position1, entity2, position_property, Clause::NOT_EQUAL, position1+distance)
        game.create_rule(entity2, position_property, Clause::NOT_EQUAL, position1, entity1, position_property, Clause::NOT_EQUAL, position1-distance)
        game.create_rule(entity2, position_property, Clause::NOT_EQUAL, position1, entity1, position_property, Clause::NOT_EQUAL, position1+distance)
      end
    end
    
    #Rules where an entity is in a specific position
    def specific_position(entity, position)
      entity = entity_called(entity) if entity.kind_of?(String)
      # Facts: Entity is in position
      # Rules: None
      game.create_fact(entity, position_property, Fact::EQUAL, position)
    end
    
    #Rules where an entity is in one of a set of specific positions
    def specific_positions(entity, position_list)
      entity = entity_called(entity) if entity.kind_of?(String)
      # Facts: Entity is NOT in any position other than the specified positions
      # Rules: None
      1.upto(positions.length) do |position|
        game.create_fact(entity, position_property, Fact::NOT_EQUAL, position) unless position_list.include?(position)
      end
    end
    
  end
end