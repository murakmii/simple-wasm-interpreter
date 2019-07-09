class Instructions
  class << self
    def execute(mod, stack, opcode)
      raise "Unsupported opcode: #{opcode}"
    end

    # @param [Module] mod
    # @param [Stack] stack
    # @param [Integer] func_index
    def call(mod, stack, func_index)
      raise "Invalid function index" if func_index >= mod.functions.size
      
      args = []
      func = mod.functions[func_index]
      func.func_type.params.reverse.each do |val_type|
        args.unshift(stack.pop_value(val_type))
      end

      frame = Frame.new(func)

      args.each.with_index do |arg, local_index|
        frame.reference_local_var(local_index).assign(arg)
      end

      stack.push_frame(frame)
    end
  end
end
