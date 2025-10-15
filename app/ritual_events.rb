# ===================================================================
# RITUAL KEEPER - Ritual Events
# ===================================================================
# Individual event implementations for ritual chains
# ===================================================================

# ===================================================================
# BASE RITUAL EVENT
# ===================================================================

class RitualEvent
  include ChainableEvent
  
  attr_reader :node_id, :element_type, :duration
  
  def initialize(node_id:, element_type:, duration: 45)
    @node_id = node_id
    @element_type = element_type
    @duration = duration
    @frames_active = 0
  end
  
  def update(context)
    @frames_active += 1
  end
  
  def completed?
    @frames_active >= @duration
  end
  
  def progress
    (@frames_active / @duration.to_f).clamp(0, 1)
  end
end

# ===================================================================
# ACTIVATE NODE EVENT
# ===================================================================

class ActivateNodeEvent < RitualEvent
  def execute(context)
    validate_context!(context, :args, :ritual, :nodes)
    
    args = context[:args]
    ritual = context[:ritual]
    nodes = context[:nodes]
    
    # Get the node
    node = nodes[@node_id]
    unless node
      return failure("Node #{@node_id} does not exist!")
    end
    
    # Check if node matches expected element
    unless node[:element] == @element_type
      context[:energy] -= 20
      spawn_ritual_failure_particles(args, node[:x], node[:y])
      return failure("Wrong element! Expected #{@element_type}, got #{node[:element]}")
    end
    
    # Check if player has enough energy
    if context[:energy] < 10
      return failure("Not enough energy!")
    end
    
    # Activate the node
    node[:state] = :active
    node[:progress] = 0
    context[:current_node] = @node_id
    context[:node_timer] = 0
    
    # Consume energy
    context[:energy] -= 10
    
    # Spawn activation particles
    spawn_node_activation_particles(args, node[:x], node[:y], Constants::ELEMENTS[@element_type][:color])
    
    success(context)
  end
end

# ===================================================================
# CHANNEL ENERGY EVENT
# ===================================================================

class ChannelEnergyEvent < RitualEvent
  def execute(context)
    validate_context!(context, :args, :ritual, :current_node, :nodes)
    
    args = context[:args]
    node_id = context[:current_node]
    nodes = context[:nodes]
    node = nodes[node_id]
    
    unless node
      return failure("No active node!")
    end
    
    # Update progress
    context[:node_timer] ||= 0
    context[:node_timer] += 1
    
    progress = context[:node_timer] / @duration.to_f
    node[:progress] = progress
    
    # Spawn energy flow particles
    if context[:node_timer] % 5 == 0
      color = Constants::ELEMENTS[node[:element]][:color]
      spawn_energy_flow_particles(args, node[:x], node[:y], color)
    end
    
    # Check if channeling is complete
    if context[:node_timer] >= @duration
      node[:state] = :completed
      context[:energy] += 5  # Restore some energy
      context[:completed_nodes] ||= []
      context[:completed_nodes] << node_id
      return success(context)
    end
    
    # Still channeling
    context[:focus] -= 0.5
    
    # Fail if focus depleted
    if context[:focus] <= 0
      node[:state] = :failed
      return failure("Lost focus during channeling!")
    end
    
    success(context)
  end
end

# ===================================================================
# CONNECT NODES EVENT
# ===================================================================

class ConnectNodesEvent < RitualEvent
  def initialize(from_node:, to_node:, element_type:)
    @from_node = from_node
    @to_node = to_node
    @element_type = element_type
    super(node_id: to_node, element_type: element_type)
  end
  
  def execute(context)
    validate_context!(context, :args, :nodes, :connections)
    
    args = context[:args]
    nodes = context[:nodes]
    
    from = nodes[@from_node]
    to = nodes[@to_node]
    
    unless from && to
      return failure("Invalid nodes for connection!")
    end
    
    # Check if from node is completed
    unless from[:state] == :completed
      return failure("Source node must be completed first!")
    end
    
    # Create connection
    connection = {
      from: @from_node,
      to: @to_node,
      progress: 0,
      active: true
    }
    
    context[:connections] ||= []
    context[:connections] << connection
    context[:current_connection] = connection
    
    # Activate destination node
    to[:state] = :active
    
    success(context)
  end
end

# ===================================================================
# COMPLETE RITUAL EVENT
# ===================================================================

class CompleteRitualEvent
  include ChainableEvent
  
  def execute(context)
    validate_context!(context, :args, :ritual, :completed_nodes)
    
    args = context[:args]
    ritual = context[:ritual]
    
    # Check if all nodes are completed
    expected_nodes = ritual[:sequence].length
    actual_nodes = context[:completed_nodes]&.length || 0
    
    unless actual_nodes == expected_nodes
      return failure("Not all nodes completed! #{actual_nodes}/#{expected_nodes}")
    end
    
    # Calculate score
    base_score = 100
    energy_bonus = (context[:energy] / 2).to_i
    focus_bonus = (context[:focus] / 2).to_i
    
    # Speed bonus if completed quickly
    time_taken = args.tick_count - context[:ritual_start_time]
    speed_bonus = time_taken < Constants::GAMEPLAY[:speed_bonus_threshold] ? 50 : 0
    
    # Perfect bonus if no failures
    perfect_bonus = context[:failures]&.empty? ? Constants::GAMEPLAY[:perfect_bonus] : 0
    
    total_score = base_score + energy_bonus + focus_bonus + speed_bonus + perfect_bonus
    
    context[:score] = total_score
    context[:completed] = true
    context[:completion_time] = time_taken
    
    # Spawn celebration particles
    spawn_ritual_completion_particles(
      args,
      Constants::RITUAL_CIRCLE[:center_x],
      Constants::RITUAL_CIRCLE[:center_y]
    )
    
    success(context)
  end
end

# ===================================================================
# VALIDATE RITUAL STATE EVENT
# ===================================================================

class ValidateRitualStateEvent
  include ChainableEvent
  
  def execute(context)
    validate_context!(context, :args, :ritual)
    
    # Check energy
    if context[:energy] <= 0
      return failure("No energy remaining!")
    end
    
    # Check focus
    if context[:focus] <= 0
      return failure("Lost all focus!")
    end
    
    success(context)
  end
end

# ===================================================================
# INITIALIZE RITUAL EVENT
# ===================================================================

class InitializeRitualEvent
  include ChainableEvent
  
  def execute(context)
    validate_context!(context, :args, :ritual)
    
    args = context[:args]
    ritual = context[:ritual]
    
    # Set up initial state
    context[:energy] = Constants::GAMEPLAY[:starting_energy]
    context[:focus] = Constants::GAMEPLAY[:starting_focus]
    context[:completed_nodes] = []
    context[:connections] = []
    context[:failures] = []
    context[:ritual_start_time] = args.tick_count
    
    # Create nodes based on ritual sequence
    nodes = {}
    sequence = ritual[:sequence]
    node_count = sequence.length
    
    sequence.each_with_index do |element_type, i|
      angle = (i / node_count.to_f) * Math::PI * 2 - Math::PI / 2
      pos = circle_position(
        Constants::RITUAL_CIRCLE[:center_x],
        Constants::RITUAL_CIRCLE[:center_y],
        Constants::RITUAL_CIRCLE[:node_radius],
        angle
      )
      
      nodes[i] = {
        id: i,
        element: element_type,
        x: pos[:x].to_i,
        y: pos[:y].to_i,
        state: :inactive,
        progress: 0
      }
    end
    
    context[:nodes] = nodes
    context[:current_step] = 0
    
    success(context)
  end
end

puts "✓ Ritual events loaded"
