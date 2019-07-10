class Instructions
  class << self
    def execute(mod, stack, opcode)
      case opcode
      when 0x20
        op_local_get(mod, stack)
      when 0x21
        op_local_set(mod, stack)
      when 0x22
        op_local_tee(mod, stack)
      else
        raise "Unsupported opcode: #{opcode}"
      end
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

      stack.push_frame(Frame.new(func, args))
    end

    private

      def op_local_get(mod, stack)
        local_idx = stack.current_expr.read_u32
        stack.push_values([stack.current_frame.reference_local_var(local_idx).dup])
      end

      def op_local_set(mod, stack)
        local_idx = stack.current_expr.read_u32
        local_var = stack.current_frame.reference_local_var(local_idx)

        value.assign(stack.pop_value(value.type))
      end

      def op_local_tee(mod, stack)
        local_idx = stack.current_expr.read_u32
        stack.current_frame.reference_local_var(local_idx).assign(stack.peek)
      end
  end
end
