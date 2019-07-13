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

  # @param [Integer] label_idx
  def pop_all_from_label(label_idx)
    @stack.slice!(label_position(label_idx)..-1)
  end

  def peek
    @stack.last
  end

  # @param [Integer] label_idx
  # @return [Function::Block]
  def label(label_idx)
    @stack[label_position(label_idx)]
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

  # @return [Integer]
  def current_labels
    raise "No current frame" if current_frame.nil?

    labels = 0


    @label_positions.reverse_each do |label_pos|
      break if label_pos < @frame_positions.last
      labels += 1
    end
  
    labels
  end

  def to_a
    @stack
  end

  private

    def label_position(label_idx)
      @label_positions[-(label_idx + 1)]
    end
end
