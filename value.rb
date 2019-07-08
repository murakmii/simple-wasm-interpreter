class Value
  attr_reader :value

  # @param [Int] type
  def initialize(type)
    @type = type
    @value = @type.default_value
  end

  def inspect
    "#<#{self.class}(#{@type.inspect}) #{@value.inspect}>"
  end
end
