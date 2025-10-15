# frozen_string_literal: true

# ==================== Enemy Events ====================

class UpdateEnemiesEvent
  include ChainableEvent
  
  def execute(context)
    game = context[:game]
    args = context[:args]
    
    # Update all enemies
    game[:enemies].each do |enemy|
      update_enemy(enemy, game, args)
    end
    
    # Remove dead enemies
    game[:enemies].reject! do |enemy|
      if enemy[:health] <= 0
        handle_enemy_death(enemy, game)
        true
      else
        false
      end
    end
    
    success(context)
  end
  
  private
  
  def update_enemy(enemy, game, args)
    # Apply slow effect
    if enemy[:slowed_until] && args.state.tick_count < enemy[:slowed_until]
      enemy[:current_speed] = enemy[:speed] * enemy[:slow_factor]
    else
      enemy[:current_speed] = enemy[:speed]
      enemy[:slowed_until] = nil
    end
    
    # Move enemy along path
    move_enemy_along_path(enemy)
    
    # Check if enemy reached end of path
    if enemy[:path_index] >= Constants::ENEMY_PATH.length
      handle_enemy_escaped(enemy, game)
    end
  end
  
  def move_enemy_along_path(enemy)
    return if enemy[:path_index] >= Constants::ENEMY_PATH.length
    
    target_tile = Constants::ENEMY_PATH[enemy[:path_index]]
    target_pos = tile_to_screen(target_tile[0], target_tile[1])
    
    # Calculate direction to target
    dx = target_pos[:x] - enemy[:x]
    dy = target_pos[:y] - enemy[:y]
    distance = Math.sqrt(dx * dx + dy * dy)
    
    # Move towards target
    if distance < 5  # Close enough to target tile
      enemy[:path_index] += 1
      
      # Get next target if not at end
      if enemy[:path_index] < Constants::ENEMY_PATH.length
        next_tile = Constants::ENEMY_PATH[enemy[:path_index]]
        enemy[:target_x] = tile_to_screen(next_tile[0], next_tile[1])[:x]
        enemy[:target_y] = tile_to_screen(next_tile[0], next_tile[1])[:y]
      end
    else
      # Move towards target
      move_speed = enemy[:current_speed] || enemy[:speed]
      enemy[:x] += (dx / distance) * move_speed
      enemy[:y] += (dy / distance) * move_speed
    end
  end
  
  def handle_enemy_death(enemy, game)
    # Award gold and score
    game.add_gold(enemy[:gold_reward])
    game.add_score(enemy[:score_value])
    
    # Spawn death particles
    game.spawn_particles(enemy[:x], enemy[:y], :death)
    
    puts "💀 #{enemy[:name]} defeated! +#{enemy[:gold_reward]} gold"
  end
  
  def handle_enemy_escaped(enemy, game)
    game.lose_life
    game.remove_enemy(enemy)
    
    puts "💔 #{enemy[:name]} escaped! Lives: #{game[:lives]}"
    
    # Check for game over
    if game[:lives] <= 0
      puts "💀 GAME OVER!"
      $gtk.args.state.scene = :game_over
    end
  end
  
  def tile_to_screen(tile_x, tile_y)
    iso_x = (tile_x - tile_y) * (Constants::TILE_WIDTH / 2)
    iso_y = (tile_x + tile_y) * (Constants::TILE_HEIGHT / 2)
    
    screen_x = iso_x + (Constants::MAP_WIDTH * Constants::TILE_WIDTH / 2)
    screen_y = iso_y
    
    { x: screen_x, y: screen_y }
  end
end

class UpdateWaveSystemEvent
  include ChainableEvent
  
  def execute(context)
    game = context[:game]
    args = context[:args]
    
    # Check if wave is complete
    if game[:wave_active] && game.is_wave_complete?
      game.complete_wave
      return success(context)
    end
    
    # Spawn enemies if wave is active
    if game[:wave_active] && !game[:enemies_to_spawn].empty?
      spawn_pending_enemies(game, args)
    end
    
    # Auto-start next wave if all enemies are dead and wave is complete
    # (optional - comment out if you want manual wave start only)
    # if game[:wave_complete] && args.state.tick_count % 180 == 0  # 3 second delay
    #   game.start_wave
    # end
    
    success(context)
  end
  
  private
  
  def spawn_pending_enemies(game, args)
    game[:spawn_timer] += 1
    
    # Check if it's time to spawn the next enemy
    while !game[:enemies_to_spawn].empty? && game[:enemies_to_spawn].first[:spawn_time] <= game[:spawn_timer]
      enemy_data = game[:enemies_to_spawn].shift
      spawn_enemy(game, enemy_data[:type])
    end
  end
  
  def spawn_enemy(game, enemy_type)
    enemy_def = Constants.enemy(enemy_type)
    
    # Get first path tile as spawn point
    spawn_tile = Constants::ENEMY_PATH.first
    spawn_pos = tile_to_screen(spawn_tile[0], spawn_tile[1])
    
    enemy = {
      type: enemy_type,
      x: spawn_pos[:x],
      y: spawn_pos[:y],
      path_index: 0,
      current_speed: enemy_def[:speed],
      slowed_until: nil,
      slow_factor: 1.0
    }.merge(enemy_def)
    
    game.add_enemy(enemy)
    game[:enemies_spawned] += 1
  end
  
  def tile_to_screen(tile_x, tile_y)
    iso_x = (tile_x - tile_y) * (Constants::TILE_WIDTH / 2)
    iso_y = (tile_x + tile_y) * (Constants::TILE_HEIGHT / 2)
    
    screen_x = iso_x + (Constants::MAP_WIDTH * Constants::TILE_WIDTH / 2)
    screen_y = iso_y
    
    { x: screen_x, y: screen_y }
  end
end
