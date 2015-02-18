require "./crypto_utils.rb"

# convert the input into a byte array
base64 = read_file_chomp_lines("./challenge-06.txt")
bytes = convert_base64_to_bytes(base64)

# make some arrays to hold the key sizes we'd like to test
number_of_keys_to_test = 3
min_distances = Array.new(number_of_keys_to_test)
min_key_sizes = Array.new(number_of_keys_to_test)
for min_index in 0..(min_distances.length - 1)
    min_distances[min_index] = 10000.0
    min_key_sizes[min_index] = -1
end

# find key sizes with minimum hamming distances
for key_size in 2..40
    
    # work out the normalised distance, taking the average over the first n blocks all against each other
    n = 10;
    distance = 0;
    distance_count = 0
    for n in 1..(n - 1)
        # check if there's room for the nth block
        if bytes.length < ((n + 1) * key_size)
            puts "not enough bytes to check any more iterations"
            break
        end        
        for m in 0..(n - 1)
            slice1 = bytes[n * key_size, key_size]
            slice2 = bytes[m * key_size, key_size]
            distance += calculate_distance(slice1, slice2)
            distance_count += 1
        end
    end    
    if distance_count == 0
        # key_size must be larger than the byte buffer
        break
    end
    normalised_distance = distance.to_f / (key_size * distance_count)
    
    # check if this key_size/normalised_distance is smaller than the largest current
    # smallest value
    current_highest_min_distance = -1
    current_highest_min_distance_index = 0
    for min_index in 0..(min_distances.length - 1)
        if min_distances[min_index] > current_highest_min_distance
            current_highest_min_distance = min_distances[min_index]
            current_highest_min_distance_index = min_index
        end
    end

    # if this distance is lower than the highest of the smallest distances then replace
    if normalised_distance < current_highest_min_distance
        min_distances[current_highest_min_distance_index] = normalised_distance
        min_key_sizes[current_highest_min_distance_index] = key_size
    end
end


# work on the smallest distances we've found and cache the best scored result
best_score = -99999
best_key_size = 0
best_key_string = ""
best_decrypted_bytes = []
best_decrypted_string = ""
for min_index in 0..(min_key_sizes.length - 1)

    key_size = min_key_sizes[min_index]
    if key_size == -1
        break;
    end

    puts "testing decrypted key_size: " + key_size.to_s
    
    # split the bytes into groups based on the key size. each member of the following
    # array will represent the characters encoded using one of the characters of the key
    byte_groups = Array.new(key_size)
    for byte_group_index in 0..(key_size - 1)
        byte_groups[byte_group_index] = Array.new()
    end

    # walk along the bytes and add them to the appropriate group
    for byte_index in 0..(bytes.length - 1)
        byte_groups[byte_index % key_size] << bytes[byte_index]
    end

    # break each group using single character xor, build the key
    key_string = ""
    key_bytes = Array.new()
    for byte_group_index in 0..(key_size - 1)
        decrypted, xor_byte, score = decrypt_single_byte_xor_cypher(byte_groups[byte_group_index])
        key_string += xor_byte.chr
        key_bytes << xor_byte
    end

    decrypted_bytes = decrypt_repeating_byte_xor_cypher(bytes, key_bytes)
    decrypted_string = convert_bytes_to_string(decrypted_bytes)
    
    score = score_text(decrypted_string)
    if (score > best_score)
        best_score = score
        best_key_size = key_size
        best_key_string = key_string
        best_decrypted_bytes = decrypted_bytes
        best_decrypted_string = decrypted_string
    end
end

puts
puts "key size:   " + best_key_size.to_s
puts "key string: " + best_key_string
puts "decrypted:"
puts best_decrypted_string
