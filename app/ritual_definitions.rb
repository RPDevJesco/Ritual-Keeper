# ===================================================================
# RITUAL KEEPER - Ritual Definitions (QTE Edition)
# ===================================================================
# Defines all available rituals in the game
# Difficulty now determines QTE timing windows instead of unlock level
# ===================================================================

module RitualDefinitions
  # ===================================================================
  # RITUAL TEMPLATE
  # ===================================================================

  def self.create_ritual(name:, description:, sequence:, fault_tolerance:, difficulty:)
    {
      name: name,
      description: description,
      sequence: sequence,  # Array of element types
      fault_tolerance: fault_tolerance,
      difficulty: difficulty, # 1-10: affects QTE timing window
      steps: sequence.length
    }
  end

  # ===================================================================
  # BEGINNER RITUALS (Difficulty 1-2)
  # Generous timing windows, perfect for learning
  # ===================================================================

  SIMPLE_FLAME = create_ritual(
    name: "Simple Flame",
    description: "Light a small fire. The most basic ritual. [Easy timing]",
    sequence: [:fire],
    fault_tolerance: :lenient,
    difficulty: 1
  )

  CLEANSING_WATERS = create_ritual(
    name: "Cleansing Waters",
    description: "Purify with fire and water. [Easy timing]",
    sequence: [:fire, :water],
    fault_tolerance: :lenient,
    difficulty: 1
  )

  ELEMENTAL_BALANCE = create_ritual(
    name: "Elemental Balance",
    description: "Balance the four basic elements. [Moderate timing]",
    sequence: [:fire, :water, :earth, :air],
    fault_tolerance: :lenient,
    difficulty: 2
  )

  # ===================================================================
  # INTERMEDIATE RITUALS (Difficulty 3-5)
  # Tighter timing, more steps to complete
  # ===================================================================

  MOONLIT_BLESSING = create_ritual(
    name: "Moonlit Blessing",
    description: "Call upon the moon's gentle power. [Strict mode, moderate timing]",
    sequence: [:water, :air, :moon],
    fault_tolerance: :strict,
    difficulty: 3
  )

  SOLAR_INVOCATION = create_ritual(
    name: "Solar Invocation",
    description: "Invoke the sun's radiant energy. [Strict mode, moderate timing]",
    sequence: [:fire, :air, :sun],
    fault_tolerance: :strict,
    difficulty: 3
  )

  EARTH_AND_SKY = create_ritual(
    name: "Earth and Sky",
    description: "Unite the ground below and heavens above. [Moderate timing]",
    sequence: [:earth, :air, :moon, :sun],
    fault_tolerance: :lenient,
    difficulty: 4
  )

  CYCLE_OF_SEASONS = create_ritual(
    name: "Cycle of Seasons",
    description: "Represent the eternal cycle of nature. [Moderate timing]",
    sequence: [:earth, :water, :fire, :air, :earth],
    fault_tolerance: :lenient,
    difficulty: 4
  )

  # ===================================================================
  # ADVANCED RITUALS (Difficulty 6-7)
  # Fast timing required, strict failure conditions
  # ===================================================================

  SHADOW_BINDING = create_ritual(
    name: "Shadow Binding",
    description: "Bind the shadows. Fast timing required! [Strict mode]",
    sequence: [:moon, :shadow, :shadow, :moon],
    fault_tolerance: :strict,
    difficulty: 5
  )

  LIGHT_REVELATION = create_ritual(
    name: "Light Revelation",
    description: "Reveal hidden truths. Fast timing required! [Strict mode]",
    sequence: [:sun, :light, :light, :sun],
    fault_tolerance: :strict,
    difficulty: 5
  )

  CELESTIAL_ALIGNMENT = create_ritual(
    name: "Celestial Alignment",
    description: "Align the celestial bodies. Very fast timing! [Strict mode]",
    sequence: [:moon, :sun, :moon, :sun, :moon, :sun],
    fault_tolerance: :strict,
    difficulty: 7
  )

  TWILIGHT_RITUAL = create_ritual(
    name: "Twilight Ritual",
    description: "Balance light and shadow. Very fast timing! [Strict mode]",
    sequence: [:light, :shadow, :light, :shadow, :light, :shadow],
    fault_tolerance: :strict,
    difficulty: 7
  )

  # ===================================================================
  # MASTER RITUAL (Difficulty 10)
  # Extreme timing challenge - for true masters only
  # ===================================================================

  GRAND_SUMMONING = create_ritual(
    name: "Grand Summoning",
    description: "The ultimate ritual. All elements in harmony. EXTREME TIMING! [Strict mode]",
    sequence: [:fire, :water, :earth, :air, :moon, :sun, :shadow, :light],
    fault_tolerance: :strict,
    difficulty: 10
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
    CYCLE_OF_SEASONS,
    SHADOW_BINDING,
    LIGHT_REVELATION,
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

puts "✓ Ritual definitions loaded (#{RitualDefinitions::ALL_RITUALS.length} rituals) [QTE Edition]"
