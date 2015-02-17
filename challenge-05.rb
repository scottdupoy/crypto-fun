require "./crypto_utils.rb"

file = "./challenge-05.txt"
key = "ICE"

buffer = read_file(file)
bytes = convert_string_to_bytes(buffer)
key_bytes = convert_string_to_bytes(key)
encrypted_bytes = encrypt_repeating_key_xor(bytes, key_bytes)
encrypted_hex = convert_bytes_to_hex(encrypted_bytes)
puts encrypted_hex

