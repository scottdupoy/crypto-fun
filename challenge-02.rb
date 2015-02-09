require "./crypto_utils.rb"

hex1 = "1c0111001f010100061a024b53535009181c"
hex2 = "686974207468652062756c6c277320657965"

xored = xor_hex(hex1, hex2)

puts "hex 1: " + hex1
puts "hex 2: " + hex2
puts
puts "xored: " + xored

