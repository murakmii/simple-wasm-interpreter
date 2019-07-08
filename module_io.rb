class ModuleIO < StringIO
  STRUCTURED_INSTRS = [0x02, 0x03, 0x04, 0x0B] # else命令(0x05)はサポートしない

  def read_u32
    read_unsigned_leb128(32)
  end

  def read_s32
    read_signed_leb128(32)
  end

  def read_vector
    Array.new(read_u32) do |i|
      yield i
    end
  end

  def read_utf8
    read(read_u32).force_encoding(Encoding::UTF_8)
  end

  def read_next_structured_instr
    loop do
      instr = readbyte
      if STRUCTURED_INSTRS.member?(instr)
        break instr
      else
        case instr
        when 0x0C, 0x0D # br, br_if
          read_u32
        when (0x20...0x24) # local.get, local.set, local.tee, global.get, global.set
          read_u32
        when 0x41, 0x42 # i32.const, i64.const
          read_s32
        when (0x45...0xBF) # i32.eqz ~ f64.reinterpret_i64
          nil
        else
          raise "Unsupported instruction: #{instr}"
        end
      end
    end
  end

  private

    def read_unsigned_leb128(max_bits)
      value = 0
      shift = 0

      loop do
        b = readbyte
        value |= ((b & 0x7F) << shift)

        shift += 7
        break if b[7] == 0

        raise "Invalid LEB128 encoding" if shift >= max_bits
      end

      value
    end

    def read_signed_leb128(max_bits)
      value = 0
      shift = 0

      loop do
        b = readbyte
        value |= ((b & 0x7F) << shift)

        shift += 7
        break if b[7] == 0

        raise "Invalid Signed LEB128 encoding" if shift >= max_bits
      end

      value |= (~0 << shift) if value[shift - 1] == 1
      value
    end
end
