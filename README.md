# 🕯️ Ritual Keeper

A mystical puzzle game where you perform ancient rituals by activating elemental nodes in a precise sequence. Test your reflexes and timing in this Quick Time Event (QTE) challenge!

## 🎮 What is Ritual Keeper?

Ritual Keeper is a rhythm-puzzle game that combines strategic thinking with quick reflexes. As a keeper of ancient rituals, you must activate elemental nodes arranged in a mystical circle, following specific sequences while racing against time.

Each ritual requires you to click on glowing nodes at the right moment. Miss the timing window, and you'll fail the ritual. Master your reflexes to complete increasingly challenging rituals and prove yourself as a true Ritual Keeper!

## ✨ Features

- **12 Unique Rituals** - From simple beginner rituals to extreme master challenges
- **8 Mystical Elements** - Fire, Water, Earth, Air, Moon, Sun, Shadow, and Light
- **Dynamic Difficulty** - Rituals range from generous timing windows to frame-perfect precision
- **QTE Mechanics** - Fast-paced Quick Time Events test your reflexes
- **Beautiful Particle Effects** - Satisfying visual feedback for every action
- **Progressive Challenge** - All rituals unlocked from start, but can you master them all?
- **Scoring System** - Compete for perfect scores with accuracy and speed bonuses

## 🎯 How to Play

### Basic Controls

- **Mouse Click** - Click on glowing nodes to activate them
- **Keyboard (1-8)** - Quick-select nodes by number
- **Arrow Keys (↑↓)** - Navigate ritual selection
- **SPACE/ENTER** - Confirm selection, continue
- **ESC** - Go back, quit ritual

### Gameplay Loop

1. **Select a Ritual** - Choose from 12 available rituals
2. **Watch for the Glow** - A node will light up with a shrinking ring
3. **Click in Time** - Click the glowing node before the timer expires
4. **Chain Success** - Complete the entire sequence without missing
5. **Earn Your Score** - Perfect timing and accuracy yield higher scores

### Understanding the Ritual Circle

The ritual circle displays 8 nodes arranged in a circle, each representing one of the mystical elements:

- **🔥 Fire** (Red Triangle) - Element of passion and transformation
- **💧 Water** (Blue Inverted Triangle) - Element of flow and purification
- **🌍 Earth** (Brown Square) - Element of stability and growth
- **💨 Air** (Cyan Circle) - Element of thought and breath
- **🌙 Moon** (Silver Crescent) - Celestial force of mystery
- **☀️ Sun** (Gold Star) - Celestial force of vitality
- **🌑 Shadow** (Purple Diamond) - Hidden element of secrets
- **✨ Light** (White Star) - Divine element of clarity

### Timing Windows

Each ritual has a difficulty rating that determines how long you have to respond:

- **Difficulty 1-2** (★★) - Easy timing, perfect for learning (2+ seconds)
- **Difficulty 3-5** (★★★★★) - Moderate timing, requires focus (~1.5 seconds)
- **Difficulty 6-7** (★★★★★★★) - Fast timing, tests your reflexes (~1 second)
- **Difficulty 10** (★★★★★★★★★★) - EXTREME timing, for masters only! (0.5 seconds)

### Fault Tolerance Modes

Rituals have different failure conditions:

- **LENIENT** - You can miss up to 3 times before failing
- **STRICT** - One miss and the ritual fails immediately

## 📊 Scoring System

Your score is calculated based on multiple factors:

- **Base Score**: 100 points
- **Accuracy Bonus**: Up to 100 points based on hit/miss ratio
- **Speed Bonus**: Extra points for fast reactions to each QTE
- **Perfect Bonus**: 50 bonus points for completing without any misses
- **Difficulty Multiplier**: Higher difficulty rituals multiply your final score

**Pro Tip**: For the highest scores, aim for perfect accuracy with lightning-fast reactions on the hardest rituals!

## 🎓 The Rituals

### Beginner Rituals (★-★★)

**Simple Flame**
- Single fire node activation
- Perfect introduction to the mechanics
- Lenient timing

**Cleansing Waters**
- Fire followed by Water
- Practice element transitions
- Lenient timing

**Elemental Balance**
- All four basic elements in sequence
- First real test of coordination
- Moderate timing

### Intermediate Rituals (★★★-★★★★★)

**Moonlit Blessing**
- Water, Air, Moon sequence
- Introduces celestial elements
- Strict mode - no mistakes allowed!

**Solar Invocation**
- Fire, Air, Sun sequence
- Balance speed with precision
- Strict mode

**Earth and Sky**
- Four-element celestial ritual
- Tests pattern recognition
- Moderate timing, lenient mode

**Cycle of Seasons**
- Five-step elemental cycle
- Longer sequences require focus
- Moderate timing

### Advanced Rituals (★★★★★-★★★★★★★)

**Shadow Binding**
- Dual shadow manipulation
- Fast timing required
- Strict mode - masters only

**Light Revelation**
- Dual light channeling
- Speed and precision critical
- Strict mode

**Celestial Alignment**
- Six-step alternating ritual
- Very fast timing
- Tests rhythm and reflexes

**Twilight Ritual**
- Light and shadow balance
- Extreme precision needed
- Very fast, strict mode

### Master Ritual (★★★★★★★★★★)

**Grand Summoning**
- All eight elements in harmony
- The ultimate challenge
- EXTREME timing windows
- One mistake means failure
- Only for true masters!

## 💡 Tips for Success

1. **Start Easy** - Master the beginner rituals before attempting harder ones
2. **Learn the Patterns** - Memorize element sequences to anticipate the next node
3. **Watch the Visual Cues** - The shrinking ring shows your remaining time
4. **Stay Calm** - Panic leads to mistakes; maintain your focus
5. **Use Keyboard Shortcuts** - Number keys (1-8) can be faster than clicking
6. **Practice Strict Mode** - Even if a ritual is lenient, try for perfect runs
7. **Study the Circle** - Know where each element is positioned before starting
8. **Aim for the Center** - Clicking near the node center is most reliable

## 🏆 Achievements to Chase

While not tracked in-game, challenge yourself with these goals:

- **Novice Keeper** - Complete all beginner rituals
- **Ritual Adept** - Complete all intermediate rituals
- **Shadow Master** - Perfect score on Shadow Binding
- **Light Bearer** - Perfect score on Light Revelation
- **Celestial Sage** - Complete Celestial Alignment without mistakes
- **Twilight Walker** - Perfect score on Twilight Ritual
- **Grand Master** - Complete Grand Summoning
- **Perfectionist** - Achieve perfect scores on all 12 rituals
- **Speed Demon** - Complete any ritual with maximum speed bonus
- **True Keeper** - Perfect score on Grand Summoning

## 🛠️ Technical Requirements

- **Platform**: DragonRuby Game Toolkit
- **Resolution**: 1280x720
- **Input**: Mouse, Keyboard, or Game Controller
- **Performance**: Runs at 60 FPS

## 📖 Game Design Philosophy

Ritual Keeper is built on the **EventChains design pattern**, which structures the game's ritual system as a series of composable events with middleware for cross-cutting concerns. This architecture makes the game:

- **Modular** - Easy to add new rituals and elements
- **Maintainable** - Clear separation between game logic and infrastructure
- **Testable** - Individual components can be tested in isolation
- **Extensible** - New features integrate naturally into the existing system

For developers interested in the technical implementation, see `DEVELOPER_README.md`.

## 🎨 Visual Design

Ritual Keeper uses a minimalist aesthetic with:

- **Dark mystical background** with subtle grid patterns
- **Color-coded elements** for instant recognition
- **Particle effects** that respond to player actions
- **Pulsing animations** for active game elements
- **Clean UI** that doesn't distract from gameplay

## 🔊 Audio

Currently, Ritual Keeper is a visual experience. Audio features are planned for future updates:

- Ambient mystical music
- Element-specific activation sounds
- Success and failure audio feedback
- Timing tick sounds for challenging rituals

## 🚀 Future Plans

Potential features for future versions:

- **Leaderboards** - Compare scores with other players
- **Custom Rituals** - Create and share your own sequences
- **Multiplayer** - Competitive and cooperative modes
- **More Elements** - Expand beyond the current eight
- **Story Mode** - Discover the lore behind the rituals
- **Challenge Mode** - Special conditions and modifiers
- **Accessibility Options** - Customizable timing windows and visual assists

## 🤝 Credits

**Game Design & Programming**: RPDevJesco (GameDevMadeEasy)

**Built With**: DragonRuby Game Toolkit

**Design Pattern**: EventChains (created by Jesse Glover)

## 📄 License

This game is provided as a demonstration of the EventChains design pattern and DragonRuby game development.
