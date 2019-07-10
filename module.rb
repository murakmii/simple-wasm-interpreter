class Module
  MAGIC_AND_VERSION = "\x00\x61\x73\x6D\x01\x00\x00\x00"

  CUSTOM_SECTION_ID = 0
  TYPE_SECTION_ID = 1
  FUNCTION_SECTION_ID = 3
  EXPORT_SECTION_ID = 7
  CODE_SECTION_ID = 10

  FUNC_EXPORT_DESC = 0x00

  attr_reader :func_types, :functions, :exported

  def initialize(path)
    io = ModuleIO.new(File.read(path, mode: "rb"))
    
    raise "Invalid WebAssembly module!" if io.read(8) != MAGIC_AND_VERSION

    last_section_id = 0

    until io.eof? do
      section_id = io.readbyte

      if section_id != CUSTOM_SECTION_ID && section_id < last_section_id
        raise "Invalid section order!"
      end

      case section_id
      when TYPE_SECTION_ID
        read_type_section(io)
      when FUNCTION_SECTION_ID
        read_function_section(io)
      when EXPORT_SECTION_ID
        read_export_section(io)
      when CODE_SECTION_ID
        read_code_section(io)
      else
        discard_section(io)
      end

      last_section_id = section_id
    end
  end

  def invoke(func_name, args)
    stack = Stack.new
    stack.push_values(args)

    Instructions.call(self, stack, functions.index {|f| f == exported[func_name] })

    begin
      while stack.current_frame do
        Instructions.execute(self, stack, stack.current_expr.readbyte)
      end

      stack.to_a
    rescue => e
      stack_content = stack.to_a
      raise "Interpretation error! [#{e.class}:#{e.message}] stack:#{stack_content.size}/#{stack_content}"
    end
  end

  private

    def read_type_section(io)
      validate_section_size(io) do
        @func_types = io.read_vector { FuncType.new(io) }
      end
    end

    def read_function_section(io)
      validate_section_size(io) do
        @functions = io.read_vector do
          type_idx = io.read_u32

          raise "Invalid type index" if type_idx >= @func_types.size

          Function.new(func_types[type_idx])
        end
      end
    end

    def read_export_section(io)
      @exported = Hash.new

      validate_section_size(io) do
        io.read_vector do
          name = io.read_utf8
          raise "Duplicated export name" if @exported.has_key?(name)

          export_desc = io.readbyte
          raise "Unsupported export desc: #{export_desc}" if export_desc != FUNC_EXPORT_DESC

          func_idx = io.read_u32
          raise "Invalid function index: #{func_idx}" if func_idx >= @functions.size

          @exported[name] = @functions[func_idx]
        end
      end
    end

    def read_code_section(io)
      validate_section_size(io) do
        io.read_vector do |func_idx|
          raise "Invalide code" if func_idx >= @functions.size

          @functions[func_idx].decode_code!(io)
        end
      end
    end

    def discard_section(io)
      size = io.read_u32
      io.pos += size
    end

    def validate_section_size(io)
      size = io.read_u32
      expected_end_pos = io.pos + size

      yield size

      raise "Invalid section size" if io.pos != expected_end_pos
    end
end
