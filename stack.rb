class Stack
  def initialize
    @stack = []
    @frame_positions = []
    @label_positions = []
  end

  # @param [Array<Value>] values
  def push_values(values)
    @stack.concat(values)
  end

  # @param [Frame] frame
  def push_frame(frame)
    @stack.push(frame)
    @frame_positions.push(@stack.size - 1)
    frame.function.expr.rewind
  end

  # @param [Function::Block]
  def push_label(label)
    @stack.push(label)
    @label_positions.push(@stack.size - 1)
  end

  # @param [ValueType] val_type
  # @return [Value]
  def pop_value(val_type)
    raise "Stack top is NOT value" if !@stack.last.is_a?(Value) || @stack.last.type != val_type
    @stack.pop
  end

  def peek
    @stack.last
  end

  # @return [Frame, nil]
  def current_frame
    return nil if @frame_positions.empty?

    @stack[@frame_positions.last]
  end

  # @return [ModuleIO]
  def current_expr
    return nil if current_frame.nil?

    current_frame.function.expr
  end

  def to_a
    @stack
  end
end
