require "./crypto_utils.rb"

#def decode_single_byte_xor_cypher(encoded_hex)
#distance = calculateDistance(a, b)

base64 = read_file_chomp_lines("./challenge-06.txt")
bytes = convert_base64_to_bytes(base64)

#for key_size in 2..40
#    puts "key size: " + key_size.to_s()
#    puts "early exit break"
#    break
#end

