# ===================================================================
# RITUAL KEEPER - Primitive Drawing Helpers (QTE Edition)
# ===================================================================
# Helper functions for drawing game elements using primitives
# ===================================================================

# ===================================================================
# ELEMENT ICONS
# ===================================================================

def draw_fire_icon(args, x, y, size = 15, color = nil)
  color ||= Constants::COLORS[:fire]

  # Triangle pointing up
  points = [
    { x: x, y: y + size },
    { x: x - size * 0.7, y: y - size * 0.5 },
    { x: x + size * 0.7, y: y - size * 0.5 }
  ]

  # Draw filled triangle using lines
  args.outputs.lines << {
    x: points[0][:x], y: points[0][:y],
    x2: points[1][:x], y2: points[1][:y],
    r: color[:r], g: color[:g], b: color[:b]
  }
  args.outputs.lines << {
    x: points[1][:x], y: points[1][:y],
    x2: points[2][:x], y2: points[2][:y],
    r: color[:r], g: color[:g], b: color[:b]
  }
  args.outputs.lines << {
    x: points[2][:x], y: points[2][:y],
    x2: points[0][:x], y2: points[0][:y],
    r: color[:r], g: color[:g], b: color[:b]
  }
end

def draw_water_icon(args, x, y, size = 15, color = nil)
  color ||= Constants::COLORS[:water]

  # Wavy lines (inverted triangle)
  points = [
    { x: x, y: y - size },
    { x: x - size * 0.7, y: y + size * 0.5 },
    { x: x + size * 0.7, y: y + size * 0.5 }
  ]

  args.outputs.lines << {
    x: points[0][:x], y: points[0][:y],
    x2: points[1][:x], y2: points[1][:y],
    r: color[:r], g: color[:g], b: color[:b]
  }
  args.outputs.lines << {
    x: points[1][:x], y: points[1][:y],
    x2: points[2][:x], y2: points[2][:y],
    r: color[:r], g: color[:g], b: color[:b]
  }
  args.outputs.lines << {
    x: points[2][:x], y: points[2][:y],
    x2: points[0][:x], y2: points[0][:y],
    r: color[:r], g: color[:g], b: color[:b]
  }
end

def draw_earth_icon(args, x, y, size = 15, color = nil)
  color ||= Constants::COLORS[:earth]

  # Square
  args.outputs.solids << {
    x: x - size * 0.5, y: y - size * 0.5,
    w: size, h: size,
    r: color[:r], g: color[:g], b: color[:b]
  }
end

def draw_air_icon(args, x, y, size = 15, color = nil)
  color ||= Constants::COLORS[:air]

  # Circle made of dots
  8.times do |i|
    angle = (i / 8.0) * Math::PI * 2
    dot_x = x + (Math.cos(angle) * size * 0.6)
    dot_y = y + (Math.sin(angle) * size * 0.6)

    args.outputs.solids << {
      x: dot_x - 2, y: dot_y - 2,
      w: 4, h: 4,
      r: color[:r], g: color[:g], b: color[:b]
    }
  end
end

def draw_moon_icon(args, x, y, size = 15, color = nil)
  color ||= Constants::COLORS[:moon]

  # Crescent shape using borders
  args.outputs.borders << {
    x: x - size * 0.5, y: y - size * 0.5,
    w: size, h: size,
    r: color[:r], g: color[:g], b: color[:b]
  }

  # Dark fill to create crescent
  args.outputs.solids << {
    x: x - size * 0.2, y: y - size * 0.5,
    w: size * 0.8, h: size,
    r: 20, g: 15, b: 30
  }
end

def draw_sun_icon(args, x, y, size = 15, color = nil)
  color ||= Constants::COLORS[:sun]

  # Center circle
  args.outputs.solids << {
    x: x - size * 0.3, y: y - size * 0.3,
    w: size * 0.6, h: size * 0.6,
    r: color[:r], g: color[:g], b: color[:b]
  }

  # Rays
  8.times do |i|
    angle = (i / 8.0) * Math::PI * 2
    start_x = x + (Math.cos(angle) * size * 0.5)
    start_y = y + (Math.sin(angle) * size * 0.5)
    end_x = x + (Math.cos(angle) * size)
    end_y = y + (Math.sin(angle) * size)

    args.outputs.lines << {
      x: start_x, y: start_y,
      x2: end_x, y2: end_y,
      r: color[:r], g: color[:g], b: color[:b]
    }
  end
end

def draw_shadow_icon(args, x, y, size = 15, color = nil)
  color ||= Constants::COLORS[:shadow]

  # Diamond shape
  points = [
    { x: x, y: y + size },
    { x: x - size, y: y },
    { x: x, y: y - size },
    { x: x + size, y: y }
  ]

  4.times do |i|
    next_i = (i + 1) % 4
    args.outputs.lines << {
      x: points[i][:x], y: points[i][:y],
      x2: points[next_i][:x], y2: points[next_i][:y],
      r: color[:r], g: color[:g], b: color[:b]
    }
  end
end

def draw_light_icon(args, x, y, size = 15, color = nil)
  color ||= Constants::COLORS[:light]

  # Star shape
  5.times do |i|
    angle1 = (i * 2 * Math::PI / 5) - Math::PI / 2
    angle2 = ((i + 2) % 5 * 2 * Math::PI / 5) - Math::PI / 2

    x1 = x + Math.cos(angle1) * size
    y1 = y + Math.sin(angle1) * size
    x2 = x + Math.cos(angle2) * size
    y2 = y + Math.sin(angle2) * size

    args.outputs.lines << {
      x: x1, y: y1, x2: x2, y2: y2,
      r: color[:r], g: color[:g], b: color[:b]
    }
  end
end

# ===================================================================
# ICON DISPATCHER
# ===================================================================

def draw_element_icon(args, x, y, element_type, size = 15, color = nil)
  case element_type
  when :fire
    draw_fire_icon(args, x, y, size, color)
  when :water
    draw_water_icon(args, x, y, size, color)
  when :earth
    draw_earth_icon(args, x, y, size, color)
  when :air
    draw_air_icon(args, x, y, size, color)
  when :moon
    draw_moon_icon(args, x, y, size, color)
  when :sun
    draw_sun_icon(args, x, y, size, color)
  when :shadow
    draw_shadow_icon(args, x, y, size, color)
  when :light
    draw_light_icon(args, x, y, size, color)
  end
end

# ===================================================================
# RITUAL NODE (QTE Edition)
# ===================================================================

def draw_ritual_node(args, x, y, element_type, state = :inactive, size = 30, is_qte_target = false)
  element = Constants::ELEMENTS[element_type]
  return unless element

  # Determine colors based on state
  border_color = case state
  when :pending
    Constants::COLORS[:ui_highlight]
  when :completed
    Constants::COLORS[:ui_success]
  when :failed
    Constants::COLORS[:ui_error]
  else
    Constants::COLORS[:ui_secondary]
  end

  # QTE target gets special bright border
  if is_qte_target
    border_color = { r: 255, g: 255, b: 100 }
  end

  fill_alpha = case state
  when :pending
    220
  when :completed
    255
  when :failed
    150
  else
    100
  end

  # QTE target gets brighter fill
  if is_qte_target
    fill_alpha = 255
  end

  # Node border (circle-like using border)
  args.outputs.borders << {
    x: x - size, y: y - size,
    w: size * 2, h: size * 2,
    r: border_color[:r], g: border_color[:g], b: border_color[:b]
  }

  # Node fill
  args.outputs.solids << {
    x: x - size + 2, y: y - size + 2,
    w: (size * 2) - 4, h: (size * 2) - 4,
    r: element[:color][:r],
    g: element[:color][:g],
    b: element[:color][:b],
    a: fill_alpha
  }

  # Element icon in center
  draw_element_icon(args, x, y, element_type, size * 0.5, element[:color])

  # Intense pulse effect for QTE target
  if is_qte_target
    pulse = (Math.sin(args.tick_count * 0.3) * 15 + 15).to_i
    args.outputs.borders << {
      x: x - size - pulse, y: y - size - pulse,
      w: (size * 2) + (pulse * 2), h: (size * 2) + (pulse * 2),
      r: 255, g: 255, b: 100,
      a: 200
    }

    # Secondary pulse
    pulse2 = (Math.sin(args.tick_count * 0.3 + Math::PI) * 10 + 10).to_i
    args.outputs.borders << {
      x: x - size - pulse2, y: y - size - pulse2,
      w: (size * 2) + (pulse2 * 2), h: (size * 2) + (pulse2 * 2),
      r: 255, g: 200, b: 50,
      a: 150
    }
  end

  # Regular pulse effect for pending nodes
  if state == :pending && !is_qte_target
    pulse = (Math.sin(args.tick_count * 0.1) * 10 + 10).to_i
    args.outputs.borders << {
      x: x - size - pulse, y: y - size - pulse,
      w: (size * 2) + (pulse * 2), h: (size * 2) + (pulse * 2),
      r: border_color[:r], g: border_color[:g], b: border_color[:b],
      a: 128
    }
  end
end

# ===================================================================
# RITUAL CIRCLE
# ===================================================================

def draw_ritual_circle(args, center_x, center_y, radius, active = false)
  color = Constants::COLORS[:ritual_circle]

  # Outer circle
  args.outputs.borders << {
    x: center_x - radius, y: center_y - radius,
    w: radius * 2, h: radius * 2,
    r: color[:r], g: color[:g], b: color[:b],
    a: active ? 255 : 100
  }

  # Inner glow
  if active
    pulse = (Math.sin(args.tick_count * 0.05) * 30 + 30).to_i
    args.outputs.solids << {
      x: center_x - radius + 10, y: center_y - radius + 10,
      w: (radius * 2) - 20, h: (radius * 2) - 20,
      r: color[:r], g: color[:g], b: color[:b],
      a: pulse
    }
  end
end

# ===================================================================
# CONNECTION LINES
# ===================================================================

def draw_connection_line(args, from_x, from_y, to_x, to_y, active = false, progress = 0)
  color = active ? Constants::COLORS[:energy] : Constants::COLORS[:ui_secondary]
  alpha = active ? 255 : 100

  # Connection line
  args.outputs.lines << {
    x: from_x, y: from_y,
    x2: to_x, y2: to_y,
    r: color[:r], g: color[:g], b: color[:b],
    a: alpha
  }

  # Energy particle traveling along line
  if active && progress > 0 && progress < 1
    particle_x = lerp(from_x, to_x, progress)
    particle_y = lerp(from_y, to_y, progress)

    args.outputs.solids << {
      x: particle_x - 4, y: particle_y - 4,
      w: 8, h: 8,
      r: 255, g: 200, b: 100
    }
  end
end

# ===================================================================
# RESOURCE BAR
# ===================================================================

def draw_resource_bar(args, x, y, label, current, max, color, width = 200, height = 20)
  # Background
  args.outputs.solids << {
    x: x, y: y, w: width, h: height,
    r: 40, g: 40, b: 40
  }

  # Border
  args.outputs.borders << {
    x: x, y: y, w: width, h: height,
    r: 100, g: 100, b: 100
  }

  # Fill
  fill_width = (current / max.to_f) * (width - 4)
  args.outputs.solids << {
    x: x + 2, y: y + 2, w: fill_width, h: height - 4,
    r: color[:r], g: color[:g], b: color[:b]
  }

  # Label
  args.outputs.labels << {
    x: x + width / 2, y: y + height - 5,
    text: "#{label}: #{current.to_i}/#{max.to_i}",
    size_enum: -1,
    alignment_enum: 1,
    r: 255, g: 255, b: 255
  }
end

puts "✓ Primitives helper loaded (QTE Edition)"
