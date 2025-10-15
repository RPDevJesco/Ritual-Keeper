# frozen_string_literal: true

# Main entry point for Isometric Tower Defense
# DragonRuby GTK will call this tick method 60 times per second

require 'app/lib/event_chains.rb'
require 'app/constants.rb'
require 'app/game_state.rb'
require 'app/systems/input_system.rb'
require 'app/systems/render_system.rb'
require 'app/systems/game_system.rb'
require 'app/events/input_events.rb'
require 'app/events/enemy_events.rb'
require 'app/events/tower_events.rb'
require 'app/events/projectile_events.rb'
require 'app/events/render_events.rb'

def tick(args)
  # Initialize game state on first tick
  if args.state.tick_count == 0
    initialize_game(args)
  end

  # Execute game loop chain every tick
  execute_game_loop(args)
end

def initialize_game(args)
  puts "🎮 Initializing Isometric Tower Defense..."
  
  # Set up game state
  args.state.game ||= GameState.new
  
  # Initialize systems
  args.state.input_system ||= InputSystem.new
  args.state.render_system ||= RenderSystem.new
  args.state.game_system ||= GameSystem.new
  
  # Set initial camera position (centered on map)
  map_center_x = (Constants::MAP_WIDTH * Constants::TILE_WIDTH) / 2
  map_center_y = (Constants::MAP_HEIGHT * Constants::TILE_HEIGHT) / 2
  
  args.state.camera = {
    x: map_center_x - 640,  # Center on screen (1280/2)
    y: map_center_y - 360,  # Center on screen (720/2)
    zoom: 1.0
  }
  
  # Set game state to main menu
  args.state.scene = :menu
  
  puts "✓ Game initialized successfully!"
end

def execute_game_loop(args)
  # Build and execute the game loop chain based on current scene
  case args.state.scene
  when :menu
    execute_menu_loop(args)
  when :playing
    execute_gameplay_loop(args)
  when :paused
    execute_pause_loop(args)
  when :game_over
    execute_game_over_loop(args)
  end
end

def execute_menu_loop(args)
  # Simple menu chain
  chain = EventChain.strict
  
  chain
    .add_event(ProcessMenuInputEvent.new)
    .add_event(RenderMenuEvent.new)
  
  args.state.game[:chain_context] = {}
  chain.context[:args] = args
  chain.context[:game] = args.state.game
  
  chain.execute
end

def execute_gameplay_loop(args)
  # Main gameplay event chain with timing middleware
  metrics = Middleware::Metrics.new if $DEBUG
  
  chain = EventChain.lenient
  
  # Add performance monitoring in debug mode
  if $DEBUG
    chain.use_middleware { metrics.call(_1) }
    chain.use_middleware { Middleware::Timing.new(threshold_ms: 16).call(_1) } # 60fps = 16.67ms
  end
  
  # Core gameplay event chain
  chain
    .add_event(ProcessInputEvent.new)
    .add_event(UpdateEnemiesEvent.new)
    .add_event(UpdateTowersEvent.new)
    .add_event(UpdateProjectilesEvent.new)
    .add_event(CheckCollisionsEvent.new)
    .add_event(UpdateWaveSystemEvent.new)
    .add_event(UpdateUIEvent.new)
    .add_event(RenderGameEvent.new)
  
  # Set up context with game state
  chain.context[:args] = args
  chain.context[:game] = args.state.game
  chain.context[:input_system] = args.state.input_system
  chain.context[:render_system] = args.state.render_system
  chain.context[:game_system] = args.state.game_system
  chain.context[:camera] = args.state.camera
  
  result = chain.execute
  
  # Show metrics in debug mode
  if $DEBUG && args.state.tick_count % 60 == 0
    metrics&.report
  end
  
  # Handle chain failures
  unless result.success?
    puts "⚠️ Gameplay chain had failures:"
    result.failures.each do |failure|
      puts "  - #{failure.event_name}: #{failure.error_message}"
    end
  end
end

def execute_pause_loop(args)
  chain = EventChain.strict
  
  chain
    .add_event(ProcessPauseInputEvent.new)
    .add_event(RenderPausedGameEvent.new)
  
  chain.context[:args] = args
  chain.context[:game] = args.state.game
  
  chain.execute
end

def execute_game_over_loop(args)
  chain = EventChain.strict
  
  chain
    .add_event(ProcessGameOverInputEvent.new)
    .add_event(RenderGameOverEvent.new)
  
  chain.context[:args] = args
  chain.context[:game] = args.state.game
  
  chain.execute
end

# ==================== Menu Scene Events ====================

class ProcessMenuInputEvent
  include ChainableEvent
  
  def execute(context)
    args = context[:args]
    
    # Start game on ENTER or SPACE
    if args.inputs.keyboard.key_down.enter || args.inputs.keyboard.key_down.space
      args.state.scene = :playing
      context[:game].start_new_game
      puts "🎮 Starting new game!"
    end
    
    success(context)
  end
end

class RenderMenuEvent
  include ChainableEvent
  
  def execute(context)
    args = context[:args]
    
    # Clear outputs
    args.outputs.sprites.clear
    
    # Render title
    args.outputs.labels << {
      x: 640,
      y: 500,
      text: "ISOMETRIC TOWER DEFENSE",
      size_enum: 20,
      alignment_enum: 1,
      r: 255,
      g: 255,
      b: 255
    }
    
    # Render subtitle
    args.outputs.labels << {
      x: 640,
      y: 400,
      text: "Press ENTER or SPACE to Start",
      size_enum: 10,
      alignment_enum: 1,
      r: 200,
      g: 200,
      b: 200
    }
    
    # Render controls
    controls = [
      "Controls:",
      "WASD - Move Camera",
      "Mouse - Select & Build Towers",
      "ESC - Pause Game",
      "1-3 - Quick Select Tower Type"
    ]
    
    y_pos = 250
    controls.each do |text|
      args.outputs.labels << {
        x: 640,
        y: y_pos,
        text: text,
        size_enum: 5,
        alignment_enum: 1,
        r: 150,
        g: 150,
        b: 150
      }
      y_pos -= 30
    end
    
    success(context)
  end
end

# ==================== Pause Scene Events ====================

class ProcessPauseInputEvent
  include ChainableEvent
  
  def execute(context)
    args = context[:args]
    
    # Resume on ESC
    if args.inputs.keyboard.key_down.escape
      args.state.scene = :playing
    end
    
    # Return to menu on Q
    if args.inputs.keyboard.key_down.q
      args.state.scene = :menu
    end
    
    success(context)
  end
end

class RenderPausedGameEvent
  include ChainableEvent
  
  def execute(context)
    args = context[:args]
    render_system = context[:render_system]
    
    # Render the game in background (frozen state)
    render_system.render_game(args, context[:game], context[:camera])
    
    # Render pause overlay
    args.outputs.primitives << {
      x: 0,
      y: 0,
      w: 1280,
      h: 720,
      r: 0,
      g: 0,
      b: 0,
      a: 180
    }.solid!
    
    args.outputs.labels << {
      x: 640,
      y: 400,
      text: "PAUSED",
      size_enum: 20,
      alignment_enum: 1,
      r: 255,
      g: 255,
      b: 255
    }
    
    args.outputs.labels << {
      x: 640,
      y: 300,
      text: "ESC - Resume | Q - Quit to Menu",
      size_enum: 8,
      alignment_enum: 1,
      r: 200,
      g: 200,
      b: 200
    }
    
    success(context)
  end
end

# ==================== Game Over Scene Events ====================

class ProcessGameOverInputEvent
  include ChainableEvent
  
  def execute(context)
    args = context[:args]
    
    # Return to menu on any key
    if args.inputs.keyboard.key_down.truthy_keys.any?
      args.state.scene = :menu
    end
    
    success(context)
  end
end

class RenderGameOverEvent
  include ChainableEvent
  
  def execute(context)
    args = context[:args]
    game = context[:game]
    
    # Render game over screen
    args.outputs.primitives << {
      x: 0,
      y: 0,
      w: 1280,
      h: 720,
      r: 0,
      g: 0,
      b: 0,
      a: 200
    }.solid!
    
    args.outputs.labels << {
      x: 640,
      y: 500,
      text: "GAME OVER",
      size_enum: 25,
      alignment_enum: 1,
      r: 255,
      g: 100,
      b: 100
    }
    
    args.outputs.labels << {
      x: 640,
      y: 400,
      text: "Wave: #{game[:wave]} | Score: #{game[:score]}",
      size_enum: 12,
      alignment_enum: 1,
      r: 255,
      g: 255,
      b: 255
    }
    
    args.outputs.labels << {
      x: 640,
      y: 300,
      text: "Press any key to return to menu",
      size_enum: 8,
      alignment_enum: 1,
      r: 200,
      g: 200,
      b: 200
    }
    
    success(context)
  end
end

# Debug overlay (toggle with F1)
def render_debug_overlay(args)
  return unless args.state.debug_mode
  
  args.outputs.labels << [10, 710, "FPS: #{args.gtk.current_framerate.to_i}", 0, 0, 255, 255, 255]
  args.outputs.labels << [10, 690, "Tick: #{args.state.tick_count}", 0, 0, 255, 255, 255]
  
  game = args.state.game
  args.outputs.labels << [10, 670, "Enemies: #{game[:enemies]&.length || 0}", 0, 0, 255, 255, 255]
  args.outputs.labels << [10, 650, "Towers: #{game[:towers]&.length || 0}", 0, 0, 255, 255, 255]
  args.outputs.labels << [10, 630, "Projectiles: #{game[:projectiles]&.length || 0}", 0, 0, 255, 255, 255]
end

# Toggle debug mode with F1
def check_debug_toggle(args)
  if args.inputs.keyboard.key_down.f1
    args.state.debug_mode = !args.state.debug_mode
  end
end
