require "./crypto_utils.rb"

file = "./challenge-05.txt"
key = "ICE"

puts encrypt_repeating_key_xor(file, key)

