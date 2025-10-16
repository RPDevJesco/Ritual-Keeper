# ===================================================================
# RITUAL KEEPER - Renderer (QTE Edition)
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
    text: "QTE Edition - Test Your Reflexes",
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
    text: "Select a Ritual - All Unlocked!",
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

  # Scrolling parameters
  max_visible_rituals = 7
  item_height = 60
  start_y = 580

  # Calculate scroll offset to keep selected item visible
  selected_index = game.selected_ritual_index
  scroll_offset = 0

  if selected_index >= max_visible_rituals
    scroll_offset = selected_index - max_visible_rituals + 1
  end

  # Clamp scroll offset
  max_scroll = [rituals.length - max_visible_rituals, 0].max
  scroll_offset = scroll_offset.clamp(0, max_scroll)

  # Visible ritual range
  visible_start = scroll_offset
  visible_end = [scroll_offset + max_visible_rituals, rituals.length].min

  # Ritual list (only visible items)
  (visible_start...visible_end).each do |i|
    ritual = rituals[i]
    visible_index = i - visible_start
    y = start_y - (visible_index * item_height)
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

    # Difficulty with timing indicator
    diff_text = "★" * ritual[:difficulty]
    timing_text = case ritual[:difficulty]
                  when 1..2
                    " (Easy Timing)"
                  when 3..5
                    " (Moderate)"
                  when 6..7
                    " (Fast!)"
                  else
                    " (EXTREME!)"
                  end

    args.outputs.labels << {
      x: 120, y: y - 20,
      text: diff_text + timing_text,
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

  # Scroll indicators
  if scroll_offset > 0
    # Up arrow indicator
    args.outputs.labels << {
      x: Constants::CENTER_X,
      y: 620,
      text: "▲ More Above",
      size_enum: 0,
      alignment_enum: 1,
      **Constants::COLORS[:text_dim]
    }
  end

  if scroll_offset < max_scroll
    # Down arrow indicator
    args.outputs.labels << {
      x: Constants::CENTER_X,
      y: 160,
      text: "▼ More Below",
      size_enum: 0,
      alignment_enum: 1,
      **Constants::COLORS[:text_dim]
    }
  end

  # Ritual counter
  args.outputs.labels << {
    x: Constants::SCREEN_W - 20,
    y: 670,
    text: "#{selected_index + 1}/#{rituals.length}",
    size_enum: 2,
    alignment_enum: 2,
    **Constants::COLORS[:text_secondary]
  }

  # Selected ritual description
  if rituals[game.selected_ritual_index]
    ritual = rituals[game.selected_ritual_index]

    args.outputs.labels << {
      x: Constants::CENTER_X,
      y: 120,
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
# GAMEPLAY SCENE (QTE Edition)
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
    # Highlight the current QTE target
    is_qte_target = ritual.current_qte &&
                    ritual.current_qte[:node_id] == id &&
                    ritual.current_qte[:state] == :active

    draw_ritual_node(
      args,
      node[:x],
      node[:y],
      node[:element],
      node[:state],
      Constants::RITUAL_CIRCLE[:node_size] / 2,
      is_qte_target
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

    # Draw QTE indicator on target node
    if is_qte_target
      draw_qte_indicator(args, node[:x], node[:y], ritual.qte_progress)
    end
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

  # Progress bar
  progress_pct = (ritual.current_step.to_f / ritual.ritual_def[:steps] * 100).to_i
  args.outputs.labels << {
    x: 20, y: 550,
    text: "Progress: #{ritual.current_step}/#{ritual.ritual_def[:steps]} (#{progress_pct}%)",
    size_enum: 2,
    **Constants::COLORS[:text_secondary]
  }

  # Accuracy stats
  total_attempts = ritual.successful_qtes + ritual.failed_qtes
  accuracy = total_attempts > 0 ? (ritual.successful_qtes.to_f / total_attempts * 100).to_i : 100

  args.outputs.labels << {
    x: 20, y: 520,
    text: "Hits: #{ritual.successful_qtes} | Misses: #{ritual.failed_qtes} | Accuracy: #{accuracy}%",
    size_enum: 2,
    **Constants::COLORS[:text_secondary]
  }

  # State indicator
  state_text = case ritual.state
               when :ready
                 "Get Ready..."
               when :waiting_for_input
                 "CLICK THE GLOWING NODE!"
               when :qte_delay
                 "Next node incoming..."
               when :completing
                 "Ritual Complete!"
               when :failed
                 "Ritual Failed!"
               else
                 ""
               end

  state_color = case ritual.state
                when :failed
                  Constants::COLORS[:ui_error]
                when :waiting_for_input
                  Constants::COLORS[:ui_highlight]
                else
                  Constants::COLORS[:ui_primary]
                end

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
    text: "Click nodes or press 1-8 | ESC to quit",
    size_enum: 0,
    alignment_enum: 1,
    **Constants::COLORS[:text_dim]
  }
end

# ===================================================================
# QTE INDICATOR
# ===================================================================

def draw_qte_indicator(args, x, y, progress)
  # Shrinking ring around the node
  remaining = 1.0 - progress
  size = 40 + (remaining * 30)

  # Color transitions from green to yellow to red as time runs out
  color = if remaining > 0.6
            { r: 100, g: 255, b: 100 }
          elsif remaining > 0.3
            { r: 255, g: 255, b: 0 }
          else
            { r: 255, g: 100, b: 100 }
          end

  # Outer ring
  args.outputs.borders << {
    x: x - size, y: y - size,
    w: size * 2, h: size * 2,
    r: color[:r], g: color[:g], b: color[:b],
    a: 200
  }

  # Inner ring
  inner_size = size - 5
  args.outputs.borders << {
    x: x - inner_size, y: y - inner_size,
    w: inner_size * 2, h: inner_size * 2,
    r: color[:r], g: color[:g], b: color[:b],
    a: 150
  }

  # Pulsing effect
  pulse = (Math.sin(args.tick_count * 0.2) * 5 + 5).to_i
  pulse_size = size + pulse
  args.outputs.borders << {
    x: x - pulse_size, y: y - pulse_size,
    w: pulse_size * 2, h: pulse_size * 2,
    r: color[:r], g: color[:g], b: color[:b],
    a: 100
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

    # Stats
    total_attempts = result[:hits] + result[:misses]
    accuracy = total_attempts > 0 ? (result[:hits].to_f / total_attempts * 100).to_i : 100

    args.outputs.labels << {
      x: Constants::CENTER_X,
      y: 350,
      text: "Hits: #{result[:hits]} | Misses: #{result[:misses]} | Accuracy: #{accuracy}%",
      size_enum: 4,
      alignment_enum: 1,
      **Constants::COLORS[:text_secondary]
    }

    # Time
    time_seconds = (result[:time] / 60.0).round(1)
    args.outputs.labels << {
      x: Constants::CENTER_X,
      y: 300,
      text: "Time: #{time_seconds}s",
      size_enum: 3,
      alignment_enum: 1,
      **Constants::COLORS[:text_secondary]
    }

    # Perfect bonus
    if result[:perfect]
      pulse_alpha = ((Math.sin(args.tick_count * 0.15) * 100 + 155).to_i)
      args.outputs.labels << {
        x: Constants::CENTER_X,
        y: 240,
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

    # Stats even on failure
    args.outputs.labels << {
      x: Constants::CENTER_X,
      y: 360,
      text: "Hits: #{result[:hits]} | Misses: #{result[:misses]}",
      size_enum: 3,
      alignment_enum: 1,
      **Constants::COLORS[:text_dim]
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

  if args.state.game&.current_ritual&.current_qte
    qte = args.state.game.current_ritual.current_qte
    args.outputs.labels << {
      x: 10, y: 650,
      text: "QTE: Node #{qte[:node_id]} | Window: #{qte[:window]}f | Progress: #{(args.state.game.current_ritual.qte_progress * 100).to_i}%",
      size_enum: -2,
      r: 255, g: 255, b: 100
    }
  end
end

puts "✓ Renderer loaded (QTE Edition)"
