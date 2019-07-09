class Function
  Block = Struct.new(:instr, :arity, :start_pc, :end_pc)

  attr_reader :func_type, :expr, :blocks

  # @param [FuncType] func_type
  def initialize(func_type)
    @func_type = func_type
  end

  def decode_code!(io)
    end_of_code = io.read_u32 + io.pos

    @locals = []
    io.read_vector do
      n = io.read_u32
      val_type = ValueType.decode(io.readbyte)

      @locals.concat(Array.new(n) { val_type })
    end
    
    @expr = ModuleIO.new(io.read(end_of_code - io.pos))

    analyze_blocks!
  end

  def create_local_variables
    @locals.map {|val_type| Value.new(val_type) }
  end

  def inspect
    "#<#{self.class} func_type=#{func_type.inspect} locals=#{@locals.inspect} expr=#{@expr.size}>"
  end

  private

    def analyze_blocks!
      @blocks = Hash.new

      block_stack = [Block.new(0x02, @func_type.results, 0, nil)]

      while block_stack.any? do
        instr = @expr.read_next_structured_instr

        if instr == 0x0B
          block = block_stack.pop
          block.end_pc = @expr.pos - 1

          @blocks[block.start_pc] = block
        else
          block_type = @expr.readbyte
          arity = (block_type == 0x40 ? [] : [ValueType.decode(block_type)])

          block_stack << Block.new(instr, arity, @expr.pos, nil)
        end
      end

      raise "Invalid constrol structure" if !@expr.eof?

      @expr.rewind
    end
end
