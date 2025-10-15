# 🕯️ RITUAL KEEPER

## 🎮 What Is This?

**Ritual Keeper** is a complete, playable game built with **DragonRuby Game Toolkit** that showcases the **EventChains design pattern** in action. It's both a fun puzzle game AND an educational reference implementation.

---

## ✨ Key Features

### As a Game
- ⚡ **12 unique rituals** from beginner to master difficulty
- 🎨 **100% primitive graphics** - no sprite assets needed
- 🌊 **Particle effects** for visual flair
- 📊 **Progression system** with leveling and unlocks
- 🎯 **Multiple difficulty modes** (STRICT vs LENIENT)
- 🎮 **Full controller support**
- 💾 **~3,500 lines** of well-commented, educational code

### As a Learning Tool
- 📚 **Clean EventChains implementation** showing real-world usage
- 🔬 **Multiple event types** demonstrating pattern flexibility
- 🛠️ **Fault tolerance modes** in actual gameplay
- 🧪 **Testable architecture** with separated concerns
- 📖 **Extensive documentation** (3 docs totaling 1,200+ lines)
- 🎓 **Teaching comments** throughout the codebase

---

## 📁 Complete File Structure

```
ritual_keeper/
│
├── app/                            Main game code
│   ├── main.rb                    (200 lines)  - Game loop & entry point
│   ├── event_chains.rb            (220 lines)  - EventChains pattern core
│   ├── constants.rb               (180 lines)  - Configuration & colors
│   ├── primitives_helper.rb       (380 lines)  - Drawing functions
│   ├── particle_system.rb         (150 lines)  - Particle effects
│   ├── ritual_events.rb           (320 lines)  - Event implementations
│   ├── ritual_definitions.rb      (180 lines)  - Ritual data
│   ├── game_state.rb              (380 lines)  - State management
│   ├── input_handler.rb           ( 70 lines)  - Input utilities
│   └── renderer.rb                (520 lines)  - All rendering code
│
├── data/                           (Empty - for future expansion)
├── sprites/                        (Empty - primitives only!)
├── sounds/                         (Empty - for future expansion)
└── fonts/                          (Empty - uses default)
```

---

## 🎯 What Makes It Special?

### 1. Educational Value

**Perfect for learning:**
- EventChains design pattern
- DragonRuby game development
- State management in games
- Primitive-based rendering
- Game architecture patterns

**Well-documented:**
- Every file has clear comments
- Complex logic explained inline
- Three comprehensive guides
- Code examples throughout

### 2. Production Quality

**Complete features:**
- Multiple game scenes
- Progression system
- Visual feedback
- Error handling
- Debug mode

**Clean code:**
- Separated concerns
- DRY principles
- Testable architecture
- Consistent style

### 3. Extensibility

**Easy to modify:**
- Add new rituals (just data!)
- Create new elements
- Implement new events
- Add middleware
- Customize visuals

**Documented extension points:**
- `ritual_definitions.rb` - Add rituals
- `constants.rb` - Tweak gameplay
- `ritual_events.rb` - New event types
- `primitives_helper.rb` - Visual style

---

## 🚀 How to Use This Project

### As a Player
1. Install DragonRuby GTK
2. Copy `ritual_keeper` to `mygame`
3. Run and play!
4. Master all 12 rituals

### As a Student
1. Read `QUICK_START.md` first
2. Play the game to understand mechanics
3. Read `TECHNICAL_DEEP_DIVE.md` for pattern details
4. Study the code files in order:
   - `event_chains.rb` (the pattern)
   - `ritual_events.rb` (events)
   - `ritual_definitions.rb` (composition)
   - `game_state.rb` (integration)
5. Experiment with modifications

### As a Developer
1. Use as reference implementation
2. Copy and adapt EventChains for your game
3. Learn primitive rendering techniques
4. Study scene management approach
5. Build your own game!

---

## 📊 Technical Stats

### Code Metrics
- **Total Lines**: ~3,800 (code + docs)
- **Ruby Files**: 10
- **Events**: 6 types
- **Rituals**: 12 unique
- **Elements**: 8 types
- **Scenes**: 4 (menu, select, gameplay, results)
- **Functions**: ~60+
- **Classes**: ~15

### Game Content
- **Difficulty Levels**: 1-10
- **Player Levels**: Unlimited (every 1000 points)
- **Fault Tolerance Modes**: 2 (strict, lenient)
- **Resource Types**: 2 (energy, focus)
- **Node Types**: 8 (one per element)
- **Particle Types**: 4 (activation, flow, success, failure)
- **Color Palettes**: 1 dark theme + 8 element colors

---

## 🎓 Learning Objectives Met

### EventChains Pattern
✅ Context flow between events
✅ Sequential execution
✅ Fault tolerance modes
✅ Event composition
✅ Middleware support (ready)
✅ Error handling
✅ Result types

### Game Development
✅ Game loop structure
✅ Scene management
✅ State persistence
✅ Input handling
✅ Rendering systems
✅ Particle effects
✅ Progression systems

### DragonRuby
✅ Primitive rendering
✅ State management (args.state)
✅ Input handling (keyboard + controller)
✅ Hot reload workflow
✅ Performance optimization
✅ Debug console usage

---

## 🎨 Visual Design Philosophy

**"Mystical Minimalism"**

Using only primitive shapes, we created:
- Sacred geometry patterns
- Glowing ritual circles
- Elemental icons
- Energy flow effects
- Particle magic

**No sprites required!** Everything is:
- `args.outputs.solids` - Filled rectangles
- `args.outputs.borders` - Rectangle outlines
- `args.outputs.lines` - Connecting lines
- `args.outputs.labels` - Text
- Math for circles/animations

---

## 🔧 Extensibility Examples

### Add a New Ritual (5 minutes)

```ruby
# In ritual_definitions.rb
COSMIC_ALIGNMENT = create_ritual(
  name: "Cosmic Alignment",
  description: "Align the cosmic forces.",
  sequence: [:sun, :moon, :light, :shadow],
  fault_tolerance: :strict,
  difficulty: 6,
  unlock_level: 7
)

# Add to ALL_RITUALS array
ALL_RITUALS = [
  # ... existing rituals
  COSMIC_ALIGNMENT
]
```

Done! The ritual is now playable.

### Add a New Element (15 minutes)

```ruby
# 1. In constants.rb
ELEMENTS = {
  # ... existing elements
  void: {
    name: "Void",
    color: { r: 30, g: 10, b: 50 },
    symbol: "◯",
    unlock_level: 10,
    description: "The element of nothingness"
  }
}

# 2. In primitives_helper.rb
def draw_void_icon(args, x, y, size = 15, color = nil)
  color ||= Constants::COLORS[:void]
  
  # Empty circle (just border)
  args.outputs.borders << {
    x: x - size, y: y - size,
    w: size * 2, h: size * 2,
    r: color[:r], g: color[:g], b: color[:b]
  }
end

# 3. Add case to draw_element_icon
when :void
  draw_void_icon(args, x, y, size, color)
```

Now you can use `:void` in ritual sequences!

### Add Middleware (20 minutes)

```ruby
# Create new middleware
class ScoreMultiplierMiddleware
  def initialize(multiplier)
    @multiplier = multiplier
  end
  
  def call(next_step)
    ->(event, context) do
      result = next_step.call(event, context)
      
      if result.success? && context[:score]
        context[:score] *= @multiplier
      end
      
      result
    end
  end
end

# Use in game_state.rb
chain.use_middleware(&ScoreMultiplierMiddleware.new(1.5).method(:call))
```

All events now get a score multiplier!

---

## 📞 Resources

- **DragonRuby**: https://dragonruby.org
- **DragonRuby Discord**: https://discord.dragonruby.org
- **DragonRuby Docs**: https://docs.dragonruby.org
- **EventChains Deep Dive**: https://github.com/RPDevJesco/EventChains-DragonRuby

---
