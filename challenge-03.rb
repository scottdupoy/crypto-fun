require './crypto_utils.rb'

encoded_hex = "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"
encoded_bytes = convert_hex_string_to_bytes(encoded_hex)
decrypted, byte, score = decrypt_single_byte_xor_cypher(encoded_bytes)

puts "encoded_hex: " + encoded_hex
puts
puts "decrypted:   " + decrypted
puts "byte:        " + byte.to_s() + " => '" + byte.chr + "'"
puts "score:       " + score.to_s()
