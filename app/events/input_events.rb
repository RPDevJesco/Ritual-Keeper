# frozen_string_literal: true

# ==================== Gameplay Input Events ====================

class ProcessInputEvent
  include ChainableEvent
  
  def execute(context)
    args = context[:args]
    game = context[:game]
    camera = context[:camera]
    
    # Pause game
    if args.inputs.keyboard.key_down.escape
      args.state.scene = :paused
      return success(context)
    end
    
    # Toggle debug mode
    if args.inputs.keyboard.key_down.f1
      args.state.debug_mode = !args.state.debug_mode
    end
    
    # Camera movement with WASD
    camera[:x] -= Constants::CAMERA_SPEED if args.inputs.keyboard.w
    camera[:x] += Constants::CAMERA_SPEED if args.inputs.keyboard.s
    camera[:y] += Constants::CAMERA_SPEED if args.inputs.keyboard.a
    camera[:y] -= Constants::CAMERA_SPEED if args.inputs.keyboard.d
    
    # Quick select tower types with number keys
    if args.inputs.keyboard.key_down.one
      game[:selected_tower_type] = :archer
    elsif args.inputs.keyboard.key_down.two
      game[:selected_tower_type] = :cannon
    elsif args.inputs.keyboard.key_down.three
      game[:selected_tower_type] = :mage
    elsif args.inputs.keyboard.key_down.four
      game[:selected_tower_type] = :sniper
    end
    
    # Deselect with right click or ESC
    if args.inputs.mouse.button_right || args.inputs.keyboard.key_down.escape
      game[:selected_tower_type] = nil
      game[:selected_tower] = nil
    end
    
    # Get mouse position in world coordinates
    mouse_x = args.inputs.mouse.x + camera[:x]
    mouse_y = args.inputs.mouse.y + camera[:y]
    
    # Convert mouse position to tile coordinates
    tile_pos = screen_to_tile(mouse_x, mouse_y)
    game[:hovered_tile] = tile_pos
    
    # Handle mouse clicks
    if args.inputs.mouse.button_left && args.inputs.mouse.click
      handle_tile_click(game, tile_pos)
    end
    
    # Start wave with SPACE
    if args.inputs.keyboard.key_down.space && !game[:wave_active]
      game.start_wave
    end
    
    success(context)
  end
  
  private
  
  def screen_to_tile(screen_x, screen_y)
    # Convert isometric screen coordinates to tile coordinates
    # This is the inverse of the tile_to_screen calculation
    
    # Offset to isometric origin
    iso_x = screen_x - (Constants::MAP_WIDTH * Constants::TILE_WIDTH / 2)
    iso_y = screen_y
    
    # Isometric to tile conversion
    tile_x = ((iso_x / Constants::TILE_WIDTH) + (iso_y / Constants::TILE_HEIGHT)).floor
    tile_y = ((iso_y / Constants::TILE_HEIGHT) - (iso_x / Constants::TILE_WIDTH)).floor
    
    { x: tile_x, y: tile_y }
  end
  
  def handle_tile_click(game, tile_pos)
    tile_x = tile_pos[:x]
    tile_y = tile_pos[:y]
    
    # Check if tile is valid
    return unless tile_x >= 0 && tile_x < Constants::MAP_WIDTH
    return unless tile_y >= 0 && tile_y < Constants::MAP_HEIGHT
    
    # If a tower is selected for building
    if game[:selected_tower_type]
      try_build_tower(game, tile_x, tile_y)
    else
      # Try to select existing tower
      tower = game.tower_at_tile(tile_x, tile_y)
      game[:selected_tower] = tower if tower
    end
  end
  
  def try_build_tower(game, tile_x, tile_y)
    tower_type = game[:selected_tower_type]
    tower_def = Constants.tower(tower_type)
    
    # Check if tile is buildable
    unless Constants.tile_buildable?(tile_x, tile_y)
      puts "❌ Cannot build here - tile not buildable"
      return
    end
    
    # Check if there's already a tower here
    if game.tower_at_tile(tile_x, tile_y)
      puts "❌ Cannot build here - tile occupied"
      return
    end
    
    # Check if player can afford it
    unless game.can_afford?(tower_def[:cost])
      puts "❌ Not enough gold! Need #{tower_def[:cost]}, have #{game[:gold]}"
      return
    end
    
    # Build the tower!
    game.spend_gold(tower_def[:cost])
    
    # Get screen position for this tile
    screen_pos = tile_to_screen(tile_x, tile_y)
    
    tower = {
      type: tower_type,
      tile_x: tile_x,
      tile_y: tile_y,
      x: screen_pos[:x],
      y: screen_pos[:y],
      target: nil,
      cooldown: 0,
      level: 1
    }.merge(tower_def)
    
    game.add_tower(tower)
    puts "✅ Built #{tower_def[:name]} at (#{tile_x}, #{tile_y}) for #{tower_def[:cost]} gold"
    
    # Keep tower type selected for quick building
    # Uncomment the line below if you want to deselect after building
    # game[:selected_tower_type] = nil
  end
  
  def tile_to_screen(tile_x, tile_y)
    # Convert tile coordinates to isometric screen coordinates
    iso_x = (tile_x - tile_y) * (Constants::TILE_WIDTH / 2)
    iso_y = (tile_x + tile_y) * (Constants::TILE_HEIGHT / 2)
    
    # Offset to center the map
    screen_x = iso_x + (Constants::MAP_WIDTH * Constants::TILE_WIDTH / 2)
    screen_y = iso_y
    
    { x: screen_x, y: screen_y }
  end
end

class UpdateUIEvent
  include ChainableEvent
  
  def execute(context)
    game = context[:game]
    
    # Update any UI animations or transitions here
    # For now, just validate that UI data is present
    
    context[:ui_data] = {
      gold: game[:gold],
      lives: game[:lives],
      score: game[:score],
      wave: game[:wave],
      wave_active: game[:wave_active],
      selected_tower_type: game[:selected_tower_type],
      selected_tower: game[:selected_tower],
      hovered_tile: game[:hovered_tile]
    }
    
    success(context)
  end
end
