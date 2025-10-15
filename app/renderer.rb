# ===================================================================
# RITUAL KEEPER - Renderer
# ===================================================================

# ===================================================================
# BACKGROUND
# ===================================================================

def render_background(args)
  # Solid background color
  args.outputs.solids << {
    x: 0, y: 0,
    w: Constants::SCREEN_W,
    h: Constants::SCREEN_H,
    r: 20, g: 15, b: 30
  }

  # Subtle grid pattern
  grid_spacing = 40
  grid_color = { r: 30, g: 25, b: 40, a: 100 }

  # Vertical lines
  (0..(Constants::SCREEN_W / grid_spacing)).each do |i|
    x = i * grid_spacing
    args.outputs.lines << {
      x: x, y: 0,
      x2: x, y2: Constants::SCREEN_H,
      **grid_color
    }
  end

  # Horizontal lines
  (0..(Constants::SCREEN_H / grid_spacing)).each do |i|
    y = i * grid_spacing
    args.outputs.lines << {
      x: 0, y: y,
      x2: Constants::SCREEN_W, y2: y,
      **grid_color
    }
  end
end

# ===================================================================
# MENU SCENE
# ===================================================================

def render_menu(args)
  # Title
  args.outputs.labels << {
    x: Constants::CENTER_X,
    y: 600,
    text: "🕯️  RITUAL KEEPER  🕯️",
    size_enum: 15,
    alignment_enum: 1,
    **Constants::COLORS[:text_primary]
  }

  # Subtitle
  args.outputs.labels << {
    x: Constants::CENTER_X,
    y: 520,
    text: "Master the Ancient Arts",
    size_enum: 5,
    alignment_enum: 1,
    **Constants::COLORS[:text_secondary]
  }

  # Animated ritual circle
  pulse = (Math.sin(args.tick_count * 0.05) * 20 + 100).to_i
  draw_ritual_circle(args, Constants::CENTER_X, 300, pulse, true)

  # Draw all elements in a circle
  8.times do |i|
    angle = (i / 8.0) * Math::PI * 2 - Math::PI / 2
    pos = circle_position(Constants::CENTER_X, 300, 120, angle)

    element_key = Constants::ELEMENTS.keys[i % Constants::ELEMENTS.keys.length]
    draw_element_icon(args, pos[:x], pos[:y], element_key, 20)
  end

  # Instructions
  pulse_alpha = ((Math.sin(args.tick_count * 0.1) * 50 + 200).to_i)
  args.outputs.labels << {
    x: Constants::CENTER_X,
    y: 100,
    text: "Press SPACE or ENTER to Begin",
    size_enum: 3,
    alignment_enum: 1,
    r: 255, g: 255, b: 255,
    a: pulse_alpha
  }
end

# ===================================================================
# RITUAL SELECT SCENE
# ===================================================================

def render_ritual_select(args)
  game = args.state.game
  rituals = game.available_rituals

  # Title
  args.outputs.labels << {
    x: Constants::CENTER_X,
    y: 680,
    text: "Select a Ritual",
    size_enum: 10,
    alignment_enum: 1,
    **Constants::COLORS[:text_primary]
  }

  # Player stats
  args.outputs.labels << {
    x: 20, y: 700,
    text: "Level: #{game.player_level}",
    size_enum: 2,
    **Constants::COLORS[:text_secondary]
  }

  args.outputs.labels << {
    x: 20, y: 670,
    text: "Score: #{game.total_score}",
    size_enum: 2,
    **Constants::COLORS[:text_secondary]
  }

  # Ritual list
  start_y = 550
  rituals.each_with_index do |ritual, i|
    y = start_y - (i * 60)
    selected = i == game.selected_ritual_index

    # Selection highlight
    if selected
      args.outputs.solids << {
        x: 100, y: y - 35,
        w: Constants::SCREEN_W - 200, h: 50,
        r: 80, g: 60, b: 120, a: 150
      }
    end

    # Ritual name
    color = selected ? Constants::COLORS[:ui_highlight] : Constants::COLORS[:text_primary]
    args.outputs.labels << {
      x: 120, y: y,
      text: ritual[:name],
      size_enum: selected ? 4 : 2,
      **color
    }

    # Difficulty
    diff_text = "★" * ritual[:difficulty]
    args.outputs.labels << {
      x: 120, y: y - 20,
      text: diff_text,
      size_enum: 0,
      **Constants::COLORS[:text_dim]
    }

    # Element icons
    ritual[:sequence].each_with_index do |element, e_i|
      icon_x = 900 + (e_i * 40)
      icon_y = y - 10
      draw_element_icon(args, icon_x, icon_y, element, 10)
    end

    # Fault tolerance indicator
    ft_text = ritual[:fault_tolerance] == :strict ? "STRICT" : "LENIENT"
    ft_color = ritual[:fault_tolerance] == :strict ?
                 Constants::COLORS[:ui_error] :
                 Constants::COLORS[:ui_success]
    args.outputs.labels << {
      x: Constants::SCREEN_W - 120, y: y,
      text: ft_text,
      size_enum: 0,
      **ft_color
    }
  end

  # Selected ritual description
  if rituals[game.selected_ritual_index]
    ritual = rituals[game.selected_ritual_index]

    args.outputs.labels << {
      x: Constants::CENTER_X,
      y: 100,
      text: ritual[:description],
      size_enum: 2,
      alignment_enum: 1,
      **Constants::COLORS[:text_secondary]
    }
  end

  # Instructions
  args.outputs.labels << {
    x: Constants::CENTER_X,
    y: 40,
    text: "↑↓ Navigate   SPACE Select   ESC Back",
    size_enum: 0,
    alignment_enum: 1,
    **Constants::COLORS[:text_dim]
  }
end

# ===================================================================
# GAMEPLAY SCENE
# ===================================================================

def render_gameplay(args)
  game = args.state.game
  ritual = game.current_ritual

  return unless ritual

  # Ritual name
  args.outputs.labels << {
    x: Constants::CENTER_X,
    y: 700,
    text: ritual.ritual_def[:name],
    size_enum: 8,
    alignment_enum: 1,
    **Constants::COLORS[:text_primary]
  }

  # Draw ritual circle
  draw_ritual_circle(
    args,
    Constants::RITUAL_CIRCLE[:center_x],
    Constants::RITUAL_CIRCLE[:center_y],
    Constants::RITUAL_CIRCLE[:radius],
    ritual.state != :ready
  )

  # Draw nodes
  ritual.nodes.each do |id, node|
    draw_ritual_node(
      args,
      node[:x],
      node[:y],
      node[:element],
      node[:state],
      Constants::RITUAL_CIRCLE[:node_size] / 2
    )

    # Draw node number
    args.outputs.labels << {
      x: node[:x],
      y: node[:y] - 45,
      text: (id + 1).to_s,
      size_enum: 1,
      alignment_enum: 1,
      **Constants::COLORS[:text_dim]
    }
  end

  # Draw connections between completed nodes
  completed = ritual.nodes.select { |_, n| n[:state] == :completed }
  if completed.length > 1
    completed_ids = completed.keys.sort
    (0...completed_ids.length - 1).each do |i|
      from_node = ritual.nodes[completed_ids[i]]
      to_node = ritual.nodes[completed_ids[i + 1]]

      draw_connection_line(
        args,
        from_node[:x],
        from_node[:y],
        to_node[:x],
        to_node[:y],
        true,
        1.0
      )
    end
  end

  # Resource bars
  draw_resource_bar(
    args,
    20, 620,
    "Energy",
    ritual.context[:energy],
    Constants::GAMEPLAY[:starting_energy],
    Constants::COLORS[:energy]
  )

  draw_resource_bar(
    args,
    20, 580,
    "Focus",
    ritual.context[:focus],
    Constants::GAMEPLAY[:starting_focus],
    Constants::COLORS[:ui_primary]
  )

  # Progress
  progress_text = "#{ritual.current_step} / #{ritual.ritual_def[:steps]}"
  args.outputs.labels << {
    x: 20, y: 550,
    text: "Progress: #{progress_text}",
    size_enum: 2,
    **Constants::COLORS[:text_secondary]
  }

  # State indicator
  state_text = case ritual.state
               when :ready
                 "Click a node or press keys 1-8"
               when :channeling
                 "Channeling..."
               when :completing
                 "Ritual Complete!"
               when :failed
                 "Ritual Failed!"
               else
                 ""
               end

  state_color = ritual.state == :failed ?
                  Constants::COLORS[:ui_error] :
                  Constants::COLORS[:ui_highlight]

  args.outputs.labels << {
    x: Constants::CENTER_X,
    y: 60,
    text: state_text,
    size_enum: 4,
    alignment_enum: 1,
    **state_color
  }

  # Instructions
  args.outputs.labels << {
    x: Constants::CENTER_X,
    y: 20,
    text: "ESC to quit",
    size_enum: 0,
    alignment_enum: 1,
    **Constants::COLORS[:text_dim]
  }
end

# ===================================================================
# RESULTS SCENE
# ===================================================================

def render_results(args)
  game = args.state.game
  result = game.result_data

  if result[:success]
    # Success!
    args.outputs.labels << {
      x: Constants::CENTER_X,
      y: 600,
      text: "RITUAL COMPLETE!",
      size_enum: 15,
      alignment_enum: 1,
      **Constants::COLORS[:ui_success]
    }

    # Ritual name
    args.outputs.labels << {
      x: Constants::CENTER_X,
      y: 520,
      text: result[:ritual_name],
      size_enum: 8,
      alignment_enum: 1,
      **Constants::COLORS[:text_primary]
    }

    # Score
    args.outputs.labels << {
      x: Constants::CENTER_X,
      y: 420,
      text: "Score: #{result[:score]}",
      size_enum: 10,
      alignment_enum: 1,
      **Constants::COLORS[:ui_highlight]
    }

    # Time
    time_seconds = (result[:time] / 60.0).round(1)
    args.outputs.labels << {
      x: Constants::CENTER_X,
      y: 350,
      text: "Time: #{time_seconds}s",
      size_enum: 4,
      alignment_enum: 1,
      **Constants::COLORS[:text_secondary]
    }

    # Perfect bonus
    if result[:perfect]
      pulse_alpha = ((Math.sin(args.tick_count * 0.15) * 100 + 155).to_i)
      args.outputs.labels << {
        x: Constants::CENTER_X,
        y: 290,
        text: "✨ PERFECT RITUAL ✨",
        size_enum: 6,
        alignment_enum: 1,
        r: 255, g: 220, b: 100, a: pulse_alpha
      }
    end
  else
    # Failure
    args.outputs.labels << {
      x: Constants::CENTER_X,
      y: 600,
      text: "RITUAL FAILED",
      size_enum: 15,
      alignment_enum: 1,
      **Constants::COLORS[:ui_error]
    }

    args.outputs.labels << {
      x: Constants::CENTER_X,
      y: 520,
      text: result[:ritual_name],
      size_enum: 8,
      alignment_enum: 1,
      **Constants::COLORS[:text_primary]
    }

    args.outputs.labels << {
      x: Constants::CENTER_X,
      y: 420,
      text: "The ritual was not completed successfully.",
      size_enum: 4,
      alignment_enum: 1,
      **Constants::COLORS[:text_secondary]
    }
  end

  # Continue instruction
  pulse_alpha = ((Math.sin(args.tick_count * 0.1) * 50 + 200).to_i)
  args.outputs.labels << {
    x: Constants::CENTER_X,
    y: 100,
    text: "Press SPACE to Continue",
    size_enum: 4,
    alignment_enum: 1,
    r: 255, g: 255, b: 255,
    a: pulse_alpha
  }
end

# ===================================================================
# PARTICLES
# ===================================================================

def render_particles(args)
  args.state.particles.each do |particle|
    particle.draw(args)
  end
end

# ===================================================================
# DEBUG INFO
# ===================================================================

def render_debug(args)
  args.outputs.labels << {
    x: 10, y: 710,
    text: "FPS: #{args.gtk.current_framerate.to_i}",
    size_enum: -2,
    r: 100, g: 255, b: 100
  }

  args.outputs.labels << {
    x: 10, y: 690,
    text: "Tick: #{args.tick_count}",
    size_enum: -2,
    r: 100, g: 255, b: 100
  }

  args.outputs.labels << {
    x: 10, y: 670,
    text: "Particles: #{args.state.particles&.length || 0}",
    size_enum: -2,
    r: 100, g: 255, b: 100
  }
end

puts "✓ Renderer loaded"