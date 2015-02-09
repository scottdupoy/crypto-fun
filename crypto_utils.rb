
def ConvertHexCharToInt(hexChar)
    # 0-F chars => 0-15 ints
    ord = hexChar.downcase.ord
    if ord >= 48 && ord <= 57
        return ord - 48
    end
    if ord >= 97 && ord <= 102
        return (ord - 97) + 10
    end
    raise "hex char " + hexChar + " is not hex"
end

def ConvertHexStringToBytes(hexString)
    # if the hex has an odd number of characters then prefix with a '0' so that
    # the byte boundaries work out correctly
    if hexString.length % 2 == 1
        hexString = "0" + hexString
    end

    # two hex characters => 1 byte. add one just in case we 
    byteCount = hexString.length / 2
    bytes = Array.new(byteCount)

    # walk along the string and pull out all of the byte values
    for index in 0..(byteCount - 1)
        # get the hex chars and extract their 4 bit numerical value
        char1 = hexString[index * 2]
        char2 = hexString[(index * 2) + 1]
        nibble1 = ConvertHexCharToInt(char1)
        nibble2 = ConvertHexCharToInt(char2)
        
        # put the nibbles together into a byte        
        bytes[index] = nibble1 << 4 | nibble2
    end
    return bytes
end

def ConvertSixBitNumberToBase64Char(sixBitNumber)
    # TODO: this would perform way quicker if a lookup table was used
    if sixBitNumber < 0
        raise "Cannot convert negative number to base 64 char"
    end    
    # A-Z
    if sixBitNumber <= 25
        return ('A'.ord + sixBitNumber).chr
    end
    # a-z
    if sixBitNumber <= 51
        return ('a'.ord + sixBitNumber - 26).chr
    end
    # 0-9
    if sixBitNumber <= 61
        return (sixBitNumber - 52).to_s()
    end
    if sixBitNumber == 62
        return '+'
    end
    if sixBitNumber == 63
        return '/'
    end
    raise "Cannot convert number > 63 to base 64 char"
end

def ConvertBytesToInt(bytes)
    # work back from least significant byte
    value = 0
    lastByte = bytes.length - 1
    for i in 0..lastByte
        index = lastByte - i
        byte = bytes[index]
        value += byte << (i * 8)
    end
    return value
end

def ConvertHexToBase64(hexString)
    bytes = ConvertHexStringToBytes(hexString)
    
    # # assert that it's in an a multiple of 3 for now
    # if bytes.length % 3 != 0
        # raise "Can't exactly represent the hex in base 64"
    # end
    
    # walk along the bytes in blocks of 3    
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
        for tripleIndex in 0..3
            # take characters from left so really it's 3 => 0
            shift = 3 - tripleIndex;
            
            # if we have reached the end of the string then last couple of characters may be '='
            # have made the following more concise, but leave fuller version as a comment as it's clearer what's going on:
            #   if (shift == 1 && (index + 1) >= bytes.length) ||  (shift == 0 && (index + 2) >= bytes.length)
            if shift < 2 && (index + (2 - shift)) >= bytes.length
                result += "="
                next
            end
            
            # not at the end of the string, so take the correct 6 bits and convert them to base 64
            sixBitSection = (triple >> shift * 6) & 0x3f # mask out 2 msbs: 00111111
            result += ConvertSixBitNumberToBase64Char(sixBitSection)
        end
                
        # move to the next set of bytes
        index += 3
    end 
    return result
end
