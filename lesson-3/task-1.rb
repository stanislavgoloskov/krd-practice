def words(word, word_arr, num)
    if(word_arr[num-2] == 'S' && word_arr[num-3] == 'C')
        puts 2
    else
        puts word.reverse
    end
end

print "Введите слово: "
word = gets.to_s
word_2 = word.upcase
word_arr = word_2.chars
num = word_arr.length

words(word, word_arr, num)