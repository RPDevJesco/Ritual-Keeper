# frozen_string_literal: true

# ==================== Game Configuration Constants ====================
# Modify these values to customize your tower defense game!

module Constants
  # ==================== Map Configuration ====================
  MAP_WIDTH = 20        # Number of tiles wide
  MAP_HEIGHT = 15       # Number of tiles tall
  TILE_WIDTH = 64       # Isometric tile width in pixels
  TILE_HEIGHT = 32      # Isometric tile height in pixels
  
  # ==================== Camera Settings ====================
  CAMERA_SPEED = 5      # Pixels per frame for camera movement
  ZOOM_MIN = 0.5
  ZOOM_MAX = 2.0
  ZOOM_SPEED = 0.1
  
  # ==================== Game Balance ====================
  STARTING_GOLD = 500
  STARTING_LIVES = 20
  
  # ==================== Enemy Definitions ====================
  # Define different enemy types with their properties
  ENEMY_TYPES = {
    basic: {
      name: "Goblin",
      health: 100,
      speed: 2.0,           # Tiles per second
      gold_reward: 10,
      score_value: 10,
      sprite_path: 'sprites/UFO/UFO(1).png',  # ← Removed leading slash
      size: 20
    },
    
    fast: {
      name: "Wolf",
      health: 60,
      speed: 4.0,
      gold_reward: 15,
      score_value: 20,
      sprite_path: 'sprites/UFO/UFO(3).png',
      size: 20
    },
    
    tank: {
      name: "Troll",
      health: 300,
      speed: 1.0,
      gold_reward: 30,
      score_value: 40,
      sprite_path: 'sprites/UFO/UFO(5).png',
      size: 20
    },
    
    flying: {
      name: "Bat",
      health: 50,
      speed: 3.0,
      gold_reward: 20,
      score_value: 30,
      sprite_path: 'sprites/UFO/UFO(6).png',
      size: 20,             # ← FIXED: Added missing comma
      flying: true          # Can't be hit by ground-only towers
    },
    
    boss: {
      name: "Dragon",
      health: 1000,
      speed: 0.8,
      gold_reward: 100,
      score_value: 200,
      sprite_path: 'sprites/UFO/UFO(8).png',
      size: 40              # ← No comma needed (last item)
    }
  }
  
  # ==================== Tower Definitions ====================
  # Define different tower types with their properties
  TOWER_TYPES = {
    archer: {
      name: "Archer Tower",
      cost: 100,
      damage: 25,
      range: 3.5,           # In tiles
      fire_rate: 1.0,       # Attacks per second
      projectile_speed: 8.0,
      projectile_type: :arrow,
      can_hit_flying: true,
      upgrade_cost: 75,
      sprite_path: 'sprites/Towers/Archer/archer_level_1.png'
    },
    
    cannon: {
      name: "Cannon Tower",
      cost: 200,
      damage: 75,
      range: 4.0,
      fire_rate: 0.5,
      projectile_speed: 6.0,
      projectile_type: :cannonball,
      splash_radius: 1.5,   # Tiles - deals damage in area
      can_hit_flying: false,
      upgrade_cost: 150,
      sprite_path: 'sprites/Towers/Archer/archer_level_1.png'
    },
    
    mage: {
      name: "Mage Tower",
      cost: 150,
      damage: 40,
      range: 4.5,
      fire_rate: 1.2,
      projectile_speed: 10.0,
      projectile_type: :magic_bolt,
      slow_effect: 0.5,     # Slows enemy by 50% for 2 seconds
      slow_duration: 120,   # 2 seconds at 60 fps
      can_hit_flying: true,
      upgrade_cost: 100,
      sprite_path: 'sprites/Towers/Barrack/barrack_level_1 (1).png'
    },
    
    sniper: {
      name: "Sniper Tower",
      cost: 300,
      damage: 200,
      range: 7.0,
      fire_rate: 0.3,
      projectile_speed: 15.0,
      projectile_type: :bullet,
      can_hit_flying: true,
      upgrade_cost: 250,
      sprite_path: 'sprites/Towers/Wizard/wizard_level_1.png'
    }
  }
  
  # ==================== Projectile Visuals ====================
  PROJECTILE_VISUALS = {
    arrow: {
      size: 8,
      sprite_path: 'sprites/Towers/Archer/arrow.png',
      trail: true
    },
    
    cannonball: {
      size: 12,
      sprite_path: 'sprites/Towers/Wizard/wizard_bullet.png',
      trail: false
    },
    
    magic_bolt: {
      size: 10,
      sprite_path: 'sprites/Towers/Barrack/sword.png',
      trail: true,
      glow: true
    },
    
    bullet: {
      size: 6,
      sprite_path: 'sprites/Towers/Archer/arrow.png',
      trail: true
    }
  }
  
  # ==================== Wave Configuration ====================
  # Define enemy waves - each wave spawns enemies over time
  WAVE_DEFINITIONS = [
    # Wave 1 - Tutorial wave
    {
      enemies: [
        { type: :basic, count: 10, spawn_interval: 60 }  # 1 enemy per second
      ]
    },
    
    # Wave 2 - Mix of basics and fast
    {
      enemies: [
        { type: :basic, count: 8, spawn_interval: 45 },
        { type: :fast, count: 5, spawn_interval: 60 }
      ]
    },
    
    # Wave 3 - Introduce tank
    {
      enemies: [
        { type: :basic, count: 12, spawn_interval: 40 },
        { type: :fast, count: 6, spawn_interval: 50 },
        { type: :tank, count: 2, spawn_interval: 120 }
      ]
    },
    
    # Wave 4 - Flying enemies
    {
      enemies: [
        { type: :basic, count: 10, spawn_interval: 35 },
        { type: :flying, count: 8, spawn_interval: 45 }
      ]
    },
    
    # Wave 5 - Boss wave
    {
      enemies: [
        { type: :basic, count: 15, spawn_interval: 30 },
        { type: :fast, count: 10, spawn_interval: 40 },
        { type: :tank, count: 3, spawn_interval: 90 },
        { type: :boss, count: 1, spawn_interval: 180 }
      ]
    }
  ]
  
  # After wave 5, generate procedural waves with increasing difficulty
  WAVE_SCALE_FACTOR = 1.2  # Each wave gets 20% harder
  
  # ==================== Path Definition ====================
  # Define the path enemies follow (in tile coordinates)
  # This creates an S-shaped path through the map
  ENEMY_PATH = [
    [1, 7],
    [5, 7],
    [5, 10],
    [10, 10],
    [10, 5],
    [15, 5],
    [15, 7],
    [19, 7]
  ]
  
  # ==================== Buildable Tiles ====================
  # Define which tiles can have towers (1 = buildable, 0 = path/blocked)
  # This is a simple example - you can make this as complex as you want
  def self.tile_buildable?(tile_x, tile_y)
    # Can't build on path tiles
    ENEMY_PATH.each do |path_tile|
      return false if (path_tile[0] - tile_x).abs <= 1 && (path_tile[1] - tile_y).abs <= 1
    end
    
    # Can't build out of bounds
    return false if tile_x < 0 || tile_x >= MAP_WIDTH
    return false if tile_y < 0 || tile_y >= MAP_HEIGHT
    
    true
  end
  
  # ==================== UI Colors & Styling ====================
  UI_COLORS = {
    background: { r: 20, g: 20, b: 30 },
    panel: { r: 40, g: 40, b: 50 },
    text: { r: 255, g: 255, b: 255 },
    text_dim: { r: 150, g: 150, b: 150 },
    gold: { r: 255, g: 215, b: 0 },
    health: { r: 255, g: 100, b: 100 },
    button: { r: 60, g: 60, b: 80 },
    button_hover: { r: 80, g: 80, b: 120 },
    button_disabled: { r: 40, g: 40, b: 40 }
  }
  
  # ==================== Tile Types ====================
  TILE_TYPES = {
    grass: { r: 80, g: 140, b: 60 },
    path: { r: 120, g: 100, b: 80 },
    buildable: { r: 100, g: 120, b: 80 },
    blocked: { r: 60, g: 60, b: 60 }
  }
  
  # ==================== Sound Effects (placeholders) ====================
  # In a full implementation, these would reference actual sound files
  SOUNDS = {
    tower_build: "sounds/build.wav",
    tower_shoot: "sounds/shoot.wav",
    enemy_hit: "sounds/hit.wav",
    enemy_death: "sounds/death.wav",
    wave_start: "sounds/wave_start.wav",
    wave_complete: "sounds/wave_complete.wav",
    game_over: "sounds/game_over.wav",
    background_music: "sounds/music.wav"
  }
  
  # ==================== Particle Effects ====================
  PARTICLE_CONFIGS = {
    explosion: {
      count: 20,
      life: 30,
      spread: 50,
      colors: [
        { r: 255, g: 100, b: 0 },
        { r: 255, g: 200, b: 0 },
        { r: 255, g: 50, b: 0 }
      ]
    },
    
    magic: {
      count: 15,
      life: 20,
      spread: 30,
      colors: [
        { r: 150, g: 150, b: 255 },
        { r: 200, g: 200, b: 255 }
      ]
    },
    
    death: {
      count: 10,
      life: 25,
      spread: 40,
      colors: [
        { r: 200, g: 0, b: 0 },
        { r: 150, g: 0, b: 0 }
      ]
    }
  }
  
  # ==================== Helper Methods ====================
  
  # Get enemy definition by type
  def self.enemy(type)
    ENEMY_TYPES[type]
  end
  
  # Get tower definition by type
  def self.tower(type)
    TOWER_TYPES[type]
  end
  
  # Get projectile visual by type
  def self.projectile(type)
    PROJECTILE_VISUALS[type]
  end
  
  # Get wave definition by wave number
  def self.wave(wave_num)
    if wave_num <= WAVE_DEFINITIONS.length
      WAVE_DEFINITIONS[wave_num - 1]
    else
      # Generate procedural wave
      generate_procedural_wave(wave_num)
    end
  end
  
  # Generate increasingly difficult waves after predefined ones
  def self.generate_procedural_wave(wave_num)
    difficulty = (wave_num - WAVE_DEFINITIONS.length) * WAVE_SCALE_FACTOR
    
    {
      enemies: [
        { type: :basic, count: (10 * difficulty).to_i, spawn_interval: 30 },
        { type: :fast, count: (5 * difficulty).to_i, spawn_interval: 40 },
        { type: :tank, count: (2 * difficulty).to_i, spawn_interval: 80 },
        { type: :flying, count: (4 * difficulty).to_i, spawn_interval: 50 },
        { type: :boss, count: (difficulty / 2).to_i, spawn_interval: 200 }
      ]
    }
  end
end