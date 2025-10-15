# ===================================================================
# RITUAL KEEPER - Constants & Configuration
# ===================================================================

module Constants
  # ==================== Screen ====================
  SCREEN_W = 1280
  SCREEN_H = 720
  CENTER_X = SCREEN_W / 2
  CENTER_Y = SCREEN_H / 2
  
  # ==================== Colors ====================
  COLORS = {
    # UI Colors
    background: { r: 20, g: 15, b: 30 },
    ui_primary: { r: 150, g: 100, b: 200 },
    ui_secondary: { r: 100, g: 80, b: 150 },
    ui_highlight: { r: 255, g: 200, b: 100 },
    ui_error: { r: 255, g: 50, b: 50 },
    ui_success: { r: 100, g: 255, b: 100 },
    text_primary: { r: 240, g: 240, b: 255 },
    text_secondary: { r: 180, g: 180, b: 200 },
    text_dim: { r: 120, g: 120, b: 140 },
    
    # Element Colors
    fire: { r: 255, g: 100, b: 0 },
    water: { r: 100, g: 150, b: 255 },
    earth: { r: 139, g: 90, b: 43 },
    air: { r: 200, g: 220, b: 255 },
    moon: { r: 220, g: 220, b: 255 },
    sun: { r: 255, g: 220, b: 50 },
    shadow: { r: 80, g: 50, b: 120 },
    light: { r: 255, g: 255, b: 240 },
    
    # Special Effects
    energy: { r: 200, g: 150, b: 255 },
    ritual_circle: { r: 150, g: 100, b: 200 }
  }
  
  # ==================== Elements ====================
  ELEMENTS = {
    fire: {
      name: "Fire",
      color: COLORS[:fire],
      symbol: "△",
      unlock_level: 1,
      description: "The element of passion and transformation"
    },
    water: {
      name: "Water",
      color: COLORS[:water],
      symbol: "▽",
      unlock_level: 2,
      description: "The element of flow and purification"
    },
    earth: {
      name: "Earth",
      color: COLORS[:earth],
      symbol: "■",
      unlock_level: 3,
      description: "The element of stability and growth"
    },
    air: {
      name: "Air",
      color: COLORS[:air],
      symbol: "○",
      unlock_level: 4,
      description: "The element of thought and breath"
    },
    moon: {
      name: "Moon",
      color: COLORS[:moon],
      symbol: "☽",
      unlock_level: 5,
      description: "The celestial force of mystery"
    },
    sun: {
      name: "Sun",
      color: COLORS[:sun],
      symbol: "☼",
      unlock_level: 7,
      description: "The celestial force of vitality"
    },
    shadow: {
      name: "Shadow",
      color: COLORS[:shadow],
      symbol: "◆",
      unlock_level: 9,
      description: "The hidden element of secrets"
    },
    light: {
      name: "Light",
      color: COLORS[:light],
      symbol: "✦",
      unlock_level: 12,
      description: "The divine element of clarity"
    }
  }
  
  # ==================== Ritual Circle ====================
  RITUAL_CIRCLE = {
    center_x: CENTER_X,
    center_y: CENTER_Y,
    radius: 200,
    node_radius: 100,
    node_size: 60,
    max_nodes: 8
  }
  
  # ==================== Timing ====================
  TIMING = {
    node_activation_time: 45,  # frames (0.75 seconds)
    energy_flow_speed: 0.03,   # per frame
    particle_lifetime: 60,      # frames (1 second)
    ritual_completion_delay: 120, # frames (2 seconds)
    fade_in_time: 30,          # frames
    fade_out_time: 30          # frames
  }
  
  # ==================== Gameplay ====================
  GAMEPLAY = {
    starting_energy: 100,
    starting_focus: 100,
    energy_per_node: 10,
    energy_regen_rate: 0.5,   # per frame
    focus_decay_rate: 0.3,    # per frame when active
    perfect_bonus: 50,
    speed_bonus_threshold: 120 # frames (2 seconds)
  }
  
  # ==================== Particle Settings ====================
  PARTICLES = {
    node_activation: {
      count: 20,
      spread: 30,
      speed_min: 2,
      speed_max: 5,
      lifetime: 60
    },
    energy_flow: {
      count: 5,
      spread: 5,
      speed_min: 1,
      speed_max: 3,
      lifetime: 30
    },
    ritual_complete: {
      count: 100,
      spread: 100,
      speed_min: 3,
      speed_max: 8,
      lifetime: 90
    },
    ritual_fail: {
      count: 50,
      spread: 50,
      speed_min: 2,
      speed_max: 6,
      lifetime: 60
    }
  }
  
  # ==================== Sound Settings ====================
  SOUNDS = {
    enabled: true,
    music_volume: 0.5,
    sfx_volume: 0.7
  }
  
  # ==================== Debug ====================
  DEBUG = {
    show_fps: false,
    show_node_coords: false,
    show_chain_state: false,
    unlock_all_rituals: false
  }
end

# Helper method to get color with optional alpha
def color_with_alpha(color_hash, alpha = 255)
  color_hash.merge(a: alpha)
end

# Helper to lerp between two values
def lerp(a, b, t)
  a + (b - a) * t
end

# Helper to lerp colors
def lerp_color(color_a, color_b, t)
  {
    r: lerp(color_a[:r], color_b[:r], t).to_i,
    g: lerp(color_a[:g], color_b[:g], t).to_i,
    b: lerp(color_a[:b], color_b[:b], t).to_i
  }
end

# Calculate position on circle
def circle_position(center_x, center_y, radius, angle)
  {
    x: center_x + Math.cos(angle) * radius,
    y: center_y + Math.sin(angle) * radius
  }
end

puts "✓ Constants loaded"
