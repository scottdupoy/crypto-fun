require './crypto_utils.rb'

File.open("challenge-04.txt", "r") do |f|
    f.each_line do |line|
        decoded, byte, score = decode_single_byte_xor_cypher(line.chomp)
        if score < 2
            next
        end
        puts "encoded_hex: " + line
        puts "decoded:     " + decoded
        puts "byte:        " + byte.to_s() + " => '" + byte.chr + "'"
        puts "score:       " + score.to_s()
        puts
    end
end

