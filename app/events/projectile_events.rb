# frozen_string_literal: true

# ==================== Projectile Events ====================

class UpdateProjectilesEvent
  include ChainableEvent
  
  def execute(context)
    game = context[:game]
    
    # Update all projectiles
    game[:projectiles].each do |projectile|
      update_projectile(projectile, game)
    end
    
    # Remove projectiles that have hit or are off screen
    game[:projectiles].reject! do |proj|
      proj[:hit] || off_screen?(proj)
    end
    
    # Update particles
    game[:particles].each do |particle|
      update_particle(particle)
    end
    
    # Remove dead particles
    game[:particles].reject! { |p| p[:life] <= 0 }
    
    success(context)
  end
  
  private
  
  def update_projectile(projectile, game)
    return if projectile[:hit]
    
    # Update target position if tracking
    if projectile[:target] && game[:enemies].include?(projectile[:target])
      projectile[:target_x] = projectile[:target][:x]
      projectile[:target_y] = projectile[:target][:y]
    end
    
    # Move towards target
    dx = projectile[:target_x] - projectile[:x]
    dy = projectile[:target_y] - projectile[:y]
    distance = Math.sqrt(dx * dx + dy * dy)
    
    # Check if hit target
    if distance < 10  # Hit detection threshold
      projectile[:hit] = true
      # Collision will be handled in CheckCollisionsEvent
    else
      # Move projectile
      projectile[:x] += (dx / distance) * projectile[:speed]
      projectile[:y] += (dy / distance) * projectile[:speed]
    end
  end
  
  def off_screen?(projectile)
    projectile[:x] < -100 || projectile[:x] > 1380 ||
    projectile[:y] < -100 || projectile[:y] > 820
  end
  
  def update_particle(particle)
    particle[:x] += particle[:vx]
    particle[:y] += particle[:vy]
    particle[:vy] -= 0.5  # Gravity
    particle[:life] -= 1
    
    # Fade out
    particle[:alpha] = (particle[:life].to_f / particle[:max_life] * 255).to_i
  end
end

class CheckCollisionsEvent
  include ChainableEvent
  
  def execute(context)
    game = context[:game]
    args = context[:args]
    
    # Check projectile collisions
    game[:projectiles].each do |projectile|
      next unless projectile[:hit]
      
      handle_projectile_hit(projectile, game, args)
    end
    
    success(context)
  end
  
  private
  
  def handle_projectile_hit(projectile, game, args)
    # Check for splash damage
    if projectile[:splash_radius]
      apply_splash_damage(projectile, game, args)
    else
      apply_single_target_damage(projectile, game, args)
    end
    
    # Spawn impact particles
    particle_type = case projectile[:type]
    when :cannonball then :explosion
    when :magic_bolt then :magic
    else :explosion
    end
    
    game.spawn_particles(projectile[:x], projectile[:y], particle_type)
  end
  
  def apply_single_target_damage(projectile, game, args)
    target = projectile[:target]
    
    return unless target && game[:enemies].include?(target)
    
    # Apply damage
    target[:health] -= projectile[:damage]
    
    # Apply slow effect if applicable
    if projectile[:slow_effect]
      target[:slow_factor] = projectile[:slow_effect]
      target[:slowed_until] = args.state.tick_count + projectile[:slow_duration]
    end
  end
  
  def apply_splash_damage(projectile, game, args)
    splash_radius_pixels = projectile[:splash_radius] * Constants::TILE_WIDTH
    
    game[:enemies].each do |enemy|
      dx = enemy[:x] - projectile[:x]
      dy = enemy[:y] - projectile[:y]
      distance = Math.sqrt(dx * dx + dy * dy)
      
      if distance <= splash_radius_pixels
        # Damage falls off with distance
        damage_multiplier = 1.0 - (distance / splash_radius_pixels) * 0.5
        damage = (projectile[:damage] * damage_multiplier).to_i
        
        enemy[:health] -= damage
        
        # Apply slow effect if applicable
        if projectile[:slow_effect]
          enemy[:slow_factor] = projectile[:slow_effect]
          enemy[:slowed_until] = args.state.tick_count + projectile[:slow_duration]
        end
      end
    end
  end
end
