class Frame
  attr_reader :function

  # @param [Function] function
  def initialize(function)
    @function = function
    @local_vals = @function.create_local_variables
  end

  # @param [Integer] local_index
  # @return [Value]
  def reference_local_var(local_index)
    raise "Invalid local index" if local_index >= @local_vals.size

    @local_vals[local_index]
  end
end
