# ===================================================================
# RITUAL KEEPER - Main Entry Point
# ===================================================================
# A mystical puzzle game showcasing the EventChains design pattern
# Created with DragonRuby Game Toolkit
# ===================================================================

require 'app/event_chains.rb'
require 'app/constants.rb'
require 'app/primitives_helper.rb'
require 'app/particle_system.rb'
require 'app/ritual_events.rb'
require 'app/ritual_definitions.rb'
require 'app/game_state.rb'
require 'app/input_handler.rb'
require 'app/renderer.rb'

# ===================================================================
# MAIN TICK - The DragonRuby Game Loop
# ===================================================================
def tick(args)
  # Initialize game state on first tick
  if args.state.tick_count == 0
    initialize_game(args)
  end
  
  # Update game systems
  update_game(args)
  
  # Render everything
  render_game(args)
end

# ===================================================================
# INITIALIZATION
# ===================================================================
def initialize_game(args)
  puts "🕯️  Initializing Ritual Keeper..."
  
  # Create game state manager
  args.state.game ||= GameState.new(args)
  
  # Initialize scene
  args.state.game.current_scene = :menu
  
  # Initialize particle system
  args.state.particles ||= []
  
  puts "✓ Ritual Keeper initialized successfully!"
end

# ===================================================================
# UPDATE LOOP
# ===================================================================
def update_game(args)
  case args.state.game.current_scene
  when :menu
    update_menu(args)
  when :ritual_select
    update_ritual_select(args)
  when :gameplay
    update_gameplay(args)
  when :results
    update_results(args)
  end
  
  # Update particles every frame
  update_particles(args)
end

# ===================================================================
# MENU SCENE
# ===================================================================
def update_menu(args)
  # Check for start input
  if args.inputs.keyboard.key_down.space ||
     args.inputs.keyboard.key_down.enter ||
     args.inputs.controller_one.key_down.a
    args.state.game.transition_to(:ritual_select)
  end
end

# ===================================================================
# RITUAL SELECT SCENE
# ===================================================================
def update_ritual_select(args)
  game = args.state.game
  
  # Navigate rituals with arrow keys
  if args.inputs.keyboard.key_down.down
    game.selected_ritual_index = (game.selected_ritual_index + 1) % game.available_rituals.length
  elsif args.inputs.keyboard.key_down.up
    game.selected_ritual_index = (game.selected_ritual_index - 1) % game.available_rituals.length
  end
  
  # Select ritual
  if args.inputs.keyboard.key_down.space ||
     args.inputs.keyboard.key_down.enter ||
     args.inputs.controller_one.key_down.a
    game.start_ritual(game.available_rituals[game.selected_ritual_index])
  end
  
  # Back to menu
  if args.inputs.keyboard.key_down.escape
    game.transition_to(:menu)
  end
end

# ===================================================================
# GAMEPLAY SCENE
# ===================================================================
def update_gameplay(args)
  game = args.state.game
  ritual = game.current_ritual
  
  return unless ritual
  
  # Update ritual state
  ritual.update(args)
  
  # Check for completion or failure
  if ritual.completed?
    game.complete_ritual
  elsif ritual.failed?
    game.fail_ritual
  end
  
  # Back to ritual select
  if args.inputs.keyboard.key_down.escape
    game.transition_to(:ritual_select)
  end
end

# ===================================================================
# RESULTS SCENE
# ===================================================================
def update_results(args)
  game = args.state.game
  
  # Continue to ritual select
  if args.inputs.keyboard.key_down.space ||
     args.inputs.keyboard.key_down.enter ||
     args.inputs.controller_one.key_down.a
    game.transition_to(:ritual_select)
  end
end

# ===================================================================
# PARTICLE SYSTEM UPDATE
# ===================================================================
def update_particles(args)
  args.state.particles.each(&:update)
  args.state.particles.reject! { |p| p.dead? }
end

# ===================================================================
# RENDER DISPATCH
# ===================================================================
def render_game(args)
  # Always render background
  render_background(args)
  
  # Render current scene
  case args.state.game.current_scene
  when :menu
    render_menu(args)
  when :ritual_select
    render_ritual_select(args)
  when :gameplay
    render_gameplay(args)
  when :results
    render_results(args)
  end
  
  # Always render particles on top
  render_particles(args)
  
  # Debug info (only in development)
  render_debug(args) if $gtk.args.state.debug_mode
end

puts "🕯️  Ritual Keeper loaded. Ready to begin..."
