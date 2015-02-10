require "./crypto_utils.rb"

def sumBits(byte)
    sum = 0
    for b in 0..7
        sum += (((1 << b) & byte)) > 0 ? 1 : 0
    end
    sum
end

def calculateDistance(string1, string2)
    puts "string1: " + string1
    puts "string2: " + string2

    if string1.length != string2.length
        raise "can't calculate distance between 2 different length strings"
    end

    if string1 == string2
        return 0
    end

    distance = 0
    for index in 0..(string1.length - 1)
        byte1 = string1[index].ord
        byte2 = string2[index].ord
        distance += sumBits(byte1 ^ byte2)
    end
    distance
end

a = "this is a test"
b = "wokka wokka!!!"

distance = calculateDistance(a, b)
puts "distance: " + distance.to_s()

for key_size in 2..40
    puts "key size: " + key_size.to_s()
    puts "early exit break"
    break
end
