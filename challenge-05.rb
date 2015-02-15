require "./crypto_utils.rb"

file = "./challenge-05.txt"
key = "ICE"

buffer = read_file(file)
puts encrypt_repeating_key_xor(buffer, key)

