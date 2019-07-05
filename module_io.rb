class ModuleIO < StringIO
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
