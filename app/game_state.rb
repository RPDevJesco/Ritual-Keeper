# frozen_string_literal: true

# GameState manages all game data
class GameState
  def initialize
    @data = {}
    start_new_game
  end

  def [](key)
    @data[key]
  end

  def []=(key, value)
    @data[key] = value
  end

  def key?(key)
    @data.key?(key)
  end

  def start_new_game
    @data = {
      # Resources
      gold: Constants::STARTING_GOLD,
      lives: Constants::STARTING_LIVES,
      score: 0,
      
      # Wave system
      wave: 1,
      wave_active: false,
      wave_complete: false,
      enemies_spawned: 0,
      enemies_to_spawn: [],
      spawn_timer: 0,
      
      # Entities
      towers: [],
      enemies: [],
      projectiles: [],
      particles: [],
      
      # Selection & UI
      selected_tower_type: nil,
      selected_tower: nil,
      hovered_tile: nil,
      
      # Game state
      game_over: false,
      paused: false
    }
  end

  # Resource management
  def can_afford?(cost)
    @data[:gold] >= cost
  end

  def spend_gold(amount)
    @data[:gold] -= amount
  end

  def add_gold(amount)
    @data[:gold] += amount
  end

  def lose_life
    @data[:lives] -= 1
    @data[:game_over] = true if @data[:lives] <= 0
  end

  def add_score(points)
    @data[:score] += points
  end

  # Tower management
  def add_tower(tower)
    @data[:towers] << tower
  end

  def remove_tower(tower)
    @data[:towers].delete(tower)
  end

  def tower_at_tile(tile_x, tile_y)
    @data[:towers].find { |t| t[:tile_x] == tile_x && t[:tile_y] == tile_y }
  end

  # Enemy management
  def add_enemy(enemy)
    @data[:enemies] << enemy
  end

  def remove_enemy(enemy)
    @data[:enemies].delete(enemy)
  end

  # Projectile management
  def add_projectile(projectile)
    @data[:projectiles] << projectile
  end

  def remove_projectile(projectile)
    @data[:projectiles].delete(projectile)
  end

  # Particle effects
  def add_particle(particle)
    @data[:particles] << particle
  end

  def spawn_particles(x, y, config_name)
    config = Constants::PARTICLE_CONFIGS[config_name]
    return unless config

    config[:count].times do
      angle = rand * Math::PI * 2
      speed = rand * config[:spread]
      color = config[:colors].sample

      particle = {
        x: x,
        y: y,
        vx: Math.cos(angle) * speed,
        vy: Math.sin(angle) * speed,
        life: config[:life],
        max_life: config[:life],
        r: color[:r],
        g: color[:g],
        b: color[:b]
      }
      add_particle(particle)
    end
  end

  # Wave management
  def start_wave
    wave_def = Constants.wave(@data[:wave])
    @data[:wave_active] = true
    @data[:wave_complete] = false
    @data[:enemies_spawned] = 0
    @data[:spawn_timer] = 0
    
    # Build enemy spawn queue
    @data[:enemies_to_spawn] = []
    wave_def[:enemies].each do |enemy_group|
      enemy_group[:count].times do
        @data[:enemies_to_spawn] << {
          type: enemy_group[:type],
          spawn_time: @data[:enemies_to_spawn].length * enemy_group[:spawn_interval]
        }
      end
    end
    
    # Sort by spawn time
    @data[:enemies_to_spawn].sort_by! { |e| e[:spawn_time] }
    
    puts "🌊 Wave #{@data[:wave]} started! #{@data[:enemies_to_spawn].length} enemies incoming!"
  end

  def complete_wave
    @data[:wave_complete] = true
    @data[:wave_active] = false
    @data[:wave] += 1
    
    # Bonus gold for completing wave
    bonus = 50 + (@data[:wave] * 10)
    add_gold(bonus)
    
    puts "✅ Wave completed! +#{bonus} gold bonus!"
  end

  def is_wave_complete?
    @data[:enemies_to_spawn].empty? && @data[:enemies].empty?
  end
end
