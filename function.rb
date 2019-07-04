class Function
  attr_reader :func_type

  # @param [FuncType] func_type
  def initialize(func_type)
    @func_type = func_type
  end

  def inspect
    "#<#{self.class} func_type=#{func_type.inspect}>"
  end
end
