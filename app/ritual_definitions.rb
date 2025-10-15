# ===================================================================
# RITUAL KEEPER - Ritual Definitions
# ===================================================================
# Defines all available rituals in the game
# ===================================================================

module RitualDefinitions
  # ===================================================================
  # RITUAL TEMPLATE
  # ===================================================================
  
  def self.create_ritual(name:, description:, sequence:, fault_tolerance:, difficulty:, unlock_level: 1)
    {
      name: name,
      description: description,
      sequence: sequence,  # Array of element types
      fault_tolerance: fault_tolerance,
      difficulty: difficulty,
      unlock_level: unlock_level,
      steps: sequence.length
    }
  end
  
  # ===================================================================
  # BEGINNER RITUALS
  # ===================================================================
  
  SIMPLE_FLAME = create_ritual(
    name: "Simple Flame",
    description: "Light a small fire. The most basic ritual.",
    sequence: [:fire],
    fault_tolerance: :lenient,
    difficulty: 1,
    unlock_level: 1
  )
  
  CLEANSING_WATERS = create_ritual(
    name: "Cleansing Waters",
    description: "Purify with fire and water.",
    sequence: [:fire, :water],
    fault_tolerance: :lenient,
    difficulty: 1,
    unlock_level: 1
  )
  
  ELEMENTAL_BALANCE = create_ritual(
    name: "Elemental Balance",
    description: "Balance the four basic elements.",
    sequence: [:fire, :water, :earth, :air],
    fault_tolerance: :lenient,
    difficulty: 2,
    unlock_level: 2
  )
  
  # ===================================================================
  # INTERMEDIATE RITUALS
  # ===================================================================
  
  MOONLIT_BLESSING = create_ritual(
    name: "Moonlit Blessing",
    description: "Call upon the moon's gentle power.",
    sequence: [:water, :air, :moon],
    fault_tolerance: :strict,
    difficulty: 3,
    unlock_level: 3
  )
  
  SOLAR_INVOCATION = create_ritual(
    name: "Solar Invocation",
    description: "Invoke the sun's radiant energy.",
    sequence: [:fire, :air, :sun],
    fault_tolerance: :strict,
    difficulty: 3,
    unlock_level: 4
  )
  
  EARTH_AND_SKY = create_ritual(
    name: "Earth and Sky",
    description: "Unite the ground below and heavens above.",
    sequence: [:earth, :air, :moon, :sun],
    fault_tolerance: :lenient,
    difficulty: 4,
    unlock_level: 5
  )
  
  # ===================================================================
  # ADVANCED RITUALS
  # ===================================================================
  
  SHADOW_BINDING = create_ritual(
    name: "Shadow Binding",
    description: "Bind the shadows. Requires perfect execution.",
    sequence: [:moon, :shadow, :shadow, :moon],
    fault_tolerance: :strict,
    difficulty: 5,
    unlock_level: 6
  )
  
  LIGHT_REVELATION = create_ritual(
    name: "Light Revelation",
    description: "Reveal hidden truths through divine light.",
    sequence: [:sun, :light, :light, :sun],
    fault_tolerance: :strict,
    difficulty: 5,
    unlock_level: 7
  )
  
  CYCLE_OF_SEASONS = create_ritual(
    name: "Cycle of Seasons",
    description: "Represent the eternal cycle of nature.",
    sequence: [:earth, :water, :fire, :air, :earth],
    fault_tolerance: :lenient,
    difficulty: 4,
    unlock_level: 5
  )
  
  # ===================================================================
  # MASTER RITUALS
  # ===================================================================
  
  CELESTIAL_ALIGNMENT = create_ritual(
    name: "Celestial Alignment",
    description: "Align the celestial bodies. Very demanding.",
    sequence: [:moon, :sun, :moon, :sun, :moon, :sun],
    fault_tolerance: :strict,
    difficulty: 7,
    unlock_level: 8
  )
  
  TWILIGHT_RITUAL = create_ritual(
    name: "Twilight Ritual",
    description: "Balance light and shadow at the threshold.",
    sequence: [:light, :shadow, :light, :shadow, :light, :shadow],
    fault_tolerance: :strict,
    difficulty: 7,
    unlock_level: 9
  )
  
  GRAND_SUMMONING = create_ritual(
    name: "Grand Summoning",
    description: "The ultimate ritual. All elements in harmony.",
    sequence: [:fire, :water, :earth, :air, :moon, :sun, :shadow, :light],
    fault_tolerance: :strict,
    difficulty: 10,
    unlock_level: 10
  )
  
  # ===================================================================
  # RITUAL COLLECTION
  # ===================================================================
  
  ALL_RITUALS = [
    SIMPLE_FLAME,
    CLEANSING_WATERS,
    ELEMENTAL_BALANCE,
    MOONLIT_BLESSING,
    SOLAR_INVOCATION,
    EARTH_AND_SKY,
    SHADOW_BINDING,
    LIGHT_REVELATION,
    CYCLE_OF_SEASONS,
    CELESTIAL_ALIGNMENT,
    TWILIGHT_RITUAL,
    GRAND_SUMMONING
  ]
  
  # ===================================================================
  # HELPER METHODS
  # ===================================================================
  
  def self.get_ritual_by_name(name)
    ALL_RITUALS.find { |r| r[:name] == name }
  end
  
  def self.rituals_for_level(level)
    ALL_RITUALS.select { |r| r[:unlock_level] <= level }
  end
  
  def self.beginner_rituals
    ALL_RITUALS.select { |r| r[:difficulty] <= 2 }
  end
  
  def self.intermediate_rituals
    ALL_RITUALS.select { |r| r[:difficulty] >= 3 && r[:difficulty] <= 5 }
  end
  
  def self.advanced_rituals
    ALL_RITUALS.select { |r| r[:difficulty] >= 6 }
  end
end

puts "✓ Ritual definitions loaded (#{RitualDefinitions::ALL_RITUALS.length} rituals)"
