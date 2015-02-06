
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
    # ensure that the hex matches byte boundaries
    if hexString.length % 2 != 0
        raise "hex input string expected to be a multiple of 2 so complete bytes"
    end
   
    # two hex characters => 1 byte
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

def ConvertHexToBase64(hexString)
    bytes = ConvertHexStringToBytes(hexString)
    
    # assert that it's in an a multiple of 3 for now
    if bytes.length % 3 != 0
        raise "Can't exactly represent the hex in base 64"
    end
    
    # walk along the bytes in blocks of 3    
    result = ""
    index = 0
    while index < bytes.length
        triple = bytes[index] << 16 | bytes[index + 1] << 8 | bytes[index + 2]
        for tripleIndex in 0..3
            # need to start from left so really it's 3 => 0
            shift = 3 - tripleIndex;
            sixBitSection = (triple >> shift * 6) & 0x3f # mask out 2 msbs: 00111111
            result += ConvertSixBitNumberToBase64Char(sixBitSection)
        end
        index += 3
    end 
    return result
end

hexString = "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d"
base64String = ConvertHexToBase64(hexString);

puts "hex:    " + hexString
puts "base64: " + base64String
