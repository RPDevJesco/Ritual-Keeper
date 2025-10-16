# ===================================================================
# RITUAL KEEPER - Game State Manager (QTE Edition)
# ===================================================================

class GameState
  attr_accessor :current_scene, :selected_ritual_index, :current_ritual,
                :player_level, :completed_rituals, :total_score

  def initialize(args)
    @args = args
    @current_scene = :menu
    @player_level = 1
    @completed_rituals = []
    @total_score = 0
    @selected_ritual_index = 0
    @current_ritual = nil
    @scene_transition_time = 0
    @transitioning = false
  end

  # ===================================================================
  # AVAILABLE RITUALS
  # ===================================================================

  def available_rituals
    # ALL RITUALS AVAILABLE FROM START - No level gating!
    RitualDefinitions::ALL_RITUALS
  end

  # ===================================================================
  # SCENE TRANSITIONS
  # ===================================================================

  def transition_to(scene)
    @current_scene = scene
    @transitioning = true
    @scene_transition_time = @args.tick_count

    # Scene-specific setup
    case scene
    when :menu
      @current_ritual = nil
    when :ritual_select
      @selected_ritual_index = 0
    when :gameplay
      # Ritual setup happens in start_ritual
    when :results
      # Results are already set up
    end
  end

  def transitioning?
    @transitioning && (@args.tick_count - @scene_transition_time) < Constants::TIMING[:fade_in_time]
  end

  # ===================================================================
  # RITUAL MANAGEMENT
  # ===================================================================

  def start_ritual(ritual_def)
    @current_ritual = ActiveRitual.new(@args, ritual_def)
    transition_to(:gameplay)
  end

  def complete_ritual
    if @current_ritual
      score = @current_ritual.score
      @total_score += score
      @completed_rituals << @current_ritual.ritual_def[:name]

      # Level up check (every 1000 points)
      new_level = (@total_score / 1000) + 1
      if new_level > @player_level
        @player_level = new_level
      end

      @result_data = {
        success: true,
        score: score,
        time: @current_ritual.completion_time,
        perfect: @current_ritual.perfect?,
        ritual_name: @current_ritual.ritual_def[:name],
        hits: @current_ritual.successful_qtes,
        misses: @current_ritual.failed_qtes
      }
    end

    transition_to(:results)
  end

  def fail_ritual
    @result_data = {
      success: false,
      score: 0,
      ritual_name: @current_ritual&.ritual_def&.[](:name) || "Unknown",
      hits: @current_ritual&.successful_qtes || 0,
      misses: @current_ritual&.failed_qtes || 0
    }
    transition_to(:results)
  end

  def result_data
    @result_data || {}
  end
end

# ===================================================================
# ACTIVE RITUAL - QTE-Based Ritual System
# ===================================================================

class ActiveRitual
  attr_reader :ritual_def, :chain, :context, :state, :nodes,
              :current_step, :score, :completion_time,
              :successful_qtes, :failed_qtes, :current_qte

  def initialize(args, ritual_def)
    @args = args
    @ritual_def = ritual_def
    @state = :initializing
    @current_step = 0
    @start_time = args.tick_count
    @completion_time = 0
    @successful_qtes = 0
    @failed_qtes = 0
    @current_qte = nil

    # QTE timing based on difficulty
    @qte_window = calculate_qte_window(ritual_def[:difficulty])

    # Create event chain based on fault tolerance
    @chain = case ritual_def[:fault_tolerance]
             when :strict
               EventChain.strict
             when :lenient
               EventChain.lenient
             when :best_effort
               EventChain.best_effort
             else
               EventChain.lenient
             end

    # Set up failure handler
    @chain.on_failure do |event, error|
      puts "⚠️  Ritual event failed: #{event.class.name} - #{error}"
    end

    # Initialize the ritual
    initialize_ritual
  end

  # ===================================================================
  # QTE TIMING CALCULATION
  # ===================================================================

  def calculate_qte_window(difficulty)
    # Difficulty 1-10, with stricter timing for higher difficulties
    base_window = 120 # frames (2 seconds)
    reduction = (difficulty - 1) * 8
    [base_window - reduction, 30].max # Minimum 0.5 seconds
  end

  # ===================================================================
  # INITIALIZATION
  # ===================================================================

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
      puts "❌ Failed to initialize ritual: #{result.failures.first&.error_message}"
    end
  end

  # ===================================================================
  # QTE SYSTEM
  # ===================================================================

  def spawn_next_qte
    return if @current_step >= @ritual_def[:sequence].length

    # Get the required element for this step
    required_element = @ritual_def[:sequence][@current_step]

    # Find all nodes with this element (there should be at least one)
    matching_nodes = @nodes.select { |_, node| node[:element] == required_element }

    if matching_nodes.empty?
      puts "⚠️  No nodes found for element #{required_element}"
      @state = :failed
      return
    end

    # Pick a random matching node
    node_id = matching_nodes.keys.sample

    @current_qte = {
      node_id: node_id,
      element: required_element,
      spawn_time: @args.tick_count,
      window: @qte_window,
      state: :active
    }

    @nodes[node_id][:state] = :pending
    @state = :waiting_for_input
  end

  def check_qte_timeout
    return unless @current_qte && @current_qte[:state] == :active

    elapsed = @args.tick_count - @current_qte[:spawn_time]

    if elapsed >= @current_qte[:window]
      # Timeout! QTE failed
      fail_current_qte
    end
  end

  def attempt_qte(node_id)
    return unless @current_qte && @current_qte[:state] == :active

    if node_id == @current_qte[:node_id]
      # Correct node clicked in time!
      complete_current_qte
    else
      # Wrong node clicked
      fail_current_qte
    end
  end

  def complete_current_qte
    return unless @current_qte

    node = @nodes[@current_qte[:node_id]]
    node[:state] = :completed
    @successful_qtes += 1
    @current_step += 1

    # Calculate time bonus based on how fast they clicked
    elapsed = @args.tick_count - @current_qte[:spawn_time]
    speed_ratio = 1.0 - (elapsed.to_f / @current_qte[:window])
    @context[:time_bonus] = (@context[:time_bonus] || 0) + (speed_ratio * 10).to_i

    # Spawn success particles
    spawn_node_activation_particles(
      @args,
      node[:x],
      node[:y],
      Constants::ELEMENTS[node[:element]][:color]
    )

    @current_qte = nil

    # Check if ritual is complete
    if @current_step >= @ritual_def[:sequence].length
      @state = :completing
      check_completion
    else
      # Spawn next QTE after brief delay
      @state = :qte_delay
      @qte_delay_start = @args.tick_count
    end
  end

  def fail_current_qte
    return unless @current_qte

    node = @nodes[@current_qte[:node_id]]
    node[:state] = :failed
    @failed_qtes += 1

    # Spawn failure particles
    spawn_ritual_failure_particles(@args, node[:x], node[:y])

    # Reset node to inactive after brief delay
    @args.state.ritual_reset_nodes ||= []
    @args.state.ritual_reset_nodes << {
      node_id: @current_qte[:node_id],
      reset_at: @args.tick_count + 30
    }

    @current_qte = nil

    # Check failure conditions
    if @ritual_def[:fault_tolerance] == :strict && @failed_qtes > 0
      @state = :failed
    elsif @failed_qtes >= 3 # Maximum 3 failures in lenient mode
      @state = :failed
    else
      # Continue to next QTE
      @state = :qte_delay
      @qte_delay_start = @args.tick_count
    end
  end

  # ===================================================================
  # UPDATE LOOP
  # ===================================================================

  def update(args)
    return if @state == :completed || @state == :failed

    # Handle node reset timers
    if args.state.ritual_reset_nodes
      args.state.ritual_reset_nodes.each do |reset_info|
        if args.tick_count >= reset_info[:reset_at]
          @nodes[reset_info[:node_id]][:state] = :inactive
        end
      end
      args.state.ritual_reset_nodes.reject! { |r| args.tick_count >= r[:reset_at] }
    end

    case @state
    when :waiting_for_input
      handle_player_input(args)
      check_qte_timeout
    when :qte_delay
      # Brief pause between QTEs
      if args.tick_count - @qte_delay_start >= 30
        spawn_next_qte
      end
    when :completing
      # Already handled in complete_current_qte
    end
  end

  # ===================================================================
  # INPUT HANDLING
  # ===================================================================

  def handle_player_input(args)
    # Check if player clicks a node
    if args.inputs.mouse.click
      clicked_node = find_clicked_node(args.inputs.mouse.x, args.inputs.mouse.y)

      if clicked_node
        attempt_qte(clicked_node)
      end
    end

    # Keyboard shortcuts for nodes (1-8)
    number_keys = [:one, :two, :three, :four, :five, :six, :seven, :eight]
    number_keys.each_with_index do |key_name, index|
      if args.inputs.keyboard.key_down.send(key_name)
        node_id = index
        if @nodes[node_id]
          attempt_qte(node_id)
        end
      end
    end
  end

  def find_clicked_node(mouse_x, mouse_y)
    @nodes.each do |id, node|
      dx = node[:x] - mouse_x
      dy = node[:y] - mouse_y
      distance = Math.sqrt(dx * dx + dy * dy)

      if distance < Constants::RITUAL_CIRCLE[:node_size] / 2
        return id
      end
    end
    nil
  end

  # ===================================================================
  # COMPLETION
  # ===================================================================

  def check_completion
    calculate_final_score
    @state = :completed

    # Spawn celebration particles
    spawn_ritual_completion_particles(
      @args,
      Constants::RITUAL_CIRCLE[:center_x],
      Constants::RITUAL_CIRCLE[:center_y]
    )
  end

  def calculate_final_score
    base_score = 100

    # Accuracy bonus
    total_attempts = @successful_qtes + @failed_qtes
    accuracy = @successful_qtes.to_f / [total_attempts, 1].max
    accuracy_bonus = (accuracy * 100).to_i

    # Time bonus (accumulated from fast QTE responses)
    time_bonus = @context[:time_bonus] || 0

    # Perfect bonus (no failures)
    perfect_bonus = perfect? ? Constants::GAMEPLAY[:perfect_bonus] : 0

    # Difficulty multiplier
    difficulty_multiplier = 1.0 + (@ritual_def[:difficulty] * 0.1)

    @completion_time = @args.tick_count - @start_time
    @score = ((base_score + accuracy_bonus + time_bonus + perfect_bonus) * difficulty_multiplier).to_i
  end

  def completed?
    @state == :completed
  end

  def failed?
    @state == :failed
  end

  def perfect?
    @failed_qtes == 0 && completed?
  end

  def qte_progress
    return 0 unless @current_qte && @current_qte[:state] == :active

    elapsed = @args.tick_count - @current_qte[:spawn_time]
    (elapsed.to_f / @current_qte[:window]).clamp(0, 1)
  end
end

puts "✓ Game state loaded (QTE Edition)"
