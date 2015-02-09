require './crypto_utils.rb'

hexString = "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d"
base64String = ConvertHexToBase64(hexString);

puts "hex:    " + hexString
puts "base64: " + base64String
