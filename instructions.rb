class Instructions
  class << self
    def execute(mod, stack, opcode)
      case opcode
      when 0x02, 0x03
        op_block(mod, stack)
      when 0x04
        op_if(mod, stack)
      when 0x20
        op_local_get(mod, stack)
      when 0x21
        op_local_set(mod, stack)
      when 0x22
        op_local_tee(mod, stack)
      when 0x41
        op_i32_const(mod, stack)
      when 0x4F
        op_i32_ge_u(mod, stack)
      when 0x6A
        op_i32_add(mod, stack)
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

      def op_block(mod, stack)
        block_start_pc = stack.current_expr.pos + 1

        label = stack.current_frame.function.blocks[block_start_pc]
        stack.current_expr.pos = label.start_pc

        stack.push_label(label)
      end

      def op_if(mod, stack)
        if stack.pop_value(Int.i32).value == 0
          block_start_pc = stack.current_expr.pos - 1

          label = stack.current_frame.function.blocks[block_start_pc]

          stack.current_expr.pos = label.end_pc + 1
        else
          op_block(mod, stack)
        end
      end

      def op_local_get(mod, stack)
        local_idx = stack.current_expr.read_u32
        stack.push_values([stack.current_frame.reference_local_var(local_idx).dup])
      end

      def op_local_set(mod, stack)
        local_idx = stack.current_expr.read_u32
        local_var = stack.current_frame.reference_local_var(local_idx)

        local_var.assign(stack.pop_value(local_var.type))
      end

      def op_local_tee(mod, stack)
        local_idx = stack.current_expr.read_u32
        stack.current_frame.reference_local_var(local_idx).assign(stack.peek)
      end

      def op_i32_const(mod, stack)
        value = stack.current_expr.read_s32
        stack.push_values([Value.new(Int.i32, value)])
      end

      def op_i32_ge_u(mod, stack)
        c2 = stack.pop_value(Int.i32)
        c1 = stack.pop_value(Int.i32)

        stack.push_values([Value.new(Int.i32, c1.value >= c2.value ? 1 : 0)])
      end

      def op_i32_add(mod, stack)
        c2 = stack.pop_value(Int.i32)
        c1 = stack.pop_value(Int.i32)

        stack.push_values([Value.new(Int.i32, c1.value + c2.value)])
      end
  end
end
