# ===================================================================
# RITUAL KEEPER - Particle System
# ===================================================================

class Particle
  attr_accessor :x, :y, :vx, :vy, :life, :max_life, :size, :color, :gravity
  
  def initialize(x, y, vx, vy, life, color, size = 4, gravity = -0.3)
    @x = x
    @y = y
    @vx = vx
    @vy = vy
    @life = life
    @max_life = life
    @color = color
    @size = size
    @gravity = gravity
  end
  
  def update
    @x += @vx
    @y += @vy
    @vy += @gravity
    @vx *= 0.98  # Air resistance
    @life -= 1
  end
  
  def dead?
    @life <= 0
  end
  
  def alpha
    (@life.to_f / @max_life * 255).to_i.clamp(0, 255)
  end
  
  def draw(args)
    half_size = @size / 2
    args.outputs.solids << {
      x: @x - half_size,
      y: @y - half_size,
      w: @size,
      h: @size,
      r: @color[:r],
      g: @color[:g],
      b: @color[:b],
      a: alpha
    }
  end
end

# ===================================================================
# Particle Emitter Helper Functions
# ===================================================================

def spawn_particles(args, x, y, settings)
  count = settings[:count] || 10
  spread = settings[:spread] || 20
  speed_min = settings[:speed_min] || 2
  speed_max = settings[:speed_max] || 5
  lifetime = settings[:lifetime] || 60
  color = settings[:color] || Constants::COLORS[:energy]
  size = settings[:size] || 4
  gravity = settings[:gravity] || -0.3
  
  count.times do
    angle = rand * Math::PI * 2
    speed = speed_min + rand * (speed_max - speed_min)
    
    vx = Math.cos(angle) * speed
    vy = Math.sin(angle) * speed
    
    offset_x = (rand - 0.5) * spread
    offset_y = (rand - 0.5) * spread
    
    particle = Particle.new(
      x + offset_x,
      y + offset_y,
      vx,
      vy,
      lifetime,
      color,
      size,
      gravity
    )
    
    args.state.particles << particle
  end
end

def spawn_node_activation_particles(args, x, y, color)
  spawn_particles(args, x, y, 
    count: 20,
    spread: 30,
    speed_min: 2,
    speed_max: 5,
    lifetime: 60,
    color: color,
    size: 4,
    gravity: -0.2
  )
end

def spawn_energy_flow_particles(args, x, y, color)
  spawn_particles(args, x, y,
    count: 5,
    spread: 5,
    speed_min: 1,
    speed_max: 3,
    lifetime: 30,
    color: color,
    size: 3,
    gravity: -0.1
  )
end

def spawn_ritual_completion_particles(args, x, y)
  spawn_particles(args, x, y,
    count: 100,
    spread: 100,
    speed_min: 3,
    speed_max: 8,
    lifetime: 90,
    color: Constants::COLORS[:ui_success],
    size: 6,
    gravity: -0.4
  )
end

def spawn_ritual_failure_particles(args, x, y)
  spawn_particles(args, x, y,
    count: 50,
    spread: 50,
    speed_min: 2,
    speed_max: 6,
    lifetime: 60,
    color: Constants::COLORS[:ui_error],
    size: 5,
    gravity: -0.3
  )
end

puts "✓ Particle system loaded"
