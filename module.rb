class Module
  MAGIC_AND_VERSION = "\x00\x61\x73\x6D\x01\x00\x00\x00"

  CUSTOM_SECTION_ID = 0
  TYPE_SECTION_ID = 1
  FUNCTION_SECTION_ID = 3
  EXPORT_SECTION_ID = 7
  CODE_SECTION_ID = 10

  attr_reader :func_types

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

  private

    def read_type_section(io)
      validate_section_size(io) do
        @func_types = io.read_vector { FuncType.new(io) }
      end
    end

    def read_function_section(io)
      puts "Start function section!"
      discard_section(io)
    end

    def read_export_section(io)
      puts "Start export section!"
      discard_section(io)
    end

    def read_code_section(io)
      puts "Start code section!"
      discard_section(io)
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
