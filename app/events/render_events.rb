# frozen_string_literal: true

# ==================== Render Events ====================

class RenderGameEvent
  include ChainableEvent
  
  def execute(context)
    args = context[:args]
    game = context[:game]
    camera = context[:camera]
    render_system = context[:render_system]
    
    # Delegate rendering to the render system
    render_system.render_game(args, game, camera)
    
    success(context)
  end
end
