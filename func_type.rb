class FuncType
  HEADER = 0x60

  attr_reader :params, :results

  # @param [ModuleIO] io
  def initialize(io)
    raise "Invalid func type(invalid header)" if io.readbyte != HEADER

    @params = io.read_vector { ValueType.decode(io.readbyte) }
    @results = io.read_vector { ValueType.decode(io.readbyte) }

    raise "Invalid func type(multiple results)" if @results.size > 1
  end

  def inspect
    "(#{@params.inspect} => #{@results.inspect})"
  end
end
