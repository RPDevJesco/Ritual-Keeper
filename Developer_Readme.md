# 🕯️ Ritual Keeper - Developer Reference

A comprehensive technical guide to the Ritual Keeper codebase, demonstrating the EventChains design pattern in a real DragonRuby game.

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [EventChains Pattern Implementation](#eventchains-pattern-implementation)
- [File Structure](#file-structure)
- [Core Systems](#core-systems)
- [Game Flow](#game-flow)
- [Adding New Content](#adding-new-content)
- [Performance Considerations](#performance-considerations)
- [Testing Strategy](#testing-strategy)
- [Common Patterns](#common-patterns)
- [Troubleshooting](#troubleshooting)

## 🏗️ Architecture Overview

Ritual Keeper is built using a clean, modular architecture that demonstrates the EventChains design pattern. The codebase is organized into distinct layers:

### Layer Structure

```
┌─────────────────────────────────────┐
│         Main Game Loop              │
│         (main.rb)                   │
└──────────────┬──────────────────────┘
               │
      ┌────────┴────────┐
      │                 │
      ▼                 ▼
┌──────────┐      ┌──────────┐
│  Update  │      │  Render  │
│  Systems │      │  Systems │
└────┬─────┘      └─────┬────┘
     │                  │
     ├──────────────────┼────────────────┐
     │                  │                │
     ▼                  ▼                ▼
┌─────────┐      ┌──────────┐    ┌──────────┐
│  Game   │      │ Renderer │    │ Particle │
│  State  │      │          │    │  System  │
└────┬────┘      └──────────┘    └──────────┘
     │
     ▼
┌──────────────────────────────────────┐
│        EventChains System             │
│  ┌────────────────────────────────┐  │
│  │  Chain → Events → Middleware   │  │
│  └────────────────────────────────┘  │
└──────────────────────────────────────┘
```

### Design Principles

1. **Separation of Concerns** - Game logic, rendering, and input handling are independent
2. **Single Responsibility** - Each class/module has one clear purpose
3. **Composition Over Inheritance** - Systems are composed of smaller, reusable pieces
4. **Data-Driven Design** - Rituals are defined as data structures, not hardcoded logic
5. **Event-Based Architecture** - Ritual execution flows through discrete events

## 🔗 EventChains Pattern Implementation

Ritual Keeper's core ritual system is built entirely on the EventChains pattern. Here's how it works:

### Core Components

#### 1. Event Context (`event_chains.rb`)

```ruby
class EventContext
  def initialize
    @data = {}
  end
  
  def []=(key, value)
    @data[key] = value
  end
  
  def [](key)
    @data[key]
  end
end
```

**Purpose**: Shared state container that flows through the entire event chain.

**In Ritual Keeper**: Stores ritual state, node data, player resources (energy, focus), and progression tracking.

#### 2. Chainable Events (`ritual_events.rb`)

```ruby
module ChainableEvent
  def execute(context)
    raise NotImplementedError
  end
  
  def success(context)
    EventResult.success(context)
  end
  
  def failure(error_message)
    EventResult.failure(error_message)
  end
end
```

**Purpose**: Defines the contract for discrete units of work in a ritual.

**In Ritual Keeper**: Individual events like `InitializeRitualEvent`, `ActivateNodeEvent`, and `CompleteRitualEvent`.

#### 3. Event Chain (`event_chains.rb`)

```ruby
class EventChain
  def initialize(fault_tolerance_mode = FaultTolerance::Mode::STRICT)
    @events = []
    @middlewares = []
    @context = EventContext.new
    @fault_tolerance = FaultTolerance::Config.new(fault_tolerance_mode)
  end
  
  def add_event(event)
    @events << event
    self
  end
  
  def use_middleware(&middleware)
    @middlewares << middleware
    self
  end
  
  def execute
    # ... pipeline construction and execution
  end
end
```

**Purpose**: Orchestrates sequential execution of events through middleware pipeline.

**In Ritual Keeper**: Used during initialization to set up ritual state and validate preconditions.

### Fault Tolerance Modes

Ritual Keeper uses three fault tolerance modes:

#### STRICT Mode
```ruby
EventChain.strict
```
- Any failure stops execution immediately
- Used for: High-difficulty rituals where precision matters
- Example: Grand Summoning, Shadow Binding

#### LENIENT Mode
```ruby
EventChain.lenient
```
- Failures are logged but execution continues
- Used for: Beginner rituals, practice modes
- Example: Simple Flame, Cleansing Waters

#### BEST_EFFORT Mode
```ruby
EventChain.best_effort
```
- All events attempted regardless of failures
- Used for: Batch operations, non-critical workflows
- Example: Not currently used in gameplay but available for future features

### Event Flow Example

Here's how a ritual initialization uses EventChains:

```ruby
# From game_state.rb - ActiveRitual#initialize_ritual
def initialize_ritual
  # Create initialization chain
  init_chain = EventChain.strict
  init_chain.add_event(InitializeRitualEvent.new)
  
  # Set up context
  init_chain.context[:args] = @args
  init_chain.context[:ritual] = @ritual_def
  
  # Execute initialization
  result = init_chain.execute
  
  if result.success?
    @context = result.data
    @nodes = @context[:nodes]
    @state = :ready
    spawn_next_qte
  else
    @state = :failed
  end
end
```

**What happens here:**

1. **Chain Creation**: A strict EventChain is created (failures stop execution)
2. **Event Addition**: `InitializeRitualEvent` is added to the chain
3. **Context Setup**: Initial data (args, ritual definition) is added to context
4. **Execution**: Chain executes the event
5. **Result Handling**: Success leads to ready state, failure leads to failed state

## 📁 File Structure

```
ritual-keeper/
├── app/
│   ├── main.rb                    # Entry point, game loop
│   ├── event_chains.rb            # EventChains pattern implementation
│   ├── constants.rb               # Game constants and configuration
│   ├── game_state.rb              # Game state manager and ActiveRitual
│   ├── ritual_definitions.rb     # All ritual data definitions
│   ├── ritual_events.rb          # Event implementations for rituals
│   ├── renderer.rb               # All rendering functions
│   ├── primitives_helper.rb      # Drawing helper functions
│   ├── particle_system.rb        # Particle effects system
│   └── input_handler.rb          # Input utility functions
├── metadata/
│   └── game_metadata.txt         # DragonRuby publishing metadata
└── README.md                      # This file
```

### File Responsibilities

| File | Responsibility | Key Classes/Modules |
|------|---------------|---------------------|
| `main.rb` | Game loop, scene management | `tick()`, `update_*()`, `render_game()` |
| `event_chains.rb` | Core pattern implementation | `EventChain`, `EventContext`, `ChainableEvent` |
| `constants.rb` | Configuration and static data | `Constants` module |
| `game_state.rb` | Game state and ritual execution | `GameState`, `ActiveRitual` |
| `ritual_definitions.rb` | Ritual data definitions | `RitualDefinitions` module |
| `ritual_events.rb` | Ritual-specific events | `InitializeRitualEvent`, etc. |
| `renderer.rb` | Visual output | `render_*()` functions |
| `primitives_helper.rb` | Drawing utilities | `draw_*()` functions |
| `particle_system.rb` | Particle effects | `Particle` class, spawn functions |
| `input_handler.rb` | Input utilities | `InputHelper` module |

## 🎮 Core Systems

### 1. Game State Management

**File**: `game_state.rb`

The `GameState` class manages high-level game flow:

```ruby
class GameState
  attr_accessor :current_scene, :selected_ritual_index, :current_ritual,
                :player_level, :completed_rituals, :total_score
  
  def initialize(args)
    @current_scene = :menu
    @player_level = 1
    @completed_rituals = []
    @total_score = 0
    @selected_ritual_index = 0
    @current_ritual = nil
  end
  
  def transition_to(scene)
    @current_scene = scene
    # Scene-specific setup...
  end
  
  def start_ritual(ritual_def)
    @current_ritual = ActiveRitual.new(@args, ritual_def)
    transition_to(:gameplay)
  end
end
```

**Scenes**:
- `:menu` - Title screen
- `:ritual_select` - Ritual selection list
- `:gameplay` - Active ritual gameplay
- `:results` - Completion/failure screen

### 2. Active Ritual System (QTE-Based)

**File**: `game_state.rb`

The `ActiveRitual` class manages the QTE-based ritual execution:

```ruby
class ActiveRitual
  attr_reader :ritual_def, :state, :nodes, :current_step,
              :successful_qtes, :failed_qtes, :current_qte
  
  def initialize(args, ritual_def)
    @ritual_def = ritual_def
    @state = :initializing
    @current_step = 0
    @successful_qtes = 0
    @failed_qtes = 0
    @current_qte = nil
    @qte_window = calculate_qte_window(ritual_def[:difficulty])
    
    initialize_ritual  # Uses EventChains
  end
  
  def update(args)
    case @state
    when :waiting_for_input
      handle_player_input(args)
      check_qte_timeout
    when :qte_delay
      # Brief pause between QTEs
    when :completing
      # Handle completion
    end
  end
end
```

**QTE States**:
- `:initializing` - Setting up ritual
- `:ready` - Ready to start
- `:waiting_for_input` - QTE active, waiting for player click
- `:qte_delay` - Brief pause between QTEs
- `:completing` - Ritual finishing
- `:completed` - Ritual successfully completed
- `:failed` - Ritual failed

**QTE Structure**:
```ruby
@current_qte = {
  node_id: 3,              # Which node must be clicked
  element: :fire,          # Element type
  spawn_time: 1000,        # When QTE started
  window: 90,              # How many frames player has
  state: :active           # QTE state
}
```

### 3. QTE Timing System

**File**: `game_state.rb`

QTE timing windows are calculated based on ritual difficulty:

```ruby
def calculate_qte_window(difficulty)
  base_window = 120  # 2 seconds at 60 FPS
  reduction = (difficulty - 1) * 8
  [base_window - reduction, 30].max  # Minimum 0.5 seconds
end
```

**Difficulty Timing Chart**:

| Difficulty | Window (frames) | Window (seconds) | Challenge Level |
|------------|-----------------|------------------|-----------------|
| 1 | 120 | 2.0 | Very Easy |
| 2 | 112 | 1.87 | Easy |
| 3 | 104 | 1.73 | Moderate |
| 4 | 96 | 1.6 | Moderate |
| 5 | 88 | 1.47 | Moderate |
| 6 | 80 | 1.33 | Fast |
| 7 | 72 | 1.2 | Fast |
| 8 | 64 | 1.07 | Very Fast |
| 9 | 56 | 0.93 | Very Fast |
| 10 | 48 | 0.8 | Extreme |

### 4. Ritual Definitions

**File**: `ritual_definitions.rb`

Rituals are defined as pure data structures:

```ruby
def self.create_ritual(name:, description:, sequence:, fault_tolerance:, difficulty:)
  {
    name: name,
    description: description,
    sequence: sequence,          # Array of element types
    fault_tolerance: fault_tolerance,  # :strict or :lenient
    difficulty: difficulty,      # 1-10
    steps: sequence.length
  }
end

SIMPLE_FLAME = create_ritual(
  name: "Simple Flame",
  description: "Light a small fire. The most basic ritual. [Easy timing]",
  sequence: [:fire],
  fault_tolerance: :lenient,
  difficulty: 1
)
```

**Key Properties**:
- `sequence` - Array of element types in order
- `fault_tolerance` - `:strict` or `:lenient`
- `difficulty` - 1-10, determines QTE timing
- `steps` - Calculated from sequence length

### 5. Rendering System

**File**: `renderer.rb`

Scene-based rendering with helper functions:

```ruby
def render_game(args)
  render_background(args)
  
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
  
  render_particles(args)
  render_debug(args) if $gtk.args.state.debug_mode
end
```

**Rendering Functions**:
- `render_background()` - Draws grid pattern background
- `render_menu()` - Title screen with animated elements
- `render_ritual_select()` - Scrolling ritual list
- `render_gameplay()` - Active ritual with QTE indicators
- `render_results()` - Score and completion info
- `render_particles()` - Particle effects overlay
- `render_debug()` - FPS and debug info

### 6. Primitive Drawing Helpers

**File**: `primitives_helper.rb`

Low-level drawing functions for game elements:

```ruby
def draw_element_icon(args, x, y, element_type, size = 15, color = nil)
  case element_type
  when :fire
    draw_fire_icon(args, x, y, size, color)
  when :water
    draw_water_icon(args, x, y, size, color)
  # ... etc
  end
end

def draw_ritual_node(args, x, y, element_type, state, size, is_qte_target)
  # Draw node border, fill, icon, and effects
end

def draw_qte_indicator(args, x, y, progress)
  # Draw shrinking ring around QTE target
end
```

**Helper Categories**:
- Element icons (8 functions for 8 elements)
- Ritual nodes and circle
- QTE indicators
- Connection lines
- Resource bars

### 7. Particle System

**File**: `particle_system.rb`

Simple particle effect system:

```ruby
class Particle
  attr_accessor :x, :y, :vx, :vy, :life, :color, :size, :gravity
  
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
  
  def draw(args)
    # Render with alpha based on remaining life
  end
end
```

**Particle Spawners**:
- `spawn_node_activation_particles()` - When node is clicked
- `spawn_energy_flow_particles()` - Energy movement effects
- `spawn_ritual_completion_particles()` - Success celebration
- `spawn_ritual_failure_particles()` - Failure feedback

## 🎯 Game Flow

### Main Game Loop

```ruby
def tick(args)
  # Initialize on first tick
  if args.state.tick_count == 0
    initialize_game(args)
  end
  
  # Update game systems
  update_game(args)
  
  # Render everything
  render_game(args)
end
```

### Update Flow

```
tick()
  └─> update_game()
      ├─> update_menu()           [if scene == :menu]
      ├─> update_ritual_select()  [if scene == :ritual_select]
      ├─> update_gameplay()       [if scene == :gameplay]
      │   └─> ActiveRitual#update()
      │       ├─> handle_player_input()
      │       ├─> check_qte_timeout()
      │       ├─> spawn_next_qte()
      │       └─> check_completion()
      ├─> update_results()        [if scene == :results]
      └─> update_particles()
```

### Ritual Execution Flow

```
Start Ritual
  │
  ├─> initialize_ritual()
  │   └─> EventChain.execute()
  │       └─> InitializeRitualEvent
  │           ├─> Set up context (energy, focus, nodes)
  │           ├─> Create node positions
  │           └─> Return success
  │
  ├─> spawn_next_qte()
  │   ├─> Find node with required element
  │   ├─> Set current_qte data
  │   └─> State = :waiting_for_input
  │
  ├─> [LOOP] update()
  │   ├─> handle_player_input()
  │   │   ├─> Mouse click?
  │   │   │   └─> attempt_qte(node_id)
  │   │   └─> Keyboard press?
  │   │       └─> attempt_qte(node_id)
  │   │
  │   ├─> check_qte_timeout()
  │   │   └─> If time expired: fail_current_qte()
  │   │
  │   ├─> attempt_qte(node_id)
  │   │   ├─> Correct node?
  │   │   │   └─> complete_current_qte()
  │   │   │       ├─> Update stats
  │   │   │       ├─> Spawn particles
  │   │   │       └─> spawn_next_qte() or check_completion()
  │   │   └─> Wrong node?
  │   │       └─> fail_current_qte()
  │   │           ├─> Update stats
  │   │           ├─> Spawn particles
  │   │           └─> Check failure conditions
  │   │
  │   └─> check_completion()
  │       ├─> All steps complete?
  │       │   └─> calculate_final_score()
  │       │       └─> State = :completed
  │       └─> Too many failures?
  │           └─> State = :failed
  │
  └─> Return to results screen
```

## 🔧 Adding New Content

### Adding a New Ritual

**Step 1**: Define the ritual in `ritual_definitions.rb`

```ruby
NEW_RITUAL = create_ritual(
  name: "Cosmic Harmony",
  description: "Unite all celestial forces. [Very fast timing]",
  sequence: [:moon, :sun, :moon, :sun, :shadow, :light],
  fault_tolerance: :strict,
  difficulty: 8
)
```

**Step 2**: Add to `ALL_RITUALS` array

```ruby
ALL_RITUALS = [
  SIMPLE_FLAME,
  # ... existing rituals ...
  NEW_RITUAL  # Add here
]
```

**Step 3**: Test the ritual

The ritual will automatically appear in the ritual selection screen and be fully playable with QTE mechanics.

### Adding a New Element

**Step 1**: Define color and properties in `constants.rb`

```ruby
COLORS = {
  # ... existing colors ...
  void: { r: 10, g: 10, b: 40 }  # New element color
}

ELEMENTS = {
  # ... existing elements ...
  void: {
    name: "Void",
    color: COLORS[:void],
    symbol: "â—‹",
    unlock_level: 15,
    description: "The element of emptiness"
  }
}
```

**Step 2**: Create drawing function in `primitives_helper.rb`

```ruby
def draw_void_icon(args, x, y, size = 15, color = nil)
  color ||= Constants::COLORS[:void]
  
  # Draw void-specific visual (e.g., empty circle with dot)
  args.outputs.borders << {
    x: x - size, y: y - size,
    w: size * 2, h: size * 2,
    r: color[:r], g: color[:g], b: color[:b]
  }
  
  args.outputs.solids << {
    x: x - 2, y: y - 2,
    w: 4, h: 4,
    r: color[:r], g: color[:g], b: color[:b]
  }
end
```

**Step 3**: Add to icon dispatcher

```ruby
def draw_element_icon(args, x, y, element_type, size = 15, color = nil)
  case element_type
  # ... existing cases ...
  when :void
    draw_void_icon(args, x, y, size, color)
  end
end
```

**Step 4**: Use in rituals

```ruby
VOID_RITUAL = create_ritual(
  name: "Embrace the Void",
  description: "Channel the emptiness.",
  sequence: [:void, :void, :shadow],
  fault_tolerance: :strict,
  difficulty: 7
)
```

### Adding Middleware (Not Currently Used But Supported)

EventChains supports middleware for cross-cutting concerns. Here's how to add logging:

```ruby
chain = EventChain.strict

# Add logging middleware
chain.use_middleware do |next_handler|
  ->(event, context) {
    puts "Starting: #{event.class.name}"
    start_time = Time.now
    
    result = next_handler.call(event, context)
    
    duration = Time.now - start_time
    puts "Completed: #{event.class.name} in #{duration}s"
    
    result
  }
end

chain.add_event(SomeEvent.new)
chain.execute
```

**Potential Use Cases**:
- **Timing Middleware** - Measure event execution time
- **Logging Middleware** - Debug event execution
- **Validation Middleware** - Pre-validate context before events
- **Retry Middleware** - Retry failed events
- **Caching Middleware** - Cache event results

## ⚡ Performance Considerations

### Current Performance

Ritual Keeper runs at **60 FPS** consistently on modern hardware.

### Optimization Points

**1. Particle System**

```ruby
# Efficient particle cleanup
args.state.particles.reject! { |p| p.dead? }

# Limit particle count
MAX_PARTICLES = 500
if args.state.particles.length > MAX_PARTICLES
  args.state.particles.shift(args.state.particles.length - MAX_PARTICLES)
end
```

**2. QTE Calculations**

```ruby
# Calculate once, reuse
@qte_window = calculate_qte_window(@ritual_def[:difficulty])

# Cache node positions (done during initialization)
@nodes = initialize_node_positions()
```

**3. Rendering Optimizations**

```ruby
# Only render visible elements
if node_visible?(node)
  draw_ritual_node(args, node)
end

# Batch similar primitives
all_borders = []
nodes.each do |node|
  all_borders << create_border_for(node)
end
args.outputs.borders << all_borders
```

**4. Context Access**

```ruby
# Direct hash access is fast
context[:energy] = 100

# Avoid repeated lookups in hot paths
energy = context[:energy]  # Cache locally
energy -= 10
energy += 5
context[:energy] = energy  # Write back once
```

### Memory Management

DragonRuby's garbage collector handles memory automatically, but follow these practices:

- **Reuse objects when possible** - Particle pooling could reduce allocations
- **Clear unused data** - Remove completed rituals from memory
- **Avoid creating temporary objects in render loop** - Pre-allocate where possible

## 🧪 Testing Strategy

### Unit Testing Events

Test individual events in isolation:

```ruby
# Test InitializeRitualEvent
def test_initialize_ritual_event
  context = EventContext.new
  context[:args] = mock_args
  context[:ritual] = TEST_RITUAL_DEF
  
  event = InitializeRitualEvent.new
  result = event.execute(context)
  
  assert result.success?
  assert_equal 100, context[:energy]
  assert_equal 100, context[:focus]
  assert_equal 8, context[:nodes].length
end
```

### Integration Testing Chains

Test complete ritual flows:

```ruby
def test_ritual_initialization_chain
  chain = EventChain.strict
  chain.add_event(InitializeRitualEvent.new)
  
  chain.context[:args] = mock_args
  chain.context[:ritual] = SIMPLE_FLAME
  
  result = chain.execute
  
  assert result.success?
  assert_not_nil result.data[:nodes]
end
```

### Manual Testing Checklist

- [ ] All rituals load without errors
- [ ] QTE timing feels appropriate for each difficulty
- [ ] Clicking correct nodes advances ritual
- [ ] Clicking wrong nodes triggers failure (in strict mode)
- [ ] QTE timeout triggers failure
- [ ] Score calculation is correct
- [ ] Particles spawn on all events
- [ ] UI updates correctly during gameplay
- [ ] Scene transitions work smoothly
- [ ] Keyboard shortcuts work (1-8, arrows, ESC)

### Debug Mode

Enable debug info by setting:

```ruby
$gtk.args.state.debug_mode = true
```

This shows:
- FPS counter
- Tick count
- Particle count
- QTE state details

## 🔍 Common Patterns

### Pattern 1: State Machine

The `ActiveRitual` class uses a state machine:

```ruby
def update(args)
  case @state
  when :waiting_for_input
    handle_player_input(args)
    check_qte_timeout
  when :qte_delay
    # Pause between QTEs
  when :completing
    # Handle completion
  end
end
```

**Benefits**:
- Clear state transitions
- Easy to debug
- Prevents invalid states

### Pattern 2: Data-Driven Design

Rituals are defined as data, not code:

```ruby
# Good: Data-driven
RITUAL = create_ritual(
  sequence: [:fire, :water],
  difficulty: 3
)

# Bad: Hard-coded
def execute_ritual
  activate_fire_node
  activate_water_node
end
```

**Benefits**:
- Easy to add new rituals
- No code changes needed
- Can load from files in future

### Pattern 3: Event-Based Architecture

Actions flow through discrete events:

```ruby
# Good: Event-based
chain.add_event(InitializeRitualEvent.new)
chain.execute

# Bad: Procedural
def initialize_ritual
  create_nodes
  set_energy
  set_focus
  # ... 50 more lines
end
```

**Benefits**:
- Testable in isolation
- Reusable events
- Clear dependencies

### Pattern 4: Functional Helpers

Many helpers are pure functions:

```ruby
# Pure function - no side effects
def circle_position(center_x, center_y, radius, angle)
  {
    x: center_x + Math.cos(angle) * radius,
    y: center_y + Math.sin(angle) * radius
  }
end
```

**Benefits**:
- Easy to test
- Easy to understand
- Reusable anywhere

## 🐛 Troubleshooting

### Common Issues

**Issue**: Ritual fails to initialize

**Cause**: Missing required context keys

**Solution**: Ensure all required keys are set:
```ruby
chain.context[:args] = args
chain.context[:ritual] = ritual_def
```

---

**Issue**: QTE not spawning

**Cause**: No nodes match required element

**Solution**: Verify ritual sequence matches available elements:
```ruby
sequence = [:fire, :water]  # Must have fire and water nodes
```

---

**Issue**: Particles not appearing

**Cause**: Particles array not initialized

**Solution**: Initialize in `initialize_game()`:
```ruby
args.state.particles ||= []
```

---

**Issue**: Wrong node count in circle

**Cause**: `RITUAL_CIRCLE[:max_nodes]` mismatch

**Solution**: Ensure `max_nodes` matches element count:
```ruby
RITUAL_CIRCLE = {
  max_nodes: 8  # Must equal number of elements
}
```

---

**Issue**: Score is 0

**Cause**: Ritual failed before completion

**Solution**: Check `failed_qtes` count and fault tolerance mode

### Debugging Tips

**1. Enable Debug Mode**

```ruby
$gtk.args.state.debug_mode = true
```

**2. Add Logging to Events**

```ruby
def execute(context)
  puts "Executing #{self.class.name}"
  puts "Context: #{context.to_h}"
  # ... event logic
end
```

**3. Inspect QTE State**

```ruby
puts "QTE: #{@current_qte.inspect}"
puts "Progress: #{qte_progress}"
puts "Window: #{@qte_window}"
```

**4. Watch Context Changes**

```ruby
before_energy = context[:energy]
# ... operation
after_energy = context[:energy]
puts "Energy: #{before_energy} -> #{after_energy}"
```

## 📚 Additional Resources

### DragonRuby Documentation

- [DragonRuby Docs](https://docs.dragonruby.org/)
- [DragonRuby Discord](https://discord.dragonruby.org/)

### EventChains Pattern

- [EventChains Deep Dive](../EVENTCHAINS_DEEP_DIVE.md)
- [Ruby Implementation](https://github.com/RPDevJesco/EventChains-Ruby)
- [C# Implementation](https://github.com/RPDevJesco/EventChains-CS)

### Game Design References

- [Game Programming Patterns](https://gameprogrammingpatterns.com/)
- [Ruby Best Practices](https://rubystyle.guide/)

## 🎯 Next Steps

### For New Contributors

1. **Read the EventChains Deep Dive** - Understand the core pattern
2. **Run the game** - Play through all rituals
3. **Enable debug mode** - See what's happening under the hood
4. **Create a test ritual** - Add a simple 2-3 element ritual
5. **Add a new element** - Follow the "Adding a New Element" guide
6. **Experiment with timing** - Try different difficulty levels

### Potential Features to Implement

1. **Combo System** - Bonus for consecutive perfect QTEs
2. **Ritual Variations** - Same sequence, different timing patterns
3. **Rhythm Mode** - QTEs spawn at regular intervals
4. **Visual Customization** - Different themes/skins
5. **Achievement System** - Track player accomplishments
6. **Replay System** - Watch recorded perfect runs
7. **Custom Rituals** - Let players create and share
8. **Multiplayer** - Competitive or cooperative modes

## 📝 Code Style Guide

### Ruby Conventions

```ruby
# Class names: PascalCase
class ActiveRitual
end

# Module names: PascalCase
module RitualDefinitions
end

# Method names: snake_case
def initialize_ritual
end

# Constants: SCREAMING_SNAKE_CASE
MAX_NODES = 8

# Instance variables: @snake_case
@current_step = 0

# Local variables: snake_case
ritual_def = {}
```

### Commenting

```ruby
# ===================================================================
# SECTION HEADER (for major sections)
# ===================================================================

# Describe what the method does (for complex logic)
def complex_method
  # Explain non-obvious steps
  result = complicated_calculation()
  
  # Why we're doing this
  result *= 2  # Double for display scaling
  
  result
end
```

### Organization

- **Group related functions** - Keep helpers near their usage
- **Order by usage** - Put initialization first, cleanup last
- **Separate concerns** - Don't mix rendering with game logic
- **Keep functions short** - Aim for < 20 lines

## 🏁 Conclusion

Ritual Keeper demonstrates how the EventChains pattern can structure a real game's architecture. The pattern provides:

- **Clear organization** through event-based workflows
- **Easy testing** through isolated events
- **Simple extension** through data-driven design
- **Maintainable code** through separation of concerns

The QTE system shows how game-specific logic (timing, input handling) integrates naturally with the pattern while keeping the benefits of the architectural approach.

Whether you're building a game, a web application, or any sequential workflow system, EventChains provides a solid foundation that scales from simple sequences to complex, multi-step processes.

---
