require './crypto_utils.rb'

File.open("challenge-04.txt", "r") do |f|
    f.each_line do |line|
        encoded_hex = line.chomp
        encoded_bytes = convert_hex_string_to_bytes(encoded_hex)
        decrypted, byte, score = decrypt_single_byte_xor_cypher(encoded_bytes)
        if score < 2
            next
        end
        puts "encoded_hex: " + line
        puts "decrypted:   " + decrypted
        puts "byte:        " + byte.to_s() + " => '" + byte.chr + "'"
        puts "score:       " + score.to_s()
        puts
    end
end

