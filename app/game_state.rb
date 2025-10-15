# ===================================================================
# RITUAL KEEPER - Game State Manager
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
    # In debug mode, unlock all rituals
    if Constants::DEBUG[:unlock_all_rituals]
      return RitualDefinitions::ALL_RITUALS
    end

    # Otherwise, only show rituals for current level
    RitualDefinitions.rituals_for_level(@player_level)
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
        ritual_name: @current_ritual.ritual_def[:name]
      }
    end

    transition_to(:results)
  end

  def fail_ritual
    @result_data = {
      success: false,
      score: 0,
      ritual_name: @current_ritual&.ritual_def&.[](:name) || "Unknown"
    }
    transition_to(:results)
  end

  def result_data
    @result_data || {}
  end
end

# ===================================================================
# ACTIVE RITUAL - Manages a ritual in progress
# ===================================================================

class ActiveRitual
  attr_reader :ritual_def, :chain, :context, :state, :nodes,
              :current_step, :score, :completion_time

  def initialize(args, ritual_def)
    @args = args
    @ritual_def = ritual_def
    @state = :initializing
    @current_step = 0
    @start_time = args.tick_count
    @completion_time = 0

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
    else
      @state = :failed
      puts "❌ Failed to initialize ritual: #{result.failures.first&.error_message}"
    end
  end

  def update(args)
    return if @state == :completed || @state == :failed

    case @state
    when :ready
      handle_player_input(args)
    when :channeling
      update_channeling
    when :completing
      check_completion
    end

    # Update energy and focus
    update_resources
  end

  def handle_player_input(args)
    # Check if player clicks a node
    if args.inputs.mouse.click
      clicked_node = find_clicked_node(args.inputs.mouse.x, args.inputs.mouse.y)

      if clicked_node
        activate_node(clicked_node)
      end
    end

    # Keyboard shortcuts for nodes (1-8)
    # DragonRuby uses word names for number keys
    number_keys = [:one, :two, :three, :four, :five, :six, :seven, :eight]
    number_keys.each_with_index do |key_name, index|
      if args.inputs.keyboard.key_down.send(key_name)
        node_id = index
        if @nodes[node_id]
          activate_node(node_id)
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

  def activate_node(node_id)
    node = @nodes[node_id]
    return unless node
    return unless node[:state] == :inactive

    # Check if this is the next correct node
    expected_element = @ritual_def[:sequence][@current_step]

    if node[:element] == expected_element
      # Correct node!
      node[:state] = :active
      @state = :channeling
      @channeling_node = node_id
      @channel_start = @args.tick_count

      # Spawn particles
      spawn_node_activation_particles(
        @args,
        node[:x],
        node[:y],
        Constants::ELEMENTS[node[:element]][:color]
      )

      # Consume energy
      @context[:energy] -= Constants::GAMEPLAY[:energy_per_node]
    else
      # Wrong node!
      @context[:energy] -= 20
      spawn_ritual_failure_particles(@args, node[:x], node[:y])

      if @ritual_def[:fault_tolerance] == :strict
        @state = :failed
      end
    end
  end

  def update_channeling
    return unless @channeling_node

    node = @nodes[@channeling_node]
    elapsed = @args.tick_count - @channel_start
    duration = Constants::TIMING[:node_activation_time]

    node[:progress] = (elapsed / duration.to_f).clamp(0, 1)

    # Spawn energy particles periodically
    if elapsed % 5 == 0
      color = Constants::ELEMENTS[node[:element]][:color]
      spawn_energy_flow_particles(@args, node[:x], node[:y], color)
    end

    # Decay focus while channeling
    @context[:focus] -= Constants::GAMEPLAY[:focus_decay_rate]

    if @context[:focus] <= 0 && @ritual_def[:fault_tolerance] == :strict
      @state = :failed
      return
    end

    # Check if channeling complete
    if elapsed >= duration
      node[:state] = :completed
      @context[:energy] += 5  # Small energy restore
      @current_step += 1

      # Check if ritual is complete
      if @current_step >= @ritual_def[:sequence].length
        @state = :completing
      else
        @state = :ready
      end

      @channeling_node = nil
    end
  end

  def check_completion
    # All nodes completed
    calculate_final_score
    @state = :completed
  end

  def calculate_final_score
    base_score = 100

    # Energy bonus
    energy_bonus = (@context[:energy] / 2).to_i

    # Focus bonus
    focus_bonus = (@context[:focus] / 2).to_i

    # Time bonus
    @completion_time = @args.tick_count - @start_time
    time_bonus = @completion_time < Constants::GAMEPLAY[:speed_bonus_threshold] ? 50 : 0

    # Perfect bonus (no errors)
    perfect_bonus = perfect? ? Constants::GAMEPLAY[:perfect_bonus] : 0

    @score = base_score + energy_bonus + focus_bonus + time_bonus + perfect_bonus
  end

  def update_resources
    # Regenerate energy slowly
    @context[:energy] += Constants::GAMEPLAY[:energy_regen_rate]
    @context[:energy] = @context[:energy].clamp(0, Constants::GAMEPLAY[:starting_energy])

    # Focus stays at max when not channeling
    if @state != :channeling
      @context[:focus] += 0.5
      @context[:focus] = @context[:focus].clamp(0, Constants::GAMEPLAY[:starting_focus])
    end
  end

  def completed?
    @state == :completed
  end

  def failed?
    @state == :failed || @context[:energy] <= 0
  end

  def perfect?
    # No errors and all nodes completed successfully
    @context[:failures]&.empty? && completed?
  end
end

puts "✓ Game state loaded"