# ===================================================================
# RITUAL KEEPER - Input Handler
# ===================================================================
# Additional input handling utilities
# ===================================================================

module InputHelper
  # Check if any "confirm" button is pressed
  def self.confirm_pressed?(args)
    args.inputs.keyboard.key_down.space ||
    args.inputs.keyboard.key_down.enter ||
    args.inputs.keyboard.key_down.z ||
    args.inputs.controller_one.key_down.a
  end
  
  # Check if any "cancel" button is pressed
  def self.cancel_pressed?(args)
    args.inputs.keyboard.key_down.escape ||
    args.inputs.keyboard.key_down.x ||
    args.inputs.controller_one.key_down.b
  end
  
  # Check if up is pressed
  def self.up_pressed?(args)
    args.inputs.keyboard.key_down.up ||
    args.inputs.keyboard.key_down.w ||
    args.inputs.controller_one.key_down.up
  end
  
  # Check if down is pressed
  def self.down_pressed?(args)
    args.inputs.keyboard.key_down.down ||
    args.inputs.keyboard.key_down.s ||
    args.inputs.controller_one.key_down.down
  end
  
  # Check if left is pressed
  def self.left_pressed?(args)
    args.inputs.keyboard.key_down.left ||
    args.inputs.keyboard.key_down.a ||
    args.inputs.controller_one.key_down.left
  end
  
  # Check if right is pressed
  def self.right_pressed?(args)
    args.inputs.keyboard.key_down.right ||
    args.inputs.keyboard.key_down.d ||
    args.inputs.controller_one.key_down.right
  end
end

puts "✓ Input handler loaded"
