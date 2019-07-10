class Frame
  attr_reader :function

  # @param [Function] function
  # @param [Array<Value>] args
  def initialize(function, args)
    @function = function
    @local_vals = args + @function.create_local_variables
  end

  # @param [Integer] local_index
  # @return [Value]
  def reference_local_var(local_index)
    raise "Invalid local index" if local_index >= @local_vals.size

    @local_vals[local_index]
  end

  def inspect
    "#<#{self.class} local=#{@local_vals}>"
  end
end
