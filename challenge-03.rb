require './crypto_utils.rb'

encoded_hex = "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"
decoded, byte, score = decode_single_byte_xor_cypher(encoded_hex)

puts "encoded_hex: " + encoded_hex
puts
puts "decoded:     " + decoded
puts "byte:        " + byte.to_s() + " => '" + byte.chr + "'"
puts "score:       " + score.to_s()
