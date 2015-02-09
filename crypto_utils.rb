
def convert_hex_char_to_int(hex_char)
    # 0-F chars => 0-15 ints
    ord = hex_char.downcase.ord
    if ord >= 48 && ord <= 57
        return ord - 48
    end
    if ord >= 97 && ord <= 102
        return (ord - 97) + 10
    end
    raise "hex char " + hex_char + " is not hex"
end

def convert_hex_string_to_bytes(hex_string)
    # if the hex has an odd number of characters then prefix with a '0' so that
    # the byte boundaries work out correctly
    if hex_string.length % 2 == 1
        hex_string = "0" + hex_string
    end

    # two hex characters => 1 byte. add one just in case we 
    byte_count = hex_string.length / 2
    bytes = Array.new(byte_count)

    # walk along the string and pull out all of the byte values
    for index in 0..(byte_count - 1)
        # get the hex chars and extract their 4 bit numerical value
        char1 = hex_string[index * 2]
        char2 = hex_string[(index * 2) + 1]
        nibble1 = convert_hex_char_to_int(char1)
        nibble2 = convert_hex_char_to_int(char2)
        
        # put the nibbles together into a byte        
        bytes[index] = nibble1 << 4 | nibble2
    end
    return bytes
end

def convert_six_bit_number_to_base64_char(six_bit_number)
    # TODO: this would perform way quicker if a lookup table was used
    if six_bit_number < 0
        raise "Cannot convert negative number to base 64 char"
    end    
    # A-Z
    if six_bit_number <= 25
        return ('A'.ord + six_bit_number).chr
    end
    # a-z
    if six_bit_number <= 51
        return ('a'.ord + six_bit_number - 26).chr
    end
    # 0-9
    if six_bit_number <= 61
        return (six_bit_number - 52).to_s()
    end
    if six_bit_number == 62
        return '+'
    end
    if six_bit_number == 63
        return '/'
    end
    raise "Cannot convert number > 63 to base 64 char"
end

def convert_bytes_to_int(bytes)
    # work back from least significant byte
    value = 0
    last_byte = bytes.length - 1
    for i in 0..last_byte
        index = last_byte - i
        byte = bytes[index]
        value += byte << (i * 8)
    end
    return value
end

def convert_hex_to_base64(hex_string)
    # walk along the bytes in blocks of 3
    bytes = convert_hex_string_to_bytes(hex_string)
    result = ""
    index = 0
    while index < bytes.length
        # pull out the bytes to use
        byte0 = bytes[index];        
        byte1 = (index + 1) < bytes.length ? bytes[index + 1] : 0;
        byte2 = (index + 2) < bytes.length ? bytes[index + 2] : 0;
        
        # join the bytes
        triple = byte0 << 16 | byte1 << 8 | byte2
        
        # walk along the bytes and build the string
        for triple_index in 0..3
            # take characters from left so really it's 3 => 0
            shift = 3 - triple_index;
            
            # if we have reached the end of the string then last couple of characters may be '='
            # have made the following more concise, but leave fuller version as a comment as it's clearer what's going on:
            #   if (shift == 1 && (index + 1) >= bytes.length) ||  (shift == 0 && (index + 2) >= bytes.length)
            if shift < 2 && (index + (2 - shift)) >= bytes.length
                result += "="
                next
            end
            
            # not at the end of the string, so take the correct 6 bits and convert them to base 64
            six_bit_section = (triple >> shift * 6) & 0x3f # mask out 2 msbs: 00111111
            result += convert_six_bit_number_to_base64_char(six_bit_section)
        end
                
        # move to the next set of bytes
        index += 3
    end 
    return result
end
