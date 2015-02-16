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
    if bytes.length < (2 * key_size)
        puts "buffer isn't long enough to test a key size of " + key_size.to_s
        break
    end
    
    # work out the normalised distance
    slice1 = bytes[0, key_size]
    slice2 = bytes[key_size, key_size]
    distance = calculate_distance(slice1, slice2)
    normalised_distance = distance.to_f / key_size

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

# work on the smallest distances we've found
for min_index in 0..(min_key_sizes.length - 1)
    key_size = min_key_sizes[min_index]
    if key_size == -1
        break;
    end

    puts "min key size: " + key_size.to_s
end

#def decode_single_byte_xor_cypher(encoded_hex)
#distance = calculate_distance(convert_string_to_bytes(a), convert_string_to_bytes(b))
