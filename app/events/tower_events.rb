# frozen_string_literal: true

# ==================== Tower Events ====================

class UpdateTowersEvent
  include ChainableEvent
  
  def execute(context)
    game = context[:game]
    args = context[:args]
    
    # Update all towers
    game[:towers].each do |tower|
      update_tower(tower, game, args)
    end
    
    success(context)
  end
  
  private
  
  def update_tower(tower, game, args)
    # Decrease cooldown
    tower[:cooldown] -= 1 if tower[:cooldown] > 0
    
    # Find target if no current target or current target is dead
    if !tower[:target] || !game[:enemies].include?(tower[:target]) || tower[:target][:health] <= 0
      tower[:target] = find_target(tower, game)
    end
    
    # Attack target if in range and cooldown is ready
    if tower[:target] && tower[:cooldown] <= 0
      if in_range?(tower, tower[:target])
        fire_at_target(tower, tower[:target], game)
        # Set cooldown based on fire rate (60 fps / attacks per second)
        tower[:cooldown] = (60.0 / tower[:fire_rate]).to_i
      else
        # Target out of range
        tower[:target] = nil
      end
    end
  end
  
  def find_target(tower, game)
    # Filter enemies based on tower capabilities
    valid_targets = game[:enemies].select do |enemy|
      # Skip if flying and tower can't hit flying
      next false if enemy[:flying] && !tower[:can_hit_flying]
      
      # Check if in range
      in_range?(tower, enemy)
    end
    
    # Return enemy furthest along the path
    valid_targets.max_by { |e| e[:path_index] }
  end
  
  def in_range?(tower, enemy)
    dx = tower[:x] - enemy[:x]
    dy = tower[:y] - enemy[:y]
    distance = Math.sqrt(dx * dx + dy * dy)
    
    # Convert range from tiles to pixels
    range_pixels = tower[:range] * Constants::TILE_WIDTH
    
    distance <= range_pixels
  end
  
  def fire_at_target(tower, target, game)
    projectile = {
      x: tower[:x],
      y: tower[:y],
      target: target,
      target_x: target[:x],
      target_y: target[:y],
      speed: tower[:projectile_speed],
      damage: tower[:damage],
      type: tower[:projectile_type],
      splash_radius: tower[:splash_radius],
      slow_effect: tower[:slow_effect],
      slow_duration: tower[:slow_duration],
      source_tower: tower
    }
    
    game.add_projectile(projectile)
  end
end
