require_relative "crypto_utils.rb"

class AdvancedEncryptionStandard

    SBOX = 
        [
            0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
            0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
            0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
            0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
            0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
            0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
            0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
            0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
            0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
            0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
            0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
            0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
            0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
            0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
            0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
            0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
        ]

    def get_number_of_state_columns
        return 4
    end
    
    def get_number_of_rounds(key_length_in_words)
        if key_length_in_words == 4
            return 10
        end
        if key_length_in_words == 6
            return 12
        end
        if key_length_in_words == 8
            return 14
        end
        raise "No number of rounds (Nr) for key length in words: " + key_length_in_words.to_s
    end
    
    def get_key_length_in_words(key_length_in_bytes)
        nk = key_length_in_bytes / 4
        if nk != 4 && nk != 6 && nk != 8
            raise "Cannot expand key with a length in words Nk = " + nk.to_s
        end
        nk        
    end
    
    def get_rcon(i)
        # TODO: faster to use a lookup table
        # double up and reduce on each iteration if overflowed
        rcon = 1
        for i in 1..(i - 1)
            rcon = rcon * 2
            if rcon > 0xff
                reduction_polynomial = (2 ** 8) + (2 ** 4) + (2 ** 3) + 2 + 1
                rcon = rcon ^ reduction_polynomial
            end
        end
        rcon = (rcon & 0xff) << 24
    end
    
    def rot_word(word)
        bytes = convert_word_into_bytes(word)
        rotated = (bytes[1] << 24) | (bytes[2] << 16) | (bytes[3] << 8) | bytes[0]
    end
    
    def sub_byte(byte)
        substituted = SBOX[byte & 0xff]
    end
    
    def sub_word(word)
        bytes = convert_word_into_bytes(word)
        substituted = sub_byte(bytes[0]) << 24 | sub_byte(bytes[1]) << 16 | sub_byte(bytes[2]) << 8 | sub_byte(bytes[3])
    end
    
    # key is a byte array, 16, 24 or 32 bytes
    def get_key_schedule(key_bytes)
        nb = get_number_of_state_columns()
        nk = get_key_length_in_words(key_bytes.length)
        nr = get_number_of_rounds(nk)
        
        words = Array.new(nb * (nr + 1))
        
        # take the words from the key
        for i in 0..(nk - 1)
            byte0 = key_bytes[4 * i]
            byte1 = key_bytes[(4 * i) + 1]
            byte2 = key_bytes[(4 * i) + 2]
            byte3 = key_bytes[(4 * i) + 3]
            words[i] = (byte0 << 24) | (byte1 << 16) | (byte2 << 8) | byte3            
        end
        
        for i in nk..((nb * (nr + 1)) - 1)
            temp = words[i - 1]
            if i % nk == 0
                temp = sub_word(rot_word(temp)) ^ get_rcon(i / nk)
            elsif nk > 6 && i % nk == 4
                temp = sub_word(temp)
            end
            words[i] = words[i - nk] ^ temp
        end
        words
    end
    
    def add_round_key(state, round_key)
        if state.length != round_key.length
            raise "state round key length mismatch"
        end
        for i in 0..(state.length - 1)
            state[i] = state[i] ^ round_key[i]
        end
        state
    end
    
    def get_round_key_bytes(key_schedule, index, nb)
        round_key = Array.new
        for i in 0..(nb - 1)
            key = convert_word_into_bytes(key_schedule[i])
            old_length = round_key.length
            round_key.concat(key)
        end
        round_key
    end
    
    def sub_bytes(bytes)
        for i in 0..(bytes.length - 1)
            bytes[i] = sub_byte(bytes[i])
        end
        bytes
    end

    def shift_rows(bytes)
        if bytes.length != 16
            raise "cannot handle non-16 byte row shifts"
        end
        results = Array.new(bytes.length)
        for i in 0..3
            for j in 0..3
                word_index = (i + j) % 4
                source_byte_index = (word_index * 4) + j
                target_byte_index = (i * 4) + j
                results[target_byte_index] = bytes[source_byte_index]
            end
        end
        results
    end

    def mix_word(bytes)
        a = Array.new(4)
        b = Array.new(4)
        # The array 'a' is simply a copy of the input array 'r'
        # The array 'b' is each element of the array 'a' multiplied by 2
        # in Rijndael's Galois field
        # a[n] ^ b[n] is element n multiplied by 3 in Rijndael's Galois field
        for i in 0..3
            a[i] = bytes[i]
            # h is 0xff if the high bit of r[c] is set, 0 otherwise
            # arithmetic right shift, thus shifting in either zeros or ones
            h = bytes[i] > 127 ? 0xff : 0x0
            b[i] = (bytes[i] << 1) && 0x7f
            b[i] ^= (h & 0x1b)
        end
        results = Array.new(bytes.length)
        results[0] = b[0] ^ a[3] ^ a[2] ^ b[1] ^ a[1]
        results[1] = b[1] ^ a[0] ^ a[3] ^ b[2] ^ a[2]
        results[2] = b[2] ^ a[1] ^ a[0] ^ b[3] ^ a[3]
        results[3] = b[3] ^ a[2] ^ a[1] ^ b[0] ^ a[0]
        results
    end

    def mix_columns(bytes)
        # http://en.wikipedia.org/wiki/Rijndael_mix_columns
        if bytes.length != 16
            raise "cannot handle non-16 byte row shifts"
        end

        results = Array.new(bytes.length)

        # extract each word and process it in turn
        for column in 0..3
            # pull out the bytes for this column
            word = Array.new(4)
            for row in 0..3
                word[row] = bytes[(column * 4) + row]
            end

            # mix the column
            word = mix_word(word)

            # insert the mixed word back in to the results array
            for row in 0..3
                results[(column * 4) + row] = word[row]
            end
        end

        results
    end
    
    def encrypt(key_bytes, input_bytes)
        nb = get_number_of_state_columns()
        nk = get_key_length_in_words(key_bytes.length)
        nr = get_number_of_rounds(nk)
        
        puts "nb: " + nb.to_s
        puts "nk: " + nk.to_s
        puts "nr: " + nr.to_s
        puts
        
        key_schedule = get_key_schedule(key_bytes)
        state = input_bytes
        
        # initial key usage
        round_key_bytes = get_round_key_bytes(key_schedule, 0, nb)
        puts "round[ 0].input  " + convert_bytes_to_hex(state)
        puts "round[ 0].k_sch  " + convert_bytes_to_hex(round_key_bytes)
        state = add_round_key(state, round_key_bytes)
        
        # handle the core rounds (the last one is handled differently)
        for round in 1..(nr - 1)
            puts "round[" + round.to_s.rjust(2) + "].start  " + convert_bytes_to_hex(state)
            state = sub_bytes(state)
            puts "round[" + round.to_s.rjust(2) + "].s_box  " + convert_bytes_to_hex(state)
            state = shift_rows(state)
            puts "round[" + round.to_s.rjust(2) + "].s_row  " + convert_bytes_to_hex(state)
            state = mix_columns(state)
            puts "round[" + round.to_s.rjust(2) + "].m_col  " + convert_bytes_to_hex(state)
            
            break
        end
        
        state
    end
end

#key_string = "YELLOW SUBMARINE"
#key_bytes = convert_string_to_bytes(key_string)
#key_bytes = [0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6, 0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c]
key_bytes = convert_hex_string_to_bytes('000102030405060708090a0b0c0d0e0f')
input_bytes = convert_hex_string_to_bytes('00112233445566778899aabbccddeeff')
#puts "key_bytes (hex):    " + convert_bytes_to_hex(key_bytes)
#puts "key_bytes (string): " + convert_bytes_to_string(key_bytes)

encrypted_bytes = AdvancedEncryptionStandard.new().encrypt(key_bytes, input_bytes)

puts
puts "input (hex):     " + convert_bytes_to_hex(input_bytes)
puts "encrypted (hex): " + convert_bytes_to_hex(encrypted_bytes)


