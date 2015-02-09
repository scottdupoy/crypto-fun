
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

def convert_nibble_to_hex(byte)
    if byte < 0
        raise "cannot convert < 0 byte to hex"
    end
    if byte < 10
        return byte.to_s()
    end
    if byte < 16
        return ('a'.ord + (byte - 10)).chr
    end
    raise "cannot convert > 15 byte to hex"
end

def convert_bytes_to_hex(bytes)
    result = ""
    for i in 0..(bytes.length - 1)    
        # do each half of the byte separately
        nibble1 = (bytes[i] & 0xf0) >> 4
        nibble2 = bytes[i] & 0xf
        result += convert_nibble_to_hex(nibble1)
        result += convert_nibble_to_hex(nibble2)
    end
    # strip off any leading '0'
    # while result.length > 0 && result[0] == '0'
        # result = result[1..(result.length - 1)]
    # end
    return result
end

def xor_bytes(lhs, rhs)
    # work from rhs to make different length buffers easier to handle.
    # i've padded from the lhs, not sure if this is the right way to do it, easy enough to change though.
    max_length = lhs.length > rhs.length ? lhs.length : rhs.length;
    results = bytes = Array.new(max_length)
    for i in 0..(max_length - 1)
        lhs_byte = i < lhs.length ? lhs[lhs.length - (i + 1)] : 0
        rhs_byte = i < rhs.length ? rhs[rhs.length - (i + 1)] : 0
        results[max_length - (i + 1)] = lhs_byte ^ rhs_byte
    end
    return results
end

def xor_hex(lhs_hex, rhs_hex)
    lhs_bytes = convert_hex_string_to_bytes(lhs_hex)
    rhs_bytes = convert_hex_string_to_bytes(rhs_hex)
    bytes = xor_bytes(lhs_bytes, rhs_bytes)
    return convert_bytes_to_hex(bytes)
end

def score_text(text)
    # strategy
    #   count the letters and add them up
    #   rank them
    #   if any of the top 6 are the expected top 6 then score += 1
    #   if any of the bottom 6 are the expected top 6 then score -= 1
    #   keep track of lower cs upper case counts. bonus 0.5 points for all upper case, all lower case or more lower than upper case.
    lowerCaseCount = 0
    upperCaseCount = 0
    spaceCount = 0
    map = Hash.new()
    for i in 0..(text.length - 1)
        c = text[i].downcase
        if c.ord >= 'a'.ord && c.ord <= 'z'.ord
            # a-z
            map[c] = map.has_key?(c) ? map[c] + 1 : 1
        end
        ord = text[i].ord
        if ord >= 'a'.ord && ord <= 'z'.ord
            lowerCaseCount += 1
        end
        if ord >= 'A'.ord && ord <= 'Z'.ord
            upperCaseCount += 1
        end
        if text[i] == ' '
            spaceCount += 1
        end
    end
    
    # find the 6 most common characters
    scores = [ 0, 0, 0, 0, 0, 0 ]
    characters = [ '-', '-', '-', '-', '-' ]    
    for i in 0..(map.keys.length - 1)
        character = map.keys[i]
        score = map[character]
        for j in 0..(scores.length - 1)
            if scores[j] < score
                scores[j] = score
                characters[j] = character
                break
            end
        end
    end
    
    # build the score by seeing which letters are in the top 6
    score = 0
    for i in 0..(scores.length - 1)
        if scores[i] == 0
            next
        end
        c = characters[i]
        if c == 'e' || c == 't' || c == 'a' || c == 'o' || c == 'i' || c == 'n'
            score += 1
        end
        if c == 'z' || c == 'q' || c == 'x' || c == 'j' || c == 'k' || c == 'v'
            score -= 1
        end
    end
    
    # check for the bonus case-based 0.5 points
    if ((lowerCaseCount == 0 && upperCaseCount > 0) || (lowerCaseCount > 0 && upperCaseCount == 0) || (lowerCaseCount > 0 && upperCaseCount > 0 && lowerCaseCount > upperCaseCount))
        score += 0.5
    end
    
    # if lower + upper case counts don't constitute a decent amount of the text then penalise the decoding
    if (lowerCaseCount + upperCaseCount + spaceCount) < (text.length * 0.85)
        score -= 5
    end
    
    return score
end

def repeat_byte(byte, n)
    bytes = Array.new(n)
    for i in 0..(n - 1)
        bytes[i] = byte
    end
    return bytes
end

def convert_bytes_to_string(bytes)
    result = ""
    for i in 0..(bytes.length - 1)
        result += bytes[i].chr
    end
    return result
end

def decode_single_byte_xor_cypher(encoded_hex)
    encoded_bytes = convert_hex_string_to_bytes(encoded_hex)    
    bestByte = -1
    bestScore = -1
    bestDecoded = ""    
    for byte in 0..255
        xor_bytes = repeat_byte(byte, encoded_bytes.length)
        decoded = convert_bytes_to_string(xor_bytes(encoded_bytes, xor_bytes))
        score = score_text(decoded)
        if score > bestScore
            bestByte = byte
            bestScore = score
            bestDecoded = decoded
        end
    end
    return bestDecoded, bestByte, bestScore;
end
