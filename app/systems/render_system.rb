# frozen_string_literal: true

# RenderSystem handles all game rendering with isometric projection
class RenderSystem
  def render_game(args, game, camera)
    # Clear outputs
    args.outputs.sprites.clear
    args.outputs.primitives.clear
    
    # Render in correct z-order for isometric view
    render_tiles(args, camera)
    render_path(args, camera)
    
    # Collect all entities for depth sorting
    entities = []
    entities.concat(prepare_tower_sprites(game[:towers], camera))
    entities.concat(prepare_enemy_sprites(game[:enemies], camera))
    entities.concat(prepare_projectile_sprites(game[:projectiles], camera))
    
    # Sort by y position (bottom to top) for proper isometric depth
    entities.sort_by! { |e| -e[:y] }
    
    # Render sorted entities
    args.outputs.sprites << entities
    
    # Render particles (always on top)
    render_particles(args, game[:particles], camera)
    
    # Render tower ranges if tower is selected
    if game[:selected_tower]
      render_tower_range(args, game[:selected_tower], camera)
    end
    
    # Render build preview if tower type is selected
    if game[:selected_tower_type] && game[:hovered_tile]
      render_build_preview(args, game, camera)
    end
    
    # Render UI (always on top, no camera offset)
    render_ui(args, game)
    
    # Render debug overlay if enabled
    render_debug(args, game, camera) if args.state.debug_mode
  end
  
  private
  
  # ==================== Tile Rendering ====================
  
  def render_tiles(args, camera)
    Constants::MAP_HEIGHT.times do |ty|
      Constants::MAP_WIDTH.times do |tx|
        pos = tile_to_screen(tx, ty)
        
        # Apply camera offset
        screen_x = pos[:x] - camera[:x]
        screen_y = pos[:y] - camera[:y]
        
        # Determine tile color
        color = get_tile_color(tx, ty)
        
        # Render isometric tile (diamond shape)
        render_isometric_tile(args, screen_x, screen_y, color)
      end
    end
  end
  
  def render_isometric_tile(args, x, y, color)
    # Draw diamond shape for isometric tile
    half_w = Constants::TILE_WIDTH / 2
    half_h = Constants::TILE_HEIGHT / 2
    
    # Diamond points
    top = { x: x, y: y + half_h }
    right = { x: x + half_w, y: y }
    bottom = { x: x, y: y - half_h }
    left = { x: x - half_w, y: y }
    
    # Fill diamond
    args.outputs.primitives << {
      x: x - half_w,
      y: y - half_h,
      x2: x,
      y2: y,
      x3: x + half_w,
      y3: y - half_h,
      r: color[:r],
      g: color[:g],
      b: color[:b],
      a: 255
    }.solid!
    
    args.outputs.primitives << {
      x: x - half_w,
      y: y - half_h,
      x2: x,
      y2: y - half_h * 2,
      x3: x + half_w,
      y3: y - half_h,
      r: color[:r] - 20,
      g: color[:g] - 20,
      b: color[:b] - 20,
      a: 255
    }.solid!
    
    # Outline
    args.outputs.lines << [
      left[:x], left[:y], top[:x], top[:y], 0, 0, 0, 100
    ]
    args.outputs.lines << [
      top[:x], top[:y], right[:x], right[:y], 0, 0, 0, 100
    ]
    args.outputs.lines << [
      right[:x], right[:y], bottom[:x], bottom[:y], 0, 0, 0, 100
    ]
    args.outputs.lines << [
      bottom[:x], bottom[:y], left[:x], left[:y], 0, 0, 0, 100
    ]
  end
  
  def get_tile_color(tx, ty)
    # Check if on path
    Constants::ENEMY_PATH.each do |path_tile|
      if (path_tile[0] - tx).abs <= 0 && (path_tile[1] - ty).abs <= 0
        return Constants::TILE_TYPES[:path]
      end
    end
    
    # Check if buildable
    if Constants.tile_buildable?(tx, ty)
      return Constants::TILE_TYPES[:buildable]
    else
      return Constants::TILE_TYPES[:blocked]
    end
  end
  
  def render_path(args, camera)
    # Render path waypoints for debugging
    return unless args.state.debug_mode
    
    Constants::ENEMY_PATH.each_with_index do |tile, idx|
      pos = tile_to_screen(tile[0], tile[1])
      screen_x = pos[:x] - camera[:x]
      screen_y = pos[:y] - camera[:y]
      
      args.outputs.labels << {
        x: screen_x,
        y: screen_y + 5,
        text: idx.to_s,
        size_enum: 2,
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 0
      }
    end
  end
  
  # ==================== Entity Sprite Preparation ====================
  
  def prepare_tower_sprites(towers, camera)
    towers.map do |tower|
      size = 40
      
      # If sprite path exists, use it
      if tower[:sprite_path]
        {
          x: tower[:x] - camera[:x] - size / 2,
          y: tower[:y] - camera[:y] - size / 2,
          w: size,
          h: size,
          path: tower[:sprite_path],
          angle: tower[:angle] || 0  # Optional rotation for targeting
        }
      else
        # Fall back to colored rectangle
        {
          x: tower[:x] - camera[:x] - size / 2,
          y: tower[:y] - camera[:y] - size / 2,
          w: size,
          h: size,
          r: tower[:color][:r],
          g: tower[:color][:g],
          b: tower[:color][:b],
          a: 255,
          primitive_marker: :solid
        }
      end
    end
  end
  
  def prepare_enemy_sprites(enemies, camera)
    enemies.map do |enemy|
      size = enemy[:size]
      
      # If sprite path exists, use it
      if enemy[:sprite_path]
        {
          x: enemy[:x] - camera[:x] - size / 2,
          y: enemy[:y] - camera[:y] - size / 2,
          w: size,
          h: size,
          path: enemy[:sprite_path],
          angle: enemy[:angle] || 0,  # Optional rotation
          flip_horizontally: enemy[:flip_h] || false,
          flip_vertically: enemy[:flip_v] || false
        }
      else
        # Fall back to colored rectangle
        {
          x: enemy[:x] - camera[:x] - size / 2,
          y: enemy[:y] - camera[:y] - size / 2,
          w: size,
          h: size,
          r: enemy[:color][:r],
          g: enemy[:color][:g],
          b: enemy[:color][:b],
          a: 255,
          primitive_marker: :solid
        }
      end
    end
  end
  
  def prepare_projectile_sprites(projectiles, camera)
    projectiles.map do |proj|
      visual = Constants.projectile(proj[:type])
      size = visual[:size]
      
      # If sprite path exists, use it
      if visual[:sprite_path]
        {
          x: proj[:x] - camera[:x] - size / 2,
          y: proj[:y] - camera[:y] - size / 2,
          w: size,
          h: size,
          path: visual[:sprite_path],
          angle: proj[:angle] || calculate_projectile_angle(proj),
          a: visual[:alpha] || 255
        }
      else
        # Fall back to colored rectangle
        {
          x: proj[:x] - camera[:x] - size / 2,
          y: proj[:y] - camera[:y] - size / 2,
          w: size,
          h: size,
          r: visual[:color][:r],
          g: visual[:color][:g],
          b: visual[:color][:b],
          a: visual[:alpha] || 255,
          primitive_marker: :solid
        }
      end
    end
  end
  
  # Calculate angle for projectile to point toward target
  def calculate_projectile_angle(proj)
    return 0 unless proj[:target_x] && proj[:target_y]
    
    dx = proj[:target_x] - proj[:x]
    dy = proj[:target_y] - proj[:y]
    
    # Convert to degrees, DragonRuby uses 0 = right, 90 = up
    Math.atan2(dy, dx) * 180 / Math::PI
  end
  
  def render_particles(args, particles, camera)
    particles.each do |particle|
      size = 4
      args.outputs.primitives << {
        x: particle[:x] - camera[:x] - size / 2,
        y: particle[:y] - camera[:y] - size / 2,
        w: size,
        h: size,
        r: particle[:r],
        g: particle[:g],
        b: particle[:b],
        a: particle[:alpha] || 255
      }.solid!
    end
  end
  
  def render_particles(args, particles, camera)
    particles.each do |particle|
      size = 4
      args.outputs.primitives << {
        x: particle[:x] - camera[:x] - size / 2,
        y: particle[:y] - camera[:y] - size / 2,
        w: size,
        h: size,
        r: particle[:r],
        g: particle[:g],
        b: particle[:b],
        a: particle[:alpha] || 255
      }.solid!
    end
  end
  
  # ==================== UI Rendering ====================
  
  def render_ui(args, game)
    # Top bar background
    args.outputs.primitives << {
      x: 0,
      y: 660,
      w: 1280,
      h: 60,
      r: 40,
      g: 40,
      b: 50,
      a: 255
    }.solid!
    
    # Gold
    args.outputs.labels << {
      x: 20,
      y: 700,
      text: "💰 Gold: #{game[:gold]}",
      size_enum: 5,
      r: 255,
      g: 215,
      b: 0
    }
    
    # Lives
    args.outputs.labels << {
      x: 200,
      y: 700,
      text: "❤️  Lives: #{game[:lives]}",
      size_enum: 5,
      r: 255,
      g: 100,
      b: 100
    }
    
    # Score
    args.outputs.labels << {
      x: 380,
      y: 700,
      text: "⭐ Score: #{game[:score]}",
      size_enum: 5,
      r: 255,
      g: 255,
      b: 100
    }
    
    # Wave info
    wave_text = game[:wave_active] ? "Wave #{game[:wave]} - IN PROGRESS" : "Wave #{game[:wave]} - Press SPACE"
    args.outputs.labels << {
      x: 640,
      y: 700,
      text: wave_text,
      size_enum: 5,
      alignment_enum: 1,
      r: 200,
      g: 200,
      b: 255
    }
    
    # Tower selection panel (right side)
    render_tower_panel(args, game)
  end
  
  def render_tower_panel(args, game)
    panel_x = 1000
    panel_y = 0
    panel_w = 280
    panel_h = 650
    
    # Panel background
    args.outputs.primitives << {
      x: panel_x,
      y: panel_y,
      w: panel_w,
      h: panel_h,
      r: 40,
      g: 40,
      b: 50,
      a: 255
    }.solid!
    
    # Title
    args.outputs.labels << {
      x: panel_x + 140,
      y: panel_y + panel_h - 20,
      text: "TOWERS",
      size_enum: 6,
      alignment_enum: 1,
      r: 255,
      g: 255,
      b: 255
    }
    
    # Tower buttons
    y_offset = panel_h - 80
    [:archer, :cannon, :mage, :sniper].each_with_index do |tower_type, idx|
      render_tower_button(args, game, tower_type, panel_x + 20, panel_y + y_offset - (idx * 120))
    end
    
    # Instructions
    args.outputs.labels << {
      x: panel_x + 140,
      y: 60,
      text: "Click to build",
      size_enum: 3,
      alignment_enum: 1,
      r: 150,
      g: 150,
      b: 150
    }
    
    args.outputs.labels << {
      x: panel_x + 140,
      y: 35,
      text: "1-4: Quick select",
      size_enum: 3,
      alignment_enum: 1,
      r: 150,
      g: 150,
      b: 150
    }
  end
  
  def render_tower_button(args, game, tower_type, x, y)
    tower_def = Constants.tower(tower_type)
    button_w = 240
    button_h = 100
    
    # Check if selected or affordable
    selected = game[:selected_tower_type] == tower_type
    affordable = game[:gold] >= tower_def[:cost]
    
    # Button background
    if selected
      color = Constants::UI_COLORS[:button_hover]
    elsif !affordable
      color = Constants::UI_COLORS[:button_disabled]
    else
      color = Constants::UI_COLORS[:button]
    end
    
    args.outputs.primitives << {
      x: x,
      y: y,
      w: button_w,
      h: button_h,
      r: color[:r],
      g: color[:g],
      b: color[:b],
      a: 255
    }.solid!
    
    # Border
    border_color = selected ? { r: 255, g: 255, b: 100 } : { r: 100, g: 100, b: 100 }
    args.outputs.borders << {
      x: x,
      y: y,
      w: button_w,
      h: button_h,
      r: border_color[:r],
      g: border_color[:g],
      b: border_color[:b]
    }
    
    # Tower name
    text_color = affordable ? { r: 255, g: 255, b: 255 } : { r: 100, g: 100, b: 100 }
    args.outputs.labels << {
      x: x + 10,
      y: y + button_h - 10,
      text: tower_def[:name],
      size_enum: 4,
      r: text_color[:r],
      g: text_color[:g],
      b: text_color[:b]
    }
    
    # Cost
    args.outputs.labels << {
      x: x + 10,
      y: y + button_h - 35,
      text: "Cost: #{tower_def[:cost]}",
      size_enum: 3,
      r: 255,
      g: 215,
      b: 0
    }
    
    # Stats
    args.outputs.labels << {
      x: x + 10,
      y: y + 35,
      text: "Damage: #{tower_def[:damage]}",
      size_enum: 2,
      r: 200,
      g: 200,
      b: 200
    }
    
    args.outputs.labels << {
      x: x + 10,
      y: y + 15,
      text: "Range: #{tower_def[:range]} | Rate: #{tower_def[:fire_rate]}/s",
      size_enum: 2,
      r: 200,
      g: 200,
      b: 200
    }
  end
  
  # ==================== Helper Rendering ====================
  
  def render_tower_range(args, tower, camera)
    range_pixels = tower[:range] * Constants::TILE_WIDTH
    screen_x = tower[:x] - camera[:x]
    screen_y = tower[:y] - camera[:y]
    
    # Draw range circle (approximated with lines)
    segments = 32
    (0...segments).each do |i|
      angle1 = (i * Math::PI * 2 / segments)
      angle2 = ((i + 1) * Math::PI * 2 / segments)
      
      x1 = screen_x + Math.cos(angle1) * range_pixels
      y1 = screen_y + Math.sin(angle1) * range_pixels
      x2 = screen_x + Math.cos(angle2) * range_pixels
      y2 = screen_y + Math.sin(angle2) * range_pixels
      
      args.outputs.lines << [x1, y1, x2, y2, 255, 255, 255, 100]
    end
  end
  
  def render_build_preview(args, game, camera)
    tile_x = game[:hovered_tile][:x]
    tile_y = game[:hovered_tile][:y]
    
    return unless tile_x >= 0 && tile_x < Constants::MAP_WIDTH
    return unless tile_y >= 0 && tile_y < Constants::MAP_HEIGHT
    
    pos = tile_to_screen(tile_x, tile_y)
    screen_x = pos[:x] - camera[:x]
    screen_y = pos[:y] - camera[:y]
    
    tower_def = Constants.tower(game[:selected_tower_type])
    can_build = Constants.tile_buildable?(tile_x, tile_y) && 
                !game.tower_at_tile(tile_x, tile_y) &&
                game.can_afford?(tower_def[:cost])
    
    # Preview color (green if can build, red if can't)
    color = can_build ? { r: 100, g: 255, b: 100 } : { r: 255, g: 100, b: 100 }
    
    # Draw preview
    size = 40
    args.outputs.primitives << {
      x: screen_x - size / 2,
      y: screen_y - size / 2,
      w: size,
      h: size,
      r: color[:r],
      g: color[:g],
      b: color[:b],
      a: 128
    }.solid!
    
    # Range preview
    range_pixels = tower_def[:range] * Constants::TILE_WIDTH
    segments = 24
    (0...segments).each do |i|
      angle1 = (i * Math::PI * 2 / segments)
      angle2 = ((i + 1) * Math::PI * 2 / segments)
      
      x1 = screen_x + Math.cos(angle1) * range_pixels
      y1 = screen_y + Math.sin(angle1) * range_pixels
      x2 = screen_x + Math.cos(angle2) * range_pixels
      y2 = screen_y + Math.sin(angle2) * range_pixels
      
      args.outputs.lines << [x1, y1, x2, y2, color[:r], color[:g], color[:b], 100]
    end
  end
  
  def render_debug(args, game, camera)
    y = 710
    args.outputs.labels << [10, y -= 20, "FPS: #{args.gtk.current_framerate.to_i}", 0, 0, 255, 255, 0]
    args.outputs.labels << [10, y -= 20, "Enemies: #{game[:enemies].length}", 0, 0, 255, 255, 0]
    args.outputs.labels << [10, y -= 20, "Towers: #{game[:towers].length}", 0, 0, 255, 255, 0]
    args.outputs.labels << [10, y -= 20, "Projectiles: #{game[:projectiles].length}", 0, 0, 255, 255, 0]
    args.outputs.labels << [10, y -= 20, "Particles: #{game[:particles].length}", 0, 0, 255, 255, 0]
    
    if game[:hovered_tile]
      args.outputs.labels << [10, y -= 20, "Tile: (#{game[:hovered_tile][:x]}, #{game[:hovered_tile][:y]})", 0, 0, 255, 255, 0]
    end
  end
  
  # ==================== Coordinate Conversion ====================
  
  def tile_to_screen(tile_x, tile_y)
    iso_x = (tile_x - tile_y) * (Constants::TILE_WIDTH / 2)
    iso_y = (tile_x + tile_y) * (Constants::TILE_HEIGHT / 2)
    
    screen_x = iso_x + (Constants::MAP_WIDTH * Constants::TILE_WIDTH / 2)
    screen_y = iso_y
    
    { x: screen_x, y: screen_y }
  end
end
