require "./crypto_utils.rb"

#######################################################################

def aes_decrypt_block(encrypted_bytes, key_bytes)
    return [ 32 ];
end

#######################################################################

file = "challenge-07.txt"
key = "YELLOW SUBMARINE"
block_size_bits = 128
block_size_bytes = block_size_bits / 8

puts "key: " + key
puts "block_size_bites: " + block_size_bytes.to_s

# convert everything into bytes
encrypted_base64 = read_file_chomp_lines(file)
puts "encrypted_base64.length: " + encrypted_base64.length.to_s
encrypted_bytes = convert_base64_to_bytes(encrypted_base64)
puts "encrypted_bytes.length: " + encrypted_bytes.length.to_s
key_bytes = convert_string_to_bytes(key)
puts "key_bytes.length: " + key_bytes.length.to_s

# an aes encrypted message should be padded correctly
if (encrypted_bytes.length % 16) != 0
    raise "encrypted byte buffer length of " + encrypted_bytes.length.to_s + 
        " is not a multiple of " + block_size_bytes.to_s + " bytes"
end

# work on the bytes in blocks of the right block_size_bytes
block_count = (encrypted_bytes.length / block_size_bytes) - 1
decrypted_bytes = Array.new
for i in 0..block_count
    puts "decrypting block: " + i.to_s + " => " + (i * block_size_bytes).to_s + " - " + ((i + 1) * block_size_bytes).to_s
    encrypted_block = encrypted_bytes[i * block_size_bytes, block_size_bytes]
    decrypted_bytes.concat(aes_decrypt_block(encrypted_block, key_bytes))
    break
end

puts "decryption complete:"
puts "[" + convert_bytes_to_string(decrypted_bytes) + "]"
